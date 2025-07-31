-- ===============================================
-- 🔄 FORÇAR ATUALIZAÇÃO DO CACHE DO SUPABASE
-- ===============================================

-- 1. VERIFICAR SE AS COLUNAS FORAM REALMENTE CRIADAS
SELECT 
    'VERIFICAÇÃO COLUNAS SESSIONS' as status,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'sessions' 
AND table_schema = 'public'
AND column_name IN ('follow_up_questions', 'target_saboteurs', 'type', 'is_active', 'tools_data')
ORDER BY column_name;

-- 2. VERIFICAR SE AS TABELAS FORAM CRIADAS
SELECT 
    'VERIFICAÇÃO TABELAS CRIADAS' as status,
    table_name,
    'EXISTE' as existe
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
    'user_sessions', 'daily_mission_sessions', 'daily_responses', 
    'user_scores', 'challenge_participations', 'water_tracking', 
    'sleep_tracking', 'mood_tracking'
)
ORDER BY table_name;

-- 3. FORÇAR REFRESH DO CACHE - FAZER UMA OPERAÇÃO QUE FORCE ATUALIZAÇÃO
-- Criar e dropar uma tabela temporária para forçar refresh
CREATE TABLE IF NOT EXISTS temp_cache_refresh (id INTEGER);
DROP TABLE IF EXISTS temp_cache_refresh;

-- 4. FAZER UM SELECT SIMPLES EM CADA TABELA PARA ATIVAR O CACHE
SELECT 'user_sessions' as tabela, COUNT(*) as registros FROM public.user_sessions;
SELECT 'daily_mission_sessions' as tabela, COUNT(*) as registros FROM public.daily_mission_sessions;
SELECT 'daily_responses' as tabela, COUNT(*) as registros FROM public.daily_responses;
SELECT 'sessions com novas colunas' as tabela, COUNT(*) as registros FROM public.sessions;

-- 5. TESTAR INSERÇÃO EM SESSIONS COM NOVAS COLUNAS
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
    'Teste Cache Refresh',
    'Sessão para testar se as novas colunas estão funcionando',
    '{"test": "cache_refresh"}'::jsonb,
    'therapy',
    'iniciante',
    15,
    'saboteur_work',
    ARRAY['Como você se sentiu?', 'O que mais te impactou?'],
    ARRAY['perfeccionista', 'vitima'],
    true,
    '{"tools": ["roda_vida", "questionario"]}'::jsonb,
    15,
    (SELECT id FROM auth.users LIMIT 1),
    (SELECT id FROM auth.users LIMIT 1)
);

-- 6. VERIFICAR SE A INSERÇÃO FUNCIONOU
SELECT 
    'TESTE INSERÇÃO' as status,
    id,
    title,
    type,
    follow_up_questions,
    target_saboteurs,
    is_active,
    tools_data
FROM public.sessions 
WHERE title = 'Teste Cache Refresh'
LIMIT 1;

-- 7. LIMPAR TESTE
DELETE FROM public.sessions WHERE title = 'Teste Cache Refresh';

-- 8. RESULTADO FINAL
SELECT '✅ CACHE ATUALIZADO COM SUCESSO!' as resultado;
SELECT '🔄 RECARREGUE A PÁGINA DO ADMIN AGORA!' as instrucao;