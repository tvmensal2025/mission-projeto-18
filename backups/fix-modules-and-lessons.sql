-- ===============================================
-- 🔧 CORREÇÃO MÓDULOS E AULAS
-- ===============================================
-- Problema: Frontend envia is_active, banco espera is_published

-- 1. VERIFICAR ESTRUTURA ATUAL DAS TABELAS
SELECT 
    'course_modules' as tabela,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'course_modules' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. ADICIONAR COLUNA is_active SE NÃO EXISTIR
ALTER TABLE public.course_modules 
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- 3. SINCRONIZAR is_active COM is_published
UPDATE public.course_modules 
SET is_active = is_published 
WHERE is_active IS NULL;

-- 4. VERIFICAR ESTRUTURA DA TABELA LESSONS
SELECT 
    'lessons' as tabela,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'lessons' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 5. ADICIONAR COLUNAS NECESSÁRIAS EM LESSONS
ALTER TABLE public.lessons 
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- 6. SINCRONIZAR DADOS EM LESSONS
UPDATE public.lessons 
SET is_active = is_published 
WHERE is_active IS NULL;

-- 7. TESTE DE INSERÇÃO DE MÓDULO
DO $$
DECLARE
    test_course_id UUID;
    test_module_id UUID;
BEGIN
    -- Buscar um curso existente
    SELECT id INTO test_course_id FROM public.courses LIMIT 1;
    
    IF test_course_id IS NOT NULL THEN
        -- Inserir módulo de teste
        INSERT INTO public.course_modules (
            course_id,
            title,
            description,
            order_index,
            is_published,
            is_active
        ) VALUES (
            test_course_id,
            'Módulo Teste',
            'Teste de criação de módulo',
            99,
            true,
            true
        ) RETURNING id INTO test_module_id;
        
        RAISE NOTICE '✅ MÓDULO CRIADO: %', test_module_id;
        
        -- Remover teste
        DELETE FROM public.course_modules WHERE id = test_module_id;
        RAISE NOTICE '🧹 MÓDULO TESTE REMOVIDO';
    END IF;
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ ERRO AO CRIAR MÓDULO: %', SQLERRM;
END $$;

-- 8. TESTE DE INSERÇÃO DE AULA
DO $$
DECLARE
    test_course_id UUID;
    test_module_id UUID;
    test_lesson_id UUID;
BEGIN
    -- Buscar curso e módulo existentes
    SELECT c.id, m.id INTO test_course_id, test_module_id
    FROM public.courses c
    JOIN public.course_modules m ON m.course_id = c.id
    LIMIT 1;
    
    IF test_course_id IS NOT NULL AND test_module_id IS NOT NULL THEN
        -- Inserir aula de teste
        INSERT INTO public.lessons (
            module_id,
            course_id,
            title,
            description,
            order_index,
            is_published,
            is_active,
            content,
            video_url
        ) VALUES (
            test_module_id,
            test_course_id,
            'Aula Teste',
            'Teste de criação de aula',
            99,
            true,
            true,
            'Conteúdo da aula teste',
            ''
        ) RETURNING id INTO test_lesson_id;
        
        RAISE NOTICE '✅ AULA CRIADA: %', test_lesson_id;
        
        -- Remover teste
        DELETE FROM public.lessons WHERE id = test_lesson_id;
        RAISE NOTICE '🧹 AULA TESTE REMOVIDA';
    END IF;
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ ERRO AO CRIAR AULA: %', SQLERRM;
END $$;

-- 9. CRIAR TRIGGER PARA SINCRONIZAR is_active E is_published
CREATE OR REPLACE FUNCTION sync_active_published()
RETURNS TRIGGER AS $$
BEGIN
    -- Sincronizar is_active com is_published
    IF NEW.is_active IS NOT NULL THEN
        NEW.is_published = NEW.is_active;
    END IF;
    
    IF NEW.is_published IS NOT NULL THEN
        NEW.is_active = NEW.is_published;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 10. APLICAR TRIGGER NAS TABELAS
DROP TRIGGER IF EXISTS sync_active_published_modules ON public.course_modules;
CREATE TRIGGER sync_active_published_modules
    BEFORE INSERT OR UPDATE ON public.course_modules
    FOR EACH ROW EXECUTE FUNCTION sync_active_published();

DROP TRIGGER IF EXISTS sync_active_published_lessons ON public.lessons;
CREATE TRIGGER sync_active_published_lessons
    BEFORE INSERT OR UPDATE ON public.lessons
    FOR EACH ROW EXECUTE FUNCTION sync_active_published();

-- 11. VERIFICAÇÃO FINAL
SELECT 
    'ESTRUTURA CORRIGIDA' as status,
    'course_modules e lessons agora suportam is_active' as detalhes;

-- 12. MOSTRAR DADOS ATUAIS
SELECT 
    'DADOS ATUAIS' as info,
    'courses' as tabela,
    COUNT(*) as total
FROM public.courses
UNION ALL
SELECT 
    'DADOS ATUAIS' as info,
    'course_modules' as tabela,
    COUNT(*) as total
FROM public.course_modules
UNION ALL
SELECT 
    'DADOS ATUAIS' as info,
    'lessons' as tabela,
    COUNT(*) as total
FROM public.lessons;