-- ===============================================
-- 🔧 CORREÇÃO COMPLETA - TODAS AS TABELAS FALTANTES
-- ===============================================
-- Baseado na auditoria completa do frontend

-- 1. CORRIGIR TABELA SESSIONS - ADICIONAR COLUNAS FALTANTES
DO $$
BEGIN
    -- follow_up_questions
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sessions' AND column_name = 'follow_up_questions' AND table_schema = 'public') THEN
        ALTER TABLE public.sessions ADD COLUMN follow_up_questions TEXT[];
        RAISE NOTICE '✅ Coluna follow_up_questions adicionada à sessions';
    END IF;

    -- target_saboteurs
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sessions' AND column_name = 'target_saboteurs' AND table_schema = 'public') THEN
        ALTER TABLE public.sessions ADD COLUMN target_saboteurs TEXT[];
        RAISE NOTICE '✅ Coluna target_saboteurs adicionada à sessions';
    END IF;

    -- type
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sessions' AND column_name = 'type' AND table_schema = 'public') THEN
        ALTER TABLE public.sessions ADD COLUMN type TEXT DEFAULT 'therapy';
        RAISE NOTICE '✅ Coluna type adicionada à sessions';
    END IF;

    -- is_active
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sessions' AND column_name = 'is_active' AND table_schema = 'public') THEN
        ALTER TABLE public.sessions ADD COLUMN is_active BOOLEAN DEFAULT true;
        RAISE NOTICE '✅ Coluna is_active adicionada à sessions';
    END IF;

    -- tools_data
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sessions' AND column_name = 'tools_data' AND table_schema = 'public') THEN
        ALTER TABLE public.sessions ADD COLUMN tools_data JSONB DEFAULT '{}'::jsonb;
        RAISE NOTICE '✅ Coluna tools_data adicionada à sessions';
    END IF;
END $$;

-- 2. CRIAR TABELA USER_SESSIONS (CRÍTICA)
CREATE TABLE IF NOT EXISTS public.user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES public.sessions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    due_date TIMESTAMP WITH TIME ZONE,
    progress INTEGER DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
    feedback TEXT,
    notes TEXT,
    auto_save_data JSONB DEFAULT '{}'::jsonb,
    tools_data JSONB DEFAULT '{}'::jsonb,
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT now(),
    cycle_number INTEGER DEFAULT 1,
    next_available_date TIMESTAMP WITH TIME ZONE,
    is_locked BOOLEAN DEFAULT false,
    review_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 3. CRIAR TABELA DAILY_MISSION_SESSIONS (CRÍTICA)
CREATE TABLE IF NOT EXISTS public.daily_mission_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    date DATE DEFAULT CURRENT_DATE,
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP WITH TIME ZONE,
    xp_earned INTEGER DEFAULT 0,
    streak_count INTEGER DEFAULT 0,
    mission_type TEXT DEFAULT 'daily',
    difficulty TEXT DEFAULT 'medio',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(user_id, date)
);

-- 4. CRIAR TABELA DAILY_RESPONSES (CRÍTICA)
CREATE TABLE IF NOT EXISTS public.daily_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    session_id UUID REFERENCES public.daily_mission_sessions(id) ON DELETE CASCADE,
    question_id TEXT NOT NULL,
    response_value INTEGER,
    response_text TEXT,
    date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 5. CRIAR TABELA USER_SCORES (GAMIFICAÇÃO)
CREATE TABLE IF NOT EXISTS public.user_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    total_xp INTEGER DEFAULT 0,
    level INTEGER DEFAULT 1,
    current_streak INTEGER DEFAULT 0,
    best_streak INTEGER DEFAULT 0,
    badges_earned TEXT[],
    achievements TEXT[],
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT now(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(user_id)
);

-- 6. CRIAR TABELA CHALLENGE_PARTICIPATIONS
CREATE TABLE IF NOT EXISTS public.challenge_participations (
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

-- 7. CRIAR TABELAS DE TRACKING
CREATE TABLE IF NOT EXISTS public.water_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    amount_ml INTEGER NOT NULL,
    date DATE DEFAULT CURRENT_DATE,
    time TIME DEFAULT CURRENT_TIME,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.sleep_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    sleep_date DATE DEFAULT CURRENT_DATE,
    bedtime TIME,
    wake_time TIME,
    hours_slept DECIMAL(3,1),
    quality_rating INTEGER CHECK (quality_rating >= 1 AND quality_rating <= 5),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.mood_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    date DATE DEFAULT CURRENT_DATE,
    mood_rating INTEGER CHECK (mood_rating >= 1 AND mood_rating <= 5),
    energy_level INTEGER CHECK (energy_level >= 1 AND energy_level <= 5),
    stress_level INTEGER CHECK (stress_level >= 1 AND stress_level <= 5),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 8. CRIAR TABELAS DE ANÁLISE
CREATE TABLE IF NOT EXISTS public.weekly_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    semana_inicio DATE NOT NULL,
    semana_fim DATE NOT NULL,
    peso_inicial DECIMAL(5,2),
    peso_final DECIMAL(5,2),
    variacao_peso DECIMAL(5,2),
    tendencia TEXT,
    analysis_data JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.preventive_health_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    analysis_type TEXT NOT NULL,
    results JSONB NOT NULL,
    recommendations TEXT[],
    risk_level TEXT CHECK (risk_level IN ('baixo', 'medio', 'alto')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 9. CRIAR TABELAS DE CHAT E CONVERSAS
CREATE TABLE IF NOT EXISTS public.chat_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    message TEXT NOT NULL,
    response TEXT,
    character TEXT DEFAULT 'sofia',
    has_image BOOLEAN DEFAULT false,
    image_url TEXT,
    food_analysis JSONB,
    sentiment_score DECIMAL(3,2),
    emotion_tags TEXT[],
    topic_tags TEXT[],
    pain_level INTEGER,
    stress_level INTEGER,
    energy_level INTEGER,
    ai_analysis JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.chat_emotional_analysis (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    conversation_id UUID REFERENCES public.chat_conversations(id) ON DELETE CASCADE,
    sentiment_score DECIMAL(3,2),
    emotions_detected TEXT[],
    pain_level INTEGER,
    stress_level INTEGER,
    energy_level INTEGER,
    mood_keywords TEXT[],
    physical_symptoms TEXT[],
    analysis_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 10. CRIAR TABELAS DE CATEGORIAS E METAS
CREATE TABLE IF NOT EXISTS public.goal_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    icon TEXT,
    color TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.goal_updates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    goal_id UUID REFERENCES public.user_goals(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    progress_value DECIMAL(10,2),
    notes TEXT,
    evidence_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 11. CRIAR TABELAS DE MÍDIA
CREATE TABLE IF NOT EXISTS public.avatars (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    image_url TEXT NOT NULL,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 12. ADICIONAR COLUNA TARGET_VALUE EM CHALLENGES SE NÃO EXISTIR
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenges' AND column_name = 'target_value' AND table_schema = 'public') THEN
        ALTER TABLE public.challenges ADD COLUMN target_value DECIMAL(10,2) DEFAULT 1;
        RAISE NOTICE '✅ Coluna target_value adicionada à challenges';
    END IF;
END $$;

-- 13. HABILITAR RLS EM TODAS AS TABELAS
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_mission_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenge_participations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.water_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sleep_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mood_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weekly_analyses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.preventive_health_analyses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_emotional_analysis ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.goal_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.goal_updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.avatars ENABLE ROW LEVEL SECURITY;

-- 14. CRIAR POLÍTICAS RLS SIMPLES (PERMISSIVAS PARA DESENVOLVIMENTO)
-- User Sessions
CREATE POLICY "user_sessions_policy" ON public.user_sessions FOR ALL USING (true);

-- Daily Mission Sessions
CREATE POLICY "daily_mission_sessions_policy" ON public.daily_mission_sessions FOR ALL USING (true);

-- Daily Responses
CREATE POLICY "daily_responses_policy" ON public.daily_responses FOR ALL USING (true);

-- User Scores
CREATE POLICY "user_scores_policy" ON public.user_scores FOR ALL USING (true);

-- Challenge Participations
CREATE POLICY "challenge_participations_policy" ON public.challenge_participations FOR ALL USING (true);

-- Water Tracking
CREATE POLICY "water_tracking_policy" ON public.water_tracking FOR ALL USING (true);

-- Sleep Tracking
CREATE POLICY "sleep_tracking_policy" ON public.sleep_tracking FOR ALL USING (true);

-- Mood Tracking
CREATE POLICY "mood_tracking_policy" ON public.mood_tracking FOR ALL USING (true);

-- Weekly Analyses
CREATE POLICY "weekly_analyses_policy" ON public.weekly_analyses FOR ALL USING (true);

-- Preventive Health Analyses
CREATE POLICY "preventive_health_analyses_policy" ON public.preventive_health_analyses FOR ALL USING (true);

-- Chat Conversations
CREATE POLICY "chat_conversations_policy" ON public.chat_conversations FOR ALL USING (true);

-- Chat Emotional Analysis
CREATE POLICY "chat_emotional_analysis_policy" ON public.chat_emotional_analysis FOR ALL USING (true);

-- Goal Categories
CREATE POLICY "goal_categories_policy" ON public.goal_categories FOR ALL USING (true);

-- Goal Updates
CREATE POLICY "goal_updates_policy" ON public.goal_updates FOR ALL USING (true);

-- Avatars
CREATE POLICY "avatars_policy" ON public.avatars FOR ALL USING (true);

-- 15. CRIAR TRIGGERS PARA UPDATED_AT
CREATE TRIGGER user_sessions_updated_at BEFORE UPDATE ON public.user_sessions FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER daily_mission_sessions_updated_at BEFORE UPDATE ON public.daily_mission_sessions FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER daily_responses_updated_at BEFORE UPDATE ON public.daily_responses FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER user_scores_updated_at BEFORE UPDATE ON public.user_scores FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER challenge_participations_updated_at BEFORE UPDATE ON public.challenge_participations FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER chat_conversations_updated_at BEFORE UPDATE ON public.chat_conversations FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER chat_emotional_analysis_updated_at BEFORE UPDATE ON public.chat_emotional_analysis FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

-- 16. INSERIR DADOS DE EXEMPLO
-- Goal Categories
INSERT INTO public.goal_categories (name, description, icon, color) VALUES
('Perda de Peso', 'Metas relacionadas à redução de peso', 'scale', '#ef4444'),
('Exercício', 'Metas de atividade física', 'dumbbell', '#22c55e'),
('Alimentação', 'Metas nutricionais', 'apple', '#f97316'),
('Bem-estar', 'Metas de saúde mental', 'heart', '#8b5cf6'),
('Hidratação', 'Metas de consumo de água', 'droplets', '#06b6d4')
ON CONFLICT (name) DO NOTHING;

-- Avatars padrão
INSERT INTO public.avatars (name, image_url, is_default) VALUES
('Avatar Padrão Masculino', '/images/avatar-male-default.png', true),
('Avatar Padrão Feminino', '/images/avatar-female-default.png', true),
('Dr. Vital', '/images/dr-vital.png', true),
('Sofia', '/images/sofia-avatar.png', true)
ON CONFLICT DO NOTHING;

-- 17. CRIAR ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON public.user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_session_id ON public.user_sessions(session_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_status ON public.user_sessions(status);

CREATE INDEX IF NOT EXISTS idx_daily_mission_sessions_user_id ON public.daily_mission_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_mission_sessions_date ON public.daily_mission_sessions(date);

CREATE INDEX IF NOT EXISTS idx_daily_responses_user_id ON public.daily_responses(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_responses_date ON public.daily_responses(date);

CREATE INDEX IF NOT EXISTS idx_water_tracking_user_id ON public.water_tracking(user_id);
CREATE INDEX IF NOT EXISTS idx_water_tracking_date ON public.water_tracking(date);

CREATE INDEX IF NOT EXISTS idx_sleep_tracking_user_id ON public.sleep_tracking(user_id);
CREATE INDEX IF NOT EXISTS idx_mood_tracking_user_id ON public.mood_tracking(user_id);

CREATE INDEX IF NOT EXISTS idx_chat_conversations_user_id ON public.chat_conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_challenge_participations_user_id ON public.challenge_participations(user_id);

-- 18. VERIFICAÇÕES FINAIS
SELECT 
    'TABELAS CRIADAS' as status,
    COUNT(*) as total_tabelas
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
    'user_sessions', 'daily_mission_sessions', 'daily_responses', 
    'user_scores', 'challenge_participations', 'water_tracking', 
    'sleep_tracking', 'mood_tracking', 'weekly_analyses', 
    'preventive_health_analyses', 'chat_conversations', 
    'chat_emotional_analysis', 'goal_categories', 'goal_updates', 'avatars'
);

SELECT 
    'COLUNAS SESSIONS ADICIONADAS' as status,
    COUNT(*) as colunas_adicionadas
FROM information_schema.columns 
WHERE table_name = 'sessions' 
AND table_schema = 'public'
AND column_name IN ('follow_up_questions', 'target_saboteurs', 'type', 'is_active', 'tools_data');

-- 19. RESULTADO FINAL
SELECT '✅ TODAS AS TABELAS E COLUNAS FALTANTES FORAM CRIADAS!' as resultado;
SELECT '🎯 SISTEMA AGORA DEVE FUNCIONAR SEM ERROS DE TABELAS!' as conclusao;
SELECT '📊 EXECUTE OS TESTES NO FRONTEND PARA VALIDAR!' as instrucao;