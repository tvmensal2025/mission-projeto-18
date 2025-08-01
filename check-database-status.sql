-- ===============================================
-- 🔍 VERIFICAÇÃO COMPLETA DO BANCO DE DADOS
-- ===============================================

-- 1. VERIFICAR SE TABELAS EXISTEM
SELECT 
    'courses' as tabela,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'courses' AND table_schema = 'public') 
         THEN '✅ EXISTE' 
         ELSE '❌ NÃO EXISTE' 
    END as status
UNION ALL
SELECT 
    'course_modules' as tabela,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'course_modules' AND table_schema = 'public') 
         THEN '✅ EXISTE' 
         ELSE '❌ NÃO EXISTE' 
    END as status
UNION ALL
SELECT 
    'lessons' as tabela,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'lessons' AND table_schema = 'public') 
         THEN '✅ EXISTE' 
         ELSE '❌ NÃO EXISTE' 
    END as status
UNION ALL
SELECT 
    'user_progress' as tabela,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_progress' AND table_schema = 'public') 
         THEN '✅ EXISTE' 
         ELSE '❌ NÃO EXISTE' 
    END as status;

-- 2. VERIFICAR ESTRUTURA DA TABELA COURSES (se existir)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'courses' AND table_schema = 'public') THEN
        RAISE NOTICE '';
        RAISE NOTICE '📚 ESTRUTURA DA TABELA COURSES:';
        FOR r IN (SELECT column_name, data_type, is_nullable FROM information_schema.columns WHERE table_name = 'courses' AND table_schema = 'public' ORDER BY ordinal_position) LOOP
            RAISE NOTICE '   % - % (nullable: %)', r.column_name, r.data_type, r.is_nullable;
        END LOOP;
    ELSE
        RAISE NOTICE '';
        RAISE NOTICE '❌ TABELA COURSES NÃO EXISTE!';
    END IF;
END $$;

-- 3. VERIFICAR RLS
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'courses' AND table_schema = 'public') THEN
        RAISE NOTICE '';
        RAISE NOTICE '🔐 STATUS RLS:';
        FOR r IN (SELECT schemaname, tablename, rowsecurity FROM pg_tables WHERE tablename IN ('courses', 'course_modules', 'lessons', 'user_progress') AND schemaname = 'public') LOOP
            RAISE NOTICE '   % - RLS: %', r.tablename, CASE WHEN r.rowsecurity THEN '✅ ATIVO' ELSE '❌ INATIVO' END;
        END LOOP;
    END IF;
END $$;

-- 4. VERIFICAR POLÍTICAS RLS
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'courses' AND table_schema = 'public') THEN
        RAISE NOTICE '';
        RAISE NOTICE '📋 POLÍTICAS RLS:';
        FOR r IN (SELECT schemaname, tablename, policyname, cmd FROM pg_policies WHERE tablename IN ('courses', 'course_modules', 'lessons', 'user_progress') AND schemaname = 'public') LOOP
            RAISE NOTICE '   %.% - % (%)', r.schemaname, r.tablename, r.policyname, r.cmd;
        END LOOP;
    END IF;
END $$;

-- 5. VERIFICAR FUNÇÃO is_admin_user
SELECT 
    'is_admin_user' as funcao,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'is_admin_user' AND routine_schema = 'public') 
         THEN '✅ EXISTE' 
         ELSE '❌ NÃO EXISTE' 
    END as status;

-- 6. TESTAR INSERÇÃO SIMPLES (se tabela existir)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'courses' AND table_schema = 'public') THEN
        BEGIN
            INSERT INTO public.courses (title, description, category, difficulty_level, instructor_name, is_published) 
            VALUES ('Teste', 'Teste descrição', 'Teste', 'beginner', 'Instrutor Teste', false);
            
            DELETE FROM public.courses WHERE title = 'Teste';
            RAISE NOTICE '';
            RAISE NOTICE '✅ TESTE DE INSERÇÃO: SUCESSO';
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE '';
            RAISE NOTICE '❌ TESTE DE INSERÇÃO: FALHOU - %', SQLERRM;
        END;
    END IF;
END $$;

-- 7. RESULTADO FINAL
SELECT '🎯 DIAGNÓSTICO COMPLETO FINALIZADO!' as resultado;