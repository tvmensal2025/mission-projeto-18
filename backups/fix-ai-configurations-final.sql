-- ===============================================
-- 🔧 CORREÇÃO DEFINITIVA DA TABELA AI_CONFIGURATIONS
-- ===============================================

-- 1. DROPAR TABELA COMPLETAMENTE E RECRIAR
DROP TABLE IF EXISTS public.ai_configurations CASCADE;

-- 2. CRIAR TABELA COM ESTRUTURA CORRETA
CREATE TABLE public.ai_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    functionality TEXT NOT NULL UNIQUE,
    service TEXT NOT NULL DEFAULT 'openai',
    model TEXT NOT NULL DEFAULT 'gpt-4o-mini',
    temperature DECIMAL(3,2) NOT NULL DEFAULT 0.7,
    max_tokens INTEGER NOT NULL DEFAULT 2048,
    cost_per_token_input DECIMAL(10,8) DEFAULT 0.00000150,
    cost_per_token_output DECIMAL(10,8) DEFAULT 0.00000600,
    total_cost_usd DECIMAL(10,4) DEFAULT 0.0000,
    is_enabled BOOLEAN NOT NULL DEFAULT true,
    is_active BOOLEAN NOT NULL DEFAULT true,
    preset_level TEXT DEFAULT 'medio',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 3. HABILITAR RLS
ALTER TABLE public.ai_configurations ENABLE ROW LEVEL SECURITY;

-- 4. CRIAR POLÍTICAS RLS
DROP POLICY IF EXISTS "ai_configurations_select_policy" ON public.ai_configurations;
CREATE POLICY "ai_configurations_select_policy" ON public.ai_configurations 
FOR SELECT USING (true); -- Todos podem ver

DROP POLICY IF EXISTS "ai_configurations_insert_policy" ON public.ai_configurations;
CREATE POLICY "ai_configurations_insert_policy" ON public.ai_configurations 
FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "ai_configurations_update_policy" ON public.ai_configurations;
CREATE POLICY "ai_configurations_update_policy" ON public.ai_configurations 
FOR UPDATE USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "ai_configurations_delete_policy" ON public.ai_configurations;
CREATE POLICY "ai_configurations_delete_policy" ON public.ai_configurations 
FOR DELETE USING (auth.uid() IS NOT NULL);

-- 5. INSERIR CONFIGURAÇÕES COMPLETAS
INSERT INTO public.ai_configurations (
    name, functionality, service, model, temperature, max_tokens, 
    cost_per_token_input, cost_per_token_output, is_enabled, is_active, preset_level
) VALUES
-- Configurações principais
('Chat Diário', 'chat_daily', 'openai', 'gpt-4o-mini', 0.8, 2048, 0.00000150, 0.00000600, true, true, 'medio'),
('Relatório Semanal', 'weekly_report', 'openai', 'gpt-4o', 0.7, 4096, 0.00001000, 0.00003000, true, true, 'alto'),
('Relatório Mensal', 'monthly_report', 'openai', 'gpt-4o', 0.6, 4096, 0.00001000, 0.00003000, true, true, 'alto'),
('Análise Médica', 'medical_analysis', 'openai', 'gpt-4o', 0.3, 4096, 0.00001000, 0.00003000, true, true, 'maximo'),
('Análise Preventiva', 'preventive_analysis', 'openai', 'gpt-4o', 0.5, 4096, 0.00001000, 0.00003000, true, true, 'alto'),
('Análise de Alimentos', 'food_analysis', 'gemini', 'gemini-1.5-flash', 0.6, 2048, 0.00000075, 0.00000300, true, true, 'medio'),
('Chat de Saúde', 'health_chat', 'openai', 'gpt-4o-mini', 0.8, 2048, 0.00000150, 0.00000600, true, true, 'medio'),
('Análise de Metas', 'goal_analysis', 'openai', 'gpt-4o-mini', 0.7, 2048, 0.00000150, 0.00000600, true, true, 'medio'),

-- Configurações adicionais para compatibilidade
('Chat GPT', 'gpt_chat', 'openai', 'gpt-4o-mini', 0.8, 2048, 0.00000150, 0.00000600, true, true, 'medio'),
('Chat GPT Avançado', 'enhanced_gpt_chat', 'openai', 'gpt-4o', 0.7, 4096, 0.00001000, 0.00003000, true, true, 'alto'),
('Chat Bot', 'chat_bot', 'openai', 'gpt-4o-mini', 0.8, 2048, 0.00000150, 0.00000600, true, true, 'medio'),
('Análise de Saúde', 'health_analysis', 'openai', 'gpt-4o', 0.5, 4096, 0.00001000, 0.00003000, true, true, 'alto'),
('Análise de Usuário', 'user_analysis', 'openai', 'gpt-4o-mini', 0.7, 2048, 0.00000150, 0.00000600, true, true, 'medio'),
('Geração de Relatórios', 'report_generation', 'openai', 'gpt-4o', 0.6, 4096, 0.00001000, 0.00003000, true, true, 'alto'),
('Análise de Conteúdo', 'content_analysis', 'openai', 'gpt-4o-mini', 0.7, 2048, 0.00000150, 0.00000600, true, true, 'medio');

-- 6. CRIAR TRIGGER PARA UPDATED_AT
CREATE OR REPLACE FUNCTION handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS ai_configurations_updated_at ON public.ai_configurations;
CREATE TRIGGER ai_configurations_updated_at
    BEFORE UPDATE ON public.ai_configurations
    FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

-- 7. CRIAR ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_ai_configurations_functionality ON public.ai_configurations(functionality);
CREATE INDEX IF NOT EXISTS idx_ai_configurations_service ON public.ai_configurations(service);
CREATE INDEX IF NOT EXISTS idx_ai_configurations_enabled ON public.ai_configurations(is_enabled);

-- 8. VERIFICAÇÕES FINAIS
SELECT 
    'ESTRUTURA DA TABELA' as status,
    COUNT(*) as total_colunas
FROM information_schema.columns 
WHERE table_name = 'ai_configurations' 
AND table_schema = 'public';

SELECT 
    'CONFIGURAÇÕES INSERIDAS' as status,
    COUNT(*) as total_configs,
    COUNT(*) FILTER (WHERE is_enabled = true) as configs_ativas,
    COUNT(*) FILTER (WHERE service = 'openai') as openai_configs,
    COUNT(*) FILTER (WHERE service = 'gemini') as gemini_configs
FROM public.ai_configurations;

-- 9. MOSTRAR PRIMEIRAS CONFIGURAÇÕES
SELECT 
    name,
    functionality,
    service,
    model,
    temperature,
    max_tokens,
    is_enabled
FROM public.ai_configurations
ORDER BY name
LIMIT 8;

-- 10. VERIFICAR RLS
SELECT 
    schemaname,
    tablename,
    rowsecurity,
    'RLS HABILITADO' as status
FROM pg_tables 
WHERE tablename = 'ai_configurations' 
AND schemaname = 'public';

-- 11. RESULTADO FINAL
SELECT '✅ TABELA AI_CONFIGURATIONS RECRIADA COM SUCESSO!' as resultado;
SELECT '🚀 AGORA TESTE A FUNCIONALIDADE "IA INTELIGENTE"' as instrucao;