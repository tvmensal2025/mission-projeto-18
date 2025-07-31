-- ===============================================
-- 🔍 DIAGNÓSTICO RÁPIDO - O QUE QUEBROU?
-- ===============================================
-- Execute este script no SQL Editor do Supabase para verificar o status

-- ===============================================
-- 1. VERIFICAR TABELAS PRINCIPAIS
-- ===============================================

SELECT 
    'TABELAS PRINCIPAIS' as categoria,
    table_name,
    CASE 
        WHEN table_name IS NOT NULL THEN '✅ EXISTE'
        ELSE '❌ NÃO EXISTE'
    END as status
FROM (
    SELECT 'profiles' as table_name
    UNION SELECT 'challenges'
    UNION SELECT 'challenge_participations'
    UNION SELECT 'user_goals'
    UNION SELECT 'courses'
    UNION SELECT 'modules'
    UNION SELECT 'lessons'
    UNION SELECT 'preventive_health_analyses'
    UNION SELECT 'company_configurations'
) t
WHERE EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = t.table_name
);

-- ===============================================
-- 2. VERIFICAR COLUNAS CRÍTICAS
-- ===============================================

SELECT 
    'COLUNAS CRÍTICAS' as categoria,
    table_name,
    column_name,
    CASE 
        WHEN column_name IS NOT NULL THEN '✅ EXISTE'
        ELSE '❌ NÃO EXISTE'
    END as status
FROM (
    SELECT 'challenges' as table_name, 'type' as column_name
    UNION SELECT 'challenges', 'created_by'
    UNION SELECT 'challenge_participations', 'best_streak'
    UNION SELECT 'challenge_participations', 'daily_logs'
    UNION SELECT 'user_goals', 'category'
    UNION SELECT 'user_goals', 'priority'
    UNION SELECT 'profiles', 'email'
    UNION SELECT 'profiles', 'role'
) t
WHERE EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = t.table_name
    AND column_name = t.column_name
);

-- ===============================================
-- 3. VERIFICAR POLÍTICAS RLS
-- ===============================================

SELECT 
    'POLÍTICAS RLS' as categoria,
    tablename,
    policyname,
    '✅ EXISTE' as status
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- ===============================================
-- 4. VERIFICAR DADOS DE TESTE
-- ===============================================

SELECT 
    'DADOS DE TESTE' as categoria,
    'challenges' as tabela,
    COUNT(*) as total_registros,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ TEM DADOS'
        ELSE '❌ SEM DADOS'
    END as status
FROM challenges
UNION ALL
SELECT 
    'DADOS DE TESTE' as categoria,
    'company_configurations' as tabela,
    COUNT(*) as total_registros,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ TEM DADOS'
        ELSE '❌ SEM DADOS'
    END as status
FROM company_configurations;

-- ===============================================
-- 5. VERIFICAR FUNÇÕES
-- ===============================================

SELECT 
    'FUNÇÕES' as categoria,
    routine_name,
    '✅ EXISTE' as status
FROM information_schema.routines 
WHERE routine_schema = 'public'
AND routine_name IN ('update_updated_at_column', 'is_admin_user');

-- ===============================================
-- 6. VERIFICAR ÍNDICES
-- ===============================================

SELECT 
    'ÍNDICES' as categoria,
    indexname,
    tablename,
    '✅ EXISTE' as status
FROM pg_indexes 
WHERE schemaname = 'public'
AND indexname LIKE 'idx_%'
ORDER BY tablename, indexname;

-- ===============================================
-- 7. VERIFICAR ENUMS
-- ===============================================

SELECT 
    'ENUMS' as categoria,
    typname,
    '✅ EXISTE' as status
FROM pg_type 
WHERE typname IN ('app_role', 'subscription_status', 'mission_type', 'mission_difficulty', 'goal_status');

-- ===============================================
-- 8. RESUMO GERAL
-- ===============================================

SELECT 
    'RESUMO GERAL' as categoria,
    'Tabelas principais' as item,
    COUNT(*) as total,
    CASE 
        WHEN COUNT(*) >= 8 THEN '✅ OK'
        WHEN COUNT(*) >= 5 THEN '⚠️ PARCIAL'
        ELSE '❌ PROBLEMA'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('profiles', 'challenges', 'challenge_participations', 'user_goals', 'courses', 'modules', 'lessons', 'preventive_health_analyses', 'company_configurations')

UNION ALL

SELECT 
    'RESUMO GERAL' as categoria,
    'Políticas RLS' as item,
    COUNT(*) as total,
    CASE 
        WHEN COUNT(*) >= 8 THEN '✅ OK'
        WHEN COUNT(*) >= 5 THEN '⚠️ PARCIAL'
        ELSE '❌ PROBLEMA'
    END as status
FROM pg_policies 
WHERE schemaname = 'public';

-- ===============================================
-- 9. TESTE DE CONEXÃO
-- ===============================================

SELECT 
    'TESTE DE CONEXÃO' as categoria,
    'auth.users' as tabela,
    COUNT(*) as total_usuarios,
    '✅ CONEXÃO OK' as status
FROM auth.users
LIMIT 1; 