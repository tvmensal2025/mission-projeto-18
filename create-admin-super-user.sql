-- Criar usuário admin com senha super
-- Inserir diretamente na tabela auth.users

-- 1. Inserir usuário na tabela auth.users
INSERT INTO auth.users (
    id,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
) VALUES (
    gen_random_uuid(),
    'admin@super.com',
    crypt('super123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"name": "Admin Super", "role": "admin"}',
    true,
    '',
    '',
    '',
    ''
) ON CONFLICT (email) DO NOTHING;

-- 2. Obter o ID do usuário criado
DO $$
DECLARE
    admin_user_id uuid;
BEGIN
    SELECT id INTO admin_user_id 
    FROM auth.users 
    WHERE email = 'admin@super.com';
    
    -- 3. Inserir perfil na tabela profiles
    INSERT INTO public.profiles (
        user_id,
        full_name,
        created_at,
        updated_at
    ) VALUES (
        admin_user_id,
        'Admin Super',
        NOW(),
        NOW()
    ) ON CONFLICT (user_id) DO UPDATE SET
        full_name = 'Admin Super',
        updated_at = NOW();
    
    RAISE NOTICE 'Usuário admin criado com ID: %', admin_user_id;
END $$;

-- 4. Verificar se foi criado
SELECT 
    'Usuário Admin:' as info,
    id,
    email,
    is_super_admin,
    created_at
FROM auth.users 
WHERE email = 'admin@super.com';

-- 5. Verificar perfil
SELECT 
    'Perfil Admin:' as info,
    user_id,
    full_name,
    created_at
FROM public.profiles 
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'admin@super.com');

-- Log final
DO $$
BEGIN
    RAISE NOTICE '✅ Usuário admin criado com sucesso!';
    RAISE NOTICE '📧 Email: admin@super.com';
    RAISE NOTICE '🔑 Senha: super123';
    RAISE NOTICE '👤 Role: Admin Super';
END $$; 