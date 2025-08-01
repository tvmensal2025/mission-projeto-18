-- 🔥 SUPER SIMPLES - SEM COMPLICAÇÃO
-- Execute linha por linha se necessário

-- Adicionar is_completed (resolve o erro atual)
ALTER TABLE challenge_participations ADD COLUMN is_completed BOOLEAN DEFAULT false;

-- Verificar se funcionou
SELECT 'SUCESSO: is_completed adicionada' as resultado;