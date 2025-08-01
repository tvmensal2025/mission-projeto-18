-- Criar usuário admin com senha super (versão corrigida)
-- Inserir diretamente na tabela auth.users

-- 1. Verificar se o usuário já existe
DO $$
DECLARE
    admin_user_id uuid;
    user_exists boolean;
BEGIN
    -- Verificar se o usuário já existe
    SELECT EXISTS(SELECT 1 FROM auth.users WHERE email = 'admin@super.com') INTO user_exists;
    
    IF NOT user_exists THEN
        -- Inserir usuário na tabela auth.users
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
        );
        
        RAISE NOTICE '✅ Usuário admin criado com sucesso!';
    ELSE
        RAISE NOTICE '⚠️ Usuário admin já existe!';
    END IF;
    
    -- Obter o ID do usuário
    SELECT id INTO admin_user_id 
    FROM auth.users 
    WHERE email = 'admin@super.com';
    
    -- Inserir/atualizar perfil na tabela profiles
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
    
    RAISE NOTICE '👤 Perfil admin criado/atualizado!';
    RAISE NOTICE '📧 Email: admin@super.com';
    RAISE NOTICE '🔑 Senha: super123';
    RAISE NOTICE '🆔 User ID: %', admin_user_id;
END $$;

-- 2. Verificar se foi criado
SELECT 
    'Usuário Admin:' as info,
    id,
    email,
    is_super_admin,
    created_at
FROM auth.users 
WHERE email = 'admin@super.com';

-- 3. Verificar perfil
SELECT 
    'Perfil Admin:' as info,
    user_id,
    full_name,
    created_at
FROM public.profiles 
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'admin@super.com'); 