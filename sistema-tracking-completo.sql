-- =====================================================
-- MIGRAÇÃO COMPLETA: SISTEMA DE TRACKING AVANÇADO
-- Aplicar tudo de uma vez no Supabase Dashboard
-- =====================================================

-- =====================================================
-- MÓDULO 1: TABELAS DE TRACKING BÁSICAS
-- =====================================================

-- Tabela para tracking de água
CREATE TABLE IF NOT EXISTS water_tracking (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  amount_ml INTEGER NOT NULL DEFAULT 0,
  goal_ml INTEGER DEFAULT 2000,
  cups_count INTEGER DEFAULT 0,
  source TEXT DEFAULT 'manual',
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- Tabela para tracking de sono
CREATE TABLE IF NOT EXISTS sleep_tracking (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  hours DECIMAL(3,1),
  quality INTEGER CHECK (quality >= 1 AND quality <= 5),
  bedtime TIME,
  wake_time TIME,
  dream_notes TEXT,
  source TEXT DEFAULT 'manual',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- Tabela para tracking de humor/energia
CREATE TABLE IF NOT EXISTS mood_tracking (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  energy_level INTEGER CHECK (energy_level >= 1 AND energy_level <= 5),
  stress_level INTEGER CHECK (stress_level >= 1 AND stress_level <= 5),
  day_rating INTEGER CHECK (day_rating >= 1 AND day_rating <= 10),
  gratitude_note TEXT,
  mood_tags TEXT[], -- Array de tags de humor
  source TEXT DEFAULT 'manual',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- =====================================================
-- MÓDULO 2: TABELAS DE TRACKING AVANÇADAS
-- =====================================================

-- Tabela para tracking de exercícios
CREATE TABLE IF NOT EXISTS exercise_tracking (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  exercise_type TEXT NOT NULL, -- 'cardio', 'strength', 'flexibility', 'other'
  exercise_name TEXT NOT NULL,
  duration_minutes INTEGER,
  calories_burned INTEGER,
  intensity INTEGER CHECK (intensity >= 1 AND intensity <= 5),
  notes TEXT,
  source TEXT DEFAULT 'manual',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela para tracking de medicações
CREATE TABLE IF NOT EXISTS medication_tracking (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  medication_name TEXT NOT NULL,
  dosage TEXT NOT NULL,
  frequency TEXT NOT NULL, -- 'daily', 'twice_daily', 'weekly', etc.
  taken_at TIMESTAMP WITH TIME ZONE NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela para tracking de sintomas
CREATE TABLE IF NOT EXISTS symptoms_tracking (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  symptom_name TEXT NOT NULL,
  severity INTEGER CHECK (severity >= 1 AND severity <= 10),
  description TEXT,
  triggers TEXT[],
  duration_hours INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela para tracking de hábitos personalizados
CREATE TABLE IF NOT EXISTS custom_habits_tracking (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  habit_name TEXT NOT NULL,
  habit_category TEXT DEFAULT 'personal',
  target_frequency INTEGER DEFAULT 1, -- quantas vezes por dia/semana
  target_period TEXT DEFAULT 'daily', -- 'daily', 'weekly', 'monthly'
  completed_at TIMESTAMP WITH TIME ZONE NOT NULL,
  completion_value INTEGER DEFAULT 1, -- para hábitos quantificáveis
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- MÓDULO 3: POLÍTICAS RLS (ROW LEVEL SECURITY)
-- =====================================================

-- Políticas para water_tracking
ALTER TABLE water_tracking ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own water tracking" ON water_tracking
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own water tracking" ON water_tracking
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own water tracking" ON water_tracking
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own water tracking" ON water_tracking
  FOR DELETE USING (auth.uid() = user_id);

-- Políticas para sleep_tracking
ALTER TABLE sleep_tracking ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own sleep tracking" ON sleep_tracking
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own sleep tracking" ON sleep_tracking
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own sleep tracking" ON sleep_tracking
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own sleep tracking" ON sleep_tracking
  FOR DELETE USING (auth.uid() = user_id);

-- Políticas para mood_tracking
ALTER TABLE mood_tracking ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own mood tracking" ON mood_tracking
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own mood tracking" ON mood_tracking
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own mood tracking" ON mood_tracking
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own mood tracking" ON mood_tracking
  FOR DELETE USING (auth.uid() = user_id);

-- Políticas para exercise_tracking
ALTER TABLE exercise_tracking ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own exercise tracking" ON exercise_tracking
  FOR ALL USING (auth.uid() = user_id);

-- Políticas para medication_tracking
ALTER TABLE medication_tracking ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own medication tracking" ON medication_tracking
  FOR ALL USING (auth.uid() = user_id);

-- Políticas para symptoms_tracking
ALTER TABLE symptoms_tracking ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own symptoms tracking" ON symptoms_tracking
  FOR ALL USING (auth.uid() = user_id);

-- Políticas para custom_habits_tracking
ALTER TABLE custom_habits_tracking ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own custom habits tracking" ON custom_habits_tracking
  FOR ALL USING (auth.uid() = user_id);

-- =====================================================
-- MÓDULO 4: ÍNDICES PARA PERFORMANCE
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_water_tracking_user_date ON water_tracking(user_id, date);
CREATE INDEX IF NOT EXISTS idx_sleep_tracking_user_date ON sleep_tracking(user_id, date);
CREATE INDEX IF NOT EXISTS idx_mood_tracking_user_date ON mood_tracking(user_id, date);
CREATE INDEX IF NOT EXISTS idx_exercise_tracking_user_date ON exercise_tracking(user_id, date);
CREATE INDEX IF NOT EXISTS idx_medication_tracking_user_taken ON medication_tracking(user_id, taken_at);
CREATE INDEX IF NOT EXISTS idx_symptoms_tracking_user_date ON symptoms_tracking(user_id, date);
CREATE INDEX IF NOT EXISTS idx_custom_habits_user_completed ON custom_habits_tracking(user_id, completed_at);

-- Índices compostos para queries complexas
CREATE INDEX IF NOT EXISTS idx_water_tracking_user_date_amount ON water_tracking(user_id, date, amount_ml);
CREATE INDEX IF NOT EXISTS idx_sleep_tracking_user_date_quality ON sleep_tracking(user_id, date, quality);
CREATE INDEX IF NOT EXISTS idx_mood_tracking_user_date_rating ON mood_tracking(user_id, date, day_rating);

-- =====================================================
-- MÓDULO 5: FUNÇÕES DE TRIGGER PARA TIMESTAMP
-- =====================================================

CREATE OR REPLACE FUNCTION update_tracking_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- MÓDULO 6: TRIGGERS PARA TODAS AS TABELAS
-- =====================================================

CREATE TRIGGER trigger_update_water_tracking_timestamp
  BEFORE UPDATE ON water_tracking
  FOR EACH ROW
  EXECUTE FUNCTION update_tracking_timestamp();

CREATE TRIGGER trigger_update_sleep_tracking_timestamp
  BEFORE UPDATE ON sleep_tracking
  FOR EACH ROW
  EXECUTE FUNCTION update_tracking_timestamp();

CREATE TRIGGER trigger_update_mood_tracking_timestamp
  BEFORE UPDATE ON mood_tracking
  FOR EACH ROW
  EXECUTE FUNCTION update_tracking_timestamp();

CREATE TRIGGER trigger_update_exercise_tracking_timestamp
  BEFORE UPDATE ON exercise_tracking
  FOR EACH ROW
  EXECUTE FUNCTION update_tracking_timestamp();

CREATE TRIGGER trigger_update_medication_tracking_timestamp
  BEFORE UPDATE ON medication_tracking
  FOR EACH ROW
  EXECUTE FUNCTION update_tracking_timestamp();

CREATE TRIGGER trigger_update_symptoms_tracking_timestamp
  BEFORE UPDATE ON symptoms_tracking
  FOR EACH ROW
  EXECUTE FUNCTION update_tracking_timestamp();

CREATE TRIGGER trigger_update_custom_habits_tracking_timestamp
  BEFORE UPDATE ON custom_habits_tracking
  FOR EACH ROW
  EXECUTE FUNCTION update_tracking_timestamp();

-- =====================================================
-- MÓDULO 7: FUNÇÕES DE ESTATÍSTICAS E ANALYTICS
-- =====================================================

-- Função para dashboard completo do usuário
CREATE OR REPLACE FUNCTION get_user_dashboard(user_uuid UUID)
RETURNS TABLE (
  -- Água hoje
  water_today INTEGER,
  water_goal INTEGER,
  water_percentage INTEGER,
  -- Sono ontem
  sleep_hours DECIMAL(3,1),
  sleep_quality INTEGER,
  -- Humor hoje
  energy_today INTEGER,
  stress_today INTEGER,
  mood_rating INTEGER,
  -- Exercício esta semana
  exercise_minutes_week INTEGER,
  -- Estatísticas gerais
  weekly_water_avg INTEGER,
  weekly_sleep_avg DECIMAL(3,1),
  weekly_mood_avg INTEGER
) AS $$
DECLARE
  today_date DATE := CURRENT_DATE;
  yesterday_date DATE := CURRENT_DATE - 1;
  week_start DATE := CURRENT_DATE - 6;
BEGIN
  RETURN QUERY
  SELECT 
    -- Água hoje
    COALESCE(w_today.amount_ml, 0)::INTEGER as water_today,
    COALESCE(w_today.goal_ml, 2000)::INTEGER as water_goal,
    CASE 
      WHEN COALESCE(w_today.goal_ml, 2000) > 0 
      THEN (COALESCE(w_today.amount_ml, 0) * 100 / COALESCE(w_today.goal_ml, 2000))
      ELSE 0 
    END::INTEGER as water_percentage,
    
    -- Sono ontem
    COALESCE(s_yesterday.hours, 0)::DECIMAL(3,1) as sleep_hours,
    COALESCE(s_yesterday.quality, 0)::INTEGER as sleep_quality,
    
    -- Humor hoje
    COALESCE(m_today.energy_level, 0)::INTEGER as energy_today,
    COALESCE(m_today.stress_level, 0)::INTEGER as stress_today,
    COALESCE(m_today.day_rating, 0)::INTEGER as mood_rating,
    
    -- Exercício esta semana
    COALESCE(e_week.total_minutes, 0)::INTEGER as exercise_minutes_week,
    
    -- Médias semanais
    COALESCE(w_week.avg_amount, 0)::INTEGER as weekly_water_avg,
    COALESCE(s_week.avg_hours, 0)::DECIMAL(3,1) as weekly_sleep_avg,
    COALESCE(m_week.avg_rating, 0)::INTEGER as weekly_mood_avg
    
  FROM (SELECT 1) as dummy
  
  -- Água hoje
  LEFT JOIN (
    SELECT amount_ml, goal_ml 
    FROM water_tracking 
    WHERE user_id = user_uuid AND date = today_date
  ) w_today ON true
  
  -- Sono ontem
  LEFT JOIN (
    SELECT hours, quality 
    FROM sleep_tracking 
    WHERE user_id = user_uuid AND date = yesterday_date
  ) s_yesterday ON true
  
  -- Humor hoje
  LEFT JOIN (
    SELECT energy_level, stress_level, day_rating 
    FROM mood_tracking 
    WHERE user_id = user_uuid AND date = today_date
  ) m_today ON true
  
  -- Exercício esta semana
  LEFT JOIN (
    SELECT SUM(duration_minutes) as total_minutes
    FROM exercise_tracking 
    WHERE user_id = user_uuid AND date >= week_start
  ) e_week ON true
  
  -- Médias água semana
  LEFT JOIN (
    SELECT AVG(amount_ml) as avg_amount
    FROM water_tracking 
    WHERE user_id = user_uuid AND date >= week_start
  ) w_week ON true
  
  -- Médias sono semana
  LEFT JOIN (
    SELECT AVG(hours) as avg_hours
    FROM sleep_tracking 
    WHERE user_id = user_uuid AND date >= week_start
  ) s_week ON true
  
  -- Médias humor semana
  LEFT JOIN (
    SELECT AVG(day_rating) as avg_rating
    FROM mood_tracking 
    WHERE user_id = user_uuid AND date >= week_start
  ) m_week ON true;
END;
$$ LANGUAGE plpgsql;

-- Função para relatório mensal
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

-- Função para criar dados realistas para teste
CREATE OR REPLACE FUNCTION create_realistic_tracking_data(user_uuid UUID)
RETURNS VOID AS $$
DECLARE
  sample_date DATE;
  day_counter INTEGER;
  random_factor DECIMAL;
  base_water INTEGER := 1800;
  base_sleep DECIMAL := 7.5;
  base_energy INTEGER := 3;
  base_stress INTEGER := 3;
  base_rating INTEGER := 7;
BEGIN
  -- Criar dados dos últimos 30 dias
  FOR day_counter IN 0..29 LOOP
    sample_date := CURRENT_DATE - day_counter;
    
    -- Fator aleatório para variação (0.7 a 1.3)
    random_factor := 0.7 + (RANDOM() * 0.6);
    
    -- Água (varia entre 1200ml e 2800ml)
    INSERT INTO water_tracking (user_id, date, amount_ml, goal_ml, cups_count)
    VALUES (
      user_uuid, 
      sample_date, 
      (base_water * random_factor)::INTEGER,
      2000,
      ((base_water * random_factor) / 250)::INTEGER
    ) ON CONFLICT (user_id, date) DO NOTHING;
    
    -- Sono (varia entre 5.5h e 9.5h)
    INSERT INTO sleep_tracking (user_id, date, hours, quality)
    VALUES (
      user_uuid,
      sample_date,
      ROUND((base_sleep * random_factor)::NUMERIC, 1),
      (2 + (RANDOM() * 3))::INTEGER
    ) ON CONFLICT (user_id, date) DO NOTHING;
    
    -- Humor (varia conforme "ciclos" mais realistas)
    INSERT INTO mood_tracking (
      user_id, date, energy_level, stress_level, day_rating, 
      gratitude_note
    )
    VALUES (
      user_uuid,
      sample_date,
      GREATEST(1, LEAST(5, (base_energy + (RANDOM() * 2 - 1))::INTEGER)),
      GREATEST(1, LEAST(5, (base_stress + (RANDOM() * 2 - 1))::INTEGER)),
      GREATEST(1, LEAST(10, (base_rating + (RANDOM() * 4 - 2))::INTEGER)),
      CASE 
        WHEN RANDOM() > 0.7 THEN 
          (ARRAY[
            'Dia produtivo e gratificante!',
            'Grato pela família e saúde.',
            'Consegui manter meus hábitos hoje.',
            'Dia desafiador mas com aprendizados.',
            'Orgulhoso do meu progresso.'
          ])[1 + (RANDOM() * 4)::INTEGER]
        ELSE NULL
      END
    ) ON CONFLICT (user_id, date) DO NOTHING;
    
    -- Exercício (alguns dias da semana - mais realista)
    IF RANDOM() > 0.4 AND EXTRACT(DOW FROM sample_date) NOT IN (0, 6) THEN  -- Não domingos/sábados
      INSERT INTO exercise_tracking (
        user_id, date, exercise_type, exercise_name, 
        duration_minutes, calories_burned, intensity
      )
      VALUES (
        user_uuid,
        sample_date,
        (ARRAY['cardio', 'strength', 'flexibility', 'other'])[1 + (RANDOM() * 3)::INTEGER],
        (ARRAY[
          'Caminhada matinal', 'Treino na academia', 'Yoga', 'Corrida', 
          'Musculação', 'Pilates', 'Ciclismo', 'Natação'
        ])[1 + (RANDOM() * 7)::INTEGER],
        (20 + (RANDOM() * 60))::INTEGER,
        (150 + (RANDOM() * 300))::INTEGER,
        (2 + (RANDOM() * 3))::INTEGER
      );
    END IF;
    
  END LOOP;
  
  RAISE NOTICE '✅ Criados 30 dias de dados realistas para usuário: %', user_uuid;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VERIFICAÇÃO FINAL E STATUS
-- =====================================================

-- Verificar se todas as tabelas foram criadas
DO $$
DECLARE
  table_count INTEGER;
BEGIN
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
  
  IF table_count = 7 THEN
    RAISE NOTICE '✅ SUCESSO: Todas as 7 tabelas de tracking foram criadas!';
    RAISE NOTICE '📊 Sistema de tracking completo implantado com sucesso!';
    RAISE NOTICE '🚀 Pronto para uso em produção!';
  ELSE
    RAISE NOTICE '⚠️ ATENÇÃO: Apenas % de 7 tabelas foram criadas.', table_count;
  END IF;
END
$$;