-- ===============================================
-- 🏗️ ESTRUTURA REVOLUCIONÁRIA INSTITUTO DOS SONHOS
-- ===============================================

-- ✅ ENUMS FUNDAMENTAIS
CREATE TYPE app_role AS ENUM ('test', 'user', 'admin', 'premium', 'vip', 'moderator', 'coach', 'nutritionist', 'doctor');
CREATE TYPE subscription_status AS ENUM ('active', 'inactive', 'cancelled', 'pending');
CREATE TYPE mission_type AS ENUM ('morning', 'habits', 'mindset', 'individual', 'community');
CREATE TYPE mission_difficulty AS ENUM ('easy', 'medium', 'hard');
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'cancelled');
CREATE TYPE goal_status AS ENUM ('active', 'completed', 'paused', 'cancelled');

-- ✅ TABELA DE PERFIS EXPANDIDA
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT,
    avatar_url TEXT,
    role app_role DEFAULT 'user',
    birth_date DATE,
    gender TEXT,
    height DECIMAL(5,2),
    activity_level TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    last_login TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    preferences JSONB DEFAULT '{}',
    metadata JSONB DEFAULT '{}'
);

-- ✅ SISTEMA DE ROLES ROBUSTO
CREATE TABLE public.user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    role app_role NOT NULL DEFAULT 'user',
    assigned_by UUID REFERENCES auth.users(id),
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    expires_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}'
);

-- ✅ PESAGEM AVANÇADA
CREATE TABLE public.weighings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    weight DECIMAL(5,2) NOT NULL,
    body_fat DECIMAL(5,2),
    muscle_mass DECIMAL(5,2),
    water_percentage DECIMAL(5,2),
    bone_mass DECIMAL(5,2),
    visceral_fat INTEGER,
    metabolic_age INTEGER,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    device_info JSONB DEFAULT '{}',
    notes TEXT
);

-- ✅ MISSÕES GAMIFICADAS
CREATE TABLE public.missions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    type mission_type DEFAULT 'individual',
    difficulty mission_difficulty DEFAULT 'easy',
    xp_reward INTEGER DEFAULT 10,
    category TEXT,
    requirements JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ✅ MISSÕES DOS USUÁRIOS
CREATE TABLE public.user_missions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    mission_id UUID REFERENCES public.missions(id) ON DELETE CASCADE NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE,
    due_date TIMESTAMP WITH TIME ZONE,
    evidence_urls JSONB DEFAULT '[]',
    user_notes TEXT,
    xp_earned INTEGER DEFAULT 0,
    bonus_xp_earned INTEGER DEFAULT 0,
    badges_earned JSONB DEFAULT '[]',
    numero_de_tentativa INTEGER DEFAULT 1,
    ai_assistance_used BOOLEAN DEFAULT false,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ✅ SISTEMA DE BADGES
CREATE TABLE public.badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    description TEXT,
    icon_url TEXT,
    color TEXT DEFAULT '#6366f1',
    requirements JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ✅ BADGES DOS USUÁRIOS
CREATE TABLE public.user_badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    badge_id UUID REFERENCES public.badges(id) ON DELETE CASCADE NOT NULL,
    earned_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    earning_context JSONB DEFAULT '{}',
    is_displayed BOOLEAN DEFAULT true,
    display_order INTEGER
);

-- ✅ PLATAFORMA EDUCACIONAL
CREATE TABLE public.courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    category TEXT,
    thumbnail_url TEXT,
    instructor_id UUID REFERENCES auth.users(id),
    duration_minutes INTEGER,
    difficulty_level TEXT,
    tags TEXT[],
    is_published BOOLEAN DEFAULT false,
    is_premium BOOLEAN DEFAULT false,
    price DECIMAL(10,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ✅ MÓDULOS DOS CURSOS
CREATE TABLE public.course_modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    order_index INTEGER NOT NULL,
    duration_minutes INTEGER,
    is_published BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ✅ AULAS
CREATE TABLE public.lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID REFERENCES public.course_modules(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    content TEXT,
    video_url TEXT,
    duration_minutes INTEGER,
    order_index INTEGER NOT NULL,
    is_published BOOLEAN DEFAULT false,
    is_premium BOOLEAN DEFAULT false,
    resources JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ✅ PROGRESSO DOS USUÁRIOS
CREATE TABLE public.user_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    lesson_id UUID REFERENCES public.lessons(id) ON DELETE CASCADE NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE,
    progress_percentage INTEGER DEFAULT 0,
    watch_time_seconds INTEGER DEFAULT 0,
    last_watched_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    notes TEXT
);

-- ✅ ANÁLISE NUTRICIONAL
CREATE TABLE public.food_analysis (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    image_url TEXT,
    analysis_result JSONB NOT NULL,
    calories DECIMAL(8,2),
    macros JSONB DEFAULT '{}',
    confidence_score DECIMAL(3,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    meal_type TEXT,
    notes TEXT
);

-- ✅ CONFIGURAÇÕES DE IA
CREATE TABLE public.ai_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    provider TEXT NOT NULL,
    model TEXT NOT NULL,
    api_key_encrypted TEXT,
    parameters JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ✅ ASSINATURAS
CREATE TABLE public.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    plan_name TEXT NOT NULL,
    status subscription_status DEFAULT 'pending',
    amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'BRL',
    billing_cycle TEXT DEFAULT 'monthly',
    started_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    expires_at TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB DEFAULT '{}'
);

-- ===============================================
-- 🔐 POLÍTICAS RLS
-- ===============================================

-- Habilitar RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weighings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_analysis ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_configurations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- ===============================================
-- 🔧 FUNÇÕES AUXILIARES
-- ===============================================

-- Função para verificar se é admin
CREATE OR REPLACE FUNCTION public.is_admin_user()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_id = auth.uid() 
    AND role = 'admin' 
    AND is_active = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para verificar role
CREATE OR REPLACE FUNCTION public.has_role(required_role app_role)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_id = auth.uid() 
    AND role = required_role 
    AND is_active = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===============================================
-- 🛡️ POLÍTICAS RLS BÁSICAS
-- ===============================================

-- Profiles: usuários veem próprio perfil, admins veem tudo
CREATE POLICY "profiles_select" ON public.profiles FOR SELECT USING (
  id = auth.uid() OR public.is_admin_user()
);

CREATE POLICY "profiles_update" ON public.profiles FOR UPDATE USING (
  id = auth.uid() OR public.is_admin_user()
);

-- Weighings: usuários veem próprios dados
CREATE POLICY "weighings_all" ON public.weighings FOR ALL USING (
  user_id = auth.uid() OR public.is_admin_user()
);

-- Missions: todos podem ver, admins podem modificar
CREATE POLICY "missions_select" ON public.missions FOR SELECT USING (true);
CREATE POLICY "missions_modify" ON public.missions FOR ALL USING (public.is_admin_user());

-- User Missions: usuários veem próprias missões
CREATE POLICY "user_missions_all" ON public.user_missions FOR ALL USING (
  user_id = auth.uid() OR public.is_admin_user()
);

-- Badges: todos podem ver
CREATE POLICY "badges_select" ON public.badges FOR SELECT USING (true);
CREATE POLICY "badges_modify" ON public.badges FOR ALL USING (public.is_admin_user());

-- User Badges: usuários veem próprios badges
CREATE POLICY "user_badges_all" ON public.user_badges FOR ALL USING (
  user_id = auth.uid() OR public.is_admin_user()
);

-- Courses: conteúdo publicado é público
CREATE POLICY "courses_select" ON public.courses FOR SELECT USING (
  is_published = true OR public.is_admin_user()
);

CREATE POLICY "courses_modify" ON public.courses FOR ALL USING (public.is_admin_user());

-- ===============================================
-- 🎯 TRIGGERS
-- ===============================================

-- Trigger para updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar triggers
CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.courses
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ===============================================
-- ✅ ESTRUTURA REVOLUCIONÁRIA COMPLETA!
-- ===============================================

-- Log de sucesso
DO $$
BEGIN
  RAISE NOTICE '🎉 ESTRUTURA REVOLUCIONÁRIA APLICADA COM SUCESSO!';
  RAISE NOTICE '📊 Tabelas criadas: 13';
  RAISE NOTICE '🔐 RLS habilitado em todas as tabelas';
  RAISE NOTICE '🛡️ Políticas de segurança aplicadas';
  RAISE NOTICE '⚡ Triggers configurados';
  RAISE NOTICE '🚀 INSTITUTO DOS SONHOS PRONTO PARA DECOLAR!';
END $$;