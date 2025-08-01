-- 🎯 CORREÇÃO SIMPLES E GARANTIDA
-- Uma coluna por vez, sem complicação

-- =====================================================
-- PASSO 1: ADICIONAR is_completed (ERRO ATUAL)
-- =====================================================
ALTER TABLE challenge_participations 
ADD COLUMN is_completed BOOLEAN DEFAULT false;

-- Confirmar que funcionou
SELECT 'is_completed' as coluna_adicionada, 
       COUNT(*) as registros_atualizados 
FROM challenge_participations;

-- =====================================================
-- PASSO 2: ADICIONAR best_streak 
-- =====================================================
ALTER TABLE challenge_participations 
ADD COLUMN best_streak INTEGER DEFAULT 0;

-- =====================================================
-- PASSO 3: ADICIONAR category em user_goals
-- =====================================================
ALTER TABLE user_goals 
ADD COLUMN category VARCHAR(100) DEFAULT 'saude';

-- =====================================================
-- PASSO 4: ADICIONAR email em profiles
-- =====================================================
ALTER TABLE profiles 
ADD COLUMN email TEXT;

-- =====================================================
-- PASSO 5: ADICIONAR is_active em modules
-- =====================================================
ALTER TABLE modules 
ADD COLUMN is_active BOOLEAN DEFAULT true;

-- =====================================================
-- VERIFICAR SE TUDO FOI ADICIONADO
-- =====================================================
SELECT 
    'VERIFICAÇÃO FINAL' as titulo,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'challenge_participations' AND column_name = 'is_completed') as is_completed_existe,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'challenge_participations' AND column_name = 'best_streak') as best_streak_existe,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'category') as category_existe,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'email') as email_existe,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'modules' AND column_name = 'is_active') as is_active_existe;

-- ✅ SIMPLES E DIRETO - SEM COMPLICAÇÃO!