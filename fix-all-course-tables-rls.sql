-- Corrigir políticas RLS para todas as tabelas relacionadas a cursos
-- Permitir que usuários autenticados gerenciem cursos, módulos e aulas

-- 1. Corrigir course_modules
DROP POLICY IF EXISTS "Admins can manage course modules" ON public.course_modules;
DROP POLICY IF EXISTS "Authenticated users can create course modules" ON public.course_modules;
DROP POLICY IF EXISTS "Authenticated users can update course modules" ON public.course_modules;
DROP POLICY IF EXISTS "Authenticated users can delete course modules" ON public.course_modules;

CREATE POLICY "Authenticated users can create course modules" 
ON public.course_modules 
FOR INSERT 
WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update course modules" 
ON public.course_modules 
FOR UPDATE 
USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can delete course modules" 
ON public.course_modules 
FOR DELETE 
USING (auth.uid() IS NOT NULL);

CREATE POLICY "Everyone can view course modules" 
ON public.course_modules 
FOR SELECT 
USING (true);

-- 2. Corrigir lessons
DROP POLICY IF EXISTS "Admins can manage lessons" ON public.lessons;
DROP POLICY IF EXISTS "Authenticated users can create lessons" ON public.lessons;
DROP POLICY IF EXISTS "Authenticated users can update lessons" ON public.lessons;
DROP POLICY IF EXISTS "Authenticated users can delete lessons" ON public.lessons;

CREATE POLICY "Authenticated users can create lessons" 
ON public.lessons 
FOR INSERT 
WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update lessons" 
ON public.lessons 
FOR UPDATE 
USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can delete lessons" 
ON public.lessons 
FOR DELETE 
USING (auth.uid() IS NOT NULL);

CREATE POLICY "Everyone can view lessons" 
ON public.lessons 
FOR SELECT 
USING (true);

-- 3. Corrigir course_lessons (se existir)
DROP POLICY IF EXISTS "Admins can manage course lessons" ON public.course_lessons;
DROP POLICY IF EXISTS "Authenticated users can manage course lessons" ON public.course_lessons;

CREATE POLICY "Authenticated users can manage course lessons" 
ON public.course_lessons 
FOR ALL 
USING (auth.uid() IS NOT NULL)
WITH CHECK (auth.uid() IS NOT NULL);

-- 4. Verificar se RLS está habilitado em todas as tabelas
ALTER TABLE public.course_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;

-- Log das alterações
DO $$
BEGIN
    RAISE NOTICE 'Políticas RLS corrigidas para todas as tabelas de cursos';
    RAISE NOTICE 'Usuários autenticados agora podem gerenciar cursos, módulos e aulas';
END $$; 