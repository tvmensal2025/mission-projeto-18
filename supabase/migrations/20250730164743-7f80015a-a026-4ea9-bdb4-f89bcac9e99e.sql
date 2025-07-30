-- Adicionar constraint única se não existir para prevenir participações duplicadas
ALTER TABLE public.challenge_participations 
ADD CONSTRAINT IF NOT EXISTS challenge_participations_user_id_challenge_id_key 
UNIQUE (user_id, challenge_id);