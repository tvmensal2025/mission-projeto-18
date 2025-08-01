-- ===============================================
-- 🔧 CORREÇÃO TABELA AI_CONFIGURATIONS
-- ===============================================
-- Problema: Tabela ai_configurations não existe

-- 1. CRIAR TABELA AI_CONFIGURATIONS
CREATE TABLE IF NOT EXISTS public.ai_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    functionality TEXT NOT NULL UNIQUE,
    service TEXT NOT NULL DEFAULT 'openai' CHECK (service IN ('openai', 'gemini')),
    model TEXT NOT NULL,
    temperature DECIMAL(3,2) DEFAULT 0.7 CHECK (temperature >= 0 AND temperature <= 2),
    max_tokens INTEGER DEFAULT 2048 CHECK (max_tokens > 0),
    is_enabled BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    preset_level TEXT DEFAULT 'medio',
    cost_per_1k_tokens DECIMAL(10,6) DEFAULT 0.002,
    monthly_usage INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2. INSERIR CONFIGURAÇÕES PADRÃO
INSERT INTO public.ai_configurations (functionality, service, model, temperature, max_tokens, is_enabled) VALUES
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
ON CONFLICT (functionality) DO NOTHING;

-- 3. HABILITAR RLS
ALTER TABLE public.ai_configurations ENABLE ROW LEVEL SECURITY;

-- 4. CRIAR POLÍTICAS RLS
DROP POLICY IF EXISTS "ai_configurations_admin_policy" ON public.ai_configurations;
CREATE POLICY "ai_configurations_admin_policy" ON public.ai_configurations 
FOR ALL USING (public.is_admin_user());

-- 5. CRIAR TRIGGER PARA UPDATED_AT
DROP TRIGGER IF EXISTS handle_updated_at ON public.ai_configurations;
CREATE TRIGGER handle_updated_at 
    BEFORE UPDATE ON public.ai_configurations
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 6. CRIAR ÍNDICES
CREATE INDEX IF NOT EXISTS idx_ai_configurations_functionality 
    ON public.ai_configurations(functionality);
CREATE INDEX IF NOT EXISTS idx_ai_configurations_enabled 
    ON public.ai_configurations(is_enabled) WHERE is_enabled = true;

-- 7. VERIFICAÇÃO
SELECT 
    'AI_CONFIGURATIONS' as tabela,
    COUNT(*) as total_configs,
    COUNT(*) FILTER (WHERE is_enabled = true) as configs_ativas
FROM public.ai_configurations;

-- 8. RESULTADO
SELECT '✅ TABELA AI_CONFIGURATIONS CRIADA COM SUCESSO!' as status;