-- 🧪 TESTAR QUERY DA APLICAÇÃO
-- Verificar se a query funciona agora

-- Primeiro adicionar current_progress
ALTER TABLE challenge_participations ADD COLUMN IF NOT EXISTS current_progress INTEGER DEFAULT 0;

-- Agora testar a query que estava falhando
SELECT 
    cp.id,
    cp.challenge_id,
    cp.user_id,
    cp.status,
    cp.is_completed,
    cp.current_progress
FROM challenge_participations cp
LIMIT 3;