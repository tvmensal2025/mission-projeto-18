-- Corrigir políticas RLS para tabela courses
-- Permitir que usuários autenticados criem cursos

-- Remover políticas restritivas existentes
DROP POLICY IF EXISTS "Admins can insert courses" ON public.courses;
DROP POLICY IF EXISTS "Admins can update courses" ON public.courses;
DROP POLICY IF EXISTS "Admins can delete courses" ON public.courses;
DROP POLICY IF EXISTS "Authenticated users can create courses" ON public.courses;
DROP POLICY IF EXISTS "Authenticated users can update courses" ON public.courses;
DROP POLICY IF EXISTS "Authenticated users can delete courses" ON public.courses;

-- Criar políticas mais permissivas para usuários autenticados
CREATE POLICY "Authenticated users can create courses" 
ON public.courses 
FOR INSERT 
WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update courses" 
ON public.courses 
FOR UPDATE 
USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can delete courses" 
ON public.courses 
FOR DELETE 
USING (auth.uid() IS NOT NULL);

-- Manter política de visualização para todos
DROP POLICY IF EXISTS "Everyone can view published courses" ON public.courses;
CREATE POLICY "Everyone can view published courses" 
ON public.courses 
FOR SELECT 
USING (is_published = true OR auth.uid() IS NOT NULL);

-- Verificar se RLS está habilitado
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;

-- Log das alterações
DO $$
BEGIN
    RAISE NOTICE 'Políticas RLS corrigidas para tabela courses';
    RAISE NOTICE 'Usuários autenticados agora podem criar/editar/deletar cursos';
END $$; 