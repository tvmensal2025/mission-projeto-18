-- ===============================================
-- 🔍 VERIFICAÇÃO SIMPLES DO BANCO DE DADOS
-- ===============================================

-- 1. VERIFICAR SE TABELAS EXISTEM
SELECT 
    'courses' as tabela,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'courses' AND table_schema = 'public') 
         THEN 'EXISTE' 
         ELSE 'NAO EXISTE' 
    END as status;

SELECT 
    'course_modules' as tabela,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'course_modules' AND table_schema = 'public') 
         THEN 'EXISTE' 
         ELSE 'NAO EXISTE' 
    END as status;

SELECT 
    'lessons' as tabela,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'lessons' AND table_schema = 'public') 
         THEN 'EXISTE' 
         ELSE 'NAO EXISTE' 
    END as status;

-- 2. VERIFICAR FUNÇÃO is_admin_user
SELECT 
    'is_admin_user' as funcao,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'is_admin_user' AND routine_schema = 'public') 
         THEN 'EXISTE' 
         ELSE 'NAO EXISTE' 
    END as status;

-- 3. VERIFICAR COLUNAS DA TABELA COURSES (se existir)
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'courses' AND table_schema = 'public' 
ORDER BY ordinal_position;

-- 4. VERIFICAR RLS
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename IN ('courses', 'course_modules', 'lessons', 'user_progress') 
AND schemaname = 'public';

-- 5. VERIFICAR POLÍTICAS
SELECT schemaname, tablename, policyname, cmd 
FROM pg_policies 
WHERE tablename IN ('courses', 'course_modules', 'lessons', 'user_progress') 
AND schemaname = 'public';

-- 6. RESULTADO FINAL
SELECT 'DIAGNOSTICO COMPLETO!' as resultado;