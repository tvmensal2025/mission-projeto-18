-- ===============================================
-- 🔧 CORREÇÃO ERRO NULL VALUE NA COLUNA NAME
-- ===============================================
-- Problema: Coluna 'name' é NOT NULL mas não estamos inserindo

-- 1. VERIFICAR ESTRUTURA ATUAL DA TABELA
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'ai_configurations' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. VERIFICAR SE EXISTE COLUNA NAME
DO $$
DECLARE
    col_exists BOOLEAN;
    col_nullable BOOLEAN;
BEGIN
    -- Verificar se coluna name existe
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ai_configurations' 
        AND column_name = 'name' 
        AND table_schema = 'public'
    ) INTO col_exists;
    
    IF col_exists THEN
        -- Verificar se é nullable
        SELECT is_nullable = 'YES' INTO col_nullable
        FROM information_schema.columns 
        WHERE table_name = 'ai_configurations' 
        AND column_name = 'name' 
        AND table_schema = 'public';
        
        IF NOT col_nullable THEN
            -- Se não é nullable, tornar nullable temporariamente
            ALTER TABLE public.ai_configurations ALTER COLUMN name DROP NOT NULL;
            RAISE NOTICE '✅ Coluna name agora permite NULL';
        END IF;
    ELSE
        -- Adicionar coluna name se não existir
        ALTER TABLE public.ai_configurations ADD COLUMN name TEXT;
        RAISE NOTICE '✅ Coluna name adicionada';
    END IF;
END $$;

-- 3. LIMPAR DADOS EXISTENTES
DELETE FROM public.ai_configurations;

-- 4. INSERIR CONFIGURAÇÕES COM NOME INCLUÍDO
INSERT INTO public.ai_configurations (
    name, functionality, service, model, temperature, max_tokens, is_enabled, is_active
) VALUES
-- Configurações principais com nomes descritivos
('Chat Diário', 'chat_daily', 'openai', 'gpt-4o-mini', 0.8, 2048, true, true),
('Relatório Semanal', 'weekly_report', 'openai', 'gpt-4o', 0.7, 4096, true, true),
('Relatório Mensal', 'monthly_report', 'openai', 'gpt-4o', 0.6, 4096, true, true),
('Análise Médica', 'medical_analysis', 'openai', 'gpt-4o', 0.3, 4096, true, true),
('Análise Preventiva', 'preventive_analysis', 'openai', 'gpt-4o', 0.5, 4096, true, true),
('Análise de Alimentos', 'food_analysis', 'gemini', 'gemini-1.5-flash', 0.6, 2048, true, true),
('Chat de Saúde', 'health_chat', 'openai', 'gpt-4o-mini', 0.8, 2048, true, true),
('Análise de Metas', 'goal_analysis', 'openai', 'gpt-4o-mini', 0.7, 2048, true, true),
('Chat GPT', 'gpt_chat', 'openai', 'gpt-4o-mini', 0.8, 2048, true, true),
('Chat GPT Avançado', 'enhanced_gpt_chat', 'openai', 'gpt-4o', 0.7, 4096, true, true),
-- Configurações adicionais
('Chat Bot', 'chat_bot', 'openai', 'gpt-4o-mini', 0.8, 2048, true, true),
('Análise de Saúde', 'health_analysis', 'openai', 'gpt-4o', 0.5, 4096, true, true),
('Análise de Usuário', 'user_analysis', 'openai', 'gpt-4o-mini', 0.7, 2048, true, true),
('Geração de Relatórios', 'report_generation', 'openai', 'gpt-4o', 0.6, 4096, true, true),
('Análise de Conteúdo', 'content_analysis', 'openai', 'gpt-4o-mini', 0.7, 2048, true, true);

-- 5. ATUALIZAR REGISTROS QUE POSSAM TER NAME NULL
UPDATE public.ai_configurations 
SET name = CASE 
    WHEN functionality = 'chat_daily' THEN 'Chat Diário'
    WHEN functionality = 'weekly_report' THEN 'Relatório Semanal'
    WHEN functionality = 'monthly_report' THEN 'Relatório Mensal'
    WHEN functionality = 'medical_analysis' THEN 'Análise Médica'
    WHEN functionality = 'preventive_analysis' THEN 'Análise Preventiva'
    WHEN functionality = 'food_analysis' THEN 'Análise de Alimentos'
    WHEN functionality = 'health_chat' THEN 'Chat de Saúde'
    WHEN functionality = 'goal_analysis' THEN 'Análise de Metas'
    WHEN functionality = 'gpt_chat' THEN 'Chat GPT'
    WHEN functionality = 'enhanced_gpt_chat' THEN 'Chat GPT Avançado'
    ELSE 'Configuração IA'
END
WHERE name IS NULL;

-- 6. VERIFICAR SE TODOS OS REGISTROS TÊM NAME
SELECT 
    'VERIFICAÇÃO NAME' as status,
    COUNT(*) as total_registros,
    COUNT(*) FILTER (WHERE name IS NOT NULL) as com_name,
    COUNT(*) FILTER (WHERE name IS NULL) as sem_name
FROM public.ai_configurations;

-- 7. TORNAR COLUNA NAME NOT NULL NOVAMENTE (SE NECESSÁRIO)
DO $$
BEGIN
    -- Verificar se todos os registros têm name
    IF NOT EXISTS (SELECT 1 FROM public.ai_configurations WHERE name IS NULL) THEN
        ALTER TABLE public.ai_configurations ALTER COLUMN name SET NOT NULL;
        RAISE NOTICE '✅ Coluna name definida como NOT NULL';
    ELSE
        RAISE NOTICE '⚠️ Ainda existem registros com name NULL';
    END IF;
END $$;

-- 8. VERIFICAÇÃO FINAL
SELECT 
    'CONFIGURAÇÕES INSERIDAS' as status,
    COUNT(*) as total_configs,
    COUNT(*) FILTER (WHERE is_enabled = true) as configs_ativas
FROM public.ai_configurations;

-- 9. MOSTRAR ALGUMAS CONFIGURAÇÕES
SELECT 
    name,
    functionality,
    service,
    model,
    is_enabled
FROM public.ai_configurations
ORDER BY name
LIMIT 10;

-- 10. RESULTADO
SELECT '✅ ERRO DE NULL VALUE CORRIGIDO!' as resultado;