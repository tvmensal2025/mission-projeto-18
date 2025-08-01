-- Verificar estrutura atual do banco para evitar duplicação
-- Execute este script no Supabase SQL Editor

-- 1. Verificar estrutura da tabela profiles
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. Verificar se há tabelas duplicadas (user_profiles vs profiles)
SELECT table_name, table_schema
FROM information_schema.tables 
WHERE table_name IN ('profiles', 'user_profiles', 'user_physical_data')
    AND table_schema = 'public';

-- 3. Verificar estrutura da tabela user_physical_data
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_physical_data' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- 4. Verificar tabelas relacionadas ao chat da Sofia
SELECT table_name
FROM information_schema.tables 
WHERE table_name LIKE '%chat%' 
    AND table_schema = 'public';

-- 5. Verificar se existe ai_configurations
SELECT 
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name = 'ai_configurations' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- 6. Verificar políticas RLS nas tabelas principais
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd,
    roles
FROM pg_policies 
WHERE tablename IN ('profiles', 'user_physical_data', 'chat_conversations')
ORDER BY tablename, policyname;