-- ===============================================
-- 🔧 CORREÇÃO CONSTRAINT DE ORDER_INDEX
-- ===============================================
-- Problema: Duplicate key value violates unique constraint "uk_module_lesson_order"

-- 1. VERIFICAR CONSTRAINT ATUAL
SELECT 
    constraint_name,
    constraint_type,
    table_name
FROM information_schema.table_constraints 
WHERE table_name = 'lessons' 
AND constraint_name LIKE '%order%';

-- 2. VERIFICAR DADOS ATUAIS DAS AULAS
SELECT 
    module_id,
    order_index,
    COUNT(*) as duplicates
FROM public.lessons 
GROUP BY module_id, order_index
HAVING COUNT(*) > 1;

-- 3. CORRIGIR DUPLICATAS EXISTENTES
DO $$
DECLARE
    lesson_record RECORD;
    new_order INTEGER;
BEGIN
    -- Para cada módulo, reorganizar order_index sequencialmente
    FOR lesson_record IN 
        SELECT DISTINCT module_id FROM public.lessons ORDER BY module_id
    LOOP
        new_order := 1;
        
        -- Atualizar cada aula do módulo com ordem sequencial
        FOR lesson_record IN 
            SELECT id FROM public.lessons 
            WHERE module_id = lesson_record.module_id 
            ORDER BY created_at
        LOOP
            UPDATE public.lessons 
            SET order_index = new_order 
            WHERE id = lesson_record.id;
            
            new_order := new_order + 1;
        END LOOP;
    END LOOP;
    
    RAISE NOTICE '✅ Order_index reorganizado para todas as aulas';
END $$;

-- 4. CRIAR FUNÇÃO PARA AUTO-INCREMENTAR ORDER_INDEX
CREATE OR REPLACE FUNCTION get_next_lesson_order(p_module_id UUID)
RETURNS INTEGER AS $$
DECLARE
    next_order INTEGER;
BEGIN
    -- Buscar o próximo order_index disponível para o módulo
    SELECT COALESCE(MAX(order_index), 0) + 1 
    INTO next_order
    FROM public.lessons 
    WHERE module_id = p_module_id;
    
    RETURN next_order;
END;
$$ LANGUAGE plpgsql;

-- 5. CRIAR TRIGGER PARA AUTO-INCREMENTAR ORDER_INDEX
CREATE OR REPLACE FUNCTION auto_set_lesson_order()
RETURNS TRIGGER AS $$
BEGIN
    -- Se order_index não foi fornecido ou é 0, calcular automaticamente
    IF NEW.order_index IS NULL OR NEW.order_index <= 0 THEN
        NEW.order_index := get_next_lesson_order(NEW.module_id);
    ELSE
        -- Verificar se já existe uma aula com este order_index no módulo
        IF EXISTS (
            SELECT 1 FROM public.lessons 
            WHERE module_id = NEW.module_id 
            AND order_index = NEW.order_index 
            AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::UUID)
        ) THEN
            -- Se existe, usar o próximo disponível
            NEW.order_index := get_next_lesson_order(NEW.module_id);
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 6. APLICAR TRIGGER
DROP TRIGGER IF EXISTS auto_set_lesson_order ON public.lessons;
CREATE TRIGGER auto_set_lesson_order
    BEFORE INSERT OR UPDATE ON public.lessons
    FOR EACH ROW EXECUTE FUNCTION auto_set_lesson_order();

-- 7. FAZER O MESMO PARA MÓDULOS
CREATE OR REPLACE FUNCTION get_next_module_order(p_course_id UUID)
RETURNS INTEGER AS $$
DECLARE
    next_order INTEGER;
BEGIN
    SELECT COALESCE(MAX(order_index), 0) + 1 
    INTO next_order
    FROM public.course_modules 
    WHERE course_id = p_course_id;
    
    RETURN next_order;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION auto_set_module_order()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_index IS NULL OR NEW.order_index <= 0 THEN
        NEW.order_index := get_next_module_order(NEW.course_id);
    ELSE
        IF EXISTS (
            SELECT 1 FROM public.course_modules 
            WHERE course_id = NEW.course_id 
            AND order_index = NEW.order_index 
            AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::UUID)
        ) THEN
            NEW.order_index := get_next_module_order(NEW.course_id);
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS auto_set_module_order ON public.course_modules;
CREATE TRIGGER auto_set_module_order
    BEFORE INSERT OR UPDATE ON public.course_modules
    FOR EACH ROW EXECUTE FUNCTION auto_set_module_order();

-- 8. TESTE DE INSERÇÃO DE AULA SEM ESPECIFICAR ORDER
DO $$
DECLARE
    test_module_id UUID;
    test_lesson_id UUID;
BEGIN
    -- Buscar um módulo existente
    SELECT id INTO test_module_id FROM public.course_modules LIMIT 1;
    
    IF test_module_id IS NOT NULL THEN
        -- Inserir aula SEM especificar order_index (será auto-calculado)
        INSERT INTO public.lessons (
            module_id,
            title,
            description,
            content
        ) VALUES (
            test_module_id,
            'Aula Auto-Order',
            'Teste de order_index automático',
            'Conteúdo teste'
        ) RETURNING id INTO test_lesson_id;
        
        RAISE NOTICE '✅ AULA CRIADA COM ORDER AUTOMÁTICO: %', test_lesson_id;
        
        -- Verificar o order_index atribuído
        SELECT order_index INTO test_lesson_id FROM public.lessons WHERE id = test_lesson_id;
        RAISE NOTICE '📊 Order_index atribuído: %', test_lesson_id;
        
        -- Limpar teste
        DELETE FROM public.lessons WHERE id = test_lesson_id;
        RAISE NOTICE '🧹 AULA TESTE REMOVIDA';
    END IF;
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ ERRO: %', SQLERRM;
END $$;

-- 9. VERIFICAÇÃO FINAL
SELECT 
    '🎉 SISTEMA DE ORDER_INDEX AUTOMÁTICO CONFIGURADO!' as status;

-- 10. MOSTRAR ESTRUTURA ATUAL
SELECT 
    m.title as modulo,
    l.title as aula,
    l.order_index
FROM public.course_modules m
LEFT JOIN public.lessons l ON l.module_id = m.id
ORDER BY m.created_at, l.order_index;