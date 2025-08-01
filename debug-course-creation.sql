-- ===============================================
-- 🔍 DEBUG CRIAÇÃO DE CURSO - TESTE DETALHADO
-- ===============================================

-- 1. VERIFICAR USUÁRIO ATUAL E PERMISSÕES
SELECT 
    'USUÁRIO ATUAL' as info,
    auth.uid() as user_id,
    auth.email() as email;

-- 2. VERIFICAR SE É ADMIN
SELECT 
    'STATUS ADMIN' as info,
    public.is_admin_user() as is_admin;

-- 3. VERIFICAR TABELAS USER_ROLES E PROFILES
SELECT 'USER_ROLES' as tabela, COUNT(*) as total FROM public.user_roles WHERE user_id = auth.uid();
SELECT 'PROFILES' as tabela, role FROM public.profiles WHERE id = auth.uid();

-- 4. TESTE DE INSERÇÃO MANUAL (simulando frontend)
DO $$
DECLARE
    test_course_id UUID;
BEGIN
    RAISE NOTICE 'Testando inserção de curso...';
    
    -- Tentar inserir curso como faria o frontend
    INSERT INTO public.courses (
        title,
        description, 
        category,
        difficulty_level,
        instructor_name,
        is_premium,
        is_published,
        duration_minutes,
        price
    ) VALUES (
        'Curso de Teste Frontend',
        'Descrição do curso de teste',
        'Bem-estar',
        'beginner',
        'Instrutor Teste',
        false,
        true,
        60,
        0.00
    ) RETURNING id INTO test_course_id;
    
    RAISE NOTICE '✅ SUCESSO! Curso criado com ID: %', test_course_id;
    
    -- Limpar teste
    DELETE FROM public.courses WHERE id = test_course_id;
    RAISE NOTICE '🧹 Curso de teste removido';
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ ERRO AO INSERIR CURSO: %', SQLERRM;
    RAISE NOTICE '📋 CÓDIGO DO ERRO: %', SQLSTATE;
END $$;

-- 5. VERIFICAR POLÍTICAS RLS ATIVAS
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'courses' 
AND schemaname = 'public';

-- 6. TESTAR SELECT NA TABELA COURSES
SELECT 
    'TESTE SELECT' as teste,
    COUNT(*) as total_courses
FROM public.courses;

-- 7. VERIFICAR SE RLS ESTÁ BLOQUEANDO
SET row_security = off;
SELECT 'SEM RLS' as teste, COUNT(*) as total FROM public.courses;
SET row_security = on;
SELECT 'COM RLS' as teste, COUNT(*) as total FROM public.courses;