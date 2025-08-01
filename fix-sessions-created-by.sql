-- ===============================================
-- 🔧 CORREÇÃO COLUNA CREATED_BY NA TABELA SESSIONS
-- ===============================================

-- 1. VERIFICAR COLUNAS ATUAIS
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'sessions' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. ADICIONAR COLUNA CREATED_BY SE NÃO EXISTIR
DO $$
BEGIN
    -- Verificar se coluna created_by existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' 
        AND column_name = 'created_by' 
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL;
        RAISE NOTICE '✅ Coluna created_by adicionada à public.sessions';
    ELSE
        RAISE NOTICE '⚠️ Coluna created_by já existe na public.sessions';
    END IF;
END $$;

-- 3. ADICIONAR OUTRAS COLUNAS QUE PODEM ESTAR FALTANDO
DO $$
BEGIN
    -- Adicionar template_id se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' 
        AND column_name = 'template_id' 
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN template_id TEXT;
        RAISE NOTICE '✅ Coluna template_id adicionada à public.sessions';
    END IF;

    -- Adicionar is_template se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' 
        AND column_name = 'is_template' 
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN is_template BOOLEAN DEFAULT false;
        RAISE NOTICE '✅ Coluna is_template adicionada à public.sessions';
    END IF;

    -- Adicionar template_category se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' 
        AND column_name = 'template_category' 
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN template_category TEXT;
        RAISE NOTICE '✅ Coluna template_category adicionada à public.sessions';
    END IF;

    -- Adicionar objectives se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' 
        AND column_name = 'objectives' 
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN objectives TEXT[];
        RAISE NOTICE '✅ Coluna objectives adicionada à public.sessions';
    END IF;

    -- Adicionar prerequisites se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' 
        AND column_name = 'prerequisites' 
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN prerequisites TEXT[];
        RAISE NOTICE '✅ Coluna prerequisites adicionada à public.sessions';
    END IF;

    -- Adicionar materials_needed se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' 
        AND column_name = 'materials_needed' 
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.sessions ADD COLUMN materials_needed TEXT[];
        RAISE NOTICE '✅ Coluna materials_needed adicionada à public.sessions';
    END IF;
END $$;

-- 4. ATUALIZAR REGISTROS EXISTENTES COM CREATED_BY
UPDATE public.sessions 
SET created_by = user_id 
WHERE created_by IS NULL AND user_id IS NOT NULL;

-- 5. ATUALIZAR POLÍTICAS RLS PARA INCLUIR CREATED_BY
-- Política de SELECT atualizada
DROP POLICY IF EXISTS "sessions_select_policy" ON public.sessions;
CREATE POLICY "sessions_select_policy" ON public.sessions 
FOR SELECT USING (
    is_published = true OR 
    user_id = auth.uid() OR 
    created_by = auth.uid() OR
    EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid() AND role = 'admin'
    )
);

-- Política de UPDATE atualizada
DROP POLICY IF EXISTS "sessions_update_policy" ON public.sessions;
CREATE POLICY "sessions_update_policy" ON public.sessions 
FOR UPDATE USING (
    user_id = auth.uid() OR 
    created_by = auth.uid() OR
    EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid() AND role = 'admin'
    )
);

-- Política de DELETE atualizada
DROP POLICY IF EXISTS "sessions_delete_policy" ON public.sessions;
CREATE POLICY "sessions_delete_policy" ON public.sessions 
FOR DELETE USING (
    user_id = auth.uid() OR 
    created_by = auth.uid() OR
    EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid() AND role = 'admin'
    )
);

-- 6. CRIAR ÍNDICE PARA CREATED_BY
CREATE INDEX IF NOT EXISTS idx_sessions_created_by ON public.sessions(created_by);

-- 7. INSERIR TEMPLATES DE EXEMPLO (se não existirem)
INSERT INTO public.sessions (
    title, description, content, session_type, difficulty, duration_minutes, 
    category, template_category, is_template, objectives, prerequisites, 
    materials_needed, is_published, user_id, created_by
) 
SELECT * FROM (VALUES
    ('Template: Meditação Guiada', 
     'Template para criar sessões de meditação guiada personalizadas.',
     '{"type": "meditation", "steps": ["Preparação", "Respiração", "Visualização", "Encerramento"], "customizable_fields": ["duration", "theme", "background_music"]}',
     'meditation', 'iniciante', 15, 'Mindfulness', 'Meditação', true,
     ARRAY['Reduzir estresse', 'Melhorar foco', 'Promover relaxamento'],
     ARRAY['Ambiente silencioso', 'Posição confortável'],
     ARRAY['Almofada ou cadeira', 'Fones de ouvido (opcional)'],
     true, (SELECT id FROM auth.users LIMIT 1), (SELECT id FROM auth.users LIMIT 1)),

    ('Template: Sessão de Terapia', 
     'Template para criar sessões terapêuticas estruturadas.',
     '{"type": "therapy", "phases": ["Acolhimento", "Exploração", "Intervenção", "Fechamento"], "techniques": ["escuta_ativa", "reflexao", "questionamento_socratico"]}',
     'therapy', 'medio', 50, 'Terapia', 'Psicoterapia', true,
     ARRAY['Autoconhecimento', 'Resolução de conflitos', 'Desenvolvimento pessoal'],
     ARRAY['Disposição para autoexploração'],
     ARRAY['Caderno para anotações', 'Ambiente privado'],
     true, (SELECT id FROM auth.users LIMIT 1), (SELECT id FROM auth.users LIMIT 1)),

    ('Template: Exercício Funcional', 
     'Template para criar treinos funcionais personalizados.',
     '{"type": "exercise", "structure": ["Aquecimento", "Exercícios principais", "Relaxamento"], "equipment": ["peso_corporal", "halteres", "elasticos"]}',
     'exercise', 'medio', 30, 'Fitness', 'Exercício', true,
     ARRAY['Melhorar condicionamento', 'Fortalecer músculos', 'Aumentar flexibilidade'],
     ARRAY['Liberação médica', 'Conhecimento básico de exercícios'],
     ARRAY['Roupas adequadas', 'Água', 'Toalha'],
     true, (SELECT id FROM auth.users LIMIT 1), (SELECT id FROM auth.users LIMIT 1))
) AS templates_data
WHERE NOT EXISTS (
    SELECT 1 FROM public.sessions WHERE is_template = true
);

-- 8. VERIFICAÇÕES FINAIS
SELECT 
    'COLUNAS SESSIONS' as status,
    COUNT(*) as total_colunas
FROM information_schema.columns 
WHERE table_name = 'sessions' AND table_schema = 'public';

SELECT 
    'VERIFICAÇÃO CREATED_BY' as status,
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' 
        AND column_name = 'created_by' 
        AND table_schema = 'public'
    ) THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END as coluna_created_by;

SELECT 
    'SESSÕES E TEMPLATES' as status,
    COUNT(*) as total_sessoes,
    COUNT(*) FILTER (WHERE is_template = true) as templates,
    COUNT(*) FILTER (WHERE is_template = false OR is_template IS NULL) as sessoes_normais
FROM public.sessions;

-- 9. MOSTRAR ESTRUTURA FINAL
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'sessions' 
AND table_schema = 'public'
AND column_name IN ('id', 'title', 'content', 'created_by', 'user_id', 'is_template', 'template_category')
ORDER BY ordinal_position;

-- 10. RESULTADO FINAL
SELECT '✅ COLUNA CREATED_BY ADICIONADA COM SUCESSO!' as resultado;
SELECT '📋 TEMPLATES DE EXEMPLO INSERIDOS!' as templates;
SELECT '🎯 AGORA TESTE CRIAR SESSÃO USANDO TEMPLATE!' as instrucao;