-- ===============================================
-- MIGRAÇÃO DE DADOS PARA PROFILES
-- ===============================================

-- 1. Atualizar altura_cm em profiles com dados de user_physical_data
UPDATE profiles 
SET altura_cm = upd.altura_cm,
    updated_at = NOW()
FROM user_physical_data upd
WHERE profiles.user_id = upd.user_id 
AND upd.altura_cm IS NOT NULL
AND profiles.altura_cm IS NULL;

-- 2. Atualizar email em profiles com dados de auth.users
UPDATE profiles 
SET email = u.email,
    updated_at = NOW()
FROM auth.users u
WHERE profiles.user_id = u.id 
AND profiles.email IS NULL;

-- 3. Verificar resultado da migração
SELECT 
    p.user_id,
    p.full_name,
    p.email,
    p.city,
    p.estado,
    p.altura_cm,
    p.gender,
    upd.altura_cm as original_altura,
    upd.sexo as original_sexo
FROM profiles p
LEFT JOIN user_physical_data upd ON p.user_id = upd.user_id
ORDER BY p.created_at; 