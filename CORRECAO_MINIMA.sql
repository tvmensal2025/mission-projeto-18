-- 🚨 CORREÇÃO MÍNIMA - RESOLVER ERRO IMEDIATO
-- Execute apenas estas linhas para resolver o erro atual

-- ERRO: Could not find the 'is_completed' column of 'challenge_participations'
ALTER TABLE challenge_participations ADD COLUMN is_completed BOOLEAN DEFAULT false;

-- Verificar se funcionou
SELECT 'is_completed adicionado' as status;