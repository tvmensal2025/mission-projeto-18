-- 🎯 EXECUTE UMA LINHA POR VEZ
-- Copie e cole cada linha individualmente

-- LINHA 1: Resolver erro atual (is_completed)
ALTER TABLE challenge_participations ADD COLUMN is_completed BOOLEAN DEFAULT false;

-- LINHA 2: Adicionar best_streak  
ALTER TABLE challenge_participations ADD COLUMN best_streak INTEGER DEFAULT 0;

-- LINHA 3: Adicionar category em user_goals
ALTER TABLE user_goals ADD COLUMN category VARCHAR(100) DEFAULT 'saude';

-- LINHA 4: Adicionar email em profiles
ALTER TABLE profiles ADD COLUMN email TEXT;

-- LINHA 5: Adicionar is_active em modules  
ALTER TABLE modules ADD COLUMN is_active BOOLEAN DEFAULT true;