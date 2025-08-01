-- ===============================================
-- MIGRAÇÃO DE DADOS: sexo → gender
-- ===============================================

-- 1. Criar perfis para usuários que não têm
INSERT INTO profiles (user_id, full_name, email, gender, created_at, updated_at)
SELECT 
    upd.user_id,
    'Usuário' as full_name,
    u.email,
    CASE 
        WHEN upd.sexo = 'masculino' THEN 'male'
        WHEN upd.sexo = 'feminino' THEN 'female'
        ELSE 'neutral'
    END as gender,
    NOW() as created_at,
    NOW() as updated_at
FROM user_physical_data upd
JOIN auth.users u ON u.id = upd.user_id
WHERE NOT EXISTS (
    SELECT 1 FROM profiles p WHERE p.user_id = upd.user_id
)
AND upd.sexo IS NOT NULL;

-- 2. Atualizar perfis existentes com dados de gender
UPDATE profiles 
SET gender = CASE 
    WHEN upd.sexo = 'masculino' THEN 'male'
    WHEN upd.sexo = 'feminino' THEN 'female'
    ELSE 'neutral'
END,
updated_at = NOW()
FROM user_physical_data upd
WHERE profiles.user_id = upd.user_id 
AND upd.sexo IS NOT NULL
AND profiles.gender IS NULL;

-- 3. Verificar resultado
SELECT 
    p.user_id,
    p.full_name,
    p.gender,
    upd.sexo as original_sexo
FROM profiles p
LEFT JOIN user_physical_data upd ON p.user_id = upd.user_id
WHERE p.gender IS NOT NULL
ORDER BY p.created_at; 