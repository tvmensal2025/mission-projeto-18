-- ===============================================
-- MIGRAÇÃO: user_physical_data → profiles
-- ===============================================

-- 1. Atualizar altura em profiles
UPDATE profiles 
SET altura_cm = upd.altura_cm,
    updated_at = NOW()
FROM user_physical_data upd
WHERE profiles.user_id = upd.user_id 
AND upd.altura_cm IS NOT NULL
AND profiles.altura_cm IS NULL;

-- 2. Verificar resultado
SELECT 
    p.user_id,
    p.full_name,
    p.altura_cm,
    p.birth_date,
    p.data_nascimento,
    upd.altura_cm as original_altura,
    upd.idade as original_idade
FROM profiles p
LEFT JOIN user_physical_data upd ON p.user_id = upd.user_id
WHERE p.altura_cm IS NOT NULL
ORDER BY p.created_at; 