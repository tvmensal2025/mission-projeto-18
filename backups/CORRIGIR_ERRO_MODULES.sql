-- 🚨 CORREÇÃO DE ERRO: Tabela "modules" não existe
-- Execute este script primeiro para criar as tabelas base

-- =====================================================
-- PARTE 1: CRIAR TABELAS BASE FALTANTES
-- =====================================================

-- 1.1 Criar tabela courses (se não existir)
CREATE TABLE IF NOT EXISTS courses (
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

-- 1.2 Criar tabela modules (se não existir)
CREATE TABLE IF NOT EXISTS modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  order_index INTEGER DEFAULT 0,
  is_published BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 1.3 Criar tabela lessons (se não existir)
CREATE TABLE IF NOT EXISTS lessons (
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

-- 1.4 Criar tabela course_enrollments (se não existir)
CREATE TABLE IF NOT EXISTS course_enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  completed_at TIMESTAMP WITH TIME ZONE,
  progress_percentage INTEGER DEFAULT 0,
  UNIQUE(user_id, course_id)
);

-- =====================================================
-- PARTE 2: VERIFICAR SE OUTRAS TABELAS EXISTEM
-- =====================================================

-- 2.1 Verificar se profiles existe e tem colunas básicas
DO $$
BEGIN
  -- Verificar se a tabela profiles existe
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles' AND table_schema = 'public') THEN
    CREATE TABLE profiles (
      id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
      email TEXT,
      full_name TEXT,
      role TEXT DEFAULT 'user' CHECK (role IN ('user', 'admin', 'moderator')),
      created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
    );
  END IF;
  
  -- Adicionar coluna role se não existir
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'role' AND table_schema = 'public') THEN
    ALTER TABLE profiles ADD COLUMN role TEXT DEFAULT 'user' CHECK (role IN ('user', 'admin', 'moderator'));
  END IF;
END $$;

-- 2.2 Criar tabela user_goals (se não existir)
CREATE TABLE IF NOT EXISTS user_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  target_value INTEGER,
  current_value INTEGER DEFAULT 0,
  status VARCHAR(20) DEFAULT 'ativo' CHECK (status IN ('ativo', 'pausado', 'concluido', 'cancelado', 'pendente')),
  evidence_required BOOLEAN DEFAULT false,
  evidence_description TEXT,
  evidence_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2.3 Criar tabela challenges (se não existir)
CREATE TABLE IF NOT EXISTS challenges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  type VARCHAR(50) DEFAULT 'individual' CHECK (type IN ('individual', 'group', 'public', 'private')),
  difficulty VARCHAR(20) DEFAULT 'medium' CHECK (difficulty IN ('easy', 'medium', 'hard')),
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

-- 2.4 Criar tabela challenge_participations (se não existir)
CREATE TABLE IF NOT EXISTS challenge_participations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'failed', 'abandoned')),
  current_progress INTEGER DEFAULT 0,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  completed_at TIMESTAMP WITH TIME ZONE,
  UNIQUE(challenge_id, user_id)
);

-- 2.5 Criar tabela sessions (se não existir)
CREATE TABLE IF NOT EXISTS sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  session_date TIMESTAMP WITH TIME ZONE,
  duration INTEGER DEFAULT 60,
  created_by UUID REFERENCES auth.users(id),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2.6 Criar tabela user_sessions (se não existir)
CREATE TABLE IF NOT EXISTS user_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
  attended BOOLEAN DEFAULT false,
  feedback TEXT,
  rating INTEGER CHECK (rating BETWEEN 1 AND 5),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- =====================================================
-- PARTE 3: HABILITAR RLS BÁSICO
-- =====================================================

-- Habilitar RLS nas tabelas principais
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_participations ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;

-- Políticas básicas de segurança
-- Cursos - todos podem ver, admins podem editar
DROP POLICY IF EXISTS "Anyone can view published courses" ON courses;
CREATE POLICY "Anyone can view published courses" ON courses FOR SELECT USING (is_published = true);

DROP POLICY IF EXISTS "Admins can manage courses" ON courses;
CREATE POLICY "Admins can manage courses" ON courses FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);

-- Módulos - seguem a política dos cursos
DROP POLICY IF EXISTS "Anyone can view published modules" ON modules;
CREATE POLICY "Anyone can view published modules" ON modules FOR SELECT USING (
  EXISTS (SELECT 1 FROM courses WHERE id = modules.course_id AND is_published = true)
);

-- Aulas - seguem a política dos módulos
DROP POLICY IF EXISTS "Anyone can view published lessons" ON lessons;
CREATE POLICY "Anyone can view published lessons" ON lessons FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM modules m 
    JOIN courses c ON m.course_id = c.id 
    WHERE m.id = lessons.module_id AND c.is_published = true
  )
);

-- Metas - usuários podem ver apenas as próprias
DROP POLICY IF EXISTS "Users can manage own goals" ON user_goals;
CREATE POLICY "Users can manage own goals" ON user_goals FOR ALL USING (user_id = auth.uid());

-- Desafios - todos podem ver ativos
DROP POLICY IF EXISTS "Anyone can view active challenges" ON challenges;
CREATE POLICY "Anyone can view active challenges" ON challenges FOR SELECT USING (is_active = true);

-- Participações - usuários podem ver apenas as próprias
DROP POLICY IF EXISTS "Users can manage own participations" ON challenge_participations;
CREATE POLICY "Users can manage own participations" ON challenge_participations FOR ALL USING (user_id = auth.uid());

-- =====================================================
-- PARTE 4: INSERIR DADOS DE TESTE
-- =====================================================

-- 4.1 Inserir alguns cursos de exemplo
INSERT INTO courses (title, description, thumbnail_url, category, instructor_name, is_published)
VALUES 
  ('Alimentação Saudável', 'Aprenda os fundamentos de uma alimentação equilibrada', '/placeholder.svg', 'Nutrição', 'Instituto dos Sonhos', true),
  ('Exercícios em Casa', 'Exercícios práticos que você pode fazer em casa', '/placeholder.svg', 'Exercício', 'Instituto dos Sonhos', true),
  ('Mindfulness e Meditação', 'Técnicas de mindfulness para o dia a dia', '/placeholder.svg', 'Bem-estar', 'Instituto dos Sonhos', true)
ON CONFLICT DO NOTHING;

-- 4.2 Inserir módulos para os cursos
INSERT INTO modules (course_id, title, description, order_index)
SELECT 
  c.id,
  'Módulo 1: Introdução',
  'Introdução ao ' || c.title,
  1
FROM courses c
WHERE NOT EXISTS (SELECT 1 FROM modules WHERE course_id = c.id);

-- 4.3 Inserir algumas aulas
INSERT INTO lessons (module_id, title, description, video_url, duration, order_index)
SELECT 
  m.id,
  'Aula 1: Fundamentos',
  'Fundamentos básicos do tema',
  'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
  1200,
  1
FROM modules m
WHERE NOT EXISTS (SELECT 1 FROM lessons WHERE module_id = m.id);

-- 4.4 Inserir desafios exemplo
INSERT INTO challenges (title, description, type, target_value, unit, reward_points)
VALUES 
  ('Hidratação Diária', 'Beba 8 copos de água por dia durante uma semana', 'individual', 56, 'copos', 100),
  ('Caminhada Matinal', 'Caminhe 30 minutos todas as manhãs por 7 dias', 'individual', 7, 'dias', 150),
  ('Meditação Consciente', 'Medite por 10 minutos diários durante 10 dias', 'individual', 10, 'sessões', 200),
  ('Alimentação Colorida', 'Inclua pelo menos 3 cores diferentes no prato por 14 dias', 'individual', 14, 'refeições', 250),
  ('Exercício em Casa', 'Faça 30 minutos de exercícios em casa por 5 dias', 'individual', 5, 'sessões', 180)
ON CONFLICT DO NOTHING;

-- =====================================================
-- PARTE 5: CRIAR ÍNDICES BÁSICOS
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_courses_published ON courses(is_published);
CREATE INDEX IF NOT EXISTS idx_modules_course_id ON modules(course_id);
CREATE INDEX IF NOT EXISTS idx_lessons_module_id ON lessons(module_id);
CREATE INDEX IF NOT EXISTS idx_user_goals_user_id ON user_goals(user_id);
CREATE INDEX IF NOT EXISTS idx_challenges_active ON challenges(is_active);
CREATE INDEX IF NOT EXISTS idx_challenge_participations_user ON challenge_participations(user_id);

-- =====================================================
-- PARTE 6: RELATÓRIO
-- =====================================================

SELECT 
  '✅ TABELAS BASE CRIADAS COM SUCESSO!' AS status,
  jsonb_build_object(
    'timestamp', now(),
    'courses', (SELECT COUNT(*) FROM courses),
    'modules', (SELECT COUNT(*) FROM modules),
    'lessons', (SELECT COUNT(*) FROM lessons),
    'challenges', (SELECT COUNT(*) FROM challenges),
    'user_goals', (SELECT COUNT(*) FROM user_goals),
    'message', 'Agora você pode executar o script principal!'
  ) as relatorio;

-- 🎯 PRIMEIRO PASSO CONCLUÍDO!
-- ✅ Execute este script primeiro
-- ✅ Depois execute APLICAR_TODAS_CORRECOES.sql
-- ✅ Todas as tabelas base agora existem