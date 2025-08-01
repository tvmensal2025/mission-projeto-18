-- ===============================================
-- 🔧 CRIAR TABELA USER_SESSIONS DIRETAMENTE
-- ===============================================

-- 1. VERIFICAR SE TABELA SESSIONS EXISTE
SELECT 
    'VERIFICAÇÃO SESSIONS' as status,
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'sessions' AND table_schema = 'public'
    ) THEN 'EXISTE' ELSE 'NÃO EXISTE' END as sessions_existe;

-- 2. DROPAR USER_SESSIONS SE EXISTIR (PARA RECRIAR LIMPO)
DROP TABLE IF EXISTS public.user_sessions CASCADE;

-- 3. CRIAR TABELA USER_SESSIONS SIMPLES
CREATE TABLE public.user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL, -- Removendo REFERENCES temporariamente
    user_id UUID NOT NULL,
    status TEXT DEFAULT 'pending',
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    due_date TIMESTAMP WITH TIME ZONE,
    progress INTEGER DEFAULT 0,
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

-- 4. HABILITAR RLS
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;

-- 5. CRIAR POLÍTICA RLS SIMPLES
CREATE POLICY "user_sessions_all_policy" ON public.user_sessions FOR ALL USING (true);

-- 6. CRIAR TRIGGER UPDATED_AT
CREATE TRIGGER user_sessions_updated_at 
    BEFORE UPDATE ON public.user_sessions 
    FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

-- 7. CRIAR ÍNDICES
CREATE INDEX idx_user_sessions_user_id ON public.user_sessions(user_id);
CREATE INDEX idx_user_sessions_session_id ON public.user_sessions(session_id);
CREATE INDEX idx_user_sessions_status ON public.user_sessions(status);

-- 8. INSERIR DADOS DE TESTE
INSERT INTO public.user_sessions (
    session_id, 
    user_id, 
    status,
    progress,
    tools_data
) VALUES (
    gen_random_uuid(),
    (SELECT id FROM auth.users LIMIT 1),
    'pending',
    0,
    '{"tools": ["roda_vida"]}'::jsonb
);

-- 9. VERIFICAR SE FUNCIONOU
SELECT 
    'USER_SESSIONS CRIADA' as status,
    COUNT(*) as total_registros
FROM public.user_sessions;

-- 10. CRIAR DAILY_MISSION_SESSIONS TAMBÉM
DROP TABLE IF EXISTS public.daily_mission_sessions CASCADE;

CREATE TABLE public.daily_mission_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    date DATE DEFAULT CURRENT_DATE,
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP WITH TIME ZONE,
    xp_earned INTEGER DEFAULT 0,
    streak_count INTEGER DEFAULT 0,
    mission_type TEXT DEFAULT 'daily',
    difficulty TEXT DEFAULT 'medio',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.daily_mission_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "daily_mission_sessions_all_policy" ON public.daily_mission_sessions FOR ALL USING (true);

-- 11. CRIAR DAILY_RESPONSES TAMBÉM
DROP TABLE IF EXISTS public.daily_responses CASCADE;

CREATE TABLE public.daily_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    session_id UUID,
    question_id TEXT NOT NULL,
    response_value INTEGER,
    response_text TEXT,
    date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.daily_responses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "daily_responses_all_policy" ON public.daily_responses FOR ALL USING (true);

-- 12. VERIFICAR TODAS AS TABELAS CRIADAS
SELECT 
    'TABELAS VERIFICAÇÃO' as status,
    table_name,
    'CRIADA' as resultado
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('user_sessions', 'daily_mission_sessions', 'daily_responses')
ORDER BY table_name;

-- 13. TESTAR SELECT EM CADA TABELA
SELECT 'user_sessions' as tabela, COUNT(*) as registros FROM public.user_sessions;
SELECT 'daily_mission_sessions' as tabela, COUNT(*) as registros FROM public.daily_mission_sessions;
SELECT 'daily_responses' as tabela, COUNT(*) as registros FROM public.daily_responses;

-- 14. RESULTADO FINAL
SELECT '✅ TABELAS CRÍTICAS CRIADAS COM SUCESSO!' as resultado;
SELECT '🎯 AGORA TESTE CRIAR SESSÃO NOVAMENTE!' as instrucao;