-- ===============================================
-- 🔧 CORREÇÃO ESTRUTURA DA TABELA AI_CONFIGURATIONS
-- ===============================================
-- Problema: Coluna 'functionality' não existe

-- 1. VERIFICAR ESTRUTURA ATUAL
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'ai_configurations' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. ADICIONAR COLUNAS FALTANTES SE NÃO EXISTIREM
ALTER TABLE public.ai_configurations 
ADD COLUMN IF NOT EXISTS functionality TEXT;

ALTER TABLE public.ai_configurations 
ADD COLUMN IF NOT EXISTS service TEXT DEFAULT 'openai';

ALTER TABLE public.ai_configurations 
ADD COLUMN IF NOT EXISTS model TEXT DEFAULT 'gpt-4o-mini';

ALTER TABLE public.ai_configurations 
ADD COLUMN IF NOT EXISTS temperature DECIMAL(3,2) DEFAULT 0.7;

ALTER TABLE public.ai_configurations 
ADD COLUMN IF NOT EXISTS max_tokens INTEGER DEFAULT 2048;

ALTER TABLE public.ai_configurations 
ADD COLUMN IF NOT EXISTS is_enabled BOOLEAN DEFAULT true;

ALTER TABLE public.ai_configurations 
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

ALTER TABLE public.ai_configurations 
ADD COLUMN IF NOT EXISTS preset_level TEXT DEFAULT 'medio';

ALTER TABLE public.ai_configurations 
ADD COLUMN IF NOT EXISTS cost_per_1k_tokens DECIMAL(10,6) DEFAULT 0.002;

ALTER TABLE public.ai_configurations 
ADD COLUMN IF NOT EXISTS monthly_usage INTEGER DEFAULT 0;

-- 3. CRIAR CONSTRAINT UNIQUE PARA FUNCTIONALITY SE NÃO EXISTIR
DO $$
BEGIN
    -- Verificar se a constraint já existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_name = 'ai_configurations' 
        AND constraint_name = 'ai_configurations_functionality_key'
    ) THEN
        ALTER TABLE public.ai_configurations 
        ADD CONSTRAINT ai_configurations_functionality_key UNIQUE (functionality);
    END IF;
END $$;

-- 4. INSERIR CONFIGURAÇÕES PADRÃO (com UPSERT seguro)
INSERT INTO public.ai_configurations (functionality, service, model, temperature, max_tokens, is_enabled) 
VALUES
('chat_daily', 'openai', 'gpt-4o-mini', 0.8, 2048, true),
('weekly_report', 'openai', 'gpt-4o', 0.7, 4096, true),
('monthly_report', 'openai', 'gpt-4o', 0.6, 4096, true),
('medical_analysis', 'openai', 'gpt-4o', 0.3, 4096, true),
('preventive_analysis', 'openai', 'gpt-4o', 0.5, 4096, true),
('food_analysis', 'gemini', 'gemini-1.5-flash', 0.6, 2048, true),
('health_chat', 'openai', 'gpt-4o-mini', 0.8, 2048, true),
('goal_analysis', 'openai', 'gpt-4o-mini', 0.7, 2048, true),
('gpt_chat', 'openai', 'gpt-4o-mini', 0.8, 2048, true),
('enhanced_gpt_chat', 'openai', 'gpt-4o', 0.7, 4096, true)
ON CONFLICT (functionality) DO UPDATE SET
    service = EXCLUDED.service,
    model = EXCLUDED.model,
    temperature = EXCLUDED.temperature,
    max_tokens = EXCLUDED.max_tokens,
    is_enabled = EXCLUDED.is_enabled,
    updated_at = now();

-- 5. VERIFICAR SE DADOS FORAM INSERIDOS
SELECT 
    'CONFIGURAÇÕES INSERIDAS' as status,
    COUNT(*) as total_configs
FROM public.ai_configurations;

-- 6. RESULTADO FINAL
SELECT '✅ ESTRUTURA DA TABELA AI_CONFIGURATIONS CORRIGIDA!' as resultado;