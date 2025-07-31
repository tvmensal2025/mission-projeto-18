-- 🚨 CORREÇÃO RÁPIDA E DIRETA - APENAS O ESSENCIAL
-- Execute este script para resolver os erros imediatos

-- Adicionar is_completed (erro atual na tela)
ALTER TABLE challenge_participations ADD COLUMN IF NOT EXISTS is_completed BOOLEAN DEFAULT false;

-- Adicionar best_streak (erro comum)
ALTER TABLE challenge_participations ADD COLUMN IF NOT EXISTS best_streak INTEGER DEFAULT 0;

-- Adicionar category (erro ao criar metas)
ALTER TABLE user_goals ADD COLUMN IF NOT EXISTS category VARCHAR(100) DEFAULT 'geral';

-- Adicionar email (erro de IA)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email TEXT;

-- Adicionar is_active (erro de módulos)
ALTER TABLE modules ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- Criar tabela de análises preventivas
CREATE TABLE IF NOT EXISTS preventive_health_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    analysis_type VARCHAR(50) NOT NULL,
    results JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Criar tabela de configurações da empresa
CREATE TABLE IF NOT EXISTS company_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name TEXT NOT NULL DEFAULT 'Instituto dos Sonhos',
    settings JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Inserir configuração padrão da empresa
INSERT INTO company_configurations (company_name) 
VALUES ('Instituto dos Sonhos') 
ON CONFLICT DO NOTHING;

-- Atualizar participações existentes
UPDATE challenge_participations 
SET is_completed = false 
WHERE is_completed IS NULL;

-- Verificar se funcionou
SELECT 
    'CORREÇÃO RÁPIDA APLICADA' as status,
    jsonb_build_object(
        'is_completed_exists', EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_participations' AND column_name = 'is_completed'),
        'category_exists', EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'category'),
        'email_exists', EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'email')
    ) as verificacao;