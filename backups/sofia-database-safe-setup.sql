-- Script seguro para garantir que Sofia tenha tudo necessário SEM DUPLICAR
-- Execute este script no Supabase SQL Editor

-- =============================================
-- 1. VERIFICAR E COMPLETAR TABELA PROFILES
-- =============================================

-- Adicionar colunas que podem estar faltando (somente se não existirem)
DO $$ 
BEGIN
    -- Campos básicos do cadastro
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='birth_date') THEN
        ALTER TABLE public.profiles ADD COLUMN birth_date DATE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='gender') THEN
        ALTER TABLE public.profiles ADD COLUMN gender TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='height') THEN
        ALTER TABLE public.profiles ADD COLUMN height NUMERIC(5,2);
    END IF;
    
    -- Campos que serão coletados durante a semana
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='weight_goal') THEN
        ALTER TABLE public.profiles ADD COLUMN weight_goal NUMERIC(5,2);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='health_goals') THEN
        ALTER TABLE public.profiles ADD COLUMN health_goals TEXT[];
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='dietary_restrictions') THEN
        ALTER TABLE public.profiles ADD COLUMN dietary_restrictions TEXT[];
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='medical_conditions') THEN
        ALTER TABLE public.profiles ADD COLUMN medical_conditions TEXT[];
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='activity_level') THEN
        ALTER TABLE public.profiles ADD COLUMN activity_level TEXT DEFAULT 'moderado';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='sleep_hours') THEN
        ALTER TABLE public.profiles ADD COLUMN sleep_hours INTEGER;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='water_goal_ml') THEN
        ALTER TABLE public.profiles ADD COLUMN water_goal_ml INTEGER DEFAULT 2000;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='profession') THEN
        ALTER TABLE public.profiles ADD COLUMN profession TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='stress_level') THEN
        ALTER TABLE public.profiles ADD COLUMN stress_level INTEGER CHECK (stress_level >= 1 AND stress_level <= 10);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='motivation_level') THEN
        ALTER TABLE public.profiles ADD COLUMN motivation_level INTEGER CHECK (motivation_level >= 1 AND motivation_level <= 10);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='preferences') THEN
        ALTER TABLE public.profiles ADD COLUMN preferences JSONB DEFAULT '{}';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='emergency_contact') THEN
        ALTER TABLE public.profiles ADD COLUMN emergency_contact JSONB;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='onboarding_completed') THEN
        ALTER TABLE public.profiles ADD COLUMN onboarding_completed BOOLEAN DEFAULT FALSE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='weekly_data_collected') THEN
        ALTER TABLE public.profiles ADD COLUMN weekly_data_collected JSONB DEFAULT '{}';
    END IF;
END $$;

-- =============================================
-- 2. TABELA CHAT_CONVERSATIONS (SOFIA)
-- =============================================

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

-- =============================================
-- 3. TABELA CHAT_EMOTIONAL_ANALYSIS (SOFIA)
-- =============================================

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

-- =============================================
-- 4. TABELA AI_CONFIGURATIONS (SOFIA)
-- =============================================

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

-- =============================================
-- 5. VERIFICAR USER_PHYSICAL_DATA
-- =============================================

-- Adicionar colunas que podem estar faltando
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name='user_physical_data') THEN
        CREATE TABLE public.user_physical_data (
            id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
            user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
            altura_cm INTEGER,
            idade INTEGER,
            sexo VARCHAR(20),
            nivel_atividade VARCHAR(50) DEFAULT 'moderado',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
    END IF;
END $$;

-- =============================================
-- 6. POLÍTICAS RLS (SEM DUPLICAR)
-- =============================================

-- Habilitar RLS nas tabelas
ALTER TABLE public.chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_emotional_analysis ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_configurations ENABLE ROW LEVEL SECURITY;

-- Políticas para chat_conversations
DROP POLICY IF EXISTS "Users can view own conversations" ON public.chat_conversations;
CREATE POLICY "Users can view own conversations" ON public.chat_conversations
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own conversations" ON public.chat_conversations;
CREATE POLICY "Users can insert own conversations" ON public.chat_conversations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Service role can manage all conversations" ON public.chat_conversations;
CREATE POLICY "Service role can manage all conversations" ON public.chat_conversations
    FOR ALL USING (auth.role() = 'service_role');

-- Políticas para chat_emotional_analysis
DROP POLICY IF EXISTS "Users can view own emotional analysis" ON public.chat_emotional_analysis;
CREATE POLICY "Users can view own emotional analysis" ON public.chat_emotional_analysis
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own emotional analysis" ON public.chat_emotional_analysis;
CREATE POLICY "Users can insert own emotional analysis" ON public.chat_emotional_analysis
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Service role can manage all emotional analysis" ON public.chat_emotional_analysis;
CREATE POLICY "Service role can manage all emotional analysis" ON public.chat_emotional_analysis
    FOR ALL USING (auth.role() = 'service_role');

-- Políticas para ai_configurations
DROP POLICY IF EXISTS "Everyone can view ai configurations" ON public.ai_configurations;
CREATE POLICY "Everyone can view ai configurations" ON public.ai_configurations
    FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Service role can manage ai configurations" ON public.ai_configurations;
CREATE POLICY "Service role can manage ai configurations" ON public.ai_configurations
    FOR ALL USING (auth.role() = 'service_role');

-- =============================================
-- 7. CONFIGURAÇÕES DE IA PARA SOFIA
-- =============================================

-- Inserir configurações padrão (sem duplicar)
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

-- =============================================
-- 8. ÍNDICES PARA PERFORMANCE
-- =============================================

CREATE INDEX IF NOT EXISTS idx_chat_conversations_user_id ON public.chat_conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_created_at ON public.chat_conversations(created_at);
CREATE INDEX IF NOT EXISTS idx_chat_emotional_analysis_user_id ON public.chat_emotional_analysis(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_emotional_analysis_conversation_id ON public.chat_emotional_analysis(conversation_id);
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON public.profiles(user_id);

-- =============================================
-- 9. TRIGGERS PARA UPDATED_AT
-- =============================================

-- Função para atualizar updated_at (se não existir)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers (sem duplicar)
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

-- =============================================
-- 10. ATUALIZAR TRIGGER DE CRIAÇÃO DE PERFIL
-- =============================================

-- Atualizar função para incluir novos campos do cadastro
CREATE OR REPLACE FUNCTION public.handle_new_user_profile()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.profiles (
    user_id, 
    full_name, 
    email,
    phone,
    birth_date,
    gender,
    city,
    state,
    height
  )
  VALUES (
    NEW.id, 
    NEW.raw_user_meta_data ->> 'full_name',
    NEW.email,
    NEW.raw_user_meta_data ->> 'phone',
    CASE 
      WHEN NEW.raw_user_meta_data ->> 'birth_date' IS NOT NULL 
      THEN (NEW.raw_user_meta_data ->> 'birth_date')::DATE 
      ELSE NULL 
    END,
    NEW.raw_user_meta_data ->> 'gender',
    NEW.raw_user_meta_data ->> 'city',
    NEW.raw_user_meta_data ->> 'state',
    CASE 
      WHEN NEW.raw_user_meta_data ->> 'height' IS NOT NULL 
      THEN (NEW.raw_user_meta_data ->> 'height')::NUMERIC 
      ELSE NULL 
    END
  );
  RETURN NEW;
END;
$$;

-- =============================================
-- VERIFICAÇÃO FINAL
-- =============================================

-- Mostrar estrutura final das tabelas principais
SELECT 'profiles' as tabela, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'profiles' AND table_schema = 'public'
UNION ALL
SELECT 'chat_conversations' as tabela, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'chat_conversations' AND table_schema = 'public'
UNION ALL
SELECT 'chat_emotional_analysis' as tabela, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'chat_emotional_analysis' AND table_schema = 'public'
ORDER BY tabela, column_name;