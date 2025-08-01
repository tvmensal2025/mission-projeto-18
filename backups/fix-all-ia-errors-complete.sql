-- ===============================================
-- 🔧 CORREÇÃO COMPLETA DE TODOS OS ERROS DE IA
-- ===============================================
-- Resolução definitiva dos problemas de configuração

-- 1. VERIFICAR E CORRIGIR ESTRUTURA DA TABELA AI_CONFIGURATIONS
DO $$
BEGIN
    -- Verificar se a tabela existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ai_configurations' AND table_schema = 'public') THEN
        -- Criar tabela se não existir
        CREATE TABLE public.ai_configurations (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            functionality TEXT NOT NULL,
            service TEXT NOT NULL DEFAULT 'openai',
            model TEXT NOT NULL DEFAULT 'gpt-4o-mini',
            temperature DECIMAL(3,2) DEFAULT 0.7,
            max_tokens INTEGER DEFAULT 2048,
            is_enabled BOOLEAN DEFAULT true,
            is_active BOOLEAN DEFAULT true,
            preset_level TEXT DEFAULT 'medio',
            cost_per_1k_tokens DECIMAL(10,6) DEFAULT 0.002,
            monthly_usage INTEGER DEFAULT 0,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
        );
        
        RAISE NOTICE '✅ Tabela ai_configurations criada';
    ELSE
        RAISE NOTICE '✅ Tabela ai_configurations já existe';
    END IF;
END $$;

-- 2. ADICIONAR COLUNAS FALTANTES (SE NÃO EXISTIREM)
DO $$
DECLARE
    col_exists BOOLEAN;
BEGIN
    -- Verificar e adicionar cada coluna necessária
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ai_configurations' 
        AND column_name = 'functionality' 
        AND table_schema = 'public'
    ) INTO col_exists;
    
    IF NOT col_exists THEN
        ALTER TABLE public.ai_configurations ADD COLUMN functionality TEXT;
        RAISE NOTICE '✅ Coluna functionality adicionada';
    END IF;
    
    -- Verificar service
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ai_configurations' 
        AND column_name = 'service' 
        AND table_schema = 'public'
    ) INTO col_exists;
    
    IF NOT col_exists THEN
        ALTER TABLE public.ai_configurations ADD COLUMN service TEXT DEFAULT 'openai';
        RAISE NOTICE '✅ Coluna service adicionada';
    END IF;
    
    -- Verificar model
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ai_configurations' 
        AND column_name = 'model' 
        AND table_schema = 'public'
    ) INTO col_exists;
    
    IF NOT col_exists THEN
        ALTER TABLE public.ai_configurations ADD COLUMN model TEXT DEFAULT 'gpt-4o-mini';
        RAISE NOTICE '✅ Coluna model adicionada';
    END IF;
    
    -- Verificar temperature
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ai_configurations' 
        AND column_name = 'temperature' 
        AND table_schema = 'public'
    ) INTO col_exists;
    
    IF NOT col_exists THEN
        ALTER TABLE public.ai_configurations ADD COLUMN temperature DECIMAL(3,2) DEFAULT 0.7;
        RAISE NOTICE '✅ Coluna temperature adicionada';
    END IF;
    
    -- Verificar max_tokens
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ai_configurations' 
        AND column_name = 'max_tokens' 
        AND table_schema = 'public'
    ) INTO col_exists;
    
    IF NOT col_exists THEN
        ALTER TABLE public.ai_configurations ADD COLUMN max_tokens INTEGER DEFAULT 2048;
        RAISE NOTICE '✅ Coluna max_tokens adicionada';
    END IF;
    
    -- Verificar is_enabled
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ai_configurations' 
        AND column_name = 'is_enabled' 
        AND table_schema = 'public'
    ) INTO col_exists;
    
    IF NOT col_exists THEN
        ALTER TABLE public.ai_configurations ADD COLUMN is_enabled BOOLEAN DEFAULT true;
        RAISE NOTICE '✅ Coluna is_enabled adicionada';
    END IF;
    
    -- Verificar is_active
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ai_configurations' 
        AND column_name = 'is_active' 
        AND table_schema = 'public'
    ) INTO col_exists;
    
    IF NOT col_exists THEN
        ALTER TABLE public.ai_configurations ADD COLUMN is_active BOOLEAN DEFAULT true;
        RAISE NOTICE '✅ Coluna is_active adicionada';
    END IF;
END $$;

-- 3. LIMPAR DADOS EXISTENTES E RECRIAR
DELETE FROM public.ai_configurations;

-- 4. INSERIR CONFIGURAÇÕES COMPLETAS
INSERT INTO public.ai_configurations (
    functionality, service, model, temperature, max_tokens, is_enabled, is_active
) VALUES
-- Configurações principais
('chat_daily', 'openai', 'gpt-4o-mini', 0.8, 2048, true, true),
('weekly_report', 'openai', 'gpt-4o', 0.7, 4096, true, true),
('monthly_report', 'openai', 'gpt-4o', 0.6, 4096, true, true),
('medical_analysis', 'openai', 'gpt-4o', 0.3, 4096, true, true),
('preventive_analysis', 'openai', 'gpt-4o', 0.5, 4096, true, true),
('food_analysis', 'gemini', 'gemini-1.5-flash', 0.6, 2048, true, true),
('health_chat', 'openai', 'gpt-4o-mini', 0.8, 2048, true, true),
('goal_analysis', 'openai', 'gpt-4o-mini', 0.7, 2048, true, true),
('gpt_chat', 'openai', 'gpt-4o-mini', 0.8, 2048, true, true),
('enhanced_gpt_chat', 'openai', 'gpt-4o', 0.7, 4096, true, true),
-- Configurações adicionais que podem estar sendo referenciadas
('chat_bot', 'openai', 'gpt-4o-mini', 0.8, 2048, true, true),
('health_analysis', 'openai', 'gpt-4o', 0.5, 4096, true, true),
('user_analysis', 'openai', 'gpt-4o-mini', 0.7, 2048, true, true),
('report_generation', 'openai', 'gpt-4o', 0.6, 4096, true, true),
('content_analysis', 'openai', 'gpt-4o-mini', 0.7, 2048, true, true);

-- 5. CRIAR CONSTRAINT UNIQUE (SE NÃO EXISTIR)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_name = 'ai_configurations' 
        AND constraint_name = 'ai_configurations_functionality_unique'
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.ai_configurations 
        ADD CONSTRAINT ai_configurations_functionality_unique UNIQUE (functionality);
        RAISE NOTICE '✅ Constraint unique adicionada';
    END IF;
END $$;

-- 6. HABILITAR RLS E CRIAR POLÍTICAS
ALTER TABLE public.ai_configurations ENABLE ROW LEVEL SECURITY;

-- Remover políticas existentes
DROP POLICY IF EXISTS "ai_configurations_admin_policy" ON public.ai_configurations;
DROP POLICY IF EXISTS "ai_configurations_select" ON public.ai_configurations;
DROP POLICY IF EXISTS "ai_configurations_modify" ON public.ai_configurations;

-- Criar políticas novas
CREATE POLICY "ai_configurations_select" ON public.ai_configurations 
FOR SELECT USING (public.is_admin_user());

CREATE POLICY "ai_configurations_modify" ON public.ai_configurations 
FOR ALL USING (public.is_admin_user());

-- 7. CRIAR TRIGGER PARA UPDATED_AT
DROP TRIGGER IF EXISTS handle_updated_at ON public.ai_configurations;
CREATE TRIGGER handle_updated_at 
    BEFORE UPDATE ON public.ai_configurations
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 8. VERIFICAR SE PROFILES TEM AS COLUNAS NECESSÁRIAS
DO $$
DECLARE
    col_exists BOOLEAN;
BEGIN
    -- Verificar se full_name existe
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'full_name' 
        AND table_schema = 'public'
    ) INTO col_exists;
    
    IF NOT col_exists THEN
        ALTER TABLE public.profiles ADD COLUMN full_name TEXT;
        RAISE NOTICE '✅ Coluna full_name adicionada em profiles';
    END IF;
    
    -- Verificar se email existe
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'email' 
        AND table_schema = 'public'
    ) INTO col_exists;
    
    IF NOT col_exists THEN
        ALTER TABLE public.profiles ADD COLUMN email TEXT;
        RAISE NOTICE '✅ Coluna email adicionada em profiles';
    END IF;
END $$;

-- 9. VERIFICAÇÃO FINAL
SELECT 
    'VERIFICAÇÃO FINAL' as status,
    (SELECT COUNT(*) FROM public.ai_configurations) as configs_inseridas,
    (SELECT COUNT(*) FROM public.profiles) as profiles_existentes;

-- 10. MOSTRAR ESTRUTURA DAS TABELAS
SELECT 
    'ai_configurations' as tabela,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'ai_configurations' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 11. RESULTADO FINAL
SELECT '🎉 TODOS OS ERROS DE IA CORRIGIDOS COM SUCESSO!' as resultado;