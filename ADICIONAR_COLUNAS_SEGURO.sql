-- 🛡️ ADICIONAR COLUNAS DE FORMA SEGURA
-- Só adiciona se não existir

-- LINHA 1: best_streak (se não existir)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_participations' AND column_name = 'best_streak') THEN
        ALTER TABLE challenge_participations ADD COLUMN best_streak INTEGER DEFAULT 0;
        RAISE NOTICE '✅ best_streak adicionado';
    ELSE
        RAISE NOTICE '⚠️ best_streak já existe';
    END IF;
END $$;

-- LINHA 2: category em user_goals (se não existir)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'category') THEN
        ALTER TABLE user_goals ADD COLUMN category VARCHAR(100) DEFAULT 'saude';
        RAISE NOTICE '✅ category adicionado';
    ELSE
        RAISE NOTICE '⚠️ category já existe';
    END IF;
END $$;

-- LINHA 3: email em profiles (se não existir)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'email') THEN
        ALTER TABLE profiles ADD COLUMN email TEXT;
        RAISE NOTICE '✅ email adicionado';
    ELSE
        RAISE NOTICE '⚠️ email já existe';
    END IF;
END $$;

-- LINHA 4: is_active em modules (se não existir)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'modules' AND column_name = 'is_active') THEN
        ALTER TABLE modules ADD COLUMN is_active BOOLEAN DEFAULT true;
        RAISE NOTICE '✅ is_active adicionado';
    ELSE
        RAISE NOTICE '⚠️ is_active já existe';
    END IF;
END $$;

-- VERIFICAÇÃO FINAL
SELECT 
    'VERIFICAÇÃO FINAL' as titulo,
    EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_participations' AND column_name = 'is_completed') as is_completed,
    EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_participations' AND column_name = 'best_streak') as best_streak,
    EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'category') as category,
    EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'email') as email,
    EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'modules' AND column_name = 'is_active') as is_active;