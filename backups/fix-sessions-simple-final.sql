-- ===============================================
-- 🔧 CORREÇÃO SIMPLES E DEFINITIVA DA TABELA SESSIONS
-- ===============================================

-- 1. DROPAR TABELA COMPLETAMENTE
DROP TABLE IF EXISTS public.sessions CASCADE;

-- 2. RECRIAR TABELA COM ESTRUTURA MÍNIMA FUNCIONAL
CREATE TABLE public.sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    content JSONB DEFAULT '{}'::jsonb,
    session_type TEXT DEFAULT 'therapy',
    difficulty TEXT DEFAULT 'iniciante',
    duration_minutes INTEGER DEFAULT 15,
    category TEXT,
    status TEXT DEFAULT 'active',
    is_published BOOLEAN DEFAULT true,
    is_template BOOLEAN DEFAULT false,
    template_category TEXT,
    template_id TEXT,
    objectives TEXT[],
    prerequisites TEXT[],
    materials_needed TEXT[],
    instructor_name TEXT,
    tags TEXT[],
    video_url TEXT,
    audio_url TEXT,
    thumbnail_url TEXT,
    completion_count INTEGER DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 3. HABILITAR RLS
ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;

-- 4. CRIAR POLÍTICAS RLS SIMPLES
CREATE POLICY "sessions_all_access" ON public.sessions 
FOR ALL USING (true);

-- 5. CRIAR TRIGGER PARA UPDATED_AT
CREATE TRIGGER sessions_updated_at
    BEFORE UPDATE ON public.sessions
    FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

-- 6. INSERIR APENAS A RODA DA VIDA (TEMPLATE PRINCIPAL)
INSERT INTO public.sessions (
    title, 
    description, 
    content, 
    session_type, 
    difficulty, 
    duration_minutes, 
    category, 
    template_category, 
    is_template, 
    is_published,
    user_id,
    created_by
) VALUES (
    'Roda da Vida - Avaliação de Equilíbrio Geral',
    'Avalie o equilíbrio das 12 áreas fundamentais da vida através de uma interface interativa. Receba análises personalizadas e um plano de ação para melhorar seu bem-estar geral.',
    '{"introduction": "A Roda da Vida avalia o equilíbrio das 12 áreas fundamentais da vida. Para cada área, selecione o emoji que melhor representa sua satisfação atual.", "wheel_interface": true}'::jsonb,
    'therapy',
    'iniciante',
    15,
    'Autoconhecimento',
    'Terapia',
    true,
    true,
    (SELECT id FROM auth.users LIMIT 1),
    (SELECT id FROM auth.users LIMIT 1)
);

-- 7. VERIFICAÇÕES FINAIS
SELECT 'TABELA SESSIONS RECRIADA' as status;

SELECT 
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name = 'sessions' 
AND table_schema = 'public'
AND column_name IN ('content', 'created_by', 'template_category')
ORDER BY column_name;

SELECT 
    'DADOS INSERIDOS' as status,
    COUNT(*) as total_sessoes
FROM public.sessions;

-- 8. RESULTADO FINAL
SELECT '✅ TABELA SESSIONS CRIADA COM SUCESSO!' as resultado;
SELECT '📋 TEMPLATE RODA DA VIDA INSERIDO!' as template;
SELECT '🎯 AGORA TESTE CRIAR SESSÃO!' as instrucao;