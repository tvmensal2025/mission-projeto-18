-- ===============================================
-- 🔧 CORREÇÃO TIPO JSONB DA COLUNA CONTENT
-- ===============================================

-- 1. VERIFICAR TIPO ATUAL DA COLUNA CONTENT
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'sessions' 
AND column_name = 'content'
AND table_schema = 'public';

-- 2. LIMPAR DADOS EXISTENTES QUE PODEM ESTAR CAUSANDO CONFLITO
DELETE FROM public.sessions WHERE content IS NOT NULL AND content::text = '{}';

-- 3. CONVERTER DADOS EXISTENTES PARA JSONB VÁLIDO
UPDATE public.sessions 
SET content = CASE 
    WHEN content IS NULL THEN '{}'::jsonb
    WHEN content::text = '' THEN '{}'::jsonb
    ELSE content
END
WHERE content IS NOT NULL;

-- 4. GARANTIR QUE A COLUNA É JSONB
DO $$
BEGIN
    -- Verificar se precisa alterar o tipo
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sessions' 
        AND column_name = 'content' 
        AND data_type != 'jsonb'
        AND table_schema = 'public'
    ) THEN
        -- Alterar tipo para JSONB
        ALTER TABLE public.sessions ALTER COLUMN content TYPE JSONB USING content::jsonb;
        RAISE NOTICE '✅ Coluna content convertida para JSONB';
    ELSE
        RAISE NOTICE '⚠️ Coluna content já é JSONB';
    END IF;
END $$;

-- 5. DEFINIR VALOR PADRÃO PARA CONTENT
ALTER TABLE public.sessions ALTER COLUMN content SET DEFAULT '{}'::jsonb;

-- 6. LIMPAR TABELA E REINSERIR DADOS CORRETOS
DELETE FROM public.sessions;

-- 7. INSERIR TEMPLATES COM JSONB CORRETO
INSERT INTO public.sessions (
    title, description, content, session_type, difficulty, duration_minutes, 
    category, template_category, is_template, objectives, prerequisites, 
    materials_needed, is_published, user_id, created_by
) VALUES
-- Template: Roda da Vida
('Roda da Vida - Avaliação de Equilíbrio Geral', 
 'Avalie o equilíbrio das 12 áreas fundamentais da vida através de uma interface interativa.',
 '{
   "introduction": "A Roda da Vida avalia o equilíbrio das 12 áreas fundamentais da vida. Para cada área, selecione o emoji que melhor representa sua satisfação atual.",
   "wheel_interface": true,
   "areas": [
     "Saúde Física", "Saúde Mental", "Relacionamentos", "Carreira", 
     "Finanças", "Desenvolvimento Pessoal", "Lazer", "Família", 
     "Espiritualidade", "Contribuição Social", "Ambiente Físico", "Diversão"
   ],
   "rating_scale": "1-10",
   "completion_time": "15 minutos"
 }'::jsonb,
 'therapy', 'iniciante', 15, 'Autoconhecimento', 'Terapia', true,
 ARRAY['Autoconhecimento', 'Identificar desequilíbrios', 'Planejar melhorias'],
 ARRAY['Disposição para autoavaliação'],
 ARRAY['Ambiente silencioso', 'Papel e caneta (opcional)'],
 true, 
 (SELECT id FROM auth.users LIMIT 1), 
 (SELECT id FROM auth.users LIMIT 1)),

-- Template: Meditação Guiada
('Template: Meditação Mindfulness', 
 'Template para criar sessões de meditação guiada personalizadas.',
 '{
   "type": "meditation",
   "steps": [
     {"name": "Preparação", "duration": 2, "instructions": "Encontre posição confortável"},
     {"name": "Respiração", "duration": 5, "instructions": "Concentre-se na respiração"},
     {"name": "Visualização", "duration": 6, "instructions": "Visualize um local tranquilo"},
     {"name": "Encerramento", "duration": 2, "instructions": "Retorne gradualmente"}
   ],
   "customizable_fields": ["duration", "theme", "background_music"],
   "background_options": ["natureza", "instrumental", "silencio"],
   "difficulty_levels": ["iniciante", "intermediario", "avancado"]
 }'::jsonb,
 'meditation', 'iniciante', 15, 'Mindfulness', 'Meditação', true,
 ARRAY['Reduzir estresse', 'Melhorar foco', 'Promover relaxamento'],
 ARRAY['Ambiente silencioso', 'Posição confortável'],
 ARRAY['Almofada ou cadeira', 'Fones de ouvido (opcional)'],
 true, 
 (SELECT id FROM auth.users LIMIT 1), 
 (SELECT id FROM auth.users LIMIT 1)),

-- Template: Sessão de Terapia
('Template: Sessão Terapêutica Estruturada', 
 'Template para criar sessões terapêuticas com estrutura profissional.',
 '{
   "type": "therapy",
   "phases": [
     {"name": "Acolhimento", "duration": 10, "objectives": ["Estabelecer rapport", "Definir agenda"]},
     {"name": "Exploração", "duration": 20, "objectives": ["Identificar questões", "Explorar sentimentos"]},
     {"name": "Intervenção", "duration": 15, "objectives": ["Aplicar técnicas", "Promover insights"]},
     {"name": "Fechamento", "duration": 5, "objectives": ["Resumir sessão", "Definir próximos passos"]}
   ],
   "techniques": ["escuta_ativa", "reflexao", "questionamento_socratico", "reestruturacao_cognitiva"],
   "assessment_tools": ["escala_humor", "inventario_sintomas"],
   "homework_options": ["diario_emocional", "exercicios_respiracao", "atividades_prazerosas"]
 }'::jsonb,
 'therapy', 'medio', 50, 'Terapia', 'Psicoterapia', true,
 ARRAY['Autoconhecimento', 'Resolução de conflitos', 'Desenvolvimento pessoal'],
 ARRAY['Disposição para autoexploração', 'Confidencialidade'],
 ARRAY['Caderno para anotações', 'Ambiente privado', 'Cronômetro'],
 true, 
 (SELECT id FROM auth.users LIMIT 1), 
 (SELECT id FROM auth.users LIMIT 1)),

-- Template: Exercício Funcional
('Template: Treino Funcional Personalizado', 
 'Template para criar treinos funcionais adaptáveis a diferentes níveis.',
 '{
   "type": "exercise",
   "structure": [
     {"phase": "Aquecimento", "duration": 5, "exercises": ["mobilidade_articular", "ativacao_muscular"]},
     {"phase": "Exercícios principais", "duration": 20, "exercises": ["funcionais", "resistencia", "forca"]},
     {"phase": "Relaxamento", "duration": 5, "exercises": ["alongamento", "respiracao"]}
   ],
   "equipment_options": ["peso_corporal", "halteres", "elasticos", "bola_suica"],
   "intensity_levels": ["baixa", "moderada", "alta"],
   "progression_system": {
     "beginner": {"sets": 2, "reps": "8-12", "rest": "60s"},
     "intermediate": {"sets": 3, "reps": "10-15", "rest": "45s"},
     "advanced": {"sets": 4, "reps": "12-20", "rest": "30s"}
   }
 }'::jsonb,
 'exercise', 'medio', 30, 'Fitness', 'Exercício', true,
 ARRAY['Melhorar condicionamento', 'Fortalecer músculos', 'Aumentar flexibilidade'],
 ARRAY['Liberação médica', 'Conhecimento básico de exercícios'],
 ARRAY['Roupas adequadas', 'Água', 'Toalha', 'Equipamentos opcionais'],
 true, 
 (SELECT id FROM auth.users LIMIT 1), 
 (SELECT id FROM auth.users LIMIT 1)),

-- Sessão Normal: Exemplo de uso
('Minha Primeira Meditação', 
 'Sessão de meditação criada a partir do template.',
 '{
   "based_on_template": "meditation",
   "duration": 10,
   "theme": "gratidao",
   "background_music": "natureza",
   "custom_instructions": "Foque em 3 coisas pelas quais você é grato hoje",
   "completed": false
 }'::jsonb,
 'meditation', 'iniciante', 10, 'Mindfulness', null, false,
 ARRAY['Praticar gratidão', 'Relaxar'],
 ARRAY['Disposição para meditar'],
 ARRAY['Local silencioso'],
 true, 
 (SELECT id FROM auth.users LIMIT 1), 
 (SELECT id FROM auth.users LIMIT 1));

-- 8. VERIFICAÇÕES FINAIS
SELECT 
    'TIPO CONTENT' as status,
    data_type,
    column_default
FROM information_schema.columns 
WHERE table_name = 'sessions' 
AND column_name = 'content'
AND table_schema = 'public';

SELECT 
    'SESSÕES INSERIDAS' as status,
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE is_template = true) as templates,
    COUNT(*) FILTER (WHERE is_template = false) as sessoes_normais
FROM public.sessions;

-- 9. TESTAR INSERÇÃO DE JSONB
SELECT 
    'TESTE JSONB' as status,
    title,
    content->>'type' as tipo_conteudo,
    jsonb_typeof(content) as tipo_jsonb
FROM public.sessions
WHERE content IS NOT NULL
LIMIT 3;

-- 10. RESULTADO FINAL
SELECT '✅ COLUNA CONTENT CORRIGIDA PARA JSONB!' as resultado;
SELECT '📋 TEMPLATES COM JSONB VÁLIDO INSERIDOS!' as templates;
SELECT '🎯 AGORA TESTE CRIAR SESSÃO!' as instrucao;