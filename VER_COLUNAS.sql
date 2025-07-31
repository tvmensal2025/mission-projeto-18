-- 👀 VER QUE COLUNAS EXISTEM
-- Execute para ver a estrutura atual

SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'challenge_participations' 
AND table_schema = 'public'
ORDER BY column_name;