-- ===============================================
-- 🚨 CORREÇÃO EMERGENCIAL - RESOLVER TODOS OS ERROS
-- ===============================================

-- 1. ADICIONAR FOREIGN KEY EM USER_SESSIONS
DO $$
BEGIN
    -- Verificar se a constraint já existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'user_sessions_session_id_fkey' 
        AND table_name = 'user_sessions'
    ) THEN
        -- Adicionar foreign key constraint
        ALTER TABLE public.user_sessions 
        ADD CONSTRAINT user_sessions_session_id_fkey 
        FOREIGN KEY (session_id) REFERENCES public.sessions(id) ON DELETE CASCADE;
        RAISE NOTICE '✅ Foreign key user_sessions -> sessions adicionada';
    END IF;
    
    -- Adicionar foreign key para user_id também
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'user_sessions_user_id_fkey' 
        AND table_name = 'user_sessions'
    ) THEN
        ALTER TABLE public.user_sessions 
        ADD CONSTRAINT user_sessions_user_id_fkey 
        FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
        RAISE NOTICE '✅ Foreign key user_sessions -> auth.users adicionada';
    END IF;
END $$;

-- 2. ADICIONAR COLUNAS FALTANTES EM SESSIONS (SE NÃO EXISTIREM)
DO $$
BEGIN
    -- is_active
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sessions' AND column_name = 'is_active' AND table_schema = 'public') THEN
        ALTER TABLE public.sessions ADD COLUMN is_active BOOLEAN DEFAULT true;
        RAISE NOTICE '✅ Coluna is_active adicionada à sessions';
    END IF;
    
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
    
    -- tools_data
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sessions' AND column_name = 'tools_data' AND table_schema = 'public') THEN
        ALTER TABLE public.sessions ADD COLUMN tools_data JSONB DEFAULT '{}'::jsonb;
        RAISE NOTICE '✅ Coluna tools_data adicionada à sessions';
    END IF;
END $$;

-- 3. ADICIONAR COLUNA USER_ID EM PROFILES (SE NÃO EXISTIR)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'user_id' AND table_schema = 'public') THEN
        ALTER TABLE public.profiles ADD COLUMN user_id UUID;
        -- Copiar valores de id para user_id para compatibilidade
        UPDATE public.profiles SET user_id = id WHERE user_id IS NULL;
        RAISE NOTICE '✅ Coluna user_id adicionada à profiles';
    END IF;
    
    -- Adicionar role se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'role' AND table_schema = 'public') THEN
        ALTER TABLE public.profiles ADD COLUMN role TEXT DEFAULT 'user';
        RAISE NOTICE '✅ Coluna role adicionada à profiles';
    END IF;
END $$;

-- 4. CRIAR TABELA USER_ROLES
CREATE TABLE IF NOT EXISTS public.user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    role TEXT NOT NULL DEFAULT 'user',
    is_active BOOLEAN DEFAULT true,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 5. CRIAR TABELA USER_MISSIONS
CREATE TABLE IF NOT EXISTS public.user_missions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    mission_id UUID,
    is_completed BOOLEAN DEFAULT false,
    date_assigned DATE DEFAULT CURRENT_DATE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 6. HABILITAR RLS NAS NOVAS TABELAS
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_missions ENABLE ROW LEVEL SECURITY;

-- 7. CRIAR POLÍTICAS RLS SIMPLES
CREATE POLICY "user_roles_policy" ON public.user_roles FOR ALL USING (true);
CREATE POLICY "user_missions_policy" ON public.user_missions FOR ALL USING (true);

-- 8. INSERIR DADOS DE EXEMPLO PARA EVITAR ERROS
-- Inserir role de admin para o primeiro usuário
INSERT INTO public.user_roles (user_id, role, is_active)
SELECT id, 'admin', true 
FROM auth.users 
LIMIT 1
ON CONFLICT DO NOTHING;

-- Atualizar profiles com role admin
UPDATE public.profiles 
SET role = 'admin' 
WHERE id = (SELECT id FROM auth.users LIMIT 1);

-- 9. ATUALIZAR SESSIONS COM VALORES PADRÃO
UPDATE public.sessions 
SET 
    is_active = COALESCE(is_active, true),
    type = COALESCE(type, 'therapy'),
    follow_up_questions = COALESCE(follow_up_questions, ARRAY['Como você se sentiu?', 'O que mais te impactou?']),
    target_saboteurs = COALESCE(target_saboteurs, ARRAY['perfeccionista', 'vitima']),
    tools_data = COALESCE(tools_data, '{}'::jsonb)
WHERE is_active IS NULL 
   OR type IS NULL 
   OR follow_up_questions IS NULL 
   OR target_saboteurs IS NULL 
   OR tools_data IS NULL;

-- 10. VERIFICAÇÕES FINAIS
SELECT 
    'VERIFICAÇÃO FOREIGN KEYS' as status,
    constraint_name,
    table_name
FROM information_schema.table_constraints 
WHERE table_name = 'user_sessions' 
AND constraint_type = 'FOREIGN KEY';

SELECT 
    'VERIFICAÇÃO COLUNAS SESSIONS' as status,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name = 'sessions' 
AND table_schema = 'public'
AND column_name IN ('is_active', 'follow_up_questions', 'target_saboteurs', 'type', 'tools_data');

SELECT 
    'VERIFICAÇÃO COLUNAS PROFILES' as status,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND table_schema = 'public'
AND column_name IN ('user_id', 'role');

SELECT 
    'VERIFICAÇÃO TABELAS CRIADAS' as status,
    table_name
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('user_roles', 'user_missions');

-- 11. RESULTADO FINAL
SELECT '✅ CORREÇÃO EMERGENCIAL COMPLETA!' as resultado;
SELECT '🔄 RECARREGUE O FRONTEND AGORA!' as instrucao;