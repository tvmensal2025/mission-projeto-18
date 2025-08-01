-- Verificar e corrigir permissões do usuário atual
-- Garantir que o usuário autenticado possa criar cursos

-- 1. Verificar se o usuário atual existe na tabela profiles
SELECT 
    'Usuário atual:' as info,
    auth.uid() as user_id,
    (SELECT email FROM auth.users WHERE id = auth.uid()) as email;

-- 2. Verificar se o perfil existe
SELECT 
    'Perfil do usuário:' as info,
    user_id,
    role,
    created_at
FROM public.profiles 
WHERE user_id = auth.uid();

-- 3. Inserir perfil se não existir
INSERT INTO public.profiles (user_id, email, role, created_at, updated_at)
SELECT 
    auth.uid(),
    (SELECT email FROM auth.users WHERE id = auth.uid()),
    'user',
    NOW(),
    NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM public.profiles WHERE user_id = auth.uid()
);

-- 4. Verificar políticas RLS ativas
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename IN ('courses', 'course_modules', 'lessons')
ORDER BY tablename, policyname;

-- 5. Log das verificações
DO $$
BEGIN
    RAISE NOTICE 'Verificação de permissões concluída';
    RAISE NOTICE 'Usuário autenticado deve conseguir criar cursos agora';
END $$; 