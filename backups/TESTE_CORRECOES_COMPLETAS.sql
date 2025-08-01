-- 🧪 TESTE COMPLETO DAS CORREÇÕES
-- Execute após CORRECAO_COMPLETA_PLATAFORMA.sql para validar tudo

-- =====================================================
-- TESTE 1: PARTICIPAR DO DESAFIO
-- =====================================================
DO $$
DECLARE
    v_user_id UUID;
    v_challenge_id UUID;
    v_participation_id UUID;
    v_test_results JSONB := '{}';
BEGIN
    -- Obter um usuário e um desafio para teste
    SELECT id INTO v_user_id FROM profiles LIMIT 1;
    SELECT id INTO v_challenge_id FROM challenges WHERE is_active = true LIMIT 1;
    
    -- TESTE: Participar do desafio
    BEGIN
        SELECT join_challenge(v_user_id, v_challenge_id) INTO v_participation_id;
        
        -- Verificar se participação foi criada com best_streak
        IF EXISTS (
            SELECT 1 FROM challenge_participations 
            WHERE id = v_participation_id 
            AND best_streak IS NOT NULL
        ) THEN
            v_test_results := v_test_results || jsonb_build_object('participar_desafio', 'PASSOU');
        ELSE
            v_test_results := v_test_results || jsonb_build_object('participar_desafio', 'FALHOU: best_streak não encontrado');
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_test_results := v_test_results || jsonb_build_object('participar_desafio', 'FALHOU: ' || SQLERRM);
    END;
    
    RAISE NOTICE 'TESTE DESAFIO: %', v_test_results;
END $$;

-- =====================================================
-- TESTE 2: CRIAR META COM CATEGORIA
-- =====================================================
DO $$
DECLARE
    v_user_id UUID;
    v_goal_id UUID;
    v_test_results JSONB := '{}';
BEGIN
    -- Obter um usuário para teste
    SELECT id INTO v_user_id FROM profiles LIMIT 1;
    
    -- TESTE: Criar meta com categoria
    BEGIN
        INSERT INTO user_goals (
            user_id, 
            title, 
            description, 
            category,
            target_value,
            priority
        ) VALUES (
            v_user_id,
            'Meta de Teste',
            'Testando criação de meta com categoria',
            'saude',
            10,
            3
        ) RETURNING id INTO v_goal_id;
        
        -- Verificar se meta foi criada com categoria
        IF EXISTS (
            SELECT 1 FROM user_goals 
            WHERE id = v_goal_id 
            AND category = 'saude'
        ) THEN
            v_test_results := v_test_results || jsonb_build_object('criar_meta', 'PASSOU');
        ELSE
            v_test_results := v_test_results || jsonb_build_object('criar_meta', 'FALHOU: categoria não salva');
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_test_results := v_test_results || jsonb_build_object('criar_meta', 'FALHOU: ' || SQLERRM);
    END;
    
    RAISE NOTICE 'TESTE META: %', v_test_results;
END $$;

-- =====================================================
-- TESTE 3: ANÁLISE PREVENTIVA
-- =====================================================
DO $$
DECLARE
    v_user_id UUID;
    v_analysis_id UUID;
    v_test_results JSONB := '{}';
BEGIN
    -- Obter um usuário para teste
    SELECT id INTO v_user_id FROM profiles LIMIT 1;
    
    -- TESTE: Criar análise preventiva
    BEGIN
        SELECT create_preventive_analysis(
            v_user_id,
            'health_check',
            '{"status": "good", "recommendations": ["exercise", "diet"]}',
            ARRAY['Pratique exercícios regulares', 'Mantenha dieta equilibrada']
        ) INTO v_analysis_id;
        
        -- Verificar se análise foi criada
        IF EXISTS (
            SELECT 1 FROM preventive_health_analyses 
            WHERE id = v_analysis_id 
            AND user_id = v_user_id
        ) THEN
            v_test_results := v_test_results || jsonb_build_object('analise_preventiva', 'PASSOU');
        ELSE
            v_test_results := v_test_results || jsonb_build_object('analise_preventiva', 'FALHOU: análise não criada');
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_test_results := v_test_results || jsonb_build_object('analise_preventiva', 'FALHOU: ' || SQLERRM);
    END;
    
    RAISE NOTICE 'TESTE ANÁLISE: %', v_test_results;
END $$;

-- =====================================================
-- TESTE 4: CARREGAR USUÁRIO COM EMAIL
-- =====================================================
DO $$
DECLARE
    v_user_id UUID;
    v_test_results JSONB := '{}';
BEGIN
    -- Obter um usuário para teste
    SELECT id INTO v_user_id FROM profiles LIMIT 1;
    
    -- TESTE: Atualizar email do usuário
    BEGIN
        UPDATE profiles 
        SET email = 'teste@institutodossonhos.com' 
        WHERE id = v_user_id;
        
        -- Verificar se email foi salvo
        IF EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = v_user_id 
            AND email = 'teste@institutodossonhos.com'
        ) THEN
            v_test_results := v_test_results || jsonb_build_object('carregar_usuario_email', 'PASSOU');
        ELSE
            v_test_results := v_test_results || jsonb_build_object('carregar_usuario_email', 'FALHOU: email não salvo');
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_test_results := v_test_results || jsonb_build_object('carregar_usuario_email', 'FALHOU: ' || SQLERRM);
    END;
    
    RAISE NOTICE 'TESTE USUÁRIO EMAIL: %', v_test_results;
END $$;

-- =====================================================
-- TESTE 5: SALVAR MÓDULO COM IS_ACTIVE
-- =====================================================
DO $$
DECLARE
    v_course_id UUID;
    v_module_id UUID;
    v_test_results JSONB := '{}';
BEGIN
    -- Obter um curso para teste
    SELECT id INTO v_course_id FROM courses LIMIT 1;
    
    -- TESTE: Criar módulo com is_active
    BEGIN
        INSERT INTO modules (
            course_id,
            title,
            description,
            is_active,
            prerequisites
        ) VALUES (
            v_course_id,
            'Módulo de Teste',
            'Testando criação de módulo com is_active',
            true,
            ARRAY['prerequisito1', 'prerequisito2']
        ) RETURNING id INTO v_module_id;
        
        -- Verificar se módulo foi criado com is_active
        IF EXISTS (
            SELECT 1 FROM modules 
            WHERE id = v_module_id 
            AND is_active = true
        ) THEN
            v_test_results := v_test_results || jsonb_build_object('salvar_modulo', 'PASSOU');
        ELSE
            v_test_results := v_test_results || jsonb_build_object('salvar_modulo', 'FALHOU: is_active não salvo');
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_test_results := v_test_results || jsonb_build_object('salvar_modulo', 'FALHOU: ' || SQLERRM);
    END;
    
    RAISE NOTICE 'TESTE MÓDULO: %', v_test_results;
END $$;

-- =====================================================
-- TESTE 6: DADOS DA EMPRESA
-- =====================================================
DO $$
DECLARE
    v_config_count INTEGER;
    v_test_results JSONB := '{}';
BEGIN
    -- TESTE: Verificar se configuração da empresa existe
    BEGIN
        SELECT COUNT(*) INTO v_config_count FROM company_configurations WHERE is_active = true;
        
        IF v_config_count > 0 THEN
            v_test_results := v_test_results || jsonb_build_object('dados_empresa', 'PASSOU');
        ELSE
            v_test_results := v_test_results || jsonb_build_object('dados_empresa', 'FALHOU: configuração não encontrada');
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_test_results := v_test_results || jsonb_build_object('dados_empresa', 'FALHOU: ' || SQLERRM);
    END;
    
    RAISE NOTICE 'TESTE EMPRESA: %', v_test_results;
END $$;

-- =====================================================
-- TESTE 7: VERIFICAR TODAS AS COLUNAS NECESSÁRIAS
-- =====================================================
SELECT 
    '🧪 VERIFICAÇÃO COMPLETA DE COLUNAS' as titulo,
    jsonb_build_object(
        'profiles_email', EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'email'),
        'profiles_avatar_url', EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'avatar_url'),
        'user_goals_category', EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'category'),
        'user_goals_priority', EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'priority'),
        'challenge_participations_best_streak', EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_participations' AND column_name = 'best_streak'),
        'challenge_participations_daily_logs', EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_participations' AND column_name = 'daily_logs'),
        'modules_is_active', EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'modules' AND column_name = 'is_active')
    ) as colunas_verificadas;

-- =====================================================
-- TESTE 8: VERIFICAR TODAS AS TABELAS NECESSÁRIAS
-- =====================================================
SELECT 
    '🧪 VERIFICAÇÃO COMPLETA DE TABELAS' as titulo,
    jsonb_build_object(
        'preventive_health_analyses', EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'preventive_health_analyses'),
        'company_configurations', EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'company_configurations'),
        'ai_user_configurations', EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'ai_user_configurations'),
        'system_notifications', EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'system_notifications'),
        'user_settings', EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'user_settings')
    ) as tabelas_verificadas;

-- =====================================================
-- TESTE 9: VERIFICAR POLÍTICAS RLS
-- =====================================================
SELECT 
    '🧪 VERIFICAÇÃO DE POLÍTICAS RLS' as titulo,
    schemaname,
    tablename,
    CASE WHEN rowsecurity THEN '✅ RLS Ativo' ELSE '❌ RLS Inativo' END as rls_status,
    (SELECT COUNT(*) FROM pg_policies p WHERE p.tablename = t.tablename) as total_politicas
FROM pg_tables t
WHERE schemaname = 'public'
  AND tablename IN (
    'preventive_health_analyses',
    'company_configurations', 
    'ai_user_configurations',
    'system_notifications',
    'user_settings'
  )
ORDER BY tablename;

-- =====================================================
-- TESTE 10: CONTAGEM FINAL DE DADOS
-- =====================================================
SELECT 
    '🧪 CONTAGEM FINAL DE DADOS' as titulo,
    jsonb_build_object(
        'challenges', (SELECT COUNT(*) FROM challenges),
        'courses', (SELECT COUNT(*) FROM courses),
        'modules', (SELECT COUNT(*) FROM modules),
        'company_configurations', (SELECT COUNT(*) FROM company_configurations),
        'system_notifications', (SELECT COUNT(*) FROM system_notifications),
        'preventive_health_analyses', (SELECT COUNT(*) FROM preventive_health_analyses),
        'user_goals', (SELECT COUNT(*) FROM user_goals),
        'challenge_participations', (SELECT COUNT(*) FROM challenge_participations)
    ) as contagem_dados;

-- 🎯 TESTES COMPLETOS EXECUTADOS!
-- Verifique os NOTICES acima para resultados detalhados
-- Todos os testes devem mostrar "PASSOU" para confirmar que os erros foram corrigidos