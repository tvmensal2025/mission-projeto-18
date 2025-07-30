-- Garantir que o usuário tenha um perfil válido
-- Inserir perfil básico se não existir

INSERT INTO public.profiles (user_id, full_name, created_at, updated_at)
SELECT 
    auth.uid(),
    'Usuário Padrão',
    NOW(),
    NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM public.profiles WHERE user_id = auth.uid()
);

-- Verificar se o perfil foi criado
SELECT 
    'Perfil criado:' as info,
    user_id,
    full_name,
    created_at
FROM public.profiles 
WHERE user_id = auth.uid();

-- Log da correção
DO $$
BEGIN
    RAISE NOTICE 'Perfil do usuário verificado/criado';
    RAISE NOTICE 'Agora deve ser possível criar cursos';
END $$; 