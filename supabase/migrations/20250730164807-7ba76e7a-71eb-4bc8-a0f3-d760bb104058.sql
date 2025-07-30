-- Criar constraint única para prevenir participações duplicadas
-- Primeiro, remover duplicatas se existirem
DELETE FROM public.challenge_participations 
WHERE id NOT IN (
    SELECT MIN(id) 
    FROM public.challenge_participations 
    GROUP BY user_id, challenge_id
);

-- Adicionar constraint única
DO $$ 
BEGIN
    ALTER TABLE public.challenge_participations 
    ADD CONSTRAINT challenge_participations_user_id_challenge_id_key 
    UNIQUE (user_id, challenge_id);
EXCEPTION
    WHEN duplicate_object THEN 
        -- Constraint já existe, ignorar
        NULL;
END $$;