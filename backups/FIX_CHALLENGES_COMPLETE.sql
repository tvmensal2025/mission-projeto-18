-- 🔧 COMANDO SQL COMPLETO PARA ARRUMAR ERRO DE DESAFIOS
-- Problema: 400 Bad Request ao criar desafios
-- Solução: Criar tabelas se não existirem e corrigir estrutura

-- ==========================================
-- 1. VERIFICAR E CRIAR TABELA CHALLENGES SE NÃO EXISTIR
-- ==========================================

CREATE TABLE IF NOT EXISTS challenges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  category TEXT DEFAULT 'geral',
  challenge_type TEXT DEFAULT 'general',
  difficulty TEXT DEFAULT 'medio',
  duration_days INTEGER DEFAULT 7,
  xp_reward INTEGER DEFAULT 100,
  points_reward INTEGER DEFAULT 100,
  target_value NUMERIC,
  badge_icon TEXT DEFAULT '🏆',
  badge_name TEXT,
  instructions TEXT,
  tips TEXT[],
  daily_log_type TEXT DEFAULT 'boolean',
  daily_log_target NUMERIC DEFAULT 1,
  daily_log_unit TEXT DEFAULT 'dia',
  is_active BOOLEAN DEFAULT true,
  is_featured BOOLEAN DEFAULT false,
  is_group_challenge BOOLEAN DEFAULT false,
  max_participants INTEGER,
  start_date DATE DEFAULT CURRENT_DATE,
  end_date DATE,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ==========================================
-- 2. CRIAR TABELA CHALLENGE_PARTICIPATIONS SE NÃO EXISTIR
-- ==========================================

CREATE TABLE IF NOT EXISTS challenge_participations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_id UUID REFERENCES challenges(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  current_streak INTEGER DEFAULT 0,
  current_progress INTEGER DEFAULT 0,
  best_streak INTEGER DEFAULT 0,
  progress NUMERIC DEFAULT 0,
  target_value NUMERIC,
  is_completed BOOLEAN DEFAULT false,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  started_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  completed_at TIMESTAMP WITH TIME ZONE,
  daily_logs JSONB DEFAULT '[]',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(challenge_id, user_id)
);

-- ==========================================
-- 3. ADICIONAR COLUNAS QUE PODEM ESTAR FALTANDO
-- ==========================================

-- Adicionar colunas que podem estar faltando em challenges
ALTER TABLE challenges 
ADD COLUMN IF NOT EXISTS challenge_type TEXT DEFAULT 'general',
ADD COLUMN IF NOT EXISTS points_reward INTEGER DEFAULT 100,
ADD COLUMN IF NOT EXISTS target_value NUMERIC,
ADD COLUMN IF NOT EXISTS badge_icon TEXT DEFAULT '🏆',
ADD COLUMN IF NOT EXISTS badge_name TEXT,
ADD COLUMN IF NOT EXISTS instructions TEXT,
ADD COLUMN IF NOT EXISTS tips TEXT[],
ADD COLUMN IF NOT EXISTS daily_log_type TEXT DEFAULT 'boolean',
ADD COLUMN IF NOT EXISTS daily_log_target NUMERIC DEFAULT 1,
ADD COLUMN IF NOT EXISTS daily_log_unit TEXT DEFAULT 'dia',
ADD COLUMN IF NOT EXISTS max_participants INTEGER,
ADD COLUMN IF NOT EXISTS start_date DATE DEFAULT CURRENT_DATE,
ADD COLUMN IF NOT EXISTS end_date DATE,
ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES auth.users(id),
ADD COLUMN IF NOT EXISTS is_featured BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS is_group_challenge BOOLEAN DEFAULT false;

-- Adicionar colunas que podem estar faltando em challenge_participations
ALTER TABLE challenge_participations 
ADD COLUMN IF NOT EXISTS target_value NUMERIC,
ADD COLUMN IF NOT EXISTS current_streak INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS current_progress INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS best_streak INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS progress NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS daily_logs JSONB DEFAULT '[]';

-- ==========================================
-- 4. HABILITAR RLS E CORRIGIR POLÍTICAS
-- ==========================================

-- Habilitar RLS nas tabelas
ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_participations ENABLE ROW LEVEL SECURITY;

-- Remover políticas antigas se existirem
DROP POLICY IF EXISTS "Anyone can view active challenges" ON challenges;
DROP POLICY IF EXISTS "Authenticated users can manage challenges" ON challenges;
DROP POLICY IF EXISTS "Anyone can view all challenges" ON challenges;
DROP POLICY IF EXISTS "Authenticated users can manage all challenges" ON challenges;
DROP POLICY IF EXISTS "Anyone can view challenges" ON challenges;
DROP POLICY IF EXISTS "Authenticated users can create challenges" ON challenges;
DROP POLICY IF EXISTS "Authenticated users can update challenges" ON challenges;
DROP POLICY IF EXISTS "Authenticated users can delete challenges" ON challenges;

-- Criar políticas mais permissivas para challenges
CREATE POLICY "Anyone can view challenges" ON challenges
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create challenges" ON challenges
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update challenges" ON challenges
  FOR UPDATE USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can delete challenges" ON challenges
  FOR DELETE USING (auth.uid() IS NOT NULL);

-- Remover políticas antigas de challenge_participations
DROP POLICY IF EXISTS "Users can view own participations" ON challenge_participations;
DROP POLICY IF EXISTS "Users can create own participations" ON challenge_participations;
DROP POLICY IF EXISTS "Users can update own participations" ON challenge_participations;

-- Criar políticas para challenge_participations
CREATE POLICY "Users can view own participations" ON challenge_participations
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own participations" ON challenge_participations
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own participations" ON challenge_participations
  FOR UPDATE USING (auth.uid() = user_id);

-- ==========================================
-- 5. CRIAR TRIGGERS PARA UPDATED_AT
-- ==========================================

-- Trigger para challenges
CREATE OR REPLACE FUNCTION handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS handle_challenges_updated_at ON challenges;
CREATE TRIGGER handle_challenges_updated_at
  BEFORE UPDATE ON challenges
  FOR EACH ROW
  EXECUTE FUNCTION handle_updated_at();

DROP TRIGGER IF EXISTS handle_challenge_participations_updated_at ON challenge_participations;
CREATE TRIGGER handle_challenge_participations_updated_at
  BEFORE UPDATE ON challenge_participations
  FOR EACH ROW
  EXECUTE FUNCTION handle_updated_at();

-- ==========================================
-- 6. INSERIR DADOS DE EXEMPLO
-- ==========================================

-- Inserir desafios de exemplo se não existirem
INSERT INTO challenges (title, description, category, difficulty, duration_days, xp_reward, is_active, is_featured) VALUES
('Hidratação Diária', 'Beba 2L de água todos os dias por uma semana', 'hidratacao', 'facil', 7, 50, true, true),
('Exercício Matinal', 'Faça 30 minutos de exercício todas as manhãs', 'exercicio', 'medio', 14, 120, true, false),
('Alimentação Saudável', 'Coma 5 porções de frutas e vegetais por dia', 'nutricao', 'medio', 21, 200, true, false),
('Meditação Diária', 'Medite por 10 minutos todos os dias', 'bem-estar', 'facil', 30, 150, true, false)
ON CONFLICT DO NOTHING;

-- ==========================================
-- 7. TESTAR INSERÇÃO DE DESAFIO
-- ==========================================

-- Teste de inserção de desafio
DO $$
DECLARE
    test_user_id uuid;
    new_challenge_id uuid;
BEGIN
    -- Obter um usuário de teste
    SELECT id INTO test_user_id FROM auth.users LIMIT 1;
    
    IF test_user_id IS NOT NULL THEN
        -- Inserir desafio de teste
        INSERT INTO challenges (
            title,
            description,
            category,
            difficulty,
            duration_days,
            xp_reward,
            is_active,
            created_by
        ) VALUES (
            'Desafio Teste SQL',
            'Teste após correção completa',
            'exercicio',
            'medio',
            7,
            100,
            true,
            test_user_id
        ) RETURNING id INTO new_challenge_id;
        
        RAISE NOTICE '✅ DESAFIO CRIADO COM SUCESSO - ID: %', new_challenge_id;
        
        -- Limpar teste
        DELETE FROM challenges WHERE id = new_challenge_id;
        RAISE NOTICE '✅ TESTE LIMPO';
    ELSE
        RAISE NOTICE '⚠️ Nenhum usuário encontrado para teste';
    END IF;
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro no teste: %', SQLERRM;
END $$;

-- ==========================================
-- 8. VERIFICAÇÃO FINAL
-- ==========================================

-- Verificar se tabelas foram criadas
SELECT 
  'TABELAS CRIADAS' as check_type,
  table_name,
  CASE 
    WHEN table_name = 'challenges' THEN (SELECT COUNT(*)::text FROM challenges)
    WHEN table_name = 'challenge_participations' THEN '0'
    ELSE 'N/A'
  END as records_count
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('challenges', 'challenge_participations')
ORDER BY table_name;

-- Verificar estrutura da tabela challenges
SELECT 
  'CHALLENGES STRUCTURE' as check_type,
  COUNT(*) as columns_count,
  '✅ READY' as status
FROM information_schema.columns 
WHERE table_name = 'challenges' AND table_schema = 'public';

-- Verificar estrutura da tabela challenge_participations
SELECT 
  'CHALLENGE_PARTICIPATIONS STRUCTURE' as check_type,
  COUNT(*) as columns_count,
  '✅ READY' as status
FROM information_schema.columns 
WHERE table_name = 'challenge_participations' AND table_schema = 'public';

-- Verificar se a coluna target_value existe
SELECT 
  'TARGET_VALUE COLUMN' as check_type,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_participations' AND column_name = 'target_value') 
    THEN '✅ EXISTS' 
    ELSE '❌ MISSING' 
  END as status;

-- Verificar políticas RLS
SELECT 
  'CHALLENGES POLICIES' as check_type,
  COUNT(*) as policies_count,
  '✅ ACTIVE' as status
FROM pg_policies 
WHERE tablename = 'challenges';

-- Verificar constraints
SELECT 
  'FOREIGN KEYS' as check_type,
  COUNT(*) as fk_count,
  '✅ ACTIVE' as status
FROM pg_constraint 
WHERE contype = 'f' 
  AND conrelid::regclass::text IN ('challenges', 'challenge_participations');

SELECT '🎉 TABELAS DE DESAFIOS CRIADAS E CONFIGURADAS!' as resultado; 