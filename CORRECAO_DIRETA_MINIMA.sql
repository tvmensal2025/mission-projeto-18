-- 🚨 CORREÇÃO DIRETA MÍNIMA
-- Execute este script diretamente no Supabase SQL Editor
-- https://supabase.com/dashboard/project/hlrkoyywijpckdotimtik/sql

-- 1. Adicionar colunas CHALLENGE_PARTICIPATIONS
ALTER TABLE challenge_participations ADD COLUMN IF NOT EXISTS current_progress INTEGER DEFAULT 0;
ALTER TABLE challenge_participations ADD COLUMN IF NOT EXISTS is_completed BOOLEAN DEFAULT false;
ALTER TABLE challenge_participations ADD COLUMN IF NOT EXISTS best_streak INTEGER DEFAULT 0;
ALTER TABLE challenge_participations ADD COLUMN IF NOT EXISTS total_points INTEGER DEFAULT 0;

-- 2. Adicionar colunas USER_GOALS
ALTER TABLE user_goals ADD COLUMN IF NOT EXISTS category VARCHAR(100) DEFAULT 'saude';
ALTER TABLE user_goals ADD COLUMN IF NOT EXISTS evidence_required BOOLEAN DEFAULT false;
ALTER TABLE user_goals ADD COLUMN IF NOT EXISTS evidence_url TEXT;

-- 3. Adicionar colunas PROFILES
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS role VARCHAR(50) DEFAULT 'user';

-- 4. Adicionar colunas MODULES/LESSONS
ALTER TABLE modules ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS duration INTEGER DEFAULT 0;
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- 5. Criar AI_CONFIGURATIONS se não existir
CREATE TABLE IF NOT EXISTS ai_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    functionality VARCHAR(100) UNIQUE NOT NULL,
    service VARCHAR(50) NOT NULL DEFAULT 'openai',
    model VARCHAR(100) NOT NULL DEFAULT 'gpt-4',
    api_key TEXT,
    enabled BOOLEAN DEFAULT true,
    max_tokens INTEGER DEFAULT 4000,
    temperature DECIMAL(3,2) DEFAULT 0.7,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 6. Criar COMPANY_CONFIGURATIONS se não existir  
CREATE TABLE IF NOT EXISTS company_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name VARCHAR(255) NOT NULL DEFAULT 'Plataforma de Saúde',
    logo_url TEXT,
    primary_color VARCHAR(7) DEFAULT '#10B981',
    secondary_color VARCHAR(7) DEFAULT '#065F46',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Inserir dados iniciais
INSERT INTO company_configurations (company_name, primary_color, secondary_color)
SELECT 'Plataforma de Saúde', '#10B981', '#065F46'
WHERE NOT EXISTS (SELECT 1 FROM company_configurations);

-- 7. Criar PREVENTIVE_HEALTH_ANALYSES se não existir
CREATE TABLE IF NOT EXISTS preventive_health_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    analysis_type VARCHAR(100) NOT NULL,
    input_data JSONB NOT NULL,
    analysis_result JSONB NOT NULL,
    recommendations TEXT[],
    severity_level VARCHAR(20) DEFAULT 'low',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 8. Habilitar RLS e criar políticas simplificadas
ALTER TABLE challenge_participations ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_configurations ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_configurations ENABLE ROW LEVEL SECURITY;
ALTER TABLE preventive_health_analyses ENABLE ROW LEVEL SECURITY;

-- Políticas RLS simplificadas (permitir tudo temporariamente)
DROP POLICY IF EXISTS "allow_all_challenge_participations" ON challenge_participations;
CREATE POLICY "allow_all_challenge_participations" ON challenge_participations FOR ALL USING (true);

DROP POLICY IF EXISTS "allow_all_user_goals" ON user_goals;
CREATE POLICY "allow_all_user_goals" ON user_goals FOR ALL USING (true);

DROP POLICY IF EXISTS "allow_all_profiles" ON profiles;
CREATE POLICY "allow_all_profiles" ON profiles FOR ALL USING (true);

DROP POLICY IF EXISTS "allow_all_modules" ON modules;
CREATE POLICY "allow_all_modules" ON modules FOR ALL USING (true);

DROP POLICY IF EXISTS "allow_all_lessons" ON lessons;
CREATE POLICY "allow_all_lessons" ON lessons FOR ALL USING (true);

DROP POLICY IF EXISTS "allow_all_ai_configurations" ON ai_configurations;
CREATE POLICY "allow_all_ai_configurations" ON ai_configurations FOR ALL USING (true);

DROP POLICY IF EXISTS "allow_all_company_configurations" ON company_configurations;
CREATE POLICY "allow_all_company_configurations" ON company_configurations FOR ALL USING (true);

DROP POLICY IF EXISTS "allow_all_preventive_health_analyses" ON preventive_health_analyses;
CREATE POLICY "allow_all_preventive_health_analyses" ON preventive_health_analyses FOR ALL USING (true);

-- Sucesso!
SELECT '✅ TODAS AS CORREÇÕES APLICADAS COM SUCESSO!' as status;