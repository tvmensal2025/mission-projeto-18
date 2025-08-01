-- Verificar se todas as tabelas necessárias para Sofia existem
-- Execute este script no Supabase SQL Editor

-- 1. Verificar tabela chat_conversations
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'chat_conversations' 
ORDER BY ordinal_position;

-- 2. Verificar tabela chat_emotional_analysis
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'chat_emotional_analysis' 
ORDER BY ordinal_position;

-- 3. Verificar tabela ai_configurations
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'ai_configurations' 
ORDER BY ordinal_position;

-- 4. Verificar tabela profiles
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'profiles' 
ORDER BY ordinal_position;

-- 5. Verificar tabela weight_measurements
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'weight_measurements' 
ORDER BY ordinal_position;

-- 6. Verificar tabela daily_mission_sessions
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'daily_mission_sessions' 
ORDER BY ordinal_position;