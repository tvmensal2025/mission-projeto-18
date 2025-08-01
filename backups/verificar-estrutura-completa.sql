-- ===============================================
-- 🔍 VERIFICAÇÃO COMPLETA DA ESTRUTURA DO PROJETO
-- ===============================================
-- Este script verifica todas as tabelas, colunas, funções e estrutura
-- ===============================================

-- ===============================================
-- 1. VERIFICAR TODAS AS TABELAS EXISTENTES
-- ===============================================
SELECT 
    schemaname,
    tablename,
    tableowner,
    hasindexes,
    hasrules,
    hastriggers,
    rowsecurity
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- ===============================================
-- 2. VERIFICAR COLUNAS DE CADA TABELA
-- ===============================================
SELECT 
    t.table_name,
    c.column_name,
    c.data_type,
    c.is_nullable,
    c.column_default,
    c.character_maximum_length,
    c.numeric_precision,
    c.numeric_scale
FROM information_schema.tables t
JOIN information_schema.columns c ON t.table_name = c.table_name
WHERE t.table_schema = 'public' 
    AND t.table_type = 'BASE TABLE'
    AND c.table_schema = 'public'
ORDER BY t.table_name, c.ordinal_position;

-- ===============================================
-- 3. VERIFICAR CHAVES PRIMÁRIAS
-- ===============================================
SELECT 
    tc.table_name,
    kcu.column_name,
    tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.constraint_type = 'PRIMARY KEY'
    AND tc.table_schema = 'public'
ORDER BY tc.table_name;

-- ===============================================
-- 4. VERIFICAR CHAVES ESTRANGEIRAS
-- ===============================================
SELECT 
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu 
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public'
ORDER BY tc.table_name;

-- ===============================================
-- 5. VERIFICAR ÍNDICES
-- ===============================================
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- ===============================================
-- 6. VERIFICAR FUNÇÕES SQL
-- ===============================================
SELECT 
    routine_name,
    routine_type,
    data_type,
    routine_definition
FROM information_schema.routines 
WHERE routine_schema = 'public'
ORDER BY routine_name;

-- ===============================================
-- 7. VERIFICAR VIEWS
-- ===============================================
SELECT 
    table_name,
    view_definition
FROM information_schema.views 
WHERE table_schema = 'public'
ORDER BY table_name;

-- ===============================================
-- 8. VERIFICAR TRIGGERS
-- ===============================================
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement,
    action_timing
FROM information_schema.triggers 
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- ===============================================
-- 9. VERIFICAR POLÍTICAS RLS
-- ===============================================
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- ===============================================
-- 10. VERIFICAR TIPOS CUSTOMIZADOS
-- ===============================================
SELECT 
    typname,
    typtype,
    typcategory
FROM pg_type 
WHERE typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
ORDER BY typname;

-- ===============================================
-- 11. VERIFICAR SEQUÊNCIAS
-- ===============================================
SELECT 
    sequence_name,
    data_type,
    start_value,
    minimum_value,
    maximum_value,
    increment
FROM information_schema.sequences 
WHERE sequence_schema = 'public'
ORDER BY sequence_name;

-- ===============================================
-- 12. VERIFICAR DADOS NAS TABELAS
-- ===============================================
SELECT 
    schemaname,
    tablename,
    n_tup_ins as inserts,
    n_tup_upd as updates,
    n_tup_del as deletes,
    n_live_tup as live_rows,
    n_dead_tup as dead_rows
FROM pg_stat_user_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- ===============================================
-- 13. VERIFICAR TAMANHO DAS TABELAS
-- ===============================================
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- ===============================================
-- 14. VERIFICAR TABELAS ESPECÍFICAS DO PROJETO
-- ===============================================

-- Verificar se tabelas essenciais existem
SELECT 
    'users' as tabela_esperada,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users' AND table_schema = 'public') 
         THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END as status
UNION ALL
SELECT 
    'profiles' as tabela_esperada,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles' AND table_schema = 'public') 
         THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END as status
UNION ALL
SELECT 
    'courses' as tabela_esperada,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'courses' AND table_schema = 'public') 
         THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END as status
UNION ALL
SELECT 
    'lessons' as tabela_esperada,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'lessons' AND table_schema = 'public') 
         THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END as status
UNION ALL
SELECT 
    'challenges' as tabela_esperada,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'challenges' AND table_schema = 'public') 
         THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END as status
UNION ALL
SELECT 
    'water_tracking' as tabela_esperada,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'water_tracking' AND table_schema = 'public') 
         THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END as status
UNION ALL
SELECT 
    'sleep_tracking' as tabela_esperada,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'sleep_tracking' AND table_schema = 'public') 
         THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END as status
UNION ALL
SELECT 
    'mood_tracking' as tabela_esperada,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'mood_tracking' AND table_schema = 'public') 
         THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END as status
UNION ALL
SELECT 
    'exercise_tracking' as tabela_esperada,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'exercise_tracking' AND table_schema = 'public') 
         THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END as status;

-- ===============================================
-- 15. VERIFICAR FUNÇÕES ESPECÍFICAS DO PROJETO
-- ===============================================
SELECT 
    'get_user_dashboard' as funcao_esperada,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'get_user_dashboard' AND routine_schema = 'public') 
         THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END as status
UNION ALL
SELECT 
    'get_sofia_insights' as funcao_esperada,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'get_sofia_insights' AND routine_schema = 'public') 
         THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END as status
UNION ALL
SELECT 
    'generate_dr_vital_report' as funcao_esperada,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'generate_dr_vital_report' AND routine_schema = 'public') 
         THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END as status;

-- ===============================================
-- 16. RESUMO FINAL
-- ===============================================
SELECT 
    'RESUMO FINAL' as tipo,
    COUNT(*) as quantidade,
    'tabelas' as unidade
FROM pg_tables 
WHERE schemaname = 'public'
UNION ALL
SELECT 
    'RESUMO FINAL' as tipo,
    COUNT(*) as quantidade,
    'funções' as unidade
FROM information_schema.routines 
WHERE routine_schema = 'public'
UNION ALL
SELECT 
    'RESUMO FINAL' as tipo,
    COUNT(*) as quantidade,
    'views' as unidade
FROM information_schema.views 
WHERE table_schema = 'public'
UNION ALL
SELECT 
    'RESUMO FINAL' as tipo,
    COUNT(*) as quantidade,
    'triggers' as unidade
FROM information_schema.triggers 
WHERE trigger_schema = 'public';

-- ===============================================
-- 17. VERIFICAR ERROS DE ESTRUTURA
-- ===============================================
-- Verificar tabelas sem chave primária
SELECT 
    t.table_name,
    'SEM CHAVE PRIMÁRIA' as problema
FROM information_schema.tables t
LEFT JOIN information_schema.table_constraints tc 
    ON t.table_name = tc.table_name 
    AND tc.constraint_type = 'PRIMARY KEY'
WHERE t.table_schema = 'public' 
    AND t.table_type = 'BASE TABLE'
    AND tc.constraint_name IS NULL
ORDER BY t.table_name;

-- Verificar colunas sem tipo definido
SELECT 
    table_name,
    column_name,
    'SEM TIPO DEFINIDO' as problema
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND data_type IS NULL
ORDER BY table_name, column_name; 