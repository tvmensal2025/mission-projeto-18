-- ===============================================
-- 🔧 CORREÇÃO SISTEMA DE CURSOS COMPLETO
-- ===============================================
-- Corrige tabelas de courses, modules e lessons

-- ===============================================
-- 1. VERIFICAR E CRIAR TABELA COURSES
-- ===============================================

CREATE TABLE IF NOT EXISTS public.courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    category TEXT,
    difficulty_level TEXT CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
    duration_minutes INTEGER DEFAULT 0,
    instructor_name TEXT,
    instructor_id UUID REFERENCES auth.users(id),
    is_premium BOOLEAN DEFAULT false,
    is_published BOOLEAN DEFAULT false,
    thumbnail_url TEXT,
    price DECIMAL(10,2) DEFAULT 0,
    tags TEXT[],
    enrollment_count INTEGER DEFAULT 0,
    completion_count INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2),
    total_ratings INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ===============================================
-- 2. VERIFICAR E CRIAR TABELA COURSE_MODULES
-- ===============================================

CREATE TABLE IF NOT EXISTS public.course_modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    order_index INTEGER NOT NULL,
    duration_minutes INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT false,
    thumbnail_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(course_id, order_index)
);

-- ===============================================
-- 3. VERIFICAR E CRIAR TABELA LESSONS
-- ===============================================

CREATE TABLE IF NOT EXISTS public.lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID REFERENCES public.course_modules(id) ON DELETE CASCADE NOT NULL,
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    content TEXT,
    video_url TEXT,
    duration_minutes INTEGER DEFAULT 0,
    order_index INTEGER NOT NULL,
    is_published BOOLEAN DEFAULT false,
    is_premium BOOLEAN DEFAULT false,
    is_free BOOLEAN DEFAULT true,
    resources JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(module_id, order_index)
);

-- ===============================================
-- 4. VERIFICAR E CRIAR TABELA USER_PROGRESS
-- ===============================================

CREATE TABLE IF NOT EXISTS public.user_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
    module_id UUID REFERENCES public.course_modules(id) ON DELETE CASCADE,
    lesson_id UUID REFERENCES public.lessons(id) ON DELETE CASCADE NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE,
    progress_percentage INTEGER DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    watch_time_seconds INTEGER DEFAULT 0,
    last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(user_id, lesson_id)
);

-- ===============================================
-- 5. HABILITAR RLS
-- ===============================================

ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;

-- ===============================================
-- 6. POLÍTICAS RLS
-- ===============================================

-- Courses - Publicados são visíveis para todos, admins podem gerenciar
CREATE POLICY "courses_select" ON public.courses FOR SELECT USING (
    is_published = true OR public.is_admin_user()
);

CREATE POLICY "courses_modify" ON public.courses FOR ALL USING (
    public.is_admin_user()
);

-- Course Modules - Seguem visibilidade do curso
CREATE POLICY "course_modules_select" ON public.course_modules FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.courses c 
        WHERE c.id = course_id 
        AND (c.is_published = true OR public.is_admin_user())
    )
);

CREATE POLICY "course_modules_modify" ON public.course_modules FOR ALL USING (
    public.is_admin_user()
);

-- Lessons - Seguem visibilidade do módulo/curso
CREATE POLICY "lessons_select" ON public.lessons FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.course_modules m
        JOIN public.courses c ON c.id = m.course_id
        WHERE m.id = module_id 
        AND (c.is_published = true OR public.is_admin_user())
    )
);

CREATE POLICY "lessons_modify" ON public.lessons FOR ALL USING (
    public.is_admin_user()
);

-- User Progress - Usuários veem próprio progresso
CREATE POLICY "user_progress_all" ON public.user_progress FOR ALL USING (
    user_id = auth.uid() OR public.is_admin_user()
);

-- ===============================================
-- 7. TRIGGERS PARA UPDATED_AT
-- ===============================================

CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.courses
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.course_modules
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.lessons
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.user_progress
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ===============================================
-- 8. ÍNDICES PARA PERFORMANCE
-- ===============================================

CREATE INDEX IF NOT EXISTS idx_courses_published ON public.courses(is_published, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_courses_category ON public.courses(category);
CREATE INDEX IF NOT EXISTS idx_course_modules_course_order ON public.course_modules(course_id, order_index);
CREATE INDEX IF NOT EXISTS idx_lessons_module_order ON public.lessons(module_id, order_index);
CREATE INDEX IF NOT EXISTS idx_user_progress_user_lesson ON public.user_progress(user_id, lesson_id);

-- ===============================================
-- 9. DADOS INICIAIS DE EXEMPLO
-- ===============================================

-- Inserir curso exemplo (usando UUIDs válidos)
DO $$
DECLARE
    curso_id UUID := gen_random_uuid();
    modulo_id UUID := gen_random_uuid();
    aula_id UUID := gen_random_uuid();
BEGIN
    -- Inserir curso exemplo
    INSERT INTO public.courses (id, title, description, category, difficulty_level, instructor_name, is_published) VALUES
    (curso_id, 'Introdução ao Bem-estar', 'Curso básico sobre bem-estar e saúde', 'Bem-estar', 'beginner', 'Dr. Exemplo', true);

    -- Inserir módulo exemplo
    INSERT INTO public.course_modules (id, course_id, title, description, order_index, is_published) VALUES
    (modulo_id, curso_id, 'Fundamentos', 'Módulo introdutório', 1, true);

    -- Inserir aula exemplo
    INSERT INTO public.lessons (id, module_id, course_id, title, description, order_index, is_published) VALUES
    (aula_id, modulo_id, curso_id, 'Primeira Aula', 'Aula introdutória', 1, true);
    
    RAISE NOTICE '📚 Dados de exemplo inseridos com sucesso!';
    RAISE NOTICE '   Curso ID: %', curso_id;
    RAISE NOTICE '   Módulo ID: %', modulo_id;
    RAISE NOTICE '   Aula ID: %', aula_id;
END $$;

-- ===============================================
-- 10. VERIFICAÇÃO FINAL
-- ===============================================

DO $$
DECLARE
    courses_count INTEGER;
    modules_count INTEGER;
    lessons_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO courses_count FROM public.courses;
    SELECT COUNT(*) INTO modules_count FROM public.course_modules;
    SELECT COUNT(*) INTO lessons_count FROM public.lessons;
    
    RAISE NOTICE '🎉 ===============================================';
    RAISE NOTICE '📚 SISTEMA DE CURSOS CORRIGIDO COM SUCESSO';
    RAISE NOTICE '🎉 ===============================================';
    RAISE NOTICE '';
    RAISE NOTICE '✅ TABELAS CRIADAS/VERIFICADAS:';
    RAISE NOTICE '   📚 courses (% registros)', courses_count;
    RAISE NOTICE '   📖 course_modules (% registros)', modules_count;
    RAISE NOTICE '   📝 lessons (% registros)', lessons_count;
    RAISE NOTICE '   📊 user_progress (criada)';
    RAISE NOTICE '';
    RAISE NOTICE '✅ RECURSOS CONFIGURADOS:';
    RAISE NOTICE '   🔐 Políticas RLS ativas';
    RAISE NOTICE '   ⚡ Triggers de updated_at';
    RAISE NOTICE '   📈 Índices de performance';
    RAISE NOTICE '   👨‍🏫 Dados de exemplo inseridos';
    RAISE NOTICE '';
    RAISE NOTICE '🚀 SISTEMA DE CURSOS PRONTO PARA USO!';
    RAISE NOTICE '✅ Criar Curso deve funcionar agora';
    RAISE NOTICE '✅ Criar Módulo deve funcionar';
    RAISE NOTICE '✅ Criar Aula deve funcionar';
    RAISE NOTICE '';
    RAISE NOTICE '🎉 ===============================================';
END $$;