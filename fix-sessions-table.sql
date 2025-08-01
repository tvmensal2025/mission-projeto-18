-- ===============================================
-- 🔧 CORREÇÃO DA TABELA SESSIONS
-- ===============================================

-- 1. VERIFICAR SE TABELA SESSIONS EXISTE
SELECT 
    'VERIFICAÇÃO SESSIONS' as status,
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'sessions' AND table_schema = 'public'
    ) THEN 'EXISTE' ELSE 'NÃO EXISTE' END as tabela_existe;

-- 2. DROPAR E RECRIAR TABELA SESSIONS
DROP TABLE IF EXISTS public.sessions CASCADE;

-- 3. CRIAR TABELA SESSIONS COMPLETA
CREATE TABLE public.sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    content JSONB, -- Esta é a coluna que estava faltando!
    session_type TEXT DEFAULT 'therapy',
    difficulty TEXT DEFAULT 'iniciante',
    duration_minutes INTEGER DEFAULT 15,
    status TEXT DEFAULT 'active',
    is_published BOOLEAN DEFAULT true,
    tags TEXT[],
    category TEXT,
    instructor_name TEXT,
    video_url TEXT,
    audio_url TEXT,
    thumbnail_url TEXT,
    completion_count INTEGER DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 4. HABILITAR RLS
ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;

-- 5. CRIAR POLÍTICAS RLS
-- Política de SELECT: Todos podem ver sessões publicadas
DROP POLICY IF EXISTS "sessions_select_policy" ON public.sessions;
CREATE POLICY "sessions_select_policy" ON public.sessions 
FOR SELECT USING (
    is_published = true OR 
    user_id = auth.uid() OR 
    EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid() AND role = 'admin'
    )
);

-- Política de INSERT: Usuários logados podem criar
DROP POLICY IF EXISTS "sessions_insert_policy" ON public.sessions;
CREATE POLICY "sessions_insert_policy" ON public.sessions 
FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL AND (
        user_id = auth.uid() OR 
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() AND role = 'admin'
        )
    )
);

-- Política de UPDATE: Apenas criador ou admin
DROP POLICY IF EXISTS "sessions_update_policy" ON public.sessions;
CREATE POLICY "sessions_update_policy" ON public.sessions 
FOR UPDATE USING (
    user_id = auth.uid() OR 
    EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid() AND role = 'admin'
    )
);

-- Política de DELETE: Apenas criador ou admin
DROP POLICY IF EXISTS "sessions_delete_policy" ON public.sessions;
CREATE POLICY "sessions_delete_policy" ON public.sessions 
FOR DELETE USING (
    user_id = auth.uid() OR 
    EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid() AND role = 'admin'
    )
);

-- 6. CRIAR TRIGGER PARA UPDATED_AT
DROP TRIGGER IF EXISTS sessions_updated_at ON public.sessions;
CREATE TRIGGER sessions_updated_at
    BEFORE UPDATE ON public.sessions
    FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

-- 7. CRIAR ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON public.sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_type ON public.sessions(session_type);
CREATE INDEX IF NOT EXISTS idx_sessions_published ON public.sessions(is_published);
CREATE INDEX IF NOT EXISTS idx_sessions_category ON public.sessions(category);

-- 8. INSERIR ALGUMAS SESSÕES DE EXEMPLO
INSERT INTO public.sessions (
    title, description, content, session_type, difficulty, duration_minutes, 
    category, instructor_name, is_published, user_id
) VALUES
-- Sessões de Terapia
('Roda da Vida - Avaliação de Equilíbrio Geral', 
 'Avalie o equilíbrio das 12 áreas fundamentais da vida através de uma interface interativa.',
 '{"introduction": "A Roda da Vida avalia o equilíbrio das 12 áreas fundamentais da vida. Para cada área, selecione o emoji que melhor representa sua satisfação atual.", "wheel_interface": true, "areas": ["Saúde Física", "Saúde Mental", "Relacionamentos", "Carreira", "Finanças", "Desenvolvimento Pessoal", "Lazer", "Família", "Espiritualidade", "Contribuição Social", "Ambiente Físico", "Diversão"]}',
 'therapy', 'iniciante', 15, 'Autoconhecimento', 'Dr. Vital', true, 
 (SELECT id FROM auth.users LIMIT 1)),

('Meditação Mindfulness Básica', 
 'Introdução à prática de mindfulness para redução do estresse e ansiedade.',
 '{"steps": ["Encontre uma posição confortável", "Feche os olhos suavemente", "Concentre-se na respiração", "Observe os pensamentos sem julgamento", "Retorne à respiração quando a mente divagar"], "duration": 10, "background_music": true}',
 'meditation', 'iniciante', 10, 'Mindfulness', 'Sofia', true,
 (SELECT id FROM auth.users LIMIT 1)),

('Gestão de Ansiedade', 
 'Técnicas práticas para identificar e gerenciar episódios de ansiedade.',
 '{"techniques": ["Respiração 4-7-8", "Técnica de Grounding 5-4-3-2-1", "Relaxamento muscular progressivo"], "emergency_tips": ["Respire profundamente", "Identifique 5 coisas que pode ver", "Lembre-se: isso vai passar"]}',
 'therapy', 'medio', 20, 'Saúde Mental', 'Dr. Vital', true,
 (SELECT id FROM auth.users LIMIT 1)),

-- Sessões de Exercício
('Alongamento Matinal', 
 'Sequência de alongamentos para começar o dia com energia.',
 '{"exercises": ["Alongamento de pescoço", "Rotação de ombros", "Alongamento de braços", "Torção de tronco", "Alongamento de pernas"], "repetitions": "10x cada", "hold_time": "15 segundos"}',
 'exercise', 'iniciante', 10, 'Movimento', 'Personal Trainer', true,
 (SELECT id FROM auth.users LIMIT 1)),

-- Sessões de Nutrição
('Planejamento de Refeições Saudáveis', 
 'Aprenda a planejar refeições equilibradas para a semana.',
 '{"principles": ["Inclua proteínas em cada refeição", "Metade do prato deve ser vegetais", "Escolha carboidratos integrais", "Hidrate-se adequadamente"], "meal_template": {"breakfast": "Proteína + Carboidrato + Fruta", "lunch": "Proteína + Vegetais + Carboidrato", "dinner": "Proteína + Vegetais + Gordura saudável"}}',
 'nutrition', 'iniciante', 25, 'Alimentação', 'Nutricionista', true,
 (SELECT id FROM auth.users LIMIT 1));

-- 9. VERIFICAÇÕES FINAIS
SELECT 
    'ESTRUTURA SESSIONS' as status,
    COUNT(*) as total_colunas
FROM information_schema.columns 
WHERE table_name = 'sessions' AND table_schema = 'public';

SELECT 
    'SESSÕES CRIADAS' as status,
    COUNT(*) as total_sessoes,
    COUNT(*) FILTER (WHERE is_published = true) as publicadas,
    COUNT(*) FILTER (WHERE session_type = 'therapy') as terapia,
    COUNT(*) FILTER (WHERE session_type = 'meditation') as meditacao
FROM public.sessions;

-- 10. VERIFICAR COLUNA CONTENT
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'sessions' 
AND table_schema = 'public' 
AND column_name = 'content';

-- 11. MOSTRAR ALGUMAS SESSÕES
SELECT 
    title,
    session_type,
    difficulty,
    duration_minutes,
    category,
    is_published
FROM public.sessions
ORDER BY created_at
LIMIT 5;

-- 12. RESULTADO FINAL
SELECT '✅ TABELA SESSIONS CRIADA COM COLUNA CONTENT!' as resultado;
SELECT '🎯 AGORA TESTE CRIAR UMA NOVA SESSÃO!' as instrucao;