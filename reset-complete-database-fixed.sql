-- ===============================================
-- 🚨 RESET COMPLETO DO BANCO DE DADOS - CORRIGIDO
-- ===============================================
-- ⚠️ ATENÇÃO: Isso vai deletar TUDO!
-- Versão corrigida para PostgreSQL/Supabase
-- ===============================================

-- Desabilitar RLS temporariamente para operações administrativas
SET session_replication_role = 'replica';

-- Deletar todas as funções, tabelas e tipos do schema public
DO $$ 
DECLARE
    r RECORD;
BEGIN
    RAISE NOTICE '🧹 Iniciando limpeza completa do banco...';
    
    -- Deletar todas as funções (usando information_schema)
    FOR r IN (SELECT routine_name FROM information_schema.routines WHERE routine_schema = 'public') LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS public.' || quote_ident(r.routine_name) || ' CASCADE';
        RAISE NOTICE 'Função deletada: %', r.routine_name;
    END LOOP;
    
    -- Deletar todas as tabelas
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP TABLE IF EXISTS public.' || quote_ident(r.tablename) || ' CASCADE';
        RAISE NOTICE 'Tabela deletada: %', r.tablename;
    END LOOP;
    
    -- Deletar todos os tipos customizados
    FOR r IN (SELECT typname FROM pg_type WHERE typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')) LOOP
        EXECUTE 'DROP TYPE IF EXISTS public.' || quote_ident(r.typname) || ' CASCADE';
        RAISE NOTICE 'Tipo deletado: %', r.typname;
    END LOOP;
    
    RAISE NOTICE '✅ Limpeza completa finalizada!';
END $$;

-- Reabilitar RLS
SET session_replication_role = 'origin';

-- Log de conclusão do reset
DO $$
BEGIN
  RAISE NOTICE '===============================================';
  RAISE NOTICE '🎉 RESET COMPLETO EXECUTADO COM SUCESSO!';
  RAISE NOTICE '===============================================';
  RAISE NOTICE '✅ Todas as tabelas deletadas';
  RAISE NOTICE '✅ Todas as funções removidas';
  RAISE NOTICE '✅ Todos os tipos removidos';
  RAISE NOTICE '✅ Banco limpo e pronto para migração única';
  RAISE NOTICE '===============================================';
END $$;