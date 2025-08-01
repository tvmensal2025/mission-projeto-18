-- 🔧 COMPLETAR TABELA CHALLENGE_PARTICIPATIONS
-- Adicionar todas as colunas necessárias

-- 1. current_progress (erro atual)
ALTER TABLE challenge_participations ADD COLUMN IF NOT EXISTS current_progress INTEGER DEFAULT 0;

-- 2. best_streak 
ALTER TABLE challenge_participations ADD COLUMN IF NOT EXISTS best_streak INTEGER DEFAULT 0;

-- 3. joined_at (pode estar faltando)
ALTER TABLE challenge_participations ADD COLUMN IF NOT EXISTS joined_at TIMESTAMP WITH TIME ZONE DEFAULT now();

-- 4. completed_at
ALTER TABLE challenge_participations ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE;

-- 5. daily_logs (para tracking)
ALTER TABLE challenge_participations ADD COLUMN IF NOT EXISTS daily_logs JSONB DEFAULT '[]';

-- Verificar estrutura final
SELECT 
    'ESTRUTURA FINAL' as titulo,
    column_name,
    data_type,
    column_default
FROM information_schema.columns 
WHERE table_name = 'challenge_participations' 
AND table_schema = 'public'
ORDER BY column_name;