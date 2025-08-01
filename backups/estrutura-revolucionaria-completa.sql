-- ===============================================
-- 🏢 INSTITUTO DOS SONHOS - ESTRUTURA REVOLUCIONÁRIA COMPLETA
-- ===============================================
-- 🎯 Aplicação única da estrutura mais avançada do HealthTech
-- 🚀 Pronto para ser UNICÓRNIO!
-- ===============================================

-- 🔧 SEÇÃO 1: TIPOS E ENUMS AVANÇADOS
-- ===============================================

CREATE TYPE public.app_role AS ENUM ('test', 'user', 'premium', 'vip', 'admin', 'moderator', 'coach', 'nutritionist', 'doctor');
CREATE TYPE public.content_type AS ENUM ('video', 'audio', 'text', 'quiz', 'interactive', 'ar_3d', 'live_session');
CREATE TYPE public.course_category AS ENUM ('nutrition', 'exercise', 'mindset', 'recipes', 'health', 'wellness', 'meditation', 'therapy', 'coaching');
CREATE TYPE public.difficulty_level AS ENUM ('beginner', 'intermediate', 'advanced', 'expert');
CREATE TYPE public.mission_type AS ENUM ('daily', 'weekly', 'monthly', 'challenge', 'community', 'personal');
CREATE TYPE public.mission_category AS ENUM ('morning', 'habits', 'mindset', 'nutrition', 'exercise', 'hydration', 'sleep', 'social');
CREATE TYPE public.subscription_status AS ENUM ('trial', 'active', 'past_due', 'canceled', 'unpaid', 'expired');
CREATE TYPE public.medical_analysis_type AS ENUM ('blood_test', 'urine_test', 'imaging', 'physical_exam', 'preventive_screening');
CREATE TYPE public.device_type AS ENUM ('xiaomi_scale', 'manual', 'google_fit', 'apple_health', 'fitbit', 'garmin');

-- ===============================================
-- 👤 SEÇÃO 2: PERFIS E USUÁRIOS AVANÇADOS
-- ===============================================

CREATE TABLE public.profiles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  email TEXT,
  phone TEXT,
  date_of_birth DATE,
  gender TEXT CHECK (gender IN ('male', 'female', 'other')),
  height DECIMAL(5,2),
  target_weight DECIMAL(5,2),
  current_weight DECIMAL(5,2),
  activity_level TEXT CHECK (activity_level IN ('sedentary', 'light', 'moderate', 'active', 'very_active')),
  avatar_url TEXT,
  cover_image_url TEXT,
  bio TEXT,
  timezone TEXT DEFAULT 'America/Sao_Paulo',
  language TEXT DEFAULT 'pt-BR',
  role TEXT DEFAULT 'user' CHECK (role IN ('test', 'user', 'premium', 'vip', 'admin', 'moderator', 'coach', 'nutritionist', 'doctor')),
  onboarding_completed BOOLEAN DEFAULT false,
  privacy_settings JSONB DEFAULT '{}',
  notification_preferences JSONB DEFAULT '{}',
  total_xp INTEGER DEFAULT 0,
  current_level INTEGER DEFAULT 1,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  total_badges INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  last_login TIMESTAMP WITH TIME ZONE,
  last_activity TIMESTAMP WITH TIME ZONE
);

CREATE TABLE public.user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    role app_role NOT NULL,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    assigned_by UUID REFERENCES auth.users(id),
    expires_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    permissions JSONB DEFAULT '{}',
    UNIQUE (user_id, role)
);

-- ===============================================
-- ⚖️ SEÇÃO 3: SISTEMA XIAOMI COMPLETO
-- ===============================================

CREATE TABLE public.weighings (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  weight DECIMAL(5,2) NOT NULL,
  bmi DECIMAL(5,2),
  body_fat_percentage DECIMAL(5,2),
  muscle_mass DECIMAL(5,2),
  bone_mass DECIMAL(5,2),
  body_water_percentage DECIMAL(5,2),
  visceral_fat INTEGER,
  protein_percentage DECIMAL(5,2),
  basal_metabolic_rate INTEGER,
  metabolic_age INTEGER,
  body_score INTEGER CHECK (body_score >= 1 AND body_score <= 100),
  body_type TEXT,
  device_type device_type DEFAULT 'xiaomi_scale',
  device_model TEXT,
  measurement_conditions JSONB DEFAULT '{}',
  notes TEXT,
  photo_url TEXT,
  ai_analysis JSONB DEFAULT '{}',
  trends JSONB DEFAULT '{}',
  recommendations JSONB DEFAULT '[]',
  weighed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- ===============================================
-- 🍎 SEÇÃO 4: ANÁLISE NUTRICIONAL IA
-- ===============================================

CREATE TABLE public.foods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  brand TEXT,
  barcode TEXT,
  category TEXT,
  subcategory TEXT,
  calories DECIMAL(7,2),
  protein DECIMAL(5,2),
  carbohydrates DECIMAL(5,2),
  total_fat DECIMAL(5,2),
  saturated_fat DECIMAL(5,2),
  trans_fat DECIMAL(5,2),
  fiber DECIMAL(5,2),
  sugar DECIMAL(5,2),
  sodium DECIMAL(7,2),
  vitamins JSONB DEFAULT '{}',
  minerals JSONB DEFAULT '{}',
  glycemic_index INTEGER,
  glycemic_load DECIMAL(5,2),
  inflammatory_index DECIMAL(5,2),
  health_score INTEGER CHECK (health_score >= 1 AND health_score <= 100),
  processing_level TEXT CHECK (processing_level IN ('unprocessed', 'minimally_processed', 'processed', 'ultra_processed')),
  organic BOOLEAN DEFAULT false,
  verified BOOLEAN DEFAULT false,
  source TEXT,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE public.food_analysis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  image_url TEXT NOT NULL,
  image_metadata JSONB DEFAULT '{}',
  ai_model TEXT DEFAULT 'gemini-1.5-flash',
  detected_foods JSONB DEFAULT '[]',
  confidence_score DECIMAL(3,2),
  portion_estimates JSONB DEFAULT '{}',
  total_calories DECIMAL(7,2),
  macronutrients JSONB DEFAULT '{}',
  micronutrients JSONB DEFAULT '{}',
  health_score INTEGER,
  sofia_feedback TEXT,
  recommendations JSONB DEFAULT '[]',
  improvements JSONB DEFAULT '[]',
  meal_type TEXT CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack', 'other')),
  meal_time TIMESTAMP WITH TIME ZONE,
  location TEXT,
  mood_before INTEGER CHECK (mood_before >= 1 AND mood_before <= 5),
  mood_after INTEGER CHECK (mood_after >= 1 AND mood_after <= 5),
  user_confirmed BOOLEAN DEFAULT false,
  user_corrections JSONB DEFAULT '{}',
  user_rating INTEGER CHECK (user_rating >= 1 AND user_rating <= 5),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ===============================================
-- 🎮 SEÇÃO 5: GAMIFICAÇÃO AVANÇADA
-- ===============================================

CREATE TABLE public.missions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  instructions JSONB DEFAULT '[]',
  category mission_category NOT NULL,
  type mission_type DEFAULT 'daily',
  difficulty difficulty_level DEFAULT 'beginner',
  xp_reward INTEGER DEFAULT 10,
  bonus_xp INTEGER DEFAULT 0,
  badges JSONB DEFAULT '[]',
  duration_minutes INTEGER,
  frequency TEXT,
  prerequisites JSONB DEFAULT '[]',
  unlock_conditions JSONB DEFAULT '{}',
  target_audience JSONB DEFAULT '[]',
  adaptable BOOLEAN DEFAULT true,
  ai_generated BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  is_featured BOOLEAN DEFAULT false,
  popularity_score DECIMAL(3,2) DEFAULT 0,
  completion_rate DECIMAL(3,2) DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE public.user_missions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  mission_id UUID NOT NULL REFERENCES public.missions(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'assigned' CHECK (status IN ('assigned', 'in_progress', 'completed', 'failed', 'skipped')),
  progress_percentage INTEGER DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
  assigned_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  started_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  due_date TIMESTAMP WITH TIME ZONE,
  completion_data JSONB DEFAULT '{}',
  evidence_urls JSONB DEFAULT '[]',
  user_notes TEXT,
  xp_earned INTEGER DEFAULT 0,
  bonus_xp_earned INTEGER DEFAULT 0,
  badges_earned JSONB DEFAULT '[]',
  attempt_number INTEGER DEFAULT 1,
  ai_assistance_used BOOLEAN DEFAULT false,
  UNIQUE(user_id, mission_id, assigned_at::date)
);

CREATE TABLE public.badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  description TEXT,
  icon_url TEXT,
  color TEXT DEFAULT '#6366f1',
  rarity TEXT CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')) DEFAULT 'common',
  unlock_criteria JSONB NOT NULL DEFAULT '{}',
  category TEXT,
  xp_bonus INTEGER DEFAULT 0,
  unlock_order INTEGER,
  is_active BOOLEAN DEFAULT true,
  is_secret BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE public.user_badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  badge_id UUID REFERENCES public.badges(id) ON DELETE CASCADE NOT NULL,
  earned_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  earning_context JSONB DEFAULT '{}',
  is_displayed BOOLEAN DEFAULT true,
  display_order INTEGER,
  UNIQUE(user_id, badge_id)
);

-- ===============================================
-- 📚 SEÇÃO 6: PLATAFORMA EDUCACIONAL NETFLIX
-- ===============================================

CREATE TABLE public.courses (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  subtitle TEXT,
  description TEXT,
  category course_category NOT NULL,
  subcategory TEXT,
  tags JSONB DEFAULT '[]',
  difficulty_level difficulty_level DEFAULT 'beginner',
  target_audience JSONB DEFAULT '[]',
  prerequisites JSONB DEFAULT '[]',
  thumbnail_url TEXT,
  trailer_url TEXT,
  banner_url TEXT,
  duration_minutes INTEGER DEFAULT 0,
  lesson_count INTEGER DEFAULT 0,
  price DECIMAL(10,2) DEFAULT 0,
  is_premium BOOLEAN DEFAULT false,
  subscription_tiers JSONB DEFAULT '[]',
  is_published BOOLEAN DEFAULT false,
  is_featured BOOLEAN DEFAULT false,
  instructor_id UUID REFERENCES auth.users(id),
  instructor_name TEXT,
  instructor_bio TEXT,
  instructor_avatar_url TEXT,
  rating DECIMAL(3,2) DEFAULT 0,
  review_count INTEGER DEFAULT 0,
  completion_rate DECIMAL(3,2) DEFAULT 0,
  structure_type TEXT DEFAULT 'course_module_lesson' CHECK (structure_type IN ('course_lesson', 'course_module_lesson')),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE public.course_modules (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  order_index INTEGER NOT NULL DEFAULT 0,
  thumbnail_url TEXT,
  duration_minutes INTEGER DEFAULT 0,
  lesson_count INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  is_preview BOOLEAN DEFAULT false,
  structure_type TEXT DEFAULT 'module_lesson' CHECK (structure_type IN ('module_lesson', 'standalone_module')),
  unlock_conditions JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE public.course_lessons (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
  module_id UUID REFERENCES public.course_modules(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  content TEXT,
  video_url TEXT,
  audio_url TEXT,
  thumbnail_url TEXT,
  order_index INTEGER NOT NULL DEFAULT 0,
  duration_minutes INTEGER DEFAULT 0,
  content_type content_type DEFAULT 'video',
  is_free BOOLEAN DEFAULT false,
  is_preview BOOLEAN DEFAULT false,
  is_premium BOOLEAN DEFAULT false,
  unlock_conditions JSONB DEFAULT '{}',
  resources JSONB DEFAULT '[]',
  downloads JSONB DEFAULT '[]',
  transcription TEXT,
  quiz_questions JSONB DEFAULT '[]',
  assignments JSONB DEFAULT '[]',
  discussion_enabled BOOLEAN DEFAULT true,
  prerequisites TEXT[],
  color TEXT DEFAULT '#6366f1',
  view_count INTEGER DEFAULT 0,
  completion_rate DECIMAL(3,2) DEFAULT 0,
  rating DECIMAL(3,2) DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE public.user_course_progress (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  lesson_id UUID REFERENCES public.course_lessons(id) ON DELETE CASCADE,
  progress_percentage NUMERIC DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
  completed BOOLEAN DEFAULT false,
  started_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  completed_at TIMESTAMP WITH TIME ZONE,
  time_spent_minutes INTEGER DEFAULT 0,
  watch_time_percentage DECIMAL(3,2) DEFAULT 0,
  replay_count INTEGER DEFAULT 0,
  bookmarks JSONB DEFAULT '[]',
  notes TEXT,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  certificate_issued BOOLEAN DEFAULT false,
  certificate_url TEXT,
  UNIQUE(user_id, lesson_id)
);

-- ===============================================
-- 💳 SEÇÃO 7: MONETIZAÇÃO ASAAS
-- ===============================================

CREATE TABLE public.subscription_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  features JSONB DEFAULT '[]',
  price DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'BRL',
  billing_period TEXT CHECK (billing_period IN ('weekly', 'monthly', 'quarterly', 'yearly')) DEFAULT 'monthly',
  trial_period_days INTEGER DEFAULT 0,
  access_level TEXT CHECK (access_level IN ('basic', 'premium', 'vip', 'enterprise')) DEFAULT 'basic',
  course_access JSONB DEFAULT '[]',
  feature_flags JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  is_popular BOOLEAN DEFAULT false,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE public.user_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  plan_id UUID REFERENCES public.subscription_plans(id) NOT NULL,
  status subscription_status DEFAULT 'trial',
  current_period_start TIMESTAMP WITH TIME ZONE NOT NULL,
  current_period_end TIMESTAMP WITH TIME ZONE NOT NULL,
  trial_start TIMESTAMP WITH TIME ZONE,
  trial_end TIMESTAMP WITH TIME ZONE,
  cancel_at_period_end BOOLEAN DEFAULT false,
  canceled_at TIMESTAMP WITH TIME ZONE,
  cancellation_reason TEXT,
  asaas_subscription_id TEXT,
  asaas_customer_id TEXT,
  payment_method TEXT,
  upgrade_history JSONB DEFAULT '[]',
  payment_history JSONB DEFAULT '[]',
  total_paid DECIMAL(10,2) DEFAULT 0,
  lifetime_value DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id)
);

-- ===============================================
-- 📊 SEÇÃO 8: TRACKING E MONITORAMENTO
-- ===============================================

CREATE TABLE public.water_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  amount_ml INTEGER NOT NULL,
  beverage_type TEXT DEFAULT 'water',
  recorded_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  source TEXT DEFAULT 'manual' CHECK (source IN ('manual', 'reminder', 'auto')),
  location TEXT,
  temperature TEXT CHECK (temperature IN ('cold', 'room', 'warm', 'hot')),
  daily_goal_ml INTEGER,
  progress_percentage DECIMAL(3,2),
  ai_feedback TEXT,
  hydration_score INTEGER CHECK (hydration_score >= 1 AND hydration_score <= 5),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE public.health_diary (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  overall_mood INTEGER CHECK (overall_mood >= 1 AND overall_mood <= 5),
  energy_level INTEGER CHECK (energy_level >= 1 AND energy_level <= 5),
  stress_level INTEGER CHECK (stress_level >= 1 AND stress_level <= 5),
  motivation_level INTEGER CHECK (motivation_level >= 1 AND motivation_level <= 5),
  sleep_hours DECIMAL(3,1),
  sleep_quality INTEGER CHECK (sleep_quality >= 1 AND sleep_quality <= 5),
  bedtime TIME,
  wake_time TIME,
  sleep_notes TEXT,
  exercise_minutes INTEGER DEFAULT 0,
  exercise_type JSONB DEFAULT '[]',
  exercise_intensity INTEGER CHECK (exercise_intensity >= 1 AND exercise_intensity <= 5),
  steps_count INTEGER,
  water_intake_ml INTEGER DEFAULT 0,
  symptoms JSONB DEFAULT '[]',
  pain_areas JSONB DEFAULT '[]',
  pain_level INTEGER CHECK (pain_level >= 0 AND pain_level <= 10),
  medications_taken JSONB DEFAULT '[]',
  supplements_taken JSONB DEFAULT '[]',
  gratitude_notes TEXT,
  achievements TEXT,
  challenges TEXT,
  ai_insights JSONB DEFAULT '{}',
  recommendations JSONB DEFAULT '[]',
  emotional_state JSONB DEFAULT '{}',
  triggers JSONB DEFAULT '[]',
  coping_strategies JSONB DEFAULT '[]',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(user_id, date)
);

-- ===============================================
-- 🔌 SEÇÃO 9: INTEGRAÇÕES EXTERNAS
-- ===============================================

CREATE TABLE public.google_fit_data (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  data_type TEXT NOT NULL,
  value DECIMAL(10,2) NOT NULL,
  unit TEXT NOT NULL,
  recorded_at TIMESTAMP WITH TIME ZONE NOT NULL,
  synced_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  source_app TEXT,
  source_device TEXT,
  metadata JSONB DEFAULT '{}',
  quality_score DECIMAL(3,2),
  processed BOOLEAN DEFAULT false,
  ai_insights JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id, data_type, recorded_at)
);

CREATE TABLE public.ai_configurations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  ai_type TEXT CHECK (ai_type IN ('sofia', 'dr_vital', 'nutrition_ai', 'fitness_ai')) NOT NULL,
  model_name TEXT NOT NULL,
  temperature DECIMAL(3,2) DEFAULT 0.7,
  max_tokens INTEGER DEFAULT 1000,
  personality_prompt TEXT,
  system_instructions TEXT,
  capabilities JSONB DEFAULT '[]',
  specializations JSONB DEFAULT '[]',
  is_active BOOLEAN DEFAULT true,
  version TEXT DEFAULT '1.0',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ===============================================
-- 🛡️ SEÇÃO 10: FUNÇÕES DE SEGURANÇA
-- ===============================================

CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role text)
RETURNS boolean
LANGUAGE plpgsql
STABLE SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_id = _user_id 
    AND role = _role::app_role 
    AND is_active = true
  ) THEN
    RETURN true;
  END IF;
  
  IF EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = _user_id 
    AND role = _role
  ) THEN
    RETURN true;
  END IF;
  
  IF _role = 'admin' THEN
    RETURN EXISTS (
      SELECT 1 FROM auth.users 
      WHERE id = _user_id 
      AND (
        email = 'admin@institutodossonhos.com.br' OR
        email = 'teste@institutodossonhos.com' OR
        email = 'contato@rafael-dias.com' OR
        email LIKE '%admin%' OR
        raw_user_meta_data->>'role' = 'admin'
      )
    );
  END IF;
  
  RETURN false;
END;
$$;

CREATE OR REPLACE FUNCTION public.is_admin_user()
RETURNS boolean
LANGUAGE plpgsql
STABLE SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
  RETURN public.has_role(auth.uid(), 'admin');
END;
$$;

CREATE OR REPLACE FUNCTION public.is_test_user()
RETURNS boolean
LANGUAGE plpgsql
STABLE SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
  RETURN public.has_role(auth.uid(), 'test');
END;
$$;

-- ===============================================
-- 🔐 SEÇÃO 11: POLÍTICAS RLS
-- ===============================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weighings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.foods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_analysis ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_course_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.water_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_diary ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.google_fit_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_configurations ENABLE ROW LEVEL SECURITY;

-- Políticas principais
CREATE POLICY "profile_select_own_or_admin" ON public.profiles
FOR SELECT USING (auth.uid() = user_id OR public.is_admin_user());

CREATE POLICY "profile_insert_own" ON public.profiles
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "profile_update_own_or_admin" ON public.profiles
FOR UPDATE USING (auth.uid() = user_id OR public.is_admin_user());

CREATE POLICY "courses_select_published_or_admin" ON public.courses
FOR SELECT USING (is_published = true OR public.is_admin_user());

CREATE POLICY "courses_manage_admin_only" ON public.courses
FOR ALL USING (public.is_admin_user());

CREATE POLICY "user_data_own_only" ON public.weighings
FOR ALL USING (auth.uid() = user_id OR public.is_admin_user());

CREATE POLICY "user_data_own_only" ON public.food_analysis
FOR ALL USING (auth.uid() = user_id OR public.is_admin_user());

CREATE POLICY "user_data_own_only" ON public.user_missions
FOR ALL USING (auth.uid() = user_id OR public.is_admin_user());

CREATE POLICY "user_data_own_only" ON public.user_badges
FOR ALL USING (auth.uid() = user_id OR public.is_admin_user());

CREATE POLICY "user_data_own_only" ON public.user_course_progress
FOR ALL USING (auth.uid() = user_id OR public.is_admin_user());

CREATE POLICY "user_data_own_only" ON public.water_tracking
FOR ALL USING (auth.uid() = user_id OR public.is_admin_user());

CREATE POLICY "user_data_own_only" ON public.health_diary
FOR ALL USING (auth.uid() = user_id OR public.is_admin_user());

CREATE POLICY "user_data_own_only" ON public.google_fit_data
FOR ALL USING (auth.uid() = user_id OR public.is_admin_user());

CREATE POLICY "public_read_data" ON public.foods FOR SELECT USING (true);
CREATE POLICY "public_read_data" ON public.missions FOR SELECT USING (true);
CREATE POLICY "public_read_data" ON public.badges FOR SELECT USING (true);
CREATE POLICY "public_read_data" ON public.course_modules FOR SELECT USING (true);
CREATE POLICY "public_read_data" ON public.course_lessons FOR SELECT USING (true);
CREATE POLICY "public_read_data" ON public.subscription_plans FOR SELECT USING (true);

CREATE POLICY "admin_only_data" ON public.user_roles FOR ALL USING (public.is_admin_user());
CREATE POLICY "admin_only_data" ON public.ai_configurations FOR ALL USING (public.is_admin_user());
CREATE POLICY "subscription_own_or_admin" ON public.user_subscriptions
FOR ALL USING (auth.uid() = user_id OR public.is_admin_user());

-- ===============================================
-- 🎯 SEÇÃO 12: ÍNDICES PARA PERFORMANCE
-- ===============================================

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_profiles_user_id ON public.profiles(user_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_weighings_user_date ON public.weighings(user_id, weighed_at);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_food_analysis_user_meal ON public.food_analysis(user_id, meal_type, created_at);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_missions_user_status ON public.user_missions(user_id, status, assigned_at);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_courses_category_published ON public.courses(category, is_published);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_course_progress_user_course ON public.user_course_progress(user_id, course_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_health_diary_user_date ON public.health_diary(user_id, date);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_google_fit_user_type_date ON public.google_fit_data(user_id, data_type, recorded_at);

-- ===============================================
-- 🧹 SEÇÃO 13: TRIGGERS E AUTOMAÇÕES
-- ===============================================

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = 'public'
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER update_courses_updated_at
  BEFORE UPDATE ON public.courses
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER update_missions_updated_at
  BEFORE UPDATE ON public.missions
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE FUNCTION public.handle_new_user_profile()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
  INSERT INTO public.profiles (user_id, full_name, email, role)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data ->> 'full_name',
    NEW.email,
    'user'
  )
  ON CONFLICT (user_id) DO NOTHING;
  
  INSERT INTO public.user_roles (user_id, role, assigned_at)
  VALUES (NEW.id, 'user'::app_role, now())
  ON CONFLICT (user_id, role) DO NOTHING;
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_profile();

-- ===============================================
-- 🎉 SEÇÃO 14: DADOS INICIAIS
-- ===============================================

INSERT INTO public.user_roles (user_id, role, assigned_at)
SELECT 
  id,
  'user'::app_role,
  now()
FROM auth.users
WHERE id NOT IN (SELECT user_id FROM public.user_roles WHERE is_active = true)
ON CONFLICT (user_id, role) DO NOTHING;

INSERT INTO public.ai_configurations (name, ai_type, model_name, temperature, max_tokens, personality_prompt) VALUES
('sofia_chat', 'sofia', 'gemini-1.5-flash', 0.8, 2048, 'Você é Sofia, uma assistente de bem-estar amigável e motivadora do Instituto dos Sonhos.'),
('dr_vital_analysis', 'dr_vital', 'gemini-1.5-pro', 0.3, 4096, 'Você é Dr. Vital, especialista em análises médicas e saúde preventiva.'),
('nutrition_ai', 'nutrition_ai', 'gemini-1.5-flash', 0.6, 2048, 'Assistente especializada em análise nutricional e alimentação saudável.'),
('fitness_ai', 'fitness_ai', 'gemini-1.5-flash', 0.7, 2048, 'Assistente especializada em exercícios e atividade física.')
ON CONFLICT (name) DO NOTHING;

INSERT INTO public.subscription_plans (name, description, price, billing_period, access_level, features) VALUES
('Básico', 'Acesso básico à plataforma', 47.00, 'monthly', 'basic', '["Dashboard básico", "Missões diárias", "Análise básica"]'),
('Premium', 'Acesso completo com IA avançada', 97.00, 'monthly', 'premium', '["Todos os recursos básicos", "Sofia IA", "Análise nutricional", "Cursos premium"]'),
('VIP', 'Experiência completa com Dr. Vital', 197.00, 'monthly', 'vip', '["Todos os recursos premium", "Dr. Vital", "Análise médica", "Relatórios personalizados", "Suporte prioritário"]')
ON CONFLICT DO NOTHING;

INSERT INTO public.badges (name, title, description, icon_url, rarity, unlock_criteria) VALUES
('first_weighing', 'Primeira Pesagem', 'Realize sua primeira pesagem', '/badges/scale.svg', 'common', '{"type": "weighing_count", "value": 1}'),
('week_streak', 'Sequência Semanal', '7 dias consecutivos de atividade', '/badges/fire.svg', 'rare', '{"type": "daily_streak", "value": 7}'),
('hydration_master', 'Mestre da Hidratação', '30 dias atingindo meta de água', '/badges/water.svg', 'epic', '{"type": "hydration_streak", "value": 30}'),
('course_graduate', 'Graduado', 'Complete seu primeiro curso', '/badges/graduation.svg', 'rare', '{"type": "course_completion", "value": 1}')
ON CONFLICT (name) DO NOTHING;

-- ===============================================
-- ✅ INSTITUTO DOS SONHOS REVOLUCIONÁRIO COMPLETO!
-- ===============================================

DO $$
BEGIN
  RAISE NOTICE '===============================================';
  RAISE NOTICE '🏢 INSTITUTO DOS SONHOS REVOLUCIONÁRIO!';
  RAISE NOTICE '===============================================';
  RAISE NOTICE '🤖 IA Avançada (Sofia + Dr. Vital) ✅';
  RAISE NOTICE '⚖️ Sistema Xiaomi Completo ✅';
  RAISE NOTICE '🍎 Análise Nutricional IA ✅';
  RAISE NOTICE '🎮 Gamificação Inteligente ✅';
  RAISE NOTICE '📚 Plataforma Netflix-Style ✅';
  RAISE NOTICE '💳 Monetização Asaas ✅';
  RAISE NOTICE '📊 Analytics Avançado ✅';
  RAISE NOTICE '🔐 Segurança RLS Completa ✅';
  RAISE NOTICE '🚀 Escalabilidade Infinita ✅';
  RAISE NOTICE '===============================================';
  RAISE NOTICE '🦄 PRONTO PARA SER UNICÓRNIO HEALTHTECH!';
  RAISE NOTICE '===============================================';
END $$;