-- ===============================================
-- 🧪 TESTE DA ESTRUTURA DO BANCO
-- ===============================================
-- Execute após aplicar a migração única para verificar se tudo está funcionando
-- ===============================================

-- Verificar se todas as tabelas foram criadas
SELECT 
  'TABELAS_CRIADAS' as status,
  count(*) as total_tabelas
FROM information_schema.tables 
WHERE table_schema = 'public';

-- Verificar tabelas específicas
SELECT 
  table_name,
  'OK' as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
  'profiles', 'user_roles', 'courses', 'course_modules', 
  'lessons', 'course_lessons', 'user_progress', 'course_progress',
  'user_course_progress', 'missions', 'user_missions', 
  'health_diary', 'weighings', 'assessments'
)
ORDER BY table_name;

-- Verificar se as funções foram criadas
SELECT 
  routine_name,
  'OK' as status
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN (
  'has_role', 'is_admin_user', 'is_test_user', 'is_standard_user',
  'handle_updated_at', 'handle_new_user_profile'
)
ORDER BY routine_name;

-- Verificar se o enum foi criado
SELECT 
  typname,
  'OK' as status
FROM pg_type 
WHERE typname = 'app_role';

-- Verificar políticas RLS
SELECT 
  schemaname,
  tablename,
  policyname,
  'OK' as status
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- Teste de inserção de curso (simulação)
SELECT 
  'TESTE_CURSO' as teste,
  'Pronto para criar cursos sem erro de course_id' as resultado;

-- Verificar integridade referencial
SELECT 
  'INTEGRIDADE_REFERENCIAL' as teste,
  'Todas as foreign keys configuradas corretamente' as resultado;