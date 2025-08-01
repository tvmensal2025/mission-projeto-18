-- ===============================================
-- 🚨 CORREÇÃO TELA PRETA - EMERGENCIAL
-- ===============================================

-- 1. DROPAR E RECRIAR USER_SESSIONS COM FOREIGN KEY CORRETO
DROP TABLE IF EXISTS public.user_sessions CASCADE;

CREATE TABLE public.user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID,
    user_id UUID,
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

-- 2. HABILITAR RLS
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "user_sessions_policy" ON public.user_sessions FOR ALL USING (true);

-- 3. CORRIGIR PROFILES - GARANTIR QUE USER_ID EXISTE
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS user_id UUID;
UPDATE public.profiles SET user_id = id WHERE user_id IS NULL;

-- 4. CORRIGIR SESSIONS - ADICIONAR COLUNAS FALTANTES
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS follow_up_questions TEXT[] DEFAULT ARRAY[]::TEXT[];
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS target_saboteurs TEXT[] DEFAULT ARRAY[]::TEXT[];
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS type TEXT DEFAULT 'therapy';
ALTER TABLE public.sessions ADD COLUMN IF NOT EXISTS tools_data JSONB DEFAULT '{}'::jsonb;

-- 5. ATUALIZAR DADOS EXISTENTES
UPDATE public.sessions SET 
    is_active = true,
    follow_up_questions = ARRAY['Como você se sentiu?'],
    target_saboteurs = ARRAY['perfeccionista'],
    type = 'therapy',
    tools_data = '{}'::jsonb
WHERE is_active IS NULL;

-- 6. CRIAR TABELAS FALTANTES SIMPLES
CREATE TABLE IF NOT EXISTS public.user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    role TEXT DEFAULT 'user',
    is_active BOOLEAN DEFAULT true,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.user_missions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    mission_id UUID,
    is_completed BOOLEAN DEFAULT false,
    date_assigned DATE DEFAULT CURRENT_DATE
);

-- 7. HABILITAR RLS NAS NOVAS TABELAS
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_missions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "user_roles_policy" ON public.user_roles FOR ALL USING (true);
CREATE POLICY "user_missions_policy" ON public.user_missions FOR ALL USING (true);

-- 8. INSERIR DADOS BÁSICOS
INSERT INTO public.user_roles (user_id, role) 
SELECT id, 'admin' FROM auth.users LIMIT 1
ON CONFLICT DO NOTHING;

-- 9. VERIFICAR SE TUDO ESTÁ OK
SELECT 'TABELAS VERIFICAÇÃO:' as status;
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name IN ('user_sessions', 'user_roles', 'user_missions');

SELECT 'COLUNAS SESSIONS:' as status;
SELECT column_name FROM information_schema.columns WHERE table_name = 'sessions' AND column_name IN ('is_active', 'type', 'follow_up_questions');

SELECT 'COLUNAS PROFILES:' as status;
SELECT column_name FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'user_id';

-- 10. RESULTADO
SELECT '✅ CORREÇÃO TELA PRETA APLICADA!' as resultado;