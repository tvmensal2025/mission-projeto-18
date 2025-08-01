-- Limpar participações duplicadas mantendo apenas a mais recente
DELETE FROM public.challenge_participations 
WHERE created_at NOT IN (
    SELECT MAX(created_at) 
    FROM public.challenge_participations 
    GROUP BY user_id, challenge_id
);