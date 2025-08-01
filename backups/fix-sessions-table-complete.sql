-- ===============================================
-- 🚨 CORREÇÃO COMPLETA - TABELA SESSIONS
-- ===============================================

-- 1. VERIFICAR ESTRUTURA ATUAL
SELECT 'ESTRUTURA ATUAL' as info, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'sessions' AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. ADICIONAR COLUNAS FALTANTES UMA POR VEZ
DO $$
BEGIN
    -- follow_up_questions
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sessions' AND column_name = 'follow_up_questions') THEN
        ALTER TABLE public.sessions ADD COLUMN follow_up_questions TEXT[] DEFAULT ARRAY[]::TEXT[];
        RAISE NOTICE '✅ Coluna follow_up_questions adicionada';
    ELSE
        RAISE NOTICE '⚠️ Coluna follow_up_questions já existe';
    END IF;

    -- target_saboteurs
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sessions' AND column_name = 'target_saboteurs') THEN
        ALTER TABLE public.sessions ADD COLUMN target_saboteurs TEXT[] DEFAULT ARRAY[]::TEXT[];
        RAISE NOTICE '✅ Coluna target_saboteurs adicionada';
    ELSE
        RAISE NOTICE '⚠️ Coluna target_saboteurs já existe';
    END IF;

    -- materials_needed
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sessions' AND column_name = 'materials_needed') THEN
        ALTER TABLE public.sessions ADD COLUMN materials_needed TEXT[] DEFAULT ARRAY[]::TEXT[];
        RAISE NOTICE '✅ Coluna materials_needed adicionada';
    ELSE
        RAISE NOTICE '⚠️ Coluna materials_needed já existe';
    END IF;

    -- type (diferente de session_type)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sessions' AND column_name = 'type') THEN
        ALTER TABLE public.sessions ADD COLUMN type VARCHAR(50) DEFAULT 'saboteur_work';
        RAISE NOTICE '✅ Coluna type adicionada';
    ELSE
        RAISE NOTICE '⚠️ Coluna type já existe';
    END IF;

    -- estimated_time
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sessions' AND column_name = 'estimated_time') THEN
        ALTER TABLE public.sessions ADD COLUMN estimated_time INTEGER DEFAULT 30;
        RAISE NOTICE '✅ Coluna estimated_time adicionada';
    ELSE
        RAISE NOTICE '⚠️ Coluna estimated_time já existe';
    END IF;

    -- is_active
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sessions' AND column_name = 'is_active') THEN
        ALTER TABLE public.sessions ADD COLUMN is_active BOOLEAN DEFAULT true;
        RAISE NOTICE '✅ Coluna is_active adicionada';
    ELSE
        RAISE NOTICE '⚠️ Coluna is_active já existe';
    END IF;

    -- tools_data
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sessions' AND column_name = 'tools_data') THEN
        ALTER TABLE public.sessions ADD COLUMN tools_data JSONB DEFAULT '{}'::JSONB;
        RAISE NOTICE '✅ Coluna tools_data adicionada';
    ELSE
        RAISE NOTICE '⚠️ Coluna tools_data já existe';
    END IF;

EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ ERRO: %', SQLERRM;
END $$;

-- 3. ATUALIZAR VALORES EXISTENTES SE NECESSÁRIO
UPDATE public.sessions 
SET 
    follow_up_questions = COALESCE(follow_up_questions, ARRAY[]::TEXT[]),
    target_saboteurs = COALESCE(target_saboteurs, ARRAY[]::TEXT[]),
    materials_needed = COALESCE(materials_needed, ARRAY[]::TEXT[]),
    type = COALESCE(type, 'saboteur_work'),
    estimated_time = COALESCE(estimated_time, 30),
    is_active = COALESCE(is_active, true),
    tools_data = COALESCE(tools_data, '{}'::JSONB)
WHERE id IS NOT NULL;

-- 4. VERIFICAR TABELA USER_SESSIONS
CREATE TABLE IF NOT EXISTS public.user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    session_id UUID REFERENCES public.sessions(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending',
    progress INTEGER DEFAULT 0,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    due_date TIMESTAMPTZ,
    notes TEXT,
    feedback JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, session_id)
);

-- 5. HABILITAR RLS
ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;

-- 6. POLÍTICAS RLS PARA SESSIONS
DROP POLICY IF EXISTS "sessions_select_policy" ON public.sessions;
CREATE POLICY "sessions_select_policy" ON public.sessions
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "sessions_insert_policy" ON public.sessions;
CREATE POLICY "sessions_insert_policy" ON public.sessions
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "sessions_update_policy" ON public.sessions;
CREATE POLICY "sessions_update_policy" ON public.sessions
    FOR UPDATE USING (true);

DROP POLICY IF EXISTS "sessions_delete_policy" ON public.sessions;
CREATE POLICY "sessions_delete_policy" ON public.sessions
    FOR DELETE USING (true);

-- 7. POLÍTICAS RLS PARA USER_SESSIONS
DROP POLICY IF EXISTS "user_sessions_select_policy" ON public.user_sessions;
CREATE POLICY "user_sessions_select_policy" ON public.user_sessions
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "user_sessions_insert_policy" ON public.user_sessions;
CREATE POLICY "user_sessions_insert_policy" ON public.user_sessions
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "user_sessions_update_policy" ON public.user_sessions;
CREATE POLICY "user_sessions_update_policy" ON public.user_sessions
    FOR UPDATE USING (true);

DROP POLICY IF EXISTS "user_sessions_delete_policy" ON public.user_sessions;
CREATE POLICY "user_sessions_delete_policy" ON public.user_sessions
    FOR DELETE USING (true);

-- 8. TESTE FINAL
DO $$
DECLARE
    test_user_id UUID;
    new_session_id UUID;
BEGIN
    -- Pegar um usuário existente
    SELECT id INTO test_user_id FROM auth.users LIMIT 1;
    
    IF test_user_id IS NULL THEN
        RAISE NOTICE '❌ Nenhum usuário encontrado';
        RETURN;
    END IF;
    
    -- Tentar inserir uma sessão de teste
    INSERT INTO public.sessions (
        title,
        description,
        content,
        type,
        difficulty,
        estimated_time,
        follow_up_questions,
        target_saboteurs,
        materials_needed,
        is_active,
        tools_data,
        created_by
    ) VALUES (
        'Teste Correção',
        'Sessão de teste pós-correção',
        '{"test": true}'::jsonb,
        'saboteur_work',
        'beginner',
        30,
        ARRAY['Como foi a experiência?'],
        ARRAY['perfeccionista'],
        ARRAY['papel', 'caneta'],
        true,
        '{}'::jsonb,
        test_user_id
    ) RETURNING id INTO new_session_id;
    
    RAISE NOTICE '✅ TESTE PASSOU! Sessão criada: %', new_session_id;
    
    -- Limpar o teste
    DELETE FROM public.sessions WHERE id = new_session_id;
    RAISE NOTICE '🧹 Teste limpo';
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ TESTE FALHOU: %', SQLERRM;
END $$;

-- 9. RESULTADO FINAL
SELECT 
    'CORREÇÃO COMPLETA!' as status,
    COUNT(*) as total_sessions,
    ARRAY_AGG(DISTINCT column_name ORDER BY column_name) as colunas_disponiveis
FROM public.sessions, information_schema.columns 
WHERE table_name = 'sessions' AND table_schema = 'public'
GROUP BY 1;