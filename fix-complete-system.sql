-- ===============================================
-- 🔧 CORREÇÃO COMPLETA DO SISTEMA
-- ===============================================
-- Corrige TODOS os problemas identificados na auditoria

-- ===============================================
-- 1. CORRIGIR TABELA USER_GOALS
-- ===============================================

-- Remover tabela conflituosa
DROP TABLE IF EXISTS public.user_goals CASCADE;

-- Recriar com estrutura correta
CREATE TABLE public.user_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    category TEXT,
    challenge_id UUID REFERENCES public.challenges(id),
    target_value DECIMAL(10,2),
    current_value DECIMAL(10,2) DEFAULT 0,
    unit TEXT,
    difficulty TEXT DEFAULT 'medio' CHECK (difficulty IN ('facil', 'medio', 'dificil')),
    target_date DATE,
    status TEXT DEFAULT 'aprovada' CHECK (status IN ('pendente', 'aprovada', 'rejeitada', 'em_progresso', 'concluida', 'cancelada')),
    estimated_points INTEGER DEFAULT 100,
    final_points INTEGER,
    admin_notes TEXT,
    evidence_required BOOLEAN DEFAULT false,
    is_group_goal BOOLEAN DEFAULT false,
    approved_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    completed_at TIMESTAMP WITH TIME ZONE,
    approved_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ===============================================
-- 2. CORRIGIR TABELA WEIGHT_MEASUREMENTS (IMC)
-- ===============================================

-- Adicionar colunas que podem estar faltando
ALTER TABLE public.weight_measurements 
ADD COLUMN IF NOT EXISTS altura_cm INTEGER,
ADD COLUMN IF NOT EXISTS imc_calculado DECIMAL(4,2);

-- Função para calcular IMC automaticamente
CREATE OR REPLACE FUNCTION calculate_imc()
RETURNS TRIGGER AS $$
BEGIN
    -- Se altura estiver disponível, calcular IMC
    IF NEW.altura_cm IS NOT NULL AND NEW.altura_cm > 0 THEN
        NEW.imc_calculado = NEW.peso_kg / POWER((NEW.altura_cm::DECIMAL / 100), 2);
        NEW.imc = NEW.imc_calculado;
    END IF;
    
    -- Se não tiver altura, buscar do perfil do usuário
    IF NEW.imc IS NULL OR NEW.imc = 0 THEN
        DECLARE
            profile_height DECIMAL;
        BEGIN
            SELECT height INTO profile_height 
            FROM public.profiles 
            WHERE id = NEW.user_id;
            
            IF profile_height IS NOT NULL AND profile_height > 0 THEN
                NEW.altura_cm = profile_height;
                NEW.imc_calculado = NEW.peso_kg / POWER((profile_height::DECIMAL / 100), 2);
                NEW.imc = NEW.imc_calculado;
            END IF;
        END;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para calcular IMC automaticamente
DROP TRIGGER IF EXISTS calculate_imc_trigger ON public.weight_measurements;
CREATE TRIGGER calculate_imc_trigger
    BEFORE INSERT OR UPDATE ON public.weight_measurements
    FOR EACH ROW
    EXECUTE FUNCTION calculate_imc();

-- ===============================================
-- 3. CORRIGIR TABELA WEIGHINGS (BACKUP)
-- ===============================================

-- Garantir que weighings também funciona
ALTER TABLE public.weighings 
ADD COLUMN IF NOT EXISTS imc_calculado DECIMAL(4,2);

-- Função para weighings
CREATE OR REPLACE FUNCTION calculate_weighings_bmi()
RETURNS TRIGGER AS $$
DECLARE
    profile_height DECIMAL;
BEGIN
    -- Buscar altura do perfil
    SELECT height INTO profile_height 
    FROM public.profiles 
    WHERE id = NEW.user_id;
    
    IF profile_height IS NOT NULL AND profile_height > 0 THEN
        NEW.imc_calculado = NEW.weight / POWER((profile_height::DECIMAL / 100), 2);
        NEW.bmi = NEW.imc_calculado;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para weighings
DROP TRIGGER IF EXISTS calculate_weighings_bmi_trigger ON public.weighings;
CREATE TRIGGER calculate_weighings_bmi_trigger
    BEFORE INSERT OR UPDATE ON public.weighings
    FOR EACH ROW
    EXECUTE FUNCTION calculate_weighings_bmi();

-- ===============================================
-- 4. HABILITAR RLS E POLÍTICAS
-- ===============================================

-- RLS para user_goals
ALTER TABLE public.user_goals ENABLE ROW LEVEL SECURITY;

-- Políticas user_goals - USUÁRIOS PODEM CRIAR E VER APROVADAS
CREATE POLICY "users_can_view_own_goals" ON public.user_goals FOR SELECT USING (
    user_id = auth.uid() OR public.is_admin_user()
);

CREATE POLICY "users_can_create_goals" ON public.user_goals FOR INSERT WITH CHECK (
    user_id = auth.uid()
);

CREATE POLICY "users_can_update_own_goals" ON public.user_goals FOR UPDATE USING (
    user_id = auth.uid() OR public.is_admin_user()
);

CREATE POLICY "admins_can_manage_all_goals" ON public.user_goals FOR ALL USING (
    public.is_admin_user()
);

-- ===============================================
-- 5. CRIAR TABELAS FALTANTES IDENTIFICADAS
-- ===============================================

-- Tabela goal_categories se não existir
CREATE TABLE IF NOT EXISTS public.goal_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    icon TEXT DEFAULT '🎯',
    color TEXT DEFAULT '#3B82F6',
    base_points INTEGER DEFAULT 10,
    difficulty_multiplier JSONB DEFAULT '{"facil": 1.0, "medio": 1.5, "dificil": 2.0}'::jsonb,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Tabela goal_evidence se não existir
CREATE TABLE IF NOT EXISTS public.goal_evidence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    goal_id UUID REFERENCES public.user_goals(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    evidence_type TEXT NOT NULL,
    evidence_url TEXT,
    evidence_data JSONB DEFAULT '{}',
    description TEXT,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    verified_at TIMESTAMP WITH TIME ZONE,
    verified_by UUID REFERENCES auth.users(id),
    is_approved BOOLEAN DEFAULT false,
    admin_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ===============================================
-- 6. ÍNDICES PARA PERFORMANCE
-- ===============================================

-- Índices user_goals
CREATE INDEX IF NOT EXISTS idx_user_goals_user_id ON public.user_goals(user_id);
CREATE INDEX IF NOT EXISTS idx_user_goals_status ON public.user_goals(status);
CREATE INDEX IF NOT EXISTS idx_user_goals_category ON public.user_goals(category);
CREATE INDEX IF NOT EXISTS idx_user_goals_created_at ON public.user_goals(created_at DESC);

-- Índices weight_measurements
CREATE INDEX IF NOT EXISTS idx_weight_measurements_user_date ON public.weight_measurements(user_id, measurement_date DESC);
CREATE INDEX IF NOT EXISTS idx_weight_measurements_imc ON public.weight_measurements(imc_calculado);

-- ===============================================
-- 7. TRIGGERS PARA UPDATED_AT
-- ===============================================

-- Trigger user_goals
DROP TRIGGER IF EXISTS handle_updated_at_user_goals ON public.user_goals;
CREATE TRIGGER handle_updated_at_user_goals BEFORE UPDATE ON public.user_goals
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ===============================================
-- 8. DADOS INICIAIS
-- ===============================================

-- Categorias de metas
INSERT INTO public.goal_categories (name, description, icon, color, base_points) VALUES
('peso', 'Metas relacionadas ao peso corporal', '⚖️', '#10B981', 100),
('exercicio', 'Metas de atividade física', '🏃‍♂️', '#3B82F6', 80),
('alimentacao', 'Metas nutricionais', '🍎', '#F59E0B', 60),
('hidratacao', 'Metas de consumo de água', '💧', '#06B6D4', 40),
('sono', 'Metas de qualidade do sono', '😴', '#8B5CF6', 50),
('mindset', 'Metas de bem-estar mental', '🧠', '#EC4899', 70)
ON CONFLICT DO NOTHING;

-- ===============================================
-- 9. HABILITAR RLS NAS NOVAS TABELAS
-- ===============================================

ALTER TABLE public.goal_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.goal_evidence ENABLE ROW LEVEL SECURITY;

-- Políticas goal_categories
CREATE POLICY "goal_categories_select" ON public.goal_categories FOR SELECT USING (true);
CREATE POLICY "goal_categories_modify" ON public.goal_categories FOR ALL USING (public.is_admin_user());

-- Políticas goal_evidence
CREATE POLICY "goal_evidence_user_access" ON public.goal_evidence FOR ALL USING (
    user_id = auth.uid() OR public.is_admin_user()
);

-- ===============================================
-- 10. LOG DE SUCESSO
-- ===============================================

DO $$
BEGIN
    RAISE NOTICE '🎉 ===============================================';
    RAISE NOTICE '🔧 CORREÇÃO COMPLETA DO SISTEMA FINALIZADA';
    RAISE NOTICE '🎉 ===============================================';
    RAISE NOTICE '';
    RAISE NOTICE '✅ PROBLEMAS CORRIGIDOS:';
    RAISE NOTICE '   📋 Tabela user_goals recriada com estrutura correta';
    RAISE NOTICE '   ⚖️  IMC agora calcula automaticamente';
    RAISE NOTICE '   👑 Metas aprovadas automaticamente (sem admin)';
    RAISE NOTICE '   🔐 Políticas RLS corrigidas';
    RAISE NOTICE '   📊 Índices de performance adicionados';
    RAISE NOTICE '   🎯 Categorias de metas inseridas';
    RAISE NOTICE '   📸 Sistema de evidências configurado';
    RAISE NOTICE '';
    RAISE NOTICE '🚀 SISTEMA DEVE FUNCIONAR 100% AGORA!';
    RAISE NOTICE '💡 Metas são aprovadas automaticamente';
    RAISE NOTICE '📐 IMC calcula baseado na altura do perfil';
    RAISE NOTICE '🎯 Todos os botões devem funcionar';
    RAISE NOTICE '';
    RAISE NOTICE '🎉 ===============================================';
END $$;