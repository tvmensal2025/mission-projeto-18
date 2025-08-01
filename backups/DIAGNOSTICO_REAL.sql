-- 🔍 DIAGNÓSTICO REAL - VAMOS VER O QUE REALMENTE EXISTE
-- Execute este primeiro para entender o estado atual

-- =====================================================
-- 1. VERIFICAR TABELAS QUE EXISTEM
-- =====================================================
SELECT 
    '📋 TABELAS EXISTENTES' as secao,
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name AND table_schema = 'public') as total_colunas
FROM information_schema.tables t
WHERE table_schema = 'public'
AND table_name IN ('challenges', 'challenge_participations', 'user_goals', 'profiles', 'modules', 'courses', 'lessons')
ORDER BY table_name;

-- =====================================================
-- 2. VERIFICAR COLUNAS EM CHALLENGE_PARTICIPATIONS
-- =====================================================
SELECT 
    '🎯 COLUNAS EM CHALLENGE_PARTICIPATIONS' as secao,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'challenge_participations' 
AND table_schema = 'public'
ORDER BY column_name;

-- =====================================================
-- 3. VERIFICAR COLUNAS EM USER_GOALS
-- =====================================================
SELECT 
    '🎯 COLUNAS EM USER_GOALS' as secao,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_goals' 
AND table_schema = 'public'
ORDER BY column_name;

-- =====================================================
-- 4. VERIFICAR COLUNAS EM PROFILES
-- =====================================================
SELECT 
    '👤 COLUNAS EM PROFILES' as secao,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND table_schema = 'public'
ORDER BY column_name;

-- =====================================================
-- 5. VERIFICAR DADOS EXISTENTES
-- =====================================================
SELECT 
    '📊 DADOS EXISTENTES' as secao,
    'challenges' as tabela,
    COUNT(*) as total_registros
FROM challenges
UNION ALL
SELECT 
    '📊 DADOS EXISTENTES' as secao,
    'challenge_participations' as tabela,
    COUNT(*) as total_registros
FROM challenge_participations
UNION ALL
SELECT 
    '📊 DADOS EXISTENTES' as secao,
    'user_goals' as tabela,
    COUNT(*) as total_registros
FROM user_goals
UNION ALL
SELECT 
    '📊 DADOS EXISTENTES' as secao,
    'profiles' as tabela,
    COUNT(*) as total_registros
FROM profiles;

-- =====================================================
-- 6. TESTAR SE CONSEGUIMOS ADICIONAR COLUNAS
-- =====================================================
DO $$
BEGIN
    -- Testar se conseguimos alterar a tabela
    BEGIN
        -- Tentar adicionar uma coluna de teste
        ALTER TABLE challenge_participations ADD COLUMN IF NOT EXISTS teste_coluna TEXT;
        DROP COLUMN IF EXISTS teste_coluna FROM challenge_participations;
        RAISE NOTICE '✅ Conseguimos alterar challenge_participations';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '❌ NÃO conseguimos alterar challenge_participations: %', SQLERRM;
    END;
END $$;

-- =====================================================
-- 7. VERIFICAR PERMISSÕES
-- =====================================================
SELECT 
    '🔐 PERMISSÕES' as secao,
    schemaname,
    tablename,
    CASE WHEN rowsecurity THEN 'RLS Ativo' ELSE 'RLS Inativo' END as rls_status
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'challenge_participations';

-- =====================================================
-- 8. MOSTRAR ESTRUTURA COMPLETA ESPERADA vs ATUAL
-- =====================================================
WITH expected_columns AS (
    SELECT 'challenge_participations' as table_name, 'is_completed' as column_name, 'BOOLEAN' as expected_type
    UNION ALL SELECT 'challenge_participations', 'best_streak', 'INTEGER'
    UNION ALL SELECT 'challenge_participations', 'daily_logs', 'JSONB'
    UNION ALL SELECT 'user_goals', 'category', 'VARCHAR'
    UNION ALL SELECT 'profiles', 'email', 'TEXT'
    UNION ALL SELECT 'modules', 'is_active', 'BOOLEAN'
),
actual_columns AS (
    SELECT 
        table_name,
        column_name,
        data_type
    FROM information_schema.columns 
    WHERE table_schema = 'public'
    AND table_name IN ('challenge_participations', 'user_goals', 'profiles', 'modules')
)
SELECT 
    '🔍 COLUNAS FALTANTES' as secao,
    e.table_name,
    e.column_name,
    e.expected_type,
    CASE WHEN a.column_name IS NULL THEN '❌ FALTANDO' ELSE '✅ EXISTE' END as status
FROM expected_columns e
LEFT JOIN actual_columns a ON e.table_name = a.table_name AND e.column_name = a.column_name
ORDER BY e.table_name, e.column_name;

-- 🔍 DIAGNÓSTICO COMPLETO!
-- Agora vamos ver EXATAMENTE o que existe e o que está faltando