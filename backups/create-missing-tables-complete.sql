-- ===============================================
-- 🔧 CRIAÇÃO DE TODAS AS TABELAS NECESSÁRIAS
-- ===============================================
-- Baseado na análise completa do código frontend

-- 1. TABELA AI_CONFIGURATIONS (já criada anteriormente)
-- Esta já foi criada no script anterior

-- 2. TABELA DAILY_MISSION_SESSIONS
CREATE TABLE IF NOT EXISTS public.daily_mission_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    is_completed BOOLEAN DEFAULT false,
    questions_answered INTEGER DEFAULT 0,
    total_questions INTEGER DEFAULT 10,
    score INTEGER DEFAULT 0,
    session_data JSONB DEFAULT '{}',
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(user_id, date)
);

-- 3. TABELA DAILY_RESPONSES
CREATE TABLE IF NOT EXISTS public.daily_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES public.daily_mission_sessions(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    question_id TEXT NOT NULL,
    question_text TEXT NOT NULL,
    response TEXT NOT NULL,
    category TEXT,
    points INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 4. TABELA CUSTOM_SABOTEURS
CREATE TABLE IF NOT EXISTS public.custom_saboteurs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT DEFAULT 'personalizado',
    trigger_situations TEXT[],
    coping_strategies TEXT[],
    severity_level INTEGER DEFAULT 1 CHECK (severity_level >= 1 AND severity_level <= 5),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 5. TABELA SESSIONS (para funcionalidades administrativas)
CREATE TABLE IF NOT EXISTS public.sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    session_type TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'completed', 'cancelled')),
    is_active BOOLEAN DEFAULT true,
    session_data JSONB DEFAULT '{}',
    started_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    ended_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 6. TABELA WATER_TRACKING
CREATE TABLE IF NOT EXISTS public.water_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    glasses_consumed INTEGER DEFAULT 0 CHECK (glasses_consumed >= 0),
    ml_consumed INTEGER DEFAULT 0 CHECK (ml_consumed >= 0),
    target_glasses INTEGER DEFAULT 8,
    target_ml INTEGER DEFAULT 2000,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(user_id, date)
);

-- 7. TABELA SLEEP_TRACKING
CREATE TABLE IF NOT EXISTS public.sleep_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    bedtime TIME,
    wake_time TIME,
    hours_slept DECIMAL(3,1),
    sleep_quality INTEGER CHECK (sleep_quality >= 1 AND sleep_quality <= 5),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(user_id, date)
);

-- 8. TABELA MOOD_TRACKING
CREATE TABLE IF NOT EXISTS public.mood_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    energy_level INTEGER CHECK (energy_level >= 1 AND energy_level <= 5),
    stress_level INTEGER CHECK (stress_level >= 1 AND stress_level <= 5),
    mood_level INTEGER CHECK (mood_level >= 1 AND mood_level <= 5),
    gratitude_note TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(user_id, date)
);

-- 9. HABILITAR RLS EM TODAS AS TABELAS
ALTER TABLE public.daily_mission_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.custom_saboteurs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.water_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sleep_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mood_tracking ENABLE ROW LEVEL SECURITY;

-- 10. CRIAR POLÍTICAS RLS
-- Daily Mission Sessions
DROP POLICY IF EXISTS "daily_mission_sessions_policy" ON public.daily_mission_sessions;
CREATE POLICY "daily_mission_sessions_policy" ON public.daily_mission_sessions 
FOR ALL USING (user_id = auth.uid() OR public.is_admin_user());

-- Daily Responses
DROP POLICY IF EXISTS "daily_responses_policy" ON public.daily_responses;
CREATE POLICY "daily_responses_policy" ON public.daily_responses 
FOR ALL USING (user_id = auth.uid() OR public.is_admin_user());

-- Custom Saboteurs
DROP POLICY IF EXISTS "custom_saboteurs_policy" ON public.custom_saboteurs;
CREATE POLICY "custom_saboteurs_policy" ON public.custom_saboteurs 
FOR ALL USING (user_id = auth.uid() OR public.is_admin_user());

-- Sessions
DROP POLICY IF EXISTS "sessions_policy" ON public.sessions;
CREATE POLICY "sessions_policy" ON public.sessions 
FOR ALL USING (user_id = auth.uid() OR public.is_admin_user());

-- Water Tracking
DROP POLICY IF EXISTS "water_tracking_policy" ON public.water_tracking;
CREATE POLICY "water_tracking_policy" ON public.water_tracking 
FOR ALL USING (user_id = auth.uid() OR public.is_admin_user());

-- Sleep Tracking
DROP POLICY IF EXISTS "sleep_tracking_policy" ON public.sleep_tracking;
CREATE POLICY "sleep_tracking_policy" ON public.sleep_tracking 
FOR ALL USING (user_id = auth.uid() OR public.is_admin_user());

-- Mood Tracking
DROP POLICY IF EXISTS "mood_tracking_policy" ON public.mood_tracking;
CREATE POLICY "mood_tracking_policy" ON public.mood_tracking 
FOR ALL USING (user_id = auth.uid() OR public.is_admin_user());

-- 11. CRIAR TRIGGERS PARA UPDATED_AT
DROP TRIGGER IF EXISTS handle_updated_at ON public.daily_mission_sessions;
CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.daily_mission_sessions
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS handle_updated_at ON public.custom_saboteurs;
CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.custom_saboteurs
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS handle_updated_at ON public.sessions;
CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.sessions
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS handle_updated_at ON public.water_tracking;
CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.water_tracking
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS handle_updated_at ON public.sleep_tracking;
CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.sleep_tracking
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS handle_updated_at ON public.mood_tracking;
CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.mood_tracking
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 12. CRIAR ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_daily_mission_sessions_user_date 
    ON public.daily_mission_sessions(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_daily_responses_session 
    ON public.daily_responses(session_id);
CREATE INDEX IF NOT EXISTS idx_custom_saboteurs_user 
    ON public.custom_saboteurs(user_id) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_sessions_user_active 
    ON public.sessions(user_id) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_water_tracking_user_date 
    ON public.water_tracking(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_sleep_tracking_user_date 
    ON public.sleep_tracking(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_mood_tracking_user_date 
    ON public.mood_tracking(user_id, date DESC);

-- 13. INSERIR DADOS DE EXEMPLO PARA TESTE
DO $$
DECLARE
    test_user_id UUID;
BEGIN
    -- Buscar um usuário existente ou usar um ID de teste
    SELECT id INTO test_user_id FROM auth.users LIMIT 1;
    
    IF test_user_id IS NULL THEN
        -- Se não há usuários, criar dados com UUID fictício para estrutura
        test_user_id := gen_random_uuid();
    END IF;
    
    -- Inserir sessão de missão diária de exemplo
    INSERT INTO public.daily_mission_sessions (user_id, date, is_completed, questions_answered, total_questions)
    VALUES (test_user_id, CURRENT_DATE, true, 8, 10)
    ON CONFLICT (user_id, date) DO NOTHING;
    
    -- Inserir tracking de água de exemplo
    INSERT INTO public.water_tracking (user_id, date, glasses_consumed, ml_consumed)
    VALUES (test_user_id, CURRENT_DATE, 6, 1500)
    ON CONFLICT (user_id, date) DO NOTHING;
    
    RAISE NOTICE '✅ Dados de exemplo inseridos para usuário: %', test_user_id;
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '⚠️ Não foi possível inserir dados de exemplo: %', SQLERRM;
END $$;

-- 14. VERIFICAÇÃO FINAL
SELECT 
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name AND table_schema = 'public') as columns_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
AND table_name IN (
    'ai_configurations',
    'daily_mission_sessions',
    'daily_responses', 
    'custom_saboteurs',
    'sessions',
    'water_tracking',
    'sleep_tracking',
    'mood_tracking'
)
ORDER BY table_name;

-- 15. RESULTADO
SELECT '🎉 TODAS AS TABELAS NECESSÁRIAS CRIADAS COM SUCESSO!' as status;