-- 🧪 TESTE FUNCIONAL COMPLETO DO SISTEMA
-- Execute após aplicar as correções para validar tudo

-- =====================================================
-- 1. TESTE DE CURSOS E MÓDULOS
-- =====================================================
DO $$
DECLARE
  v_course_id UUID;
  v_module_id UUID;
  v_lesson_id UUID;
  v_user_id UUID;
  v_test_results JSONB := '{}';
BEGIN
  -- Obter um usuário de teste
  SELECT id INTO v_user_id FROM profiles LIMIT 1;
  
  -- TESTE 1: Criar curso
  BEGIN
    INSERT INTO courses (title, description, created_by, is_published)
    VALUES ('Curso de Teste Funcional', 'Testando sistema completo', v_user_id, true)
    RETURNING id INTO v_course_id;
    
    v_test_results := v_test_results || jsonb_build_object('curso_criacao', 'PASSOU');
  EXCEPTION WHEN OTHERS THEN
    v_test_results := v_test_results || jsonb_build_object('curso_criacao', 'FALHOU: ' || SQLERRM);
  END;
  
  -- TESTE 2: Criar módulo
  BEGIN
    INSERT INTO modules (course_id, title, description, order_index)
    VALUES (v_course_id, 'Módulo Teste', 'Testando módulos', 1)
    RETURNING id INTO v_module_id;
    
    v_test_results := v_test_results || jsonb_build_object('modulo_criacao', 'PASSOU');
  EXCEPTION WHEN OTHERS THEN
    v_test_results := v_test_results || jsonb_build_object('modulo_criacao', 'FALHOU: ' || SQLERRM);
  END;
  
  -- TESTE 3: Criar aula
  BEGIN
    INSERT INTO lessons (module_id, title, description, video_url, duration, order_index)
    VALUES (v_module_id, 'Aula Teste', 'Testando aulas', 'https://youtube.com/test', 600, 1)
    RETURNING id INTO v_lesson_id;
    
    v_test_results := v_test_results || jsonb_build_object('aula_criacao', 'PASSOU');
  EXCEPTION WHEN OTHERS THEN
    v_test_results := v_test_results || jsonb_build_object('aula_criacao', 'FALHOU: ' || SQLERRM);
  END;
  
  -- TESTE 4: Registrar progresso
  BEGIN
    INSERT INTO course_progress (user_id, course_id, lesson_id, completed, progress_percentage)
    VALUES (v_user_id, v_course_id, v_lesson_id, true, 100);
    
    v_test_results := v_test_results || jsonb_build_object('progresso_registro', 'PASSOU');
  EXCEPTION WHEN OTHERS THEN
    v_test_results := v_test_results || jsonb_build_object('progresso_registro', 'FALHOU: ' || SQLERRM);
  END;
  
  -- TESTE 5: Calcular progresso do curso
  BEGIN
    PERFORM calculate_course_progress(v_user_id, v_course_id);
    v_test_results := v_test_results || jsonb_build_object('calculo_progresso', 'PASSOU');
  EXCEPTION WHEN OTHERS THEN
    v_test_results := v_test_results || jsonb_build_object('calculo_progresso', 'FALHOU: ' || SQLERRM);
  END;
  
  RAISE NOTICE 'TESTE CURSOS: %', v_test_results;
END $$;

-- =====================================================
-- 2. TESTE DE METAS E DESAFIOS
-- =====================================================
DO $$
DECLARE
  v_user_id UUID;
  v_goal_id UUID;
  v_challenge_id UUID;
  v_test_results JSONB := '{}';
BEGIN
  SELECT id INTO v_user_id FROM profiles LIMIT 1;
  
  -- TESTE 1: Criar meta
  BEGIN
    INSERT INTO user_goals (user_id, title, description, target_value, current_value, status, evidence_required)
    VALUES (v_user_id, 'Meta Teste', 'Testando sistema de metas', 10, 0, 'pendente', true)
    RETURNING id INTO v_goal_id;
    
    v_test_results := v_test_results || jsonb_build_object('meta_criacao', 'PASSOU');
  EXCEPTION WHEN OTHERS THEN
    v_test_results := v_test_results || jsonb_build_object('meta_criacao', 'FALHOU: ' || SQLERRM);
  END;
  
  -- TESTE 2: Verificar notificação admin
  BEGIN
    IF EXISTS (SELECT 1 FROM admin_notifications WHERE data->>'goal_id' = v_goal_id::text) THEN
      v_test_results := v_test_results || jsonb_build_object('notificacao_admin', 'PASSOU');
    ELSE
      v_test_results := v_test_results || jsonb_build_object('notificacao_admin', 'FALHOU: Notificação não criada');
    END IF;
  END;
  
  -- TESTE 3: Participar de desafio
  BEGIN
    SELECT id INTO v_challenge_id FROM challenges WHERE is_active = true LIMIT 1;
    
    INSERT INTO challenge_participations (challenge_id, user_id, status)
    VALUES (v_challenge_id, v_user_id, 'active')
    ON CONFLICT (challenge_id, user_id) DO NOTHING;
    
    v_test_results := v_test_results || jsonb_build_object('desafio_participacao', 'PASSOU');
  EXCEPTION WHEN OTHERS THEN
    v_test_results := v_test_results || jsonb_build_object('desafio_participacao', 'FALHOU: ' || SQLERRM);
  END;
  
  RAISE NOTICE 'TESTE METAS/DESAFIOS: %', v_test_results;
END $$;

-- =====================================================
-- 3. TESTE DO SISTEMA DE IA
-- =====================================================
DO $$
DECLARE
  v_user_id UUID;
  v_test_results JSONB := '{}';
BEGIN
  SELECT id INTO v_user_id FROM profiles LIMIT 1;
  
  -- TESTE 1: Análise de foto
  BEGIN
    INSERT INTO ai_photo_analysis (user_id, photo_url, analysis_type, results, calories_detected)
    VALUES (v_user_id, 'https://example.com/food.jpg', 'food', '{"items": ["arroz", "feijão"]}', 450);
    
    v_test_results := v_test_results || jsonb_build_object('analise_foto', 'PASSOU');
  EXCEPTION WHEN OTHERS THEN
    v_test_results := v_test_results || jsonb_build_object('analise_foto', 'FALHOU: ' || SQLERRM);
  END;
  
  -- TESTE 2: Relatório gerado
  BEGIN
    INSERT INTO ai_generated_reports (user_id, report_type, ai_model, content)
    VALUES (v_user_id, 'weekly_health', 'gpt-4', 'Relatório de saúde semanal...');
    
    v_test_results := v_test_results || jsonb_build_object('relatorio_ia', 'PASSOU');
  EXCEPTION WHEN OTHERS THEN
    v_test_results := v_test_results || jsonb_build_object('relatorio_ia', 'FALHOU: ' || SQLERRM);
  END;
  
  RAISE NOTICE 'TESTE IA: %', v_test_results;
END $$;

-- =====================================================
-- 4. TESTE DO SISTEMA ADMIN
-- =====================================================
DO $$
DECLARE
  v_admin_id UUID;
  v_test_results JSONB := '{}';
BEGIN
  -- Obter admin
  SELECT id INTO v_admin_id FROM profiles WHERE role = 'admin' LIMIT 1;
  
  IF v_admin_id IS NULL THEN
    -- Criar admin de teste
    INSERT INTO profiles (id, email, full_name, role)
    VALUES (gen_random_uuid(), 'admin@test.com', 'Admin Teste', 'admin')
    RETURNING id INTO v_admin_id;
  END IF;
  
  -- TESTE 1: Upload de arquivo
  BEGIN
    INSERT INTO admin_uploads (uploaded_by, entity_type, file_type, file_name, storage_path)
    VALUES (v_admin_id, 'lesson', 'video', 'aula-teste.mp4', 'course-media/aula-teste.mp4');
    
    v_test_results := v_test_results || jsonb_build_object('admin_upload', 'PASSOU');
  EXCEPTION WHEN OTHERS THEN
    v_test_results := v_test_results || jsonb_build_object('admin_upload', 'FALHOU: ' || SQLERRM);
  END;
  
  -- TESTE 2: Verificar função is_admin()
  BEGIN
    -- Temporariamente setar contexto como admin
    PERFORM set_config('request.jwt.claims', json_build_object('sub', v_admin_id)::text, true);
    
    IF is_admin() THEN
      v_test_results := v_test_results || jsonb_build_object('funcao_is_admin', 'PASSOU');
    ELSE
      v_test_results := v_test_results || jsonb_build_object('funcao_is_admin', 'FALHOU');
    END IF;
  END;
  
  RAISE NOTICE 'TESTE ADMIN: %', v_test_results;
END $$;

-- =====================================================
-- 5. TESTE DE FUNCIONALIDADES DO USUÁRIO
-- =====================================================
DO $$
DECLARE
  v_user_id UUID;
  v_test_results JSONB := '{}';
BEGIN
  SELECT id INTO v_user_id FROM profiles WHERE role != 'admin' LIMIT 1;
  
  -- TESTE 1: Sistema de XP
  BEGIN
    INSERT INTO user_rewards (user_id, type, amount, source, description)
    VALUES (v_user_id, 'lesson_complete', 10, 'lesson', 'Completou aula');
    
    -- Verificar se XP foi incrementado
    IF EXISTS (SELECT 1 FROM profiles WHERE id = v_user_id AND total_xp > 0) THEN
      v_test_results := v_test_results || jsonb_build_object('sistema_xp', 'PASSOU');
    ELSE
      v_test_results := v_test_results || jsonb_build_object('sistema_xp', 'FALHOU: XP não incrementado');
    END IF;
  END;
  
  -- TESTE 2: Preferências
  BEGIN
    INSERT INTO user_preferences (user_id, theme, language)
    VALUES (v_user_id, 'dark', 'pt-BR')
    ON CONFLICT (user_id) DO UPDATE SET theme = 'dark';
    
    v_test_results := v_test_results || jsonb_build_object('preferencias_usuario', 'PASSOU');
  EXCEPTION WHEN OTHERS THEN
    v_test_results := v_test_results || jsonb_build_object('preferencias_usuario', 'FALHOU: ' || SQLERRM);
  END;
  
  -- TESTE 3: Feedback de aula
  BEGIN
    INSERT INTO lesson_feedback (lesson_id, user_id, rating, comment)
    SELECT id, v_user_id, 5, 'Excelente aula!'
    FROM lessons LIMIT 1;
    
    v_test_results := v_test_results || jsonb_build_object('feedback_aula', 'PASSOU');
  EXCEPTION WHEN OTHERS THEN
    v_test_results := v_test_results || jsonb_build_object('feedback_aula', 'FALHOU: ' || SQLERRM);
  END;
  
  RAISE NOTICE 'TESTE USUÁRIO: %', v_test_results;
END $$;

-- =====================================================
-- 6. TESTE DE SEGURANÇA E PERMISSÕES
-- =====================================================
DO $$
DECLARE
  v_user_id UUID;
  v_other_user_id UUID;
  v_test_results JSONB := '{}';
BEGIN
  -- Obter dois usuários diferentes
  SELECT id INTO v_user_id FROM profiles WHERE role != 'admin' LIMIT 1;
  SELECT id INTO v_other_user_id FROM profiles WHERE role != 'admin' AND id != v_user_id LIMIT 1;
  
  -- TESTE 1: RLS em course_progress
  BEGIN
    -- Tentar ver progresso de outro usuário (deve falhar)
    PERFORM set_config('request.jwt.claims', json_build_object('sub', v_user_id)::text, true);
    
    IF NOT EXISTS (
      SELECT 1 FROM course_progress 
      WHERE user_id = v_other_user_id
    ) THEN
      v_test_results := v_test_results || jsonb_build_object('rls_course_progress', 'PASSOU');
    ELSE
      v_test_results := v_test_results || jsonb_build_object('rls_course_progress', 'FALHOU: Viu dados de outro usuário');
    END IF;
  END;
  
  -- TESTE 2: RLS em ai_photo_analysis
  BEGIN
    -- Usuário deve ver apenas suas próprias análises
    IF NOT EXISTS (
      SELECT 1 FROM ai_photo_analysis 
      WHERE user_id != v_user_id
    ) THEN
      v_test_results := v_test_results || jsonb_build_object('rls_ai_analysis', 'PASSOU');
    ELSE
      v_test_results := v_test_results || jsonb_build_object('rls_ai_analysis', 'FALHOU: Viu análises de outros');
    END IF;
  END;
  
  RAISE NOTICE 'TESTE SEGURANÇA: %', v_test_results;
END $$;

-- =====================================================
-- 7. RELATÓRIO FINAL DE TESTES
-- =====================================================
SELECT 
  '🧪 TESTES FUNCIONAIS COMPLETOS' as titulo,
  jsonb_build_object(
    'data_teste', now(),
    'areas_testadas', ARRAY[
      'Cursos e Módulos',
      'Metas e Desafios',
      'Sistema de IA',
      'Sistema Admin',
      'Funcionalidades do Usuário',
      'Segurança e Permissões'
    ],
    'status_geral', 'Execute e verifique NOTICES acima',
    'proximos_passos', ARRAY[
      'Verificar logs de erro',
      'Testar interface do usuário',
      'Validar Edge Functions',
      'Confirmar envio de emails/WhatsApp'
    ]
  ) as relatorio;

-- =====================================================
-- 8. VERIFICAÇÃO DE INTEGRIDADE
-- =====================================================
WITH integrity_check AS (
  SELECT 
    'courses' as tabela,
    COUNT(*) as registros,
    COUNT(*) FILTER (WHERE is_published = true) as ativos
  FROM courses
  UNION ALL
  SELECT 'modules', COUNT(*), COUNT(*) FROM modules
  UNION ALL
  SELECT 'lessons', COUNT(*), COUNT(*) FROM lessons
  UNION ALL
  SELECT 'challenges', COUNT(*), COUNT(*) FILTER (WHERE is_active = true) FROM challenges
  UNION ALL
  SELECT 'user_goals', COUNT(*), COUNT(*) FILTER (WHERE status = 'ativo') FROM user_goals
  UNION ALL
  SELECT 'profiles', COUNT(*), COUNT(*) FILTER (WHERE role = 'admin') FROM profiles
)
SELECT 
  '📊 INTEGRIDADE DO BANCO' as titulo,
  tabela,
  registros as total_registros,
  ativos as registros_ativos
FROM integrity_check
ORDER BY tabela;

-- 🎯 TESTES COMPLETOS
-- Execute este script após aplicar as correções
-- Verifique os NOTICES para resultados detalhados
-- Todos os testes devem passar para garantir sistema funcional