-- ===============================================
-- 🧪 TESTE DAS TABELAS DO SISTEMA MULTI-AGENTE
-- ===============================================

-- Verificar se as tabelas existem
SELECT 
  schemaname,
  tablename,
  'Módulo 1 - Personalidade' as modulo
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('ai_personalities', 'personality_adaptations')

UNION ALL

SELECT 
  schemaname,
  tablename,
  'Módulo 2 - Conhecimento' as modulo
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('knowledge_base', 'knowledge_usage_log', 'embedding_configurations')

UNION ALL

SELECT 
  schemaname,
  tablename,
  'Módulo 3 - Calendar' as modulo
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('calendar_integrations', 'ai_managed_events', 'calendar_conflicts', 'event_templates')

UNION ALL

SELECT 
  schemaname,
  tablename,
  'Módulo 4 - Análise' as modulo
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('eating_pattern_analysis', 'image_context_data', 'food_analysis_feedback')

UNION ALL

SELECT 
  schemaname,
  tablename,
  'Módulo 5 - Relatórios' as modulo
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('health_reports', 'report_templates', 'report_feedback', 'report_schedules')

UNION ALL

SELECT 
  schemaname,
  tablename,
  'Módulo 6 - Comportamental' as modulo
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('behavioral_patterns', 'behavioral_interventions', 'behavior_tracking_logs', 'behavioral_analysis_config')

ORDER BY modulo, tablename;