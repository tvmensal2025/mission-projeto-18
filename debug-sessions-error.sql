-- ===============================================
-- 🔍 DEBUG - ERRO EM SESSÕES
-- ===============================================

-- 1. VERIFICAR ESTRUTURA DA TABELA SESSIONS
SELECT 
    'ESTRUTURA SESSIONS' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'sessions' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. VERIFICAR SE AS COLUNAS NECESSÁRIAS EXISTEM
SELECT 
    'COLUNAS NECESSÁRIAS' as status,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sessions' AND column_name = 'type') THEN 'type: ✅' ELSE 'type: ❌' END as col_type,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sessions' AND column_name = 'follow_up_questions') THEN 'follow_up_questions: ✅' ELSE 'follow_up_questions: ❌' END as col_follow_up,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sessions' AND column_name = 'target_saboteurs') THEN 'target_saboteurs: ✅' ELSE 'target_saboteurs: ❌' END as col_saboteurs,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sessions' AND column_name = 'is_active') THEN 'is_active: ✅' ELSE 'is_active: ❌' END as col_active,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sessions' AND column_name = 'tools_data') THEN 'tools_data: ✅' ELSE 'tools_data: ❌' END as col_tools;

-- 3. VERIFICAR RLS DA TABELA SESSIONS
SELECT 
    'RLS SESSIONS' as info,
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename = 'sessions' 
AND schemaname = 'public';

-- 4. VERIFICAR POLÍTICAS RLS
SELECT 
    'POLÍTICAS SESSIONS' as info,
    policyname,
    cmd,
    permissive,
    roles
FROM pg_policies 
WHERE tablename = 'sessions' 
AND schemaname = 'public';

-- 5. TESTAR INSERÇÃO SIMPLES
DO $$
DECLARE
    test_user_id UUID;
    new_session_id UUID;
BEGIN
    -- Pegar um usuário existente
    SELECT id INTO test_user_id FROM auth.users LIMIT 1;
    
    IF test_user_id IS NULL THEN
        RAISE NOTICE '❌ Nenhum usuário encontrado em auth.users';
        RETURN;
    END IF;
    
    -- Tentar inserir uma sessão de teste
    INSERT INTO public.sessions (
        title,
        description,
        content,
        session_type,
        difficulty,
        duration_minutes,
        type,
        follow_up_questions,
        target_saboteurs,
        is_active,
        tools_data,
        estimated_time,
        user_id,
        created_by
    ) VALUES (
        'Teste Debug',
        'Sessão de teste para debug',
        '{"test": true}'::jsonb,
        'therapy',
        'iniciante',
        15,
        'saboteur_work',
        ARRAY['Como foi?'],
        ARRAY['perfeccionista'],
        true,
        '{}'::jsonb,
        15,
        test_user_id,
        test_user_id
    ) RETURNING id INTO new_session_id;
    
    RAISE NOTICE '✅ Sessão de teste criada com ID: %', new_session_id;
    
    -- Limpar o teste
    DELETE FROM public.sessions WHERE id = new_session_id;
    RAISE NOTICE '🧹 Sessão de teste removida';
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ ERRO AO INSERIR SESSÃO: %', SQLERRM;
END $$;

-- 6. VERIFICAR TABELA USER_SESSIONS
SELECT 
    'USER_SESSIONS' as info,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_sessions' AND table_schema = 'public') 
         THEN 'EXISTE' 
         ELSE 'NÃO EXISTE' 
    END as tabela_existe;

-- 7. CONTAR REGISTROS EXISTENTES
SELECT 
    'DADOS ATUAIS' as info,
    (SELECT COUNT(*) FROM public.sessions) as total_sessions,
    (SELECT COUNT(*) FROM public.user_sessions) as total_user_sessions,
    (SELECT COUNT(*) FROM auth.users) as total_users;

-- 8. RESULTADO
SELECT '🔍 DEBUG SESSIONS COMPLETO!' as resultado;