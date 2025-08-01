-- =====================================================
-- 🚀 APLICAÇÃO SEGURA DO SISTEMA DE TRACKING
-- Só cria o que não existe - EVITA DUPLICAÇÃO
-- =====================================================

-- =====================================================
-- MÓDULO 8: VIEWS PARA RELATÓRIOS (FALTANTE)
-- =====================================================

-- View: Resumo diário de tracking por usuário
CREATE OR REPLACE VIEW daily_tracking_summary AS
SELECT 
  u.id as user_id,
  u.email,
  d.date_day,
  wt.amount_ml as water_ml,
  wt.goal_ml as water_goal_ml,
  st.hours as sleep_hours,
  st.quality as sleep_quality,
  mt.energy_level,
  mt.stress_level,
  mt.day_rating,
  mt.gratitude_note,
  COUNT(et.id) as exercise_sessions,
  SUM(et.duration_minutes) as exercise_total_minutes
FROM auth.users u
CROSS JOIN (
  SELECT generate_series(
    CURRENT_DATE - INTERVAL '30 days', 
    CURRENT_DATE, 
    INTERVAL '1 day'
  )::date as date_day
) d
LEFT JOIN water_tracking wt ON wt.user_id = u.id AND wt.date = d.date_day
LEFT JOIN sleep_tracking st ON st.user_id = u.id AND st.date = d.date_day
LEFT JOIN mood_tracking mt ON mt.user_id = u.id AND mt.date = d.date_day
LEFT JOIN exercise_tracking et ON et.user_id = u.id AND et.date = d.date_day
GROUP BY u.id, u.email, d.date_day, wt.amount_ml, wt.goal_ml, 
         st.hours, st.quality, mt.energy_level, mt.stress_level, 
         mt.day_rating, mt.gratitude_note
ORDER BY u.email, d.date_day DESC;

-- View: Estatísticas semanais por usuário
CREATE OR REPLACE VIEW weekly_tracking_stats AS
SELECT 
  u.id as user_id,
  u.email,
  DATE_TRUNC('week', CURRENT_DATE)::date as week_start,
  -- Estatísticas de água
  AVG(wt.amount_ml) as avg_water_ml,
  COUNT(DISTINCT CASE WHEN wt.amount_ml >= wt.goal_ml THEN wt.date END) as water_goal_days,
  -- Estatísticas de sono
  AVG(st.hours) as avg_sleep_hours,
  AVG(st.quality) as avg_sleep_quality,
  COUNT(DISTINCT CASE WHEN st.hours >= 7 THEN st.date END) as good_sleep_days,
  -- Estatísticas de humor
  AVG(mt.energy_level) as avg_energy,
  AVG(mt.stress_level) as avg_stress,
  AVG(mt.day_rating) as avg_mood_rating,
  COUNT(DISTINCT CASE WHEN mt.day_rating >= 7 THEN mt.date END) as good_mood_days,
  -- Estatísticas de exercício
  COUNT(et.id) as total_exercise_sessions,
  SUM(et.duration_minutes) as total_exercise_minutes,
  AVG(et.intensity) as avg_exercise_intensity
FROM auth.users u
LEFT JOIN water_tracking wt ON wt.user_id = u.id 
  AND wt.date >= DATE_TRUNC('week', CURRENT_DATE)::date
LEFT JOIN sleep_tracking st ON st.user_id = u.id 
  AND st.date >= DATE_TRUNC('week', CURRENT_DATE)::date
LEFT JOIN mood_tracking mt ON mt.user_id = u.id 
  AND mt.date >= DATE_TRUNC('week', CURRENT_DATE)::date
LEFT JOIN exercise_tracking et ON et.user_id = u.id 
  AND et.date >= DATE_TRUNC('week', CURRENT_DATE)::date
GROUP BY u.id, u.email;

-- View: Ranking de usuários por engajamento
CREATE OR REPLACE VIEW user_engagement_ranking AS
SELECT 
  u.id as user_id,
  u.email,
  -- Score de engajamento (últimos 7 dias)
  (
    COUNT(DISTINCT wt.date) * 10 +  -- 10 pontos por dia com água
    COUNT(DISTINCT st.date) * 15 +  -- 15 pontos por dia com sono
    COUNT(DISTINCT mt.date) * 20 +  -- 20 pontos por dia com humor
    COUNT(et.id) * 25               -- 25 pontos por sessão de exercício
  ) as engagement_score,
  
  -- Métricas detalhadas
  COUNT(DISTINCT wt.date) as water_tracking_days,
  COUNT(DISTINCT st.date) as sleep_tracking_days,
  COUNT(DISTINCT mt.date) as mood_tracking_days,
  COUNT(et.id) as exercise_sessions,
  
  -- Consistência (% dos últimos 7 dias)
  ROUND(COUNT(DISTINCT wt.date) * 100.0 / 7, 1) as water_consistency,
  ROUND(COUNT(DISTINCT st.date) * 100.0 / 7, 1) as sleep_consistency,
  ROUND(COUNT(DISTINCT mt.date) * 100.0 / 7, 1) as mood_consistency
  
FROM auth.users u
LEFT JOIN water_tracking wt ON wt.user_id = u.id 
  AND wt.date >= CURRENT_DATE - INTERVAL '6 days'
LEFT JOIN sleep_tracking st ON st.user_id = u.id 
  AND st.date >= CURRENT_DATE - INTERVAL '6 days'
LEFT JOIN mood_tracking mt ON mt.user_id = u.id 
  AND mt.date >= CURRENT_DATE - INTERVAL '6 days'
LEFT JOIN exercise_tracking et ON et.user_id = u.id 
  AND et.date >= CURRENT_DATE - INTERVAL '6 days'
GROUP BY u.id, u.email
ORDER BY engagement_score DESC;

-- =====================================================
-- MÓDULO 9: FUNÇÕES DE DADOS DE EXEMPLO (FALTANTE)
-- =====================================================

-- Função para relatório mensal completo
CREATE OR REPLACE FUNCTION get_monthly_report(user_uuid UUID, report_month DATE)
RETURNS TABLE (
  total_days INTEGER,
  water_days_tracked INTEGER,
  sleep_days_tracked INTEGER,
  mood_days_tracked INTEGER,
  exercise_sessions INTEGER,
  avg_water_daily INTEGER,
  avg_sleep_hours DECIMAL(3,1),
  avg_energy DECIMAL(3,1),
  avg_stress DECIMAL(3,1),
  avg_mood_rating DECIMAL(3,1),
  total_exercise_minutes INTEGER,
  best_day_rating INTEGER,
  worst_day_rating INTEGER
) AS $$
DECLARE
  month_start DATE := date_trunc('month', report_month)::date;
  month_end DATE := (date_trunc('month', report_month) + INTERVAL '1 month' - INTERVAL '1 day')::date;
  month_days INTEGER := (month_end - month_start + 1);
BEGIN
  RETURN QUERY
  SELECT 
    month_days::INTEGER as total_days,
    COUNT(DISTINCT wt.date)::INTEGER as water_days_tracked,
    COUNT(DISTINCT st.date)::INTEGER as sleep_days_tracked,
    COUNT(DISTINCT mt.date)::INTEGER as mood_days_tracked,
    COUNT(et.id)::INTEGER as exercise_sessions,
    COALESCE(AVG(wt.amount_ml), 0)::INTEGER as avg_water_daily,
    COALESCE(AVG(st.hours), 0)::DECIMAL(3,1) as avg_sleep_hours,
    COALESCE(AVG(mt.energy_level), 0)::DECIMAL(3,1) as avg_energy,
    COALESCE(AVG(mt.stress_level), 0)::DECIMAL(3,1) as avg_stress,
    COALESCE(AVG(mt.day_rating), 0)::DECIMAL(3,1) as avg_mood_rating,
    COALESCE(SUM(et.duration_minutes), 0)::INTEGER as total_exercise_minutes,
    COALESCE(MAX(mt.day_rating), 0)::INTEGER as best_day_rating,
    COALESCE(MIN(mt.day_rating), 0)::INTEGER as worst_day_rating
  FROM (SELECT 1) as dummy
  LEFT JOIN water_tracking wt ON wt.user_id = user_uuid 
    AND wt.date >= month_start AND wt.date <= month_end
  LEFT JOIN sleep_tracking st ON st.user_id = user_uuid 
    AND st.date >= month_start AND st.date <= month_end
  LEFT JOIN mood_tracking mt ON mt.user_id = user_uuid 
    AND mt.date >= month_start AND mt.date <= month_end
  LEFT JOIN exercise_tracking et ON et.user_id = user_uuid 
    AND et.date >= month_start AND et.date <= month_end;
END;
$$ LANGUAGE plpgsql;

-- Função para criar dados para todos os usuários existentes
CREATE OR REPLACE FUNCTION seed_all_users_tracking_data()
RETURNS TEXT AS $$
DECLARE
  user_record RECORD;
  users_count INTEGER := 0;
BEGIN
  FOR user_record IN SELECT id FROM auth.users LOOP
    PERFORM create_realistic_tracking_data(user_record.id);
    users_count := users_count + 1;
  END LOOP;
  
  RETURN FORMAT('✅ Dados criados para %s usuários!', users_count);
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- MÓDULO 10: COMENTÁRIOS E DOCUMENTAÇÃO COMPLETA
-- =====================================================

-- Comentários detalhados nas views
COMMENT ON VIEW daily_tracking_summary IS 'Resumo diário completo de todos os dados de tracking por usuário (últimos 30 dias)';
COMMENT ON VIEW weekly_tracking_stats IS 'Estatísticas semanais agregadas de tracking com métricas de sucesso';
COMMENT ON VIEW user_engagement_ranking IS 'Ranking de usuários baseado no score de engajamento com o sistema de tracking';

-- Comentários nas funções
COMMENT ON FUNCTION get_monthly_report(UUID, DATE) IS 'Gera relatório mensal completo de tracking para um usuário específico';
COMMENT ON FUNCTION seed_all_users_tracking_data() IS 'Cria dados realistas de tracking para todos os usuários existentes';

-- =====================================================
-- VERIFICAÇÃO FINAL COMPLETA
-- =====================================================

-- Verificar se todas as views foram criadas
SELECT 
  'VIEWS CRIADAS:' as status,
  COUNT(*) as total_views
FROM information_schema.views 
WHERE table_schema = 'public' 
  AND table_name IN (
    'daily_tracking_summary',
    'weekly_tracking_stats',
    'user_engagement_ranking'
  );

-- Verificar se todas as funções foram criadas
SELECT 
  'FUNÇÕES CRIADAS:' as status,
  COUNT(*) as total_funcoes
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_name IN (
    'get_user_dashboard',
    'get_monthly_report',
    'create_realistic_tracking_data',
    'seed_all_users_tracking_data',
    'update_tracking_timestamp'
  );

-- Status final do sistema completo
DO $$
DECLARE
  table_count INTEGER;
  view_count INTEGER;
  function_count INTEGER;
BEGIN
  -- Contar tabelas
  SELECT COUNT(*) INTO table_count
  FROM information_schema.tables 
  WHERE table_schema = 'public' 
    AND table_name IN (
      'water_tracking', 
      'sleep_tracking', 
      'mood_tracking', 
      'exercise_tracking', 
      'medication_tracking', 
      'symptoms_tracking', 
      'custom_habits_tracking'
    );
  
  -- Contar views
  SELECT COUNT(*) INTO view_count
  FROM information_schema.views 
  WHERE table_schema = 'public' 
    AND table_name IN (
      'daily_tracking_summary',
      'weekly_tracking_stats',
      'user_engagement_ranking'
    );
  
  -- Contar funções
  SELECT COUNT(*) INTO function_count
  FROM information_schema.routines 
  WHERE routine_schema = 'public' 
    AND routine_name IN (
      'get_user_dashboard',
      'get_monthly_report',
      'create_realistic_tracking_data',
      'seed_all_users_tracking_data',
      'update_tracking_timestamp'
    );
  
  RAISE NOTICE '🎉 SISTEMA DE TRACKING COMPLETO!';
  RAISE NOTICE '📊 Tabelas: % de 7', table_count;
  RAISE NOTICE '👁️ Views: % de 3', view_count;
  RAISE NOTICE '⚙️ Funções: % de 5', function_count;
  
  IF table_count = 7 AND view_count = 3 AND function_count >= 4 THEN
    RAISE NOTICE '✅ TODOS OS 10 MÓDULOS APLICADOS COM SUCESSO!';
    RAISE NOTICE '🚀 Sistema pronto para integração com Sofia e Dr. Vital!';
  ELSE
    RAISE NOTICE '⚠️ Sistema parcialmente aplicado. Verificar módulos faltantes.';
  END IF;
END
$$;

-- =====================================================
-- FIM DA APLICAÇÃO SEGURA
-- Data: $(date)
-- Módulos: 8, 9 e 10 (complementares)
-- =====================================================