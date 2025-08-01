-- Criar tabelas que podem estar faltando para Sofia funcionar 100%
-- Execute este script no Supabase SQL Editor

-- 1. Tabela chat_conversations (principal)
CREATE TABLE IF NOT EXISTS public.chat_conversations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    response TEXT NOT NULL,
    character VARCHAR(50) DEFAULT 'Sofia',
    has_image BOOLEAN DEFAULT FALSE,
    image_url TEXT,
    food_analysis JSONB,
    sentiment_score NUMERIC(3,2) DEFAULT 0,
    emotion_tags TEXT[] DEFAULT '{}',
    topic_tags TEXT[] DEFAULT '{}',
    pain_level INTEGER CHECK (pain_level >= 0 AND pain_level <= 10),
    stress_level INTEGER CHECK (stress_level >= 0 AND stress_level <= 10),
    energy_level INTEGER CHECK (energy_level >= 0 AND energy_level <= 10),
    ai_analysis JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Tabela chat_emotional_analysis (análise detalhada)
CREATE TABLE IF NOT EXISTS public.chat_emotional_analysis (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    conversation_id UUID REFERENCES public.chat_conversations(id) ON DELETE CASCADE,
    sentiment_score NUMERIC(3,2) DEFAULT 0,
    emotions_detected TEXT[] DEFAULT '{}',
    pain_level INTEGER CHECK (pain_level >= 0 AND pain_level <= 10),
    stress_level INTEGER CHECK (stress_level >= 0 AND stress_level <= 10),
    energy_level INTEGER CHECK (energy_level >= 0 AND energy_level <= 10),
    mood_keywords TEXT[] DEFAULT '{}',
    physical_symptoms TEXT[] DEFAULT '{}',
    emotional_topics TEXT[] DEFAULT '{}',
    concerns_mentioned TEXT[] DEFAULT '{}',
    goals_mentioned TEXT[] DEFAULT '{}',
    achievements_mentioned TEXT[] DEFAULT '{}',
    analysis_metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Tabela ai_configurations (configurações de IA)
CREATE TABLE IF NOT EXISTS public.ai_configurations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    functionality VARCHAR(100) NOT NULL UNIQUE,
    service VARCHAR(50) DEFAULT 'openai',
    model VARCHAR(100) DEFAULT 'gpt-3.5-turbo',
    max_tokens INTEGER DEFAULT 2048,
    temperature NUMERIC(3,2) DEFAULT 0.7,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Verificar/Criar colunas necessárias na tabela profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS full_name TEXT,
ADD COLUMN IF NOT EXISTS avatar_url TEXT,
ADD COLUMN IF NOT EXISTS bio TEXT,
ADD COLUMN IF NOT EXISTS birth_date DATE,
ADD COLUMN IF NOT EXISTS gender VARCHAR(20),
ADD COLUMN IF NOT EXISTS height_cm INTEGER,
ADD COLUMN IF NOT EXISTS activity_level VARCHAR(20),
ADD COLUMN IF NOT EXISTS health_goals TEXT[],
ADD COLUMN IF NOT EXISTS dietary_restrictions TEXT[],
ADD COLUMN IF NOT EXISTS medical_conditions TEXT[],
ADD COLUMN IF NOT EXISTS emergency_contact JSONB,
ADD COLUMN IF NOT EXISTS preferences JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- 5. Tabela weight_measurements (se não existir)
CREATE TABLE IF NOT EXISTS public.weight_measurements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    peso_kg NUMERIC(5,2) NOT NULL,
    imc NUMERIC(4,2),
    gordura_corporal NUMERIC(4,2),
    massa_muscular NUMERIC(4,2),
    agua_corporal NUMERIC(4,2),
    massa_ossea NUMERIC(4,2),
    metabolismo_basal INTEGER,
    idade_metabolica INTEGER,
    gordura_visceral INTEGER,
    measurement_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    device_source VARCHAR(100) DEFAULT 'manual',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Tabela daily_mission_sessions (se não existir)
CREATE TABLE IF NOT EXISTS public.daily_mission_sessions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    missions_completed INTEGER DEFAULT 0,
    total_missions INTEGER DEFAULT 0,
    streak_days INTEGER DEFAULT 0,
    xp_earned INTEGER DEFAULT 0,
    session_data JSONB,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- 7. Políticas RLS para chat_conversations
ALTER TABLE public.chat_conversations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own conversations" ON public.chat_conversations;
CREATE POLICY "Users can view own conversations" ON public.chat_conversations
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own conversations" ON public.chat_conversations;
CREATE POLICY "Users can insert own conversations" ON public.chat_conversations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Service role can manage all conversations" ON public.chat_conversations;
CREATE POLICY "Service role can manage all conversations" ON public.chat_conversations
    FOR ALL USING (auth.role() = 'service_role');

-- 8. Políticas RLS para chat_emotional_analysis
ALTER TABLE public.chat_emotional_analysis ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own emotional analysis" ON public.chat_emotional_analysis;
CREATE POLICY "Users can view own emotional analysis" ON public.chat_emotional_analysis
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own emotional analysis" ON public.chat_emotional_analysis;
CREATE POLICY "Users can insert own emotional analysis" ON public.chat_emotional_analysis
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Service role can manage all emotional analysis" ON public.chat_emotional_analysis;
CREATE POLICY "Service role can manage all emotional analysis" ON public.chat_emotional_analysis
    FOR ALL USING (auth.role() = 'service_role');

-- 9. Políticas RLS para ai_configurations
ALTER TABLE public.ai_configurations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Everyone can view ai configurations" ON public.ai_configurations;
CREATE POLICY "Everyone can view ai configurations" ON public.ai_configurations
    FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Service role can manage ai configurations" ON public.ai_configurations;
CREATE POLICY "Service role can manage ai configurations" ON public.ai_configurations
    FOR ALL USING (auth.role() = 'service_role');

-- 10. Inserir configurações padrão de IA
INSERT INTO public.ai_configurations (functionality, service, model, max_tokens, temperature, is_active)
VALUES 
    ('health_chat', 'google', 'gemini-1.5-flash', 2048, 0.7, true),
    ('medical_analysis', 'google', 'gemini-1.5-flash', 4096, 0.3, true),
    ('food_analysis', 'google', 'gemini-1.5-flash', 1024, 0.6, true),
    ('weekly_report', 'google', 'gemini-1.5-pro', 8192, 0.5, true),
    ('emotional_analysis', 'google', 'gemini-1.5-flash', 1024, 0.3, true)
ON CONFLICT (functionality) DO UPDATE SET
    service = EXCLUDED.service,
    model = EXCLUDED.model,
    max_tokens = EXCLUDED.max_tokens,
    temperature = EXCLUDED.temperature,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- 11. Índices para performance
CREATE INDEX IF NOT EXISTS idx_chat_conversations_user_id ON public.chat_conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_created_at ON public.chat_conversations(created_at);
CREATE INDEX IF NOT EXISTS idx_chat_emotional_analysis_user_id ON public.chat_emotional_analysis(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_emotional_analysis_conversation_id ON public.chat_emotional_analysis(conversation_id);
CREATE INDEX IF NOT EXISTS idx_weight_measurements_user_id ON public.weight_measurements(user_id);
CREATE INDEX IF NOT EXISTS idx_weight_measurements_date ON public.weight_measurements(measurement_date);
CREATE INDEX IF NOT EXISTS idx_daily_mission_sessions_user_id ON public.daily_mission_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_mission_sessions_date ON public.daily_mission_sessions(date);

-- 12. Triggers para updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_chat_conversations_updated_at ON public.chat_conversations;
CREATE TRIGGER update_chat_conversations_updated_at
    BEFORE UPDATE ON public.chat_conversations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_chat_emotional_analysis_updated_at ON public.chat_emotional_analysis;
CREATE TRIGGER update_chat_emotional_analysis_updated_at
    BEFORE UPDATE ON public.chat_emotional_analysis
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_ai_configurations_updated_at ON public.ai_configurations;
CREATE TRIGGER update_ai_configurations_updated_at
    BEFORE UPDATE ON public.ai_configurations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();