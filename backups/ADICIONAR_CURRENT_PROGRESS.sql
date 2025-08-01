-- 🎯 ADICIONAR CURRENT_PROGRESS
-- Resolver o erro atual

-- Adicionar current_progress
ALTER TABLE challenge_participations ADD COLUMN current_progress INTEGER DEFAULT 0;

-- Verificar se funcionou
SELECT 'current_progress adicionado com sucesso' as resultado;