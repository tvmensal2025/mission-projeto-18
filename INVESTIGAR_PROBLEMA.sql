-- 🔍 INVESTIGAR O PROBLEMA REAL
-- Vamos ver exatamente o que existe

-- =====================================================
-- 1. VER TODAS AS COLUNAS EM CHALLENGE_PARTICIPATIONS
-- =====================================================
SELECT 
    '🎯 COLUNAS EM CHALLENGE_PARTICIPATIONS' as titulo,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'challenge_participations' 
AND table_schema = 'public'
ORDER BY column_name;

-- =====================================================
-- 2. VER DADOS NA TABELA
-- =====================================================
SELECT 
    '📊 DADOS EM CHALLENGE_PARTICIPATIONS' as titulo,
    COUNT(*) as total_registros,
    COUNT(is_completed) as registros_com_is_completed,
    SUM(CASE WHEN is_completed = true THEN 1 ELSE 0 END) as completados,
    SUM(CASE WHEN is_completed = false THEN 1 ELSE 0 END) as nao_completados
FROM challenge_participations;

-- =====================================================
-- 3. VER SAMPLE DE DADOS
-- =====================================================
SELECT 
    '📋 SAMPLE DE DADOS' as titulo,
    id,
    user_id,
    challenge_id,
    status,
    is_completed,
    current_progress
FROM challenge_participations 
LIMIT 5;

-- =====================================================
-- 4. VERIFICAR SE OUTRAS COLUNAS EXISTEM
-- =====================================================
SELECT 
    '✅ VERIFICAÇÃO DE COLUNAS CRÍTICAS' as titulo,
    EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_participations' AND column_name = 'is_completed') as is_completed_existe,
    EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_participations' AND column_name = 'best_streak') as best_streak_existe,
    EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'category') as category_existe,
    EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'email') as email_existe,
    EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'modules' AND column_name = 'is_active') as is_active_existe;

-- =====================================================
-- 5. TESTAR QUERY QUE A APLICAÇÃO DEVE ESTAR FAZENDO
-- =====================================================
-- Simular o que a aplicação faz quando tenta participar do desafio
SELECT 
    '🧪 TESTE DE QUERY DA APLICAÇÃO' as titulo,
    cp.id,
    cp.challenge_id,
    cp.user_id,
    cp.status,
    cp.is_completed,
    cp.current_progress,
    c.title as challenge_title
FROM challenge_participations cp
JOIN challenges c ON c.id = cp.challenge_id
LIMIT 3;