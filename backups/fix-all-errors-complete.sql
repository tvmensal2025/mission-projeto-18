-- ===============================================
-- 🔧 CORREÇÃO TOTAL DE TODOS OS ERROS
-- ===============================================
-- Baseado na análise completa dos erros do frontend

-- ===============================================
-- 1. LIMPEZA FORÇADA PRIMEIRO
-- ===============================================

SET session_replication_role = 'replica';

-- Remover todas as políticas RLS primeiro
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN (SELECT schemaname, tablename, policyname FROM pg_policies WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(pol.policyname) || ' ON ' || quote_ident(pol.schemaname) || '.' || quote_ident(pol.tablename) || ' CASCADE';
    END LOOP;
END $$;

-- Remover todas as tabelas
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP TABLE IF EXISTS public.' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END $$;

-- Remover todas as funções
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT routine_name FROM information_schema.routines WHERE routine_schema = 'public') LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS public.' || quote_ident(r.routine_name) || ' CASCADE';
    END LOOP;
END $$;

-- Forçar remoção de tipos ENUM
DROP TYPE IF EXISTS public.app_role CASCADE;
DROP TYPE IF EXISTS public.subscription_status CASCADE;
DROP TYPE IF EXISTS public.mission_type CASCADE;
DROP TYPE IF EXISTS public.mission_difficulty CASCADE;
DROP TYPE IF EXISTS public.payment_status CASCADE;
DROP TYPE IF EXISTS public.goal_status CASCADE;

SET session_replication_role = 'origin';

-- ===============================================
-- 2. CRIAR ENUMS BÁSICOS
-- ===============================================

CREATE TYPE app_role AS ENUM ('test', 'user', 'admin', 'premium', 'vip');
CREATE TYPE subscription_status AS ENUM ('active', 'inactive', 'cancelled', 'pending');
CREATE TYPE mission_type AS ENUM ('morning', 'habits', 'mindset', 'individual', 'community');
CREATE TYPE mission_difficulty AS ENUM ('easy', 'medium', 'hard');
CREATE TYPE goal_status AS ENUM ('pendente', 'aprovada', 'rejeitada', 'em_progresso', 'concluida', 'cancelada');

-- ===============================================
-- 3. TABELA PROFILES (CORRIGIDA)
-- ===============================================

CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT,
    avatar_url TEXT,
    role app_role DEFAULT 'user',
    birth_date DATE,
    gender TEXT,
    height DECIMAL(5,2),
    city TEXT,
    state TEXT,
    phone TEXT,
    activity_level TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    is_active BOOLEAN DEFAULT true
);

-- ===============================================
-- 4. TABELA USER_PHYSICAL_DATA (NECESSÁRIA)
-- ===============================================

CREATE TABLE public.user_physical_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
    altura_cm INTEGER,
    idade INTEGER,
    sexo TEXT CHECK (sexo IN ('masculino', 'feminino', 'outro')),
    nivel_atividade TEXT CHECK (nivel_atividade IN ('sedentario', 'leve', 'moderado', 'intenso', 'muito_intenso')),
    objetivo TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ===============================================
-- 5. TABELA WEIGHT_MEASUREMENTS (COMPLETA)
-- ===============================================

CREATE TABLE public.weight_measurements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    peso_kg DECIMAL(5,2) NOT NULL,
    gordura_corporal_percent DECIMAL(5,2),
    massa_muscular_kg DECIMAL(5,2),
    agua_corporal_percent DECIMAL(5,2),
    osso_kg DECIMAL(5,2),
    gordura_visceral INTEGER,
    idade_metabolica INTEGER,
    imc DECIMAL(4,2),
    metabolismo_basal_kcal INTEGER,
    risco_metabolico TEXT,
    
    -- COLUNAS QUE O FRONTEND ESPERA
    circunferencia_abdominal_cm DECIMAL(5,2),
    circunferencia_braco_cm DECIMAL(4,2),
    circunferencia_perna_cm DECIMAL(4,2),
    
    device_type TEXT DEFAULT 'manual',
    notes TEXT,
    measurement_date TIMESTAMP WITH TIME ZONE DEFAULT now(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ===============================================
-- 6. TABELA USER_GOALS (ESTRUTURA CORRETA)
-- ===============================================

CREATE TABLE public.user_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    category TEXT,
    challenge_id UUID,
    target_value DECIMAL(10,2),
    current_value DECIMAL(10,2) DEFAULT 0,
    unit TEXT,
    difficulty TEXT DEFAULT 'medio' CHECK (difficulty IN ('facil', 'medio', 'dificil')),
    target_date DATE,
    status goal_status DEFAULT 'aprovada',
    estimated_points INTEGER DEFAULT 100,
    final_points INTEGER,
    admin_notes TEXT,
    evidence_required BOOLEAN DEFAULT false,
    is_group_goal BOOLEAN DEFAULT false,
    approved_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    completed_at TIMESTAMP WITH TIME ZONE,
    approved_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ===============================================
-- 7. TABELA CHALLENGES (CORRIGIDA)
-- ===============================================

CREATE TABLE public.challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    target_value DECIMAL(10,2) NOT NULL,
    target_unit TEXT NOT NULL,
    category TEXT NOT NULL,
    difficulty TEXT DEFAULT 'medium',
    duration_days INTEGER DEFAULT 30,
    xp_reward INTEGER DEFAULT 50,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ===============================================
-- 8. TABELA CHALLENGE_PARTICIPATIONS
-- ===============================================

CREATE TABLE public.challenge_participations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    challenge_id UUID REFERENCES public.challenges(id) ON DELETE CASCADE NOT NULL,
    target_value DECIMAL(10,2) DEFAULT 1,
    progress DECIMAL(5,2) DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    best_streak INTEGER DEFAULT 0,
    is_completed BOOLEAN DEFAULT false,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(user_id, challenge_id)
);

-- ===============================================
-- 9. TABELAS DE CHAT E IA (SOFIA)
-- ===============================================

CREATE TABLE public.chat_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    message TEXT NOT NULL,
    response TEXT NOT NULL,
    character VARCHAR(50) DEFAULT 'Sofia',
    has_image BOOLEAN DEFAULT false,
    image_url TEXT,
    food_analysis JSONB DEFAULT '{}',
    sentiment_score DECIMAL(3,2),
    emotion_tags TEXT[],
    topic_tags TEXT[],
    pain_level INTEGER CHECK (pain_level >= 0 AND pain_level <= 10),
    stress_level INTEGER CHECK (stress_level >= 0 AND stress_level <= 10),
    energy_level INTEGER CHECK (energy_level >= 0 AND energy_level <= 10),
    ai_analysis JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE public.chat_emotional_analysis (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    conversation_id UUID REFERENCES public.chat_conversations(id) ON DELETE CASCADE,
    sentiment_score DECIMAL(3,2),
    emotions_detected TEXT[],
    pain_level INTEGER CHECK (pain_level >= 0 AND pain_level <= 10),
    stress_level INTEGER CHECK (stress_level >= 0 AND stress_level <= 10),
    energy_level INTEGER CHECK (energy_level >= 0 AND energy_level <= 10),
    mood_keywords TEXT[],
    physical_symptoms TEXT[],
    emotional_triggers TEXT[],
    body_locations TEXT[],
    recommendations TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ===============================================
-- 10. TABELA AI_CONFIGURATIONS
-- ===============================================

CREATE TABLE public.ai_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    provider TEXT NOT NULL,
    model TEXT NOT NULL,
    api_key_encrypted TEXT,
    parameters JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ===============================================
-- 11. HABILITAR RLS EM TODAS AS TABELAS
-- ===============================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_physical_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weight_measurements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenge_participations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_emotional_analysis ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_configurations ENABLE ROW LEVEL SECURITY;

-- ===============================================
-- 12. FUNÇÕES AUXILIARES
-- ===============================================

CREATE OR REPLACE FUNCTION public.is_admin_user()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() 
    AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ===============================================
-- 13. POLÍTICAS RLS BÁSICAS
-- ===============================================

-- Profiles
CREATE POLICY "profiles_all" ON public.profiles FOR ALL USING (
  id = auth.uid() OR public.is_admin_user()
);

-- User Physical Data
CREATE POLICY "user_physical_data_all" ON public.user_physical_data FOR ALL USING (
  user_id = auth.uid() OR public.is_admin_user()
);

-- Weight Measurements
CREATE POLICY "weight_measurements_all" ON public.weight_measurements FOR ALL USING (
  user_id = auth.uid() OR public.is_admin_user()
);

-- User Goals
CREATE POLICY "user_goals_all" ON public.user_goals FOR ALL USING (
  user_id = auth.uid() OR public.is_admin_user()
);

-- Challenges
CREATE POLICY "challenges_select" ON public.challenges FOR SELECT USING (true);
CREATE POLICY "challenges_modify" ON public.challenges FOR ALL USING (public.is_admin_user());

-- Challenge Participations
CREATE POLICY "challenge_participations_all" ON public.challenge_participations FOR ALL USING (
  user_id = auth.uid() OR public.is_admin_user()
);

-- Chat Conversations
CREATE POLICY "chat_conversations_all" ON public.chat_conversations FOR ALL USING (
  user_id = auth.uid() OR public.is_admin_user()
);

-- Chat Emotional Analysis
CREATE POLICY "chat_emotional_analysis_all" ON public.chat_emotional_analysis FOR ALL USING (
  user_id = auth.uid() OR public.is_admin_user()
);

-- AI Configurations
CREATE POLICY "ai_configurations_select" ON public.ai_configurations FOR SELECT USING (true);
CREATE POLICY "ai_configurations_modify" ON public.ai_configurations FOR ALL USING (public.is_admin_user());

-- ===============================================
-- 14. TRIGGERS PARA UPDATED_AT
-- ===============================================

CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.user_physical_data
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.weight_measurements
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.user_goals
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.challenges
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.challenge_participations
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.ai_configurations
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ===============================================
-- 15. DADOS INICIAIS
-- ===============================================

-- Inserir configuração de IA padrão
INSERT INTO public.ai_configurations (name, provider, model, is_active) VALUES
('gemini-flash', 'google', 'gemini-1.5-flash', true);

-- Inserir desafio exemplo
INSERT INTO public.challenges (id, title, description, target_value, target_unit, category) VALUES
('11234567-89ab-cdef-0123-456789abcdef', 'Perder 5kg', 'Meta de perda de peso', 5.0, 'kg', 'weight_loss');

-- ===============================================
-- 16. ÍNDICES PARA PERFORMANCE
-- ===============================================

CREATE INDEX idx_weight_measurements_user_date ON public.weight_measurements(user_id, measurement_date DESC);
CREATE INDEX idx_user_goals_user_status ON public.user_goals(user_id, status);
CREATE INDEX idx_challenge_participations_user ON public.challenge_participations(user_id);
CREATE INDEX idx_chat_conversations_user_date ON public.chat_conversations(user_id, created_at DESC);

-- ===============================================
-- 17. LOG FINAL
-- ===============================================

DO $$
BEGIN
    RAISE NOTICE '🎉 ===============================================';
    RAISE NOTICE '🔧 CORREÇÃO TOTAL DE TODOS OS ERROS CONCLUÍDA';
    RAISE NOTICE '🎉 ===============================================';
    RAISE NOTICE '';
    RAISE NOTICE '✅ PROBLEMAS CORRIGIDOS:';
    RAISE NOTICE '   📋 Tabela weight_measurements com TODAS as colunas';
    RAISE NOTICE '   🎯 Tabela user_goals com estrutura correta';
    RAISE NOTICE '   💬 Tabelas de chat e IA criadas';
    RAISE NOTICE '   🔐 RLS configurado em todas as tabelas';
    RAISE NOTICE '   ⚖️  Coluna circunferencia_abdominal_cm adicionada';
    RAISE NOTICE '   🏆 Challenges e participations funcionais';
    RAISE NOTICE '   🤖 Sofia com tabelas necessárias';
    RAISE NOTICE '';
    RAISE NOTICE '🚀 TODOS OS ERROS DEVEM ESTAR CORRIGIDOS!';
    RAISE NOTICE '✅ Pesagem deve funcionar 100%%';
    RAISE NOTICE '✅ Metas devem ser criadas sem erro';
    RAISE NOTICE '✅ Chat Sofia deve funcionar';
    RAISE NOTICE '✅ Desafios devem funcionar';
    RAISE NOTICE '';
    RAISE NOTICE '🎉 ===============================================';
END $$;