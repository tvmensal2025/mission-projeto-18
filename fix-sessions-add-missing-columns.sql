-- ===============================================
-- 🔧 ADICIONAR COLUNAS FALTANTES NA TABELA SESSIONS
-- ===============================================

-- 1. VERIFICAR COLUNAS ATUAIS
SELECT 
    'COLUNAS ATUAIS' as status,
    COUNT(*) as total_colunas
FROM information_schema.columns 
WHERE table_name = 'sessions' AND table_schema = 'public';

-- 2. ADICIONAR TODAS AS COLUNAS QUE PODEM ESTAR FALTANDO
DO $$
BEGIN
    -- estimated_time
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' AND column_name = 'estimated_time' AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN estimated_time INTEGER DEFAULT 15;
        RAISE NOTICE '✅ Coluna estimated_time adicionada';
    END IF;

    -- session_date
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' AND column_name = 'session_date' AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN session_date TIMESTAMP WITH TIME ZONE;
        RAISE NOTICE '✅ Coluna session_date adicionada';
    END IF;

    -- notes
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' AND column_name = 'notes' AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN notes TEXT;
        RAISE NOTICE '✅ Coluna notes adicionada';
    END IF;

    -- is_completed
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' AND column_name = 'is_completed' AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN is_completed BOOLEAN DEFAULT false;
        RAISE NOTICE '✅ Coluna is_completed adicionada';
    END IF;

    -- completed_at
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' AND column_name = 'completed_at' AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN completed_at TIMESTAMP WITH TIME ZONE;
        RAISE NOTICE '✅ Coluna completed_at adicionada';
    END IF;

    -- progress_percentage
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' AND column_name = 'progress_percentage' AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN progress_percentage INTEGER DEFAULT 0;
        RAISE NOTICE '✅ Coluna progress_percentage adicionada';
    END IF;

    -- feedback
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' AND column_name = 'feedback' AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN feedback TEXT;
        RAISE NOTICE '✅ Coluna feedback adicionada';
    END IF;

    -- mood_before
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' AND column_name = 'mood_before' AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN mood_before INTEGER;
        RAISE NOTICE '✅ Coluna mood_before adicionada';
    END IF;

    -- mood_after
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' AND column_name = 'mood_after' AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN mood_after INTEGER;
        RAISE NOTICE '✅ Coluna mood_after adicionada';
    END IF;

    -- energy_level
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' AND column_name = 'energy_level' AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN energy_level INTEGER;
        RAISE NOTICE '✅ Coluna energy_level adicionada';
    END IF;

    -- stress_level
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' AND column_name = 'stress_level' AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN stress_level INTEGER;
        RAISE NOTICE '✅ Coluna stress_level adicionada';
    END IF;

    -- session_data (para dados específicos da sessão)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' AND column_name = 'session_data' AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN session_data JSONB DEFAULT '{}'::jsonb;
        RAISE NOTICE '✅ Coluna session_data adicionada';
    END IF;

    -- is_favorite
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' AND column_name = 'is_favorite' AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN is_favorite BOOLEAN DEFAULT false;
        RAISE NOTICE '✅ Coluna is_favorite adicionada';
    END IF;

    -- reminder_time
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' AND column_name = 'reminder_time' AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN reminder_time TIMESTAMP WITH TIME ZONE;
        RAISE NOTICE '✅ Coluna reminder_time adicionada';
    END IF;

    -- location
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' AND column_name = 'location' AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN location TEXT;
        RAISE NOTICE '✅ Coluna location adicionada';
    END IF;
END $$;

-- 3. ATUALIZAR REGISTROS EXISTENTES COM VALORES PADRÃO
UPDATE public.sessions 
SET 
    estimated_time = COALESCE(estimated_time, duration_minutes, 15),
    is_completed = COALESCE(is_completed, false),
    progress_percentage = COALESCE(progress_percentage, 0),
    is_favorite = COALESCE(is_favorite, false)
WHERE estimated_time IS NULL 
   OR is_completed IS NULL 
   OR progress_percentage IS NULL 
   OR is_favorite IS NULL;

-- 4. CRIAR ÍNDICES PARA AS NOVAS COLUNAS
CREATE INDEX IF NOT EXISTS idx_sessions_estimated_time ON public.sessions(estimated_time);
CREATE INDEX IF NOT EXISTS idx_sessions_is_completed ON public.sessions(is_completed);
CREATE INDEX IF NOT EXISTS idx_sessions_session_date ON public.sessions(session_date);
CREATE INDEX IF NOT EXISTS idx_sessions_is_favorite ON public.sessions(is_favorite);

-- 5. VERIFICAÇÕES FINAIS
SELECT 
    'COLUNAS APÓS ADIÇÃO' as status,
    COUNT(*) as total_colunas
FROM information_schema.columns 
WHERE table_name = 'sessions' AND table_schema = 'public';

-- Verificar colunas específicas
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'sessions' 
AND table_schema = 'public'
AND column_name IN (
    'estimated_time', 'session_date', 'notes', 'is_completed', 
    'completed_at', 'progress_percentage', 'feedback', 'mood_before', 
    'mood_after', 'energy_level', 'stress_level', 'session_data',
    'is_favorite', 'reminder_time', 'location'
)
ORDER BY column_name;

-- 6. MOSTRAR ESTRUTURA COMPLETA DA TABELA
SELECT 
    'ESTRUTURA COMPLETA' as info,
    COUNT(*) as total_colunas,
    string_agg(column_name, ', ' ORDER BY ordinal_position) as todas_colunas
FROM information_schema.columns 
WHERE table_name = 'sessions' AND table_schema = 'public';

-- 7. TESTAR INSERÇÃO COM NOVAS COLUNAS
SELECT 
    'TESTE DADOS EXISTENTES' as status,
    COUNT(*) as total_sessoes,
    COUNT(*) FILTER (WHERE estimated_time IS NOT NULL) as com_estimated_time,
    COUNT(*) FILTER (WHERE is_completed IS NOT NULL) as com_is_completed
FROM public.sessions;

-- 8. RESULTADO FINAL
SELECT '✅ TODAS AS COLUNAS FALTANTES ADICIONADAS!' as resultado;
SELECT '🔍 VERIFIQUE SE ESTIMATED_TIME ESTÁ PRESENTE!' as verificacao;
SELECT '🎯 AGORA TESTE CRIAR SESSÃO NOVAMENTE!' as instrucao;