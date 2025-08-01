-- ===============================================
-- 🏢 INSTITUTO DOS SONHOS - BANCO DE DADOS COMPLETO
-- ===============================================
-- 🎯 Plataforma Revolucionária de Saúde e Bem-Estar Integral
-- 🤖 IA Avançada + Gamificação + Análise 3D + Educação + Medicina Preventiva
-- 💎 Arquitetura para Escalar para Milhões de Usuários
-- ===============================================

-- 🔧 SEÇÃO 1: TIPOS E ENUMS AVANÇADOS
-- ===============================================

-- Enum para roles do sistema (expandido)
CREATE TYPE public.app_role AS ENUM ('test', 'user', 'premium', 'vip', 'admin', 'moderator', 'coach', 'nutritionist', 'doctor');

-- Enum para tipos de conteúdo
CREATE TYPE public.content_type AS ENUM ('video', 'audio', 'text', 'quiz', 'interactive', 'ar_3d', 'live_session');

-- Enum para categorias de curso
CREATE TYPE public.course_category AS ENUM ('nutrition', 'exercise', 'mindset', 'recipes', 'health', 'wellness', 'meditation', 'therapy', 'coaching');

-- Enum para dificuldades
CREATE TYPE public.difficulty_level AS ENUM ('beginner', 'intermediate', 'advanced', 'expert');

-- Enum para tipos de missão
CREATE TYPE public.mission_type AS ENUM ('daily', 'weekly', 'monthly', 'challenge', 'community', 'personal');

-- Enum para categorias de missão
CREATE TYPE public.mission_category AS ENUM ('morning', 'habits', 'mindset', 'nutrition', 'exercise', 'hydration', 'sleep', 'social');

-- Enum para status de assinatura
CREATE TYPE public.subscription_status AS ENUM ('trial', 'active', 'past_due', 'canceled', 'unpaid', 'expired');

-- Enum para tipos de análise médica
CREATE TYPE public.medical_analysis_type AS ENUM ('blood_test', 'urine_test', 'imaging', 'physical_exam', 'preventive_screening');

-- Enum para tipos de dispositivo
CREATE TYPE public.device_type AS ENUM ('xiaomi_scale', 'manual', 'google_fit', 'apple_health', 'fitbit', 'garmin');

-- ===============================================
-- 👤 SEÇÃO 2: PERFIS E USUÁRIOS AVANÇADOS
-- ===============================================

-- 2.1 Perfis de usuário expandidos
CREATE TABLE public.profiles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Dados básicos
  full_name TEXT,
  email TEXT,
  phone TEXT,
  date_of_birth DATE,
  gender TEXT CHECK (gender IN ('male', 'female', 'other')),
  
  -- Dados físicos
  height DECIMAL(5,2), -- cm
  target_weight DECIMAL(5,2), -- kg
  current_weight DECIMAL(5,2), -- kg
  activity_level TEXT CHECK (activity_level IN ('sedentary', 'light', 'moderate', 'active', 'very_active')),
  
  -- Personalização
  avatar_url TEXT,
  cover_image_url TEXT,
  bio TEXT,
  timezone TEXT DEFAULT 'America/Sao_Paulo',
  language TEXT DEFAULT 'pt-BR',
  
  -- Sistema
  role TEXT DEFAULT 'user' CHECK (role IN ('test', 'user', 'premium', 'vip', 'admin', 'moderator', 'coach', 'nutritionist', 'doctor')),
  onboarding_completed BOOLEAN DEFAULT false,
  privacy_settings JSONB DEFAULT '{}',
  notification_preferences JSONB DEFAULT '{}',
  
  -- Gamificação
  total_xp INTEGER DEFAULT 0,
  current_level INTEGER DEFAULT 1,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  total_badges INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  last_login TIMESTAMP WITH TIME ZONE,
  last_activity TIMESTAMP WITH TIME ZONE
);

-- 2.2 Sistema de roles robusto
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

-- 2.3 Anamnese sistêmica digital
CREATE TABLE public.anamnesis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- História médica
  medical_history JSONB DEFAULT '{}',
  current_medications JSONB DEFAULT '[]',
  allergies JSONB DEFAULT '[]',
  chronic_conditions JSONB DEFAULT '[]',
  family_history JSONB DEFAULT '{}',
  
  -- Estilo de vida
  smoking_status TEXT CHECK (smoking_status IN ('never', 'former', 'current')),
  alcohol_consumption TEXT CHECK (alcohol_consumption IN ('none', 'occasional', 'moderate', 'heavy')),
  exercise_frequency TEXT,
  sleep_quality INTEGER CHECK (sleep_quality >= 1 AND sleep_quality <= 5),
  stress_level INTEGER CHECK (stress_level >= 1 AND stress_level <= 5),
  
  -- Motivações e objetivos
  primary_goals JSONB DEFAULT '[]',
  motivation_factors JSONB DEFAULT '[]',
  previous_attempts JSONB DEFAULT '[]',
  
  -- Avaliação psicológica
  saboteur_patterns JSONB DEFAULT '{}',
  emotional_triggers JSONB DEFAULT '[]',
  support_system JSONB DEFAULT '{}',
  
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  
  UNIQUE(user_id)
);

-- ===============================================
-- ⚖️ SEÇÃO 3: SISTEMA DE PESAGEM E ANÁLISE CORPORAL AVANÇADO
-- ===============================================

-- 3.1 Pesagens com dados completos da balança Xiaomi
CREATE TABLE public.weighings (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Dados básicos
  weight DECIMAL(5,2) NOT NULL, -- kg
  bmi DECIMAL(5,2), -- calculado automaticamente
  
  -- Composição corporal
  body_fat_percentage DECIMAL(5,2),
  muscle_mass DECIMAL(5,2), -- kg
  bone_mass DECIMAL(5,2), -- kg
  body_water_percentage DECIMAL(5,2),
  visceral_fat INTEGER,
  protein_percentage DECIMAL(5,2),
  
  -- Metabolismo
  basal_metabolic_rate INTEGER, -- kcal
  metabolic_age INTEGER, -- anos
  
  -- Medidas adicionais
  body_score INTEGER CHECK (body_score >= 1 AND body_score <= 100),
  body_type TEXT,
  
  -- Circunferências (opcionais)
  waist_circumference DECIMAL(5,2), -- cm
  hip_circumference DECIMAL(5,2), -- cm
  chest_circumference DECIMAL(5,2), -- cm
  arm_circumference DECIMAL(5,2), -- cm
  thigh_circumference DECIMAL(5,2), -- cm
  
  -- Metadados
  device_type device_type DEFAULT 'xiaomi_scale',
  device_model TEXT,
  measurement_conditions JSONB DEFAULT '{}', -- hora do dia, jejum, etc.
  notes TEXT,
  photo_url TEXT, -- foto da balança/resultado
  
  -- Análise automática
  ai_analysis JSONB DEFAULT '{}',
  trends JSONB DEFAULT '{}',
  recommendations JSONB DEFAULT '[]',
  
  weighed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- 3.2 Metas corporais personalizadas
CREATE TABLE public.body_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Metas de peso
  target_weight DECIMAL(5,2),
  target_bmi DECIMAL(5,2),
  target_body_fat_percentage DECIMAL(5,2),
  target_muscle_mass DECIMAL(5,2),
  target_waist_circumference DECIMAL(5,2),
  
  -- Timeline
  start_date DATE DEFAULT CURRENT_DATE,
  target_date DATE,
  weekly_goal DECIMAL(4,2), -- kg por semana
  
  -- Status
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'paused', 'completed', 'cancelled')),
  progress_percentage DECIMAL(5,2) DEFAULT 0,
  
  -- Configurações
  reminder_frequency TEXT DEFAULT 'daily',
  coaching_enabled BOOLEAN DEFAULT true,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ===============================================
-- 🍎 SEÇÃO 4: SISTEMA DE ANÁLISE NUTRICIONAL AVANÇADO
-- ===============================================

-- 4.1 Base de dados de alimentos expandida
CREATE TABLE public.foods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Identificação
  name TEXT NOT NULL,
  brand TEXT,
  barcode TEXT,
  category TEXT,
  subcategory TEXT,
  
  -- Informações nutricionais (por 100g)
  calories DECIMAL(7,2),
  protein DECIMAL(5,2),
  carbohydrates DECIMAL(5,2),
  total_fat DECIMAL(5,2),
  saturated_fat DECIMAL(5,2),
  trans_fat DECIMAL(5,2),
  fiber DECIMAL(5,2),
  sugar DECIMAL(5,2),
  sodium DECIMAL(7,2), -- mg
  
  -- Micronutrientes
  vitamins JSONB DEFAULT '{}',
  minerals JSONB DEFAULT '{}',
  
  -- Índices
  glycemic_index INTEGER,
  glycemic_load DECIMAL(5,2),
  inflammatory_index DECIMAL(5,2),
  
  -- Metadados
  portion_sizes JSONB DEFAULT '[]', -- tamanhos de porção comuns
  preparation_methods JSONB DEFAULT '[]',
  storage_instructions TEXT,
  allergens JSONB DEFAULT '[]',
  
  -- Qualidade
  health_score INTEGER CHECK (health_score >= 1 AND health_score <= 100),
  processing_level TEXT CHECK (processing_level IN ('unprocessed', 'minimally_processed', 'processed', 'ultra_processed')),
  organic BOOLEAN DEFAULT false,
  
  -- Sistema
  verified BOOLEAN DEFAULT false,
  source TEXT,
  image_url TEXT,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 4.2 Análise de alimentos por imagem (Sofia IA)
CREATE TABLE public.food_analysis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Imagem
  image_url TEXT NOT NULL,
  image_metadata JSONB DEFAULT '{}',
  
  -- Análise da IA
  ai_model TEXT DEFAULT 'gemini-1.5-flash',
  detected_foods JSONB DEFAULT '[]', -- alimentos identificados
  confidence_score DECIMAL(3,2), -- 0-1
  portion_estimates JSONB DEFAULT '{}',
  
  -- Cálculos nutricionais
  total_calories DECIMAL(7,2),
  macronutrients JSONB DEFAULT '{}',
  micronutrients JSONB DEFAULT '{}',
  health_score INTEGER,
  
  -- Feedback da Sofia
  sofia_feedback TEXT,
  recommendations JSONB DEFAULT '[]',
  improvements JSONB DEFAULT '[]',
  
  -- Contexto
  meal_type TEXT CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack', 'other')),
  meal_time TIMESTAMP WITH TIME ZONE,
  location TEXT,
  mood_before INTEGER CHECK (mood_before >= 1 AND mood_before <= 5),
  mood_after INTEGER CHECK (mood_after >= 1 AND mood_after <= 5),
  
  -- Validação do usuário
  user_confirmed BOOLEAN DEFAULT false,
  user_corrections JSONB DEFAULT '{}',
  user_rating INTEGER CHECK (user_rating >= 1 AND user_rating <= 5),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 4.3 Diário alimentar detalhado
CREATE TABLE public.food_diary (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Refeição
  meal_type TEXT CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack', 'other')),
  meal_time TIMESTAMP WITH TIME ZONE NOT NULL,
  
  -- Alimentos
  foods JSONB DEFAULT '[]', -- lista de alimentos com quantidades
  total_calories DECIMAL(7,2),
  macronutrients JSONB DEFAULT '{}',
  
  -- Contexto
  location TEXT,
  company TEXT, -- sozinho, família, amigos
  preparation_method TEXT,
  eating_speed TEXT CHECK (eating_speed IN ('very_slow', 'slow', 'normal', 'fast', 'very_fast')),
  
  -- Sensações
  hunger_before INTEGER CHECK (hunger_before >= 1 AND hunger_before <= 5),
  satiety_after INTEGER CHECK (satiety_after >= 1 AND satiety_after <= 5),
  mood_before INTEGER CHECK (mood_before >= 1 AND mood_before <= 5),
  mood_after INTEGER CHECK (mood_after >= 1 AND mood_after <= 5),
  energy_after INTEGER CHECK (energy_after >= 1 AND energy_after <= 5),
  
  -- Análise
  ai_analysis JSONB DEFAULT '{}',
  nutritionist_notes TEXT,
  
  -- Metadados
  photos JSONB DEFAULT '[]',
  notes TEXT,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ===============================================
-- 🎮 SEÇÃO 5: SISTEMA DE GAMIFICAÇÃO AVANÇADO
-- ===============================================

-- 5.1 Missões personalizadas e inteligentes
CREATE TABLE public.missions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  
  -- Identificação
  title TEXT NOT NULL,
  description TEXT,
  instructions JSONB DEFAULT '[]',
  
  -- Classificação
  category mission_category NOT NULL,
  type mission_type DEFAULT 'daily',
  difficulty difficulty_level DEFAULT 'beginner',
  
  -- Gamificação
  xp_reward INTEGER DEFAULT 10,
  bonus_xp INTEGER DEFAULT 0,
  badges JSONB DEFAULT '[]',
  
  -- Configuração
  duration_minutes INTEGER, -- tempo estimado
  frequency TEXT, -- daily, weekly, etc.
  prerequisites JSONB DEFAULT '[]',
  unlock_conditions JSONB DEFAULT '{}',
  
  -- Personalização
  target_audience JSONB DEFAULT '[]', -- roles, níveis, etc.
  adaptable BOOLEAN DEFAULT true,
  ai_generated BOOLEAN DEFAULT false,
  
  -- Conteúdo
  media_urls JSONB DEFAULT '[]',
  resources JSONB DEFAULT '[]',
  tips JSONB DEFAULT '[]',
  
  -- Sistema
  is_active BOOLEAN DEFAULT true,
  is_featured BOOLEAN DEFAULT false,
  popularity_score DECIMAL(3,2) DEFAULT 0,
  completion_rate DECIMAL(3,2) DEFAULT 0,
  
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- 5.2 Progresso das missões do usuário
CREATE TABLE public.user_missions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  mission_id UUID NOT NULL REFERENCES public.missions(id) ON DELETE CASCADE,
  
  -- Status
  status TEXT DEFAULT 'assigned' CHECK (status IN ('assigned', 'in_progress', 'completed', 'failed', 'skipped')),
  progress_percentage INTEGER DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
  
  -- Timestamps
  assigned_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  started_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  due_date TIMESTAMP WITH TIME ZONE,
  
  -- Dados de conclusão
  completion_data JSONB DEFAULT '{}',
  evidence_urls JSONB DEFAULT '[]', -- fotos, vídeos de evidência
  user_notes TEXT,
  
  -- Recompensas
  xp_earned INTEGER DEFAULT 0,
  bonus_xp_earned INTEGER DEFAULT 0,
  badges_earned JSONB DEFAULT '[]',
  
  -- Avaliação
  difficulty_rating INTEGER CHECK (difficulty_rating >= 1 AND difficulty_rating <= 5),
  enjoyment_rating INTEGER CHECK (enjoyment_rating >= 1 AND enjoyment_rating <= 5),
  
  -- Sistema
  attempt_number INTEGER DEFAULT 1,
  ai_assistance_used BOOLEAN DEFAULT false,
  
  UNIQUE(user_id, mission_id, assigned_at::date)
);

-- 5.3 Sistema de badges e conquistas
CREATE TABLE public.badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Identificação
  name TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  description TEXT,
  
  -- Visual
  icon_url TEXT,
  color TEXT DEFAULT '#6366f1',
  rarity TEXT CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')) DEFAULT 'common',
  
  -- Critérios
  unlock_criteria JSONB NOT NULL DEFAULT '{}',
  category TEXT,
  
  -- Gamificação
  xp_bonus INTEGER DEFAULT 0,
  unlock_order INTEGER,
  
  -- Sistema
  is_active BOOLEAN DEFAULT true,
  is_secret BOOLEAN DEFAULT false,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 5.4 Badges conquistados pelos usuários
CREATE TABLE public.user_badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  badge_id UUID REFERENCES public.badges(id) ON DELETE CASCADE NOT NULL,
  
  -- Conquista
  earned_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  earning_context JSONB DEFAULT '{}',
  
  -- Display
  is_displayed BOOLEAN DEFAULT true,
  display_order INTEGER,
  
  UNIQUE(user_id, badge_id)
);

-- 5.5 Sistema de ranking e leaderboards
CREATE TABLE public.leaderboards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Configuração
  name TEXT NOT NULL,
  description TEXT,
  metric TEXT NOT NULL, -- xp, weight_lost, streak, etc.
  period TEXT CHECK (period IN ('daily', 'weekly', 'monthly', 'all_time')) DEFAULT 'weekly',
  
  -- Filtros
  category TEXT,
  filters JSONB DEFAULT '{}',
  
  -- Sistema
  is_active BOOLEAN DEFAULT true,
  is_public BOOLEAN DEFAULT true,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ===============================================
-- 📚 SEÇÃO 6: PLATAFORMA EDUCACIONAL NETFLIX-STYLE
-- ===============================================

-- 6.1 Cursos estruturados
CREATE TABLE public.courses (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  
  -- Identificação
  title TEXT NOT NULL,
  subtitle TEXT,
  description TEXT,
  
  -- Categorização
  category course_category NOT NULL,
  subcategory TEXT,
  tags JSONB DEFAULT '[]',
  
  -- Dificuldade e público
  difficulty_level difficulty_level DEFAULT 'beginner',
  target_audience JSONB DEFAULT '[]',
  prerequisites JSONB DEFAULT '[]',
  
  -- Conteúdo
  thumbnail_url TEXT,
  trailer_url TEXT,
  banner_url TEXT,
  duration_minutes INTEGER DEFAULT 0,
  lesson_count INTEGER DEFAULT 0,
  
  -- Pricing
  price DECIMAL(10,2) DEFAULT 0,
  is_premium BOOLEAN DEFAULT false,
  subscription_tiers JSONB DEFAULT '[]',
  
  -- Status
  is_published BOOLEAN DEFAULT false,
  is_featured BOOLEAN DEFAULT false,
  
  -- Metadados
  instructor_id UUID REFERENCES auth.users(id),
  instructor_name TEXT,
  instructor_bio TEXT,
  instructor_avatar_url TEXT,
  
  -- Qualidade
  rating DECIMAL(3,2) DEFAULT 0,
  review_count INTEGER DEFAULT 0,
  completion_rate DECIMAL(3,2) DEFAULT 0,
  
  -- SEO
  slug TEXT UNIQUE,
  meta_title TEXT,
  meta_description TEXT,
  
  -- Sistema
  structure_type TEXT DEFAULT 'course_module_lesson' CHECK (structure_type IN ('course_lesson', 'course_module_lesson')),
  
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- 6.2 Módulos de curso
CREATE TABLE public.course_modules (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
  
  -- Identificação
  title TEXT NOT NULL,
  description TEXT,
  
  -- Organização
  order_index INTEGER NOT NULL DEFAULT 0,
  
  -- Conteúdo
  thumbnail_url TEXT,
  duration_minutes INTEGER DEFAULT 0,
  lesson_count INTEGER DEFAULT 0,
  
  -- Status
  is_active BOOLEAN DEFAULT true,
  is_preview BOOLEAN DEFAULT false,
  
  -- Configuração
  structure_type TEXT DEFAULT 'module_lesson' CHECK (structure_type IN ('module_lesson', 'standalone_module')),
  unlock_conditions JSONB DEFAULT '{}',
  
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- 6.3 Aulas detalhadas
CREATE TABLE public.course_lessons (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
  module_id UUID REFERENCES public.course_modules(id) ON DELETE CASCADE,
  
  -- Identificação
  title TEXT NOT NULL,
  description TEXT,
  
  -- Conteúdo
  content TEXT,
  video_url TEXT,
  audio_url TEXT,
  thumbnail_url TEXT,
  
  -- Organização
  order_index INTEGER NOT NULL DEFAULT 0,
  
  -- Metadados
  duration_minutes INTEGER DEFAULT 0,
  content_type content_type DEFAULT 'video',
  
  -- Acesso
  is_free BOOLEAN DEFAULT false,
  is_preview BOOLEAN DEFAULT false,
  is_premium BOOLEAN DEFAULT false,
  unlock_conditions JSONB DEFAULT '{}',
  
  -- Recursos
  resources JSONB DEFAULT '[]',
  downloads JSONB DEFAULT '[]',
  transcription TEXT,
  
  -- Interatividade
  quiz_questions JSONB DEFAULT '[]',
  assignments JSONB DEFAULT '[]',
  discussion_enabled BOOLEAN DEFAULT true,
  
  -- Configuração
  prerequisites TEXT[],
  color TEXT DEFAULT '#6366f1',
  
  -- Sistema
  view_count INTEGER DEFAULT 0,
  completion_rate DECIMAL(3,2) DEFAULT 0,
  rating DECIMAL(3,2) DEFAULT 0,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 6.4 Progresso do usuário nos cursos
CREATE TABLE public.user_course_progress (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  lesson_id UUID REFERENCES public.course_lessons(id) ON DELETE CASCADE,
  
  -- Progresso
  progress_percentage NUMERIC DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
  completed BOOLEAN DEFAULT false,
  
  -- Timestamps
  started_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  completed_at TIMESTAMP WITH TIME ZONE,
  
  -- Métricas
  time_spent_minutes INTEGER DEFAULT 0,
  watch_time_percentage DECIMAL(3,2) DEFAULT 0,
  replay_count INTEGER DEFAULT 0,
  
  -- Interação
  bookmarks JSONB DEFAULT '[]',
  notes TEXT,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  
  -- Certificação
  certificate_issued BOOLEAN DEFAULT false,
  certificate_url TEXT,
  
  UNIQUE(user_id, lesson_id)
);

-- ===============================================
-- 🏥 SEÇÃO 7: SISTEMA MÉDICO E DE SAÚDE AVANÇADO
-- ===============================================

-- 7.1 Exames médicos e análises
CREATE TABLE public.medical_exams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Identificação
  exam_type medical_analysis_type NOT NULL,
  exam_name TEXT NOT NULL,
  exam_date DATE NOT NULL,
  
  -- Arquivo
  file_url TEXT,
  file_type TEXT,
  file_size INTEGER,
  
  -- Análise da IA (Dr. Vital)
  ai_analysis JSONB DEFAULT '{}',
  ai_model TEXT DEFAULT 'gemini-1.5-pro',
  confidence_score DECIMAL(3,2),
  
  -- Resultados estruturados
  results JSONB DEFAULT '{}',
  reference_ranges JSONB DEFAULT '{}',
  abnormal_values JSONB DEFAULT '[]',
  
  -- Interpretação
  dr_vital_interpretation TEXT,
  risk_factors JSONB DEFAULT '[]',
  recommendations JSONB DEFAULT '[]',
  follow_up_needed BOOLEAN DEFAULT false,
  urgency_level TEXT CHECK (urgency_level IN ('low', 'medium', 'high', 'critical')) DEFAULT 'low',
  
  -- Contexto médico
  requesting_doctor TEXT,
  medical_facility TEXT,
  lab_name TEXT,
  
  -- Sistema
  processed BOOLEAN DEFAULT false,
  verified_by_doctor BOOLEAN DEFAULT false,
  doctor_notes TEXT,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 7.2 Análises preventivas de saúde
CREATE TABLE public.health_insights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Tipo de análise
  analysis_type TEXT NOT NULL,
  period_start DATE,
  period_end DATE,
  
  -- Dados analisados
  data_sources JSONB DEFAULT '[]', -- pesagens, exames, diário, etc.
  metrics_analyzed JSONB DEFAULT '{}',
  
  -- Insights da IA
  ai_insights JSONB DEFAULT '[]',
  risk_assessment JSONB DEFAULT '{}',
  trend_analysis JSONB DEFAULT '{}',
  
  -- Recomendações
  recommendations JSONB DEFAULT '[]',
  action_items JSONB DEFAULT '[]',
  preventive_measures JSONB DEFAULT '[]',
  
  -- Alertas
  alerts JSONB DEFAULT '[]',
  warnings JSONB DEFAULT '[]',
  
  -- Score de saúde
  health_score INTEGER CHECK (health_score >= 0 AND health_score <= 100),
  score_breakdown JSONB DEFAULT '{}',
  
  -- Sistema
  generated_by TEXT DEFAULT 'dr_vital_ai',
  reviewed_by_doctor BOOLEAN DEFAULT false,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 7.3 Calendário de saúde e agendamentos
CREATE TABLE public.health_calendar (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Evento
  title TEXT NOT NULL,
  description TEXT,
  event_type TEXT CHECK (event_type IN ('appointment', 'exam', 'medication', 'reminder', 'goal_check', 'consultation')),
  
  -- Agendamento
  scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
  duration_minutes INTEGER DEFAULT 60,
  timezone TEXT DEFAULT 'America/Sao_Paulo',
  
  -- Participantes
  doctor_name TEXT,
  facility_name TEXT,
  contact_info JSONB DEFAULT '{}',
  
  -- Status
  status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'confirmed', 'completed', 'cancelled', 'rescheduled')),
  
  -- Lembretes
  reminders JSONB DEFAULT '[]',
  notifications_sent JSONB DEFAULT '[]',
  
  -- Resultados
  notes TEXT,
  outcomes JSONB DEFAULT '{}',
  follow_up_needed BOOLEAN DEFAULT false,
  
  -- Sistema
  created_by TEXT DEFAULT 'user',
  automated BOOLEAN DEFAULT false,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ===============================================
-- 💳 SEÇÃO 8: SISTEMA DE MONETIZAÇÃO AVANÇADO
-- ===============================================

-- 8.1 Planos de assinatura
CREATE TABLE public.subscription_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Identificação
  name TEXT NOT NULL,
  description TEXT,
  features JSONB DEFAULT '[]',
  
  -- Pricing
  price DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'BRL',
  billing_period TEXT CHECK (billing_period IN ('weekly', 'monthly', 'quarterly', 'yearly')) DEFAULT 'monthly',
  
  -- Trial
  trial_period_days INTEGER DEFAULT 0,
  
  -- Configuração
  max_users INTEGER DEFAULT 1,
  storage_limit_gb INTEGER,
  api_calls_limit INTEGER,
  
  -- Acesso
  access_level TEXT CHECK (access_level IN ('basic', 'premium', 'vip', 'enterprise')) DEFAULT 'basic',
  course_access JSONB DEFAULT '[]',
  feature_flags JSONB DEFAULT '{}',
  
  -- Sistema
  is_active BOOLEAN DEFAULT true,
  is_popular BOOLEAN DEFAULT false,
  sort_order INTEGER DEFAULT 0,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 8.2 Assinaturas dos usuários
CREATE TABLE public.user_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  plan_id UUID REFERENCES public.subscription_plans(id) NOT NULL,
  
  -- Status
  status subscription_status DEFAULT 'trial',
  
  -- Período
  current_period_start TIMESTAMP WITH TIME ZONE NOT NULL,
  current_period_end TIMESTAMP WITH TIME ZONE NOT NULL,
  
  -- Trial
  trial_start TIMESTAMP WITH TIME ZONE,
  trial_end TIMESTAMP WITH TIME ZONE,
  
  -- Cancelamento
  cancel_at_period_end BOOLEAN DEFAULT false,
  canceled_at TIMESTAMP WITH TIME ZONE,
  cancellation_reason TEXT,
  
  -- Pagamento (Asaas)
  asaas_subscription_id TEXT,
  asaas_customer_id TEXT,
  payment_method TEXT,
  
  -- Histórico
  upgrade_history JSONB DEFAULT '[]',
  payment_history JSONB DEFAULT '[]',
  
  -- Métricas
  total_paid DECIMAL(10,2) DEFAULT 0,
  lifetime_value DECIMAL(10,2) DEFAULT 0,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  
  UNIQUE(user_id)
);

-- ===============================================
-- 📊 SEÇÃO 9: TRACKING E MONITORAMENTO AVANÇADO
-- ===============================================

-- 9.1 Tracking de hidratação inteligente
CREATE TABLE public.water_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Consumo
  amount_ml INTEGER NOT NULL,
  beverage_type TEXT DEFAULT 'water',
  
  -- Contexto
  recorded_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  source TEXT DEFAULT 'manual' CHECK (source IN ('manual', 'reminder', 'auto')),
  location TEXT,
  temperature TEXT CHECK (temperature IN ('cold', 'room', 'warm', 'hot')),
  
  -- Metas
  daily_goal_ml INTEGER,
  progress_percentage DECIMAL(3,2),
  
  -- Análise
  ai_feedback TEXT,
  hydration_score INTEGER CHECK (hydration_score >= 1 AND hydration_score <= 5),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 9.2 Diário de saúde completo
CREATE TABLE public.health_diary (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  
  -- Bem-estar geral
  overall_mood INTEGER CHECK (overall_mood >= 1 AND overall_mood <= 5),
  energy_level INTEGER CHECK (energy_level >= 1 AND energy_level <= 5),
  stress_level INTEGER CHECK (stress_level >= 1 AND stress_level <= 5),
  motivation_level INTEGER CHECK (motivation_level >= 1 AND motivation_level <= 5),
  
  -- Sono
  sleep_hours DECIMAL(3,1),
  sleep_quality INTEGER CHECK (sleep_quality >= 1 AND sleep_quality <= 5),
  bedtime TIME,
  wake_time TIME,
  sleep_notes TEXT,
  
  -- Atividade física
  exercise_minutes INTEGER DEFAULT 0,
  exercise_type JSONB DEFAULT '[]',
  exercise_intensity INTEGER CHECK (exercise_intensity >= 1 AND exercise_intensity <= 5),
  steps_count INTEGER,
  
  -- Hidratação
  water_intake_ml INTEGER DEFAULT 0,
  
  -- Sintomas e sensações
  symptoms JSONB DEFAULT '[]',
  pain_areas JSONB DEFAULT '[]',
  pain_level INTEGER CHECK (pain_level >= 0 AND pain_level <= 10),
  
  -- Medicamentos
  medications_taken JSONB DEFAULT '[]',
  supplements_taken JSONB DEFAULT '[]',
  
  -- Gratidão e mindset
  gratitude_notes TEXT,
  achievements TEXT,
  challenges TEXT,
  
  -- Análise da IA
  ai_insights JSONB DEFAULT '{}',
  recommendations JSONB DEFAULT '[]',
  
  -- Mapeamento emocional
  emotional_state JSONB DEFAULT '{}',
  triggers JSONB DEFAULT '[]',
  coping_strategies JSONB DEFAULT '[]',
  
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(user_id, date)
);

-- ===============================================
-- 👥 SEÇÃO 10: COMUNIDADE E SOCIAL
-- ===============================================

-- 10.1 Posts do feed social de saúde
CREATE TABLE public.social_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Conteúdo
  content TEXT NOT NULL,
  media_urls JSONB DEFAULT '[]',
  post_type TEXT CHECK (post_type IN ('progress', 'achievement', 'tip', 'question', 'motivation', 'recipe')) DEFAULT 'progress',
  
  -- Engajamento
  likes_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  shares_count INTEGER DEFAULT 0,
  
  -- Configuração
  is_public BOOLEAN DEFAULT true,
  allow_comments BOOLEAN DEFAULT true,
  
  -- Moderação
  is_flagged BOOLEAN DEFAULT false,
  moderation_status TEXT DEFAULT 'approved' CHECK (moderation_status IN ('pending', 'approved', 'rejected')),
  
  -- Hashtags e menções
  hashtags JSONB DEFAULT '[]',
  mentions JSONB DEFAULT '[]',
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 10.2 Comentários
CREATE TABLE public.post_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES public.social_posts(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  parent_comment_id UUID REFERENCES public.post_comments(id),
  
  -- Conteúdo
  content TEXT NOT NULL,
  
  -- Engajamento
  likes_count INTEGER DEFAULT 0,
  
  -- Moderação
  is_flagged BOOLEAN DEFAULT false,
  moderation_status TEXT DEFAULT 'approved' CHECK (moderation_status IN ('pending', 'approved', 'rejected')),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 10.3 Sistema de seguidores/inspiração
CREATE TABLE public.user_follows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  follower_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  following_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Status
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'muted', 'blocked')),
  
  -- Notificações
  notify_posts BOOLEAN DEFAULT true,
  notify_achievements BOOLEAN DEFAULT true,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  
  UNIQUE(follower_id, following_id),
  CHECK (follower_id != following_id)
);

-- ===============================================
-- 🔌 SEÇÃO 11: INTEGRAÇÕES EXTERNAS
-- ===============================================

-- 11.1 Dados do Google Fit
CREATE TABLE public.google_fit_data (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Tipo de dados
  data_type TEXT NOT NULL, -- steps, calories, distance, heart_rate, etc.
  value DECIMAL(10,2) NOT NULL,
  unit TEXT NOT NULL,
  
  -- Timestamp
  recorded_at TIMESTAMP WITH TIME ZONE NOT NULL,
  synced_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  
  -- Fonte
  source_app TEXT,
  source_device TEXT,
  
  -- Metadados
  metadata JSONB DEFAULT '{}',
  quality_score DECIMAL(3,2),
  
  -- Processamento
  processed BOOLEAN DEFAULT false,
  ai_insights JSONB DEFAULT '{}',
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  
  UNIQUE(user_id, data_type, recorded_at)
);

-- 11.2 Configurações de IA (Sofia e Dr. Vital)
CREATE TABLE public.ai_configurations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Identificação
  name TEXT NOT NULL UNIQUE,
  ai_type TEXT CHECK (ai_type IN ('sofia', 'dr_vital', 'nutrition_ai', 'fitness_ai')) NOT NULL,
  
  -- Configuração do modelo
  model_name TEXT NOT NULL,
  temperature DECIMAL(3,2) DEFAULT 0.7,
  max_tokens INTEGER DEFAULT 1000,
  
  -- Personalidade
  personality_prompt TEXT,
  system_instructions TEXT,
  
  -- Capacidades
  capabilities JSONB DEFAULT '[]',
  specializations JSONB DEFAULT '[]',
  
  -- Limitações
  rate_limit_per_hour INTEGER DEFAULT 100,
  max_conversation_length INTEGER DEFAULT 50,
  
  -- Sistema
  is_active BOOLEAN DEFAULT true,
  version TEXT DEFAULT '1.0',
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ===============================================
-- 📈 SEÇÃO 12: ANALYTICS E RELATÓRIOS
-- ===============================================

-- 12.1 Eventos de usuário para analytics
CREATE TABLE public.user_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Evento
  event_name TEXT NOT NULL,
  event_category TEXT,
  event_action TEXT,
  event_label TEXT,
  
  -- Contexto
  page_url TEXT,
  referrer TEXT,
  user_agent TEXT,
  ip_address INET,
  
  -- Dados customizados
  properties JSONB DEFAULT '{}',
  
  -- Sessão
  session_id TEXT,
  
  -- Timestamp
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT now(),
  
  -- Processamento
  processed BOOLEAN DEFAULT false
);

-- 12.2 Relatórios semanais automatizados
CREATE TABLE public.weekly_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Período
  week_start DATE NOT NULL,
  week_end DATE NOT NULL,
  
  -- Métricas de peso
  weight_metrics JSONB DEFAULT '{}',
  body_composition_metrics JSONB DEFAULT '{}',
  
  -- Métricas de atividade
  activity_metrics JSONB DEFAULT '{}',
  mission_metrics JSONB DEFAULT '{}',
  
  -- Métricas de nutrição
  nutrition_metrics JSONB DEFAULT '{}',
  hydration_metrics JSONB DEFAULT '{}',
  
  -- Métricas de bem-estar
  wellness_metrics JSONB DEFAULT '{}',
  sleep_metrics JSONB DEFAULT '{}',
  
  -- Análise da IA
  ai_summary TEXT,
  achievements JSONB DEFAULT '[]',
  recommendations JSONB DEFAULT '[]',
  next_week_goals JSONB DEFAULT '[]',
  
  -- Status
  generated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  sent_at TIMESTAMP WITH TIME ZONE,
  viewed_at TIMESTAMP WITH TIME ZONE,
  
  -- Configuração
  report_type TEXT DEFAULT 'standard',
  language TEXT DEFAULT 'pt-BR',
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ===============================================
-- 🎯 SEÇÃO 13: ÍNDICES E OTIMIZAÇÕES
-- ===============================================

-- Índices para performance (críticos para escala)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_profiles_user_id ON public.profiles(user_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_weighings_user_id ON public.weighings(user_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_weighings_date ON public.weighings(weighed_at);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_food_analysis_user_id ON public.food_analysis(user_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_food_analysis_date ON public.food_analysis(created_at);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_missions_user_id ON public.user_missions(user_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_missions_status ON public.user_missions(status);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_missions_date ON public.user_missions(assigned_at);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_courses_category ON public.courses(category);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_courses_published ON public.courses(is_published);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_course_progress_user_id ON public.user_course_progress(user_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_course_progress_course_id ON public.user_course_progress(course_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_health_diary_user_id ON public.health_diary(user_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_health_diary_date ON public.health_diary(date);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_social_posts_user_id ON public.social_posts(user_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_social_posts_created_at ON public.social_posts(created_at);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_events_user_id ON public.user_events(user_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_events_timestamp ON public.user_events(timestamp);

-- Índices compostos para queries complexas
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_missions_user_status_date ON public.user_missions(user_id, status, assigned_at);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_weighings_user_date ON public.weighings(user_id, weighed_at);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_food_analysis_user_meal ON public.food_analysis(user_id, meal_type, created_at);

-- ===============================================
-- ✅ INSTITUTO DOS SONHOS - BANCO COMPLETO!
-- ===============================================

-- Log de conclusão
DO $$
BEGIN
  RAISE NOTICE '===============================================';
  RAISE NOTICE '🏢 INSTITUTO DOS SONHOS - BANCO COMPLETO!';
  RAISE NOTICE '===============================================';
  RAISE NOTICE '🤖 IA Avançada (Sofia + Dr. Vital)';
  RAISE NOTICE '⚖️ Sistema de Pesagem Xiaomi Completo';
  RAISE NOTICE '🍎 Análise Nutricional por Imagem';
  RAISE NOTICE '🎮 Gamificação Inteligente';
  RAISE NOTICE '📚 Plataforma Educacional Netflix-Style';
  RAISE NOTICE '🏥 Sistema Médico Preventivo';
  RAISE NOTICE '💳 Monetização Asaas Integrada';
  RAISE NOTICE '📊 Analytics e Relatórios Automáticos';
  RAISE NOTICE '👥 Comunidade Social';
  RAISE NOTICE '🔌 Integrações (Google Fit, etc.)';
  RAISE NOTICE '📈 Escalabilidade para Milhões';
  RAISE NOTICE '===============================================';
  RAISE NOTICE '🚀 PRONTO PARA SER UNICÓRNIO HEALTHTECH!';
  RAISE NOTICE '===============================================';
END $$;