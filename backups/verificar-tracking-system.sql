-- =====================================================
-- 🔍 VERIFICAÇÃO DO SISTEMA DE TRACKING
-- Executar PRIMEIRO para verificar o que já existe
-- =====================================================

-- Verificar se as tabelas de tracking existem
SELECT 
  'TABELAS DE TRACKING EXISTENTES:' as status,
  COUNT(*) as total_tabelas
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN (
    'water_tracking', 
    'sleep_tracking', 
    'mood_tracking', 
    'exercise_tracking', 
    'medication_tracking', 
    'symptoms_tracking', 
    'custom_habits_tracking'
  );

-- Listar quais tabelas existem
SELECT 
  table_name as tabela_existente,
  'OK' as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN (
    'water_tracking', 
    'sleep_tracking', 
    'mood_tracking', 
    'exercise_tracking', 
    'medication_tracking', 
    'symptoms_tracking', 
    'custom_habits_tracking'
  )
ORDER BY table_name;

-- Verificar se as funções de tracking existem
SELECT 
  routine_name as funcao_existente,
  routine_type as tipo
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_name IN (
    'get_user_dashboard',
    'create_realistic_tracking_data',
    'update_tracking_timestamp'
  )
ORDER BY routine_name;

-- Verificar se os índices existem
SELECT 
  indexname as indice_existente,
  tablename as tabela
FROM pg_indexes 
WHERE schemaname = 'public' 
  AND indexname LIKE '%tracking%'
ORDER BY tablename, indexname;

-- Status final
SELECT 
  CASE 
    WHEN COUNT(*) = 7 THEN '✅ SISTEMA TRACKING JÁ APLICADO - NÃO DUPLICAR!'
    WHEN COUNT(*) > 0 THEN '⚠️ SISTEMA PARCIALMENTE APLICADO - VERIFICAR'
    ELSE '❌ SISTEMA NÃO APLICADO - PODE APLICAR'
  END as resultado_final
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN (
    'water_tracking', 
    'sleep_tracking', 
    'mood_tracking', 
    'exercise_tracking', 
    'medication_tracking', 
    'symptoms_tracking', 
    'custom_habits_tracking'
  );