-- ===============================================
-- 🚨 RESTAURAÇÃO RÁPIDA - TUDO FUNCIONANDO
-- ===============================================
-- Restaura todas as funcionalidades que estavam funcionando
-- Execute este script no SQL Editor do Supabase

-- ===============================================
-- 1. LIMPEZA E PREPARAÇÃO
-- ===============================================

-- Remover políticas conflitantes
DROP POLICY IF EXISTS "profiles_all" ON profiles;
DROP POLICY IF EXISTS "profiles_policy" ON profiles;
DROP POLICY IF EXISTS "challenges_select" ON challenges;
DROP POLICY IF EXISTS "challenges_modify" ON challenges;
DROP POLICY IF EXISTS "challenges_select_policy" ON challenges;
DROP POLICY IF EXISTS "challenges_modify_policy" ON challenges;
DROP POLICY IF EXISTS "challenge_participations_all" ON challenge_participations;
DROP POLICY IF EXISTS "challenge_participations_policy" ON challenge_participations;
DROP POLICY IF EXISTS "user_goals_all" ON user_goals;
DROP POLICY IF EXISTS "user_goals_policy" ON user_goals;

-- ===============================================
-- 2. CRIAR/VERIFICAR ENUMS
-- ===============================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'app_role') THEN
        CREATE TYPE app_role AS ENUM ('test', 'user', 'admin', 'premium', 'vip');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'subscription_status') THEN
        CREATE TYPE subscription_status AS ENUM ('active', 'inactive', 'cancelled', 'pending');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'mission_type') THEN
        CREATE TYPE mission_type AS ENUM ('morning', 'habits', 'mindset', 'individual', 'community');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'mission_difficulty') THEN
        CREATE TYPE mission_difficulty AS ENUM ('easy', 'medium', 'hard');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'goal_status') THEN
        CREATE TYPE goal_status AS ENUM ('pendente', 'aprovada', 'rejeitada', 'em_progresso', 'concluida', 'cancelada');
    END IF;
END $$;

-- ===============================================
-- 3. RESTAURAR TABELA PROFILES
-- ===============================================

CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT,
    avatar_url TEXT,
    email TEXT,
    phone TEXT,
    birth_date DATE,
    gender TEXT,
    height DECIMAL(5,2),
    city TEXT,
    state TEXT,
    activity_level TEXT,
    preferences JSONB DEFAULT '{}',
    role app_role DEFAULT 'user',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    is_active BOOLEAN DEFAULT true
);

-- Adicionar colunas faltantes
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'email') THEN
        ALTER TABLE profiles ADD COLUMN email TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'avatar_url') THEN
        ALTER TABLE profiles ADD COLUMN avatar_url TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'preferences') THEN
        ALTER TABLE profiles ADD COLUMN preferences JSONB DEFAULT '{}';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'role') THEN
        ALTER TABLE profiles ADD COLUMN role app_role DEFAULT 'user';
    END IF;
END $$;

-- ===============================================
-- 4. RESTAURAR TABELA CHALLENGES
-- ===============================================

CREATE TABLE IF NOT EXISTS public.challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    type VARCHAR(50) DEFAULT 'individual',
    category VARCHAR(100),
    difficulty mission_difficulty DEFAULT 'medium',
    target_value DECIMAL(10,2),
    unit TEXT,
    reward_points INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Adicionar colunas faltantes
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenges' AND column_name = 'type') THEN
        ALTER TABLE challenges ADD COLUMN type VARCHAR(50) DEFAULT 'individual';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenges' AND column_name = 'created_by') THEN
        ALTER TABLE challenges ADD COLUMN created_by UUID REFERENCES auth.users(id);
    END IF;
END $$;

-- ===============================================
-- 5. RESTAURAR TABELA CHALLENGE_PARTICIPATIONS
-- ===============================================

CREATE TABLE IF NOT EXISTS public.challenge_participations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    challenge_id UUID REFERENCES challenges(id) ON DELETE CASCADE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    current_streak INTEGER DEFAULT 0,
    best_streak INTEGER DEFAULT 0,
    total_points INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    daily_logs JSONB DEFAULT '{}',
    achievements_unlocked JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, challenge_id)
);

-- Adicionar colunas faltantes
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_participations' AND column_name = 'best_streak') THEN
        ALTER TABLE challenge_participations ADD COLUMN best_streak INTEGER DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_participations' AND column_name = 'daily_logs') THEN
        ALTER TABLE challenge_participations ADD COLUMN daily_logs JSONB DEFAULT '{}';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_participations' AND column_name = 'achievements_unlocked') THEN
        ALTER TABLE challenge_participations ADD COLUMN achievements_unlocked JSONB DEFAULT '{}';
    END IF;
END $$;

-- ===============================================
-- 6. RESTAURAR TABELA USER_GOALS
-- ===============================================

CREATE TABLE IF NOT EXISTS public.user_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    category VARCHAR(100) DEFAULT 'geral',
    priority INTEGER DEFAULT 1,
    tags TEXT[] DEFAULT '{}',
    target_value DECIMAL(10,2),
    current_value DECIMAL(10,2) DEFAULT 0,
    unit TEXT,
    deadline DATE,
    status VARCHAR(20) DEFAULT 'pendente',
    evidence_required BOOLEAN DEFAULT false,
    evidence_text TEXT,
    points INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Adicionar colunas faltantes
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'category') THEN
        ALTER TABLE user_goals ADD COLUMN category VARCHAR(100) DEFAULT 'geral';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'priority') THEN
        ALTER TABLE user_goals ADD COLUMN priority INTEGER DEFAULT 1;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'tags') THEN
        ALTER TABLE user_goals ADD COLUMN tags TEXT[] DEFAULT '{}';
    END IF;
END $$;

-- ===============================================
-- 7. RESTAURAR TABELAS DE CURSOS
-- ===============================================

-- Tabela de cursos
CREATE TABLE IF NOT EXISTS public.courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de módulos
CREATE TABLE IF NOT EXISTS public.modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    order_index INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    prerequisites TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de aulas
CREATE TABLE IF NOT EXISTS public.lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID REFERENCES modules(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    content TEXT,
    video_url TEXT,
    order_index INTEGER DEFAULT 0,
    duration_minutes INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Adicionar colunas faltantes em modules
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'modules' AND column_name = 'is_active') THEN
        ALTER TABLE modules ADD COLUMN is_active BOOLEAN DEFAULT true;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'modules' AND column_name = 'prerequisites') THEN
        ALTER TABLE modules ADD COLUMN prerequisites TEXT[] DEFAULT '{}';
    END IF;
END $$;

-- ===============================================
-- 8. RESTAURAR TABELAS ADICIONAIS
-- ===============================================

-- Tabela de análises preventivas
CREATE TABLE IF NOT EXISTS public.preventive_health_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    analysis_type VARCHAR(50) NOT NULL,
    results JSONB DEFAULT '{}',
    recommendations TEXT[] DEFAULT '{}',
    risk_level VARCHAR(20) DEFAULT 'low',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de configurações da empresa
CREATE TABLE IF NOT EXISTS public.company_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name TEXT NOT NULL DEFAULT 'Instituto dos Sonhos',
    logo_url TEXT,
    primary_color TEXT DEFAULT '#3B82F6',
    secondary_color TEXT DEFAULT '#1E40AF',
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===============================================
-- 9. HABILITAR RLS E CRIAR POLÍTICAS SIMPLES
-- ===============================================

-- Habilitar RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_participations ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE preventive_health_analyses ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_configurations ENABLE ROW LEVEL SECURITY;

-- Criar políticas RLS simples e funcionais
CREATE POLICY "profiles_simple" ON profiles FOR ALL USING (id = auth.uid());
CREATE POLICY "challenges_select_simple" ON challenges FOR SELECT USING (true);
CREATE POLICY "challenges_modify_simple" ON challenges FOR ALL USING (auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin'));
CREATE POLICY "challenge_participations_simple" ON challenge_participations FOR ALL USING (user_id = auth.uid());
CREATE POLICY "user_goals_simple" ON user_goals FOR ALL USING (user_id = auth.uid());
CREATE POLICY "courses_select_simple" ON courses FOR SELECT USING (true);
CREATE POLICY "courses_modify_simple" ON courses FOR ALL USING (auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin'));
CREATE POLICY "modules_select_simple" ON modules FOR SELECT USING (true);
CREATE POLICY "modules_modify_simple" ON modules FOR ALL USING (auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin'));
CREATE POLICY "lessons_select_simple" ON lessons FOR SELECT USING (true);
CREATE POLICY "lessons_modify_simple" ON lessons FOR ALL USING (auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin'));
CREATE POLICY "preventive_health_analyses_simple" ON preventive_health_analyses FOR ALL USING (user_id = auth.uid());
CREATE POLICY "company_configurations_select_simple" ON company_configurations FOR SELECT USING (true);
CREATE POLICY "company_configurations_modify_simple" ON company_configurations FOR ALL USING (auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin'));

-- ===============================================
-- 10. CRIAR FUNÇÕES E TRIGGERS
-- ===============================================

-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Função para verificar se é admin
CREATE OR REPLACE FUNCTION is_admin_user()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM profiles 
        WHERE id = auth.uid() AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql;

-- Aplicar triggers
DO $$
DECLARE
    table_name TEXT;
BEGIN
    FOR table_name IN 
        SELECT tablename FROM pg_tables 
        WHERE schemaname = 'public' 
        AND tablename IN ('profiles', 'challenges', 'challenge_participations', 'user_goals', 'courses', 'modules', 'lessons', 'preventive_health_analyses', 'company_configurations')
    LOOP
        EXECUTE format('
            DROP TRIGGER IF EXISTS update_updated_at_trigger ON %I;
            CREATE TRIGGER update_updated_at_trigger
                BEFORE UPDATE ON %I
                FOR EACH ROW
                EXECUTE FUNCTION update_updated_at_column();
        ', table_name, table_name);
    END LOOP;
END $$;

-- ===============================================
-- 11. CRIAR ÍNDICES
-- ===============================================

CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE INDEX IF NOT EXISTS idx_challenges_active ON challenges(is_active);
CREATE INDEX IF NOT EXISTS idx_challenge_participations_user ON challenge_participations(user_id);
CREATE INDEX IF NOT EXISTS idx_user_goals_user_status ON user_goals(user_id, status);
CREATE INDEX IF NOT EXISTS idx_courses_active ON courses(is_active);
CREATE INDEX IF NOT EXISTS idx_modules_course ON modules(course_id);
CREATE INDEX IF NOT EXISTS idx_lessons_module ON lessons(module_id);
CREATE INDEX IF NOT EXISTS idx_preventive_health_analyses_user ON preventive_health_analyses(user_id);

-- ===============================================
-- 12. INSERIR DADOS DE TESTE
-- ===============================================

-- Inserir desafios de exemplo
INSERT INTO challenges (title, description, type, category, difficulty, reward_points, is_active)
VALUES 
    ('Hidratação Diária', 'Beba 2L de água por dia', 'individual', 'saude', 'easy', 10, true),
    ('Exercício Matinal', 'Faça 30 minutos de exercício pela manhã', 'individual', 'fitness', 'medium', 15, true),
    ('Meditação', 'Medite por 10 minutos', 'individual', 'mente', 'easy', 5, true),
    ('Leitura', 'Leia 30 minutos por dia', 'individual', 'desenvolvimento', 'medium', 10, true),
    ('Gratidão', 'Anote 3 coisas pelas quais é grato', 'individual', 'mente', 'easy', 5, true)
ON CONFLICT DO NOTHING;

-- Inserir configuração da empresa
INSERT INTO company_configurations (company_name, logo_url, primary_color, secondary_color, settings)
VALUES (
    'Instituto dos Sonhos',
    '/images/dr-vital.png',
    '#3B82F6',
    '#1E40AF',
    '{"theme": "light", "features": {"challenges": true, "goals": true, "ai": true, "courses": true}}'
)
ON CONFLICT DO NOTHING;

-- ===============================================
-- 13. VERIFICAÇÃO FINAL
-- ===============================================

-- Verificar se tudo foi criado
SELECT 
    'RESTAURAÇÃO CONCLUÍDA' as status,
    COUNT(*) as total_tabelas
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('profiles', 'challenges', 'challenge_participations', 'user_goals', 'courses', 'modules', 'lessons', 'preventive_health_analyses', 'company_configurations');

-- Verificar políticas RLS
SELECT 
    'POLÍTICAS RLS' as status,
    COUNT(*) as total_politicas
FROM pg_policies 
WHERE schemaname = 'public';

-- ===============================================
-- ✅ RESTAURAÇÃO CONCLUÍDA
-- ===============================================

DO $$
BEGIN
    RAISE NOTICE '🎉 RESTAURAÇÃO RÁPIDA CONCLUÍDA!';
    RAISE NOTICE '📊 Todas as tabelas foram restauradas';
    RAISE NOTICE '🔒 Políticas RLS foram aplicadas';
    RAISE NOTICE '⚡ Índices foram criados';
    RAISE NOTICE '📝 Dados de teste foram inseridos';
    RAISE NOTICE '✅ Sistema pronto para uso!';
END $$; 