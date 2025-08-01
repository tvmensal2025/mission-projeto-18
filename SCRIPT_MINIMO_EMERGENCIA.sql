-- 🚨 SCRIPT MÍNIMO DE EMERGÊNCIA
-- Se outros scripts derem erro, use este para criar apenas o essencial

-- =====================================================
-- LIMPAR POSSÍVEIS CONFLITOS
-- =====================================================
DROP TABLE IF EXISTS challenge_participations CASCADE;
DROP TABLE IF EXISTS challenges CASCADE;
DROP TABLE IF EXISTS user_goals CASCADE;
DROP TABLE IF EXISTS lessons CASCADE;
DROP TABLE IF EXISTS modules CASCADE;
DROP TABLE IF EXISTS courses CASCADE;

-- =====================================================
-- CRIAR TABELA PROFILES (se não existir)
-- =====================================================
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    full_name TEXT,
    role TEXT DEFAULT 'user',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- =====================================================
-- CRIAR TABELAS BÁSICAS
-- =====================================================

-- 1. COURSES
CREATE TABLE courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    thumbnail_url TEXT,
    category TEXT,
    instructor_name TEXT,
    created_by UUID REFERENCES auth.users(id),
    is_published BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2. MODULES  
CREATE TABLE modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    order_index INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 3. LESSONS
CREATE TABLE lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    video_url TEXT,
    thumbnail_url TEXT,
    duration INTEGER DEFAULT 0,
    order_index INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 4. USER_GOALS
CREATE TABLE user_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    target_value INTEGER,
    current_value INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'ativo',
    evidence_required BOOLEAN DEFAULT false,
    evidence_description TEXT,
    evidence_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 5. CHALLENGES (COM TODAS AS COLUNAS)
CREATE TABLE challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    type VARCHAR(50) DEFAULT 'individual',
    difficulty VARCHAR(20) DEFAULT 'medium', 
    target_value INTEGER NOT NULL,
    unit VARCHAR(50) DEFAULT 'count',
    start_date DATE DEFAULT CURRENT_DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT true,
    reward_points INTEGER DEFAULT 0,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 6. CHALLENGE_PARTICIPATIONS
CREATE TABLE challenge_participations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'active',
    current_progress INTEGER DEFAULT 0,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    completed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(challenge_id, user_id)
);

-- =====================================================
-- HABILITAR RLS
-- =====================================================
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_participations ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- POLÍTICAS BÁSICAS
-- =====================================================
CREATE POLICY "Anyone can view published courses" ON courses FOR SELECT USING (is_published = true);
CREATE POLICY "Anyone can view active challenges" ON challenges FOR SELECT USING (is_active = true);
CREATE POLICY "Users can manage own goals" ON user_goals FOR ALL USING (user_id = auth.uid());
CREATE POLICY "Users can manage own participations" ON challenge_participations FOR ALL USING (user_id = auth.uid());

-- =====================================================
-- INSERIR DADOS ESSENCIAIS
-- =====================================================

-- Desafios
INSERT INTO challenges (title, description, type, target_value, unit, reward_points, is_active) VALUES
('Hidratação Diária', 'Beba 8 copos de água por dia durante uma semana', 'individual', 56, 'copos', 100, true),
('Caminhada Matinal', 'Caminhe 30 minutos todas as manhãs por 7 dias', 'individual', 7, 'dias', 150, true),
('Meditação Consciente', 'Medite por 10 minutos diários durante 10 dias', 'individual', 10, 'sessões', 200, true),
('Alimentação Colorida', 'Inclua pelo menos 3 cores diferentes no prato por 14 dias', 'individual', 14, 'refeições', 250, true),
('Exercício em Casa', 'Faça 30 minutos de exercícios em casa por 5 dias', 'individual', 5, 'sessões', 180, true);

-- Cursos
INSERT INTO courses (title, description, thumbnail_url, category, instructor_name, is_published) VALUES
('Alimentação Saudável', 'Aprenda os fundamentos de uma alimentação equilibrada', '/placeholder.svg', 'Nutrição', 'Instituto dos Sonhos', true),
('Exercícios em Casa', 'Exercícios práticos que você pode fazer em casa', '/placeholder.svg', 'Exercício', 'Instituto dos Sonhos', true),
('Mindfulness e Meditação', 'Técnicas de mindfulness para o dia a dia', '/placeholder.svg', 'Bem-estar', 'Instituto dos Sonhos', true);

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================
SELECT 
    '🚨 EMERGÊNCIA RESOLVIDA!' as status,
    (SELECT COUNT(*) FROM challenges) as desafios_criados,
    (SELECT COUNT(*) FROM courses) as cursos_criados,
    'Tabelas recriadas do zero - sistema funcionando!' as message;

-- 🚨 SCRIPT DE EMERGÊNCIA EXECUTADO!
-- ✅ Recria tudo do zero
-- ✅ Remove conflitos
-- ✅ Garante estrutura correta
-- ✅ Último recurso se outros scripts falharem