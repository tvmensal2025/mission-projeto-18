-- ===============================================
-- 🔧 CRIAR TABELAS FALTANTES
-- ===============================================

-- ===============================================
-- 1. TABELA CHALLENGE_PARTICIPATIONS
-- ===============================================
CREATE TABLE IF NOT EXISTS challenge_participations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    challenge_id UUID REFERENCES challenges(id) ON DELETE CASCADE,
    target_value DECIMAL(10,2) NOT NULL,
    current_value DECIMAL(10,2) DEFAULT 0,
    progress_percentage DECIMAL(5,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'abandoned')),
    start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    end_date TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, challenge_id)
);

-- ===============================================
-- 2. TABELA WATER_TRACKING
-- ===============================================
CREATE TABLE IF NOT EXISTS water_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    target_ml INTEGER DEFAULT 2000,
    consumed_ml INTEGER DEFAULT 0,
    glasses_count INTEGER DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- ===============================================
-- 3. TABELA SLEEP_TRACKING
-- ===============================================
CREATE TABLE IF NOT EXISTS sleep_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    bedtime TIME,
    wake_time TIME,
    sleep_duration_hours DECIMAL(4,2),
    sleep_quality INTEGER CHECK (sleep_quality >= 1 AND sleep_quality <= 10),
    deep_sleep_hours DECIMAL(4,2),
    rem_sleep_hours DECIMAL(4,2),
    sleep_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- ===============================================
-- 4. TABELA MOOD_TRACKING
-- ===============================================
CREATE TABLE IF NOT EXISTS mood_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    mood_score INTEGER CHECK (mood_score >= 1 AND mood_score <= 10),
    energy_level INTEGER CHECK (energy_level >= 1 AND energy_level <= 10),
    stress_level INTEGER CHECK (stress_level >= 1 AND stress_level <= 10),
    anxiety_level INTEGER CHECK (anxiety_level >= 1 AND anxiety_level <= 10),
    depression_level INTEGER CHECK (depression_level >= 1 AND depression_level <= 10),
    mood_notes TEXT,
    activities TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- ===============================================
-- 5. TABELA EXERCISE_TRACKING
-- ===============================================
CREATE TABLE IF NOT EXISTS exercise_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    exercise_type VARCHAR(100),
    duration_minutes INTEGER,
    calories_burned INTEGER,
    distance_km DECIMAL(5,2),
    heart_rate_avg INTEGER,
    heart_rate_max INTEGER,
    intensity_level VARCHAR(20) CHECK (intensity_level IN ('low', 'medium', 'high')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date, exercise_type)
);

-- ===============================================
-- 6. TABELA MEDICATION_TRACKING
-- ===============================================
CREATE TABLE IF NOT EXISTS medication_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    medication_name VARCHAR(200) NOT NULL,
    dosage VARCHAR(100),
    frequency VARCHAR(100),
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT true,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===============================================
-- 7. TABELA SYMPTOM_TRACKING
-- ===============================================
CREATE TABLE IF NOT EXISTS symptom_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    symptom_name VARCHAR(200) NOT NULL,
    severity INTEGER CHECK (severity >= 1 AND severity <= 10),
    duration_hours INTEGER,
    triggers TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===============================================
-- 8. TABELA CUSTOM_HABITS
-- ===============================================
CREATE TABLE IF NOT EXISTS custom_habits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    habit_name VARCHAR(200) NOT NULL,
    description TEXT,
    frequency VARCHAR(100),
    target_value INTEGER,
    unit VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===============================================
-- 9. TABELA HABIT_TRACKING
-- ===============================================
CREATE TABLE IF NOT EXISTS habit_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    habit_id UUID REFERENCES custom_habits(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    completed BOOLEAN DEFAULT false,
    value INTEGER,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, habit_id, date)
);

-- ===============================================
-- 10. TABELA NUTRITION_TRACKING
-- ===============================================
CREATE TABLE IF NOT EXISTS nutrition_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    meal_type VARCHAR(50) CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
    food_name VARCHAR(200),
    calories INTEGER,
    protein_g DECIMAL(5,2),
    carbs_g DECIMAL(5,2),
    fat_g DECIMAL(5,2),
    fiber_g DECIMAL(5,2),
    sugar_g DECIMAL(5,2),
    sodium_mg INTEGER,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===============================================
-- 11. TABELA BLOOD_PRESSURE_TRACKING
-- ===============================================
CREATE TABLE IF NOT EXISTS blood_pressure_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    time TIME,
    systolic INTEGER CHECK (systolic >= 70 AND systolic <= 200),
    diastolic INTEGER CHECK (diastolic >= 40 AND diastolic <= 130),
    pulse INTEGER CHECK (pulse >= 40 AND pulse <= 200),
    position VARCHAR(50) DEFAULT 'sitting',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===============================================
-- 12. TABELA BLOOD_GLUCOSE_TRACKING
-- ===============================================
CREATE TABLE IF NOT EXISTS blood_glucose_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    time TIME,
    glucose_level INTEGER CHECK (glucose_level >= 40 AND glucose_level <= 600),
    measurement_type VARCHAR(50) CHECK (measurement_type IN ('fasting', 'post_meal', 'random')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===============================================
-- 13. TABELA BODY_COMPOSITION_TRACKING
-- ===============================================
CREATE TABLE IF NOT EXISTS body_composition_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    body_fat_percentage DECIMAL(4,2),
    muscle_mass_kg DECIMAL(5,2),
    bone_mass_kg DECIMAL(4,2),
    water_percentage DECIMAL(4,2),
    visceral_fat_level INTEGER,
    bmr_calories INTEGER,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- ===============================================
-- 14. TABELA SKIN_CONDITION_TRACKING
-- ===============================================
CREATE TABLE IF NOT EXISTS skin_condition_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    skin_condition VARCHAR(100),
    severity INTEGER CHECK (severity >= 1 AND severity <= 10),
    affected_areas TEXT[],
    symptoms TEXT[],
    treatments TEXT[],
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===============================================
-- 15. TABELA MENTAL_HEALTH_TRACKING
-- ===============================================
CREATE TABLE IF NOT EXISTS mental_health_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    anxiety_level INTEGER CHECK (anxiety_level >= 1 AND anxiety_level <= 10),
    depression_level INTEGER CHECK (depression_level >= 1 AND depression_level <= 10),
    stress_level INTEGER CHECK (stress_level >= 1 AND stress_level <= 10),
    sleep_quality INTEGER CHECK (sleep_quality >= 1 AND sleep_quality <= 10),
    social_interaction_hours INTEGER,
    therapy_session BOOLEAN DEFAULT false,
    medication_taken BOOLEAN DEFAULT false,
    coping_strategies TEXT[],
    triggers TEXT[],
    positive_events TEXT[],
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- ===============================================
-- 16. TABELA REPRODUCTIVE_HEALTH_TRACKING
-- ===============================================
CREATE TABLE IF NOT EXISTS reproductive_health_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    cycle_day INTEGER,
    flow_intensity VARCHAR(20) CHECK (flow_intensity IN ('light', 'medium', 'heavy')),
    symptoms TEXT[],
    mood_changes TEXT[],
    energy_level INTEGER CHECK (energy_level >= 1 AND energy_level <= 10),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- ===============================================
-- 17. TABELA IMMUNITY_TRACKING
-- ===============================================
CREATE TABLE IF NOT EXISTS immunity_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    immune_symptoms TEXT[],
    exposure_risk VARCHAR(50),
    vaccination_status VARCHAR(100),
    supplements_taken TEXT[],
    rest_hours INTEGER,
    stress_level INTEGER CHECK (stress_level >= 1 AND stress_level <= 10),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- ===============================================
-- 18. TABELA DETOX_TRACKING
-- ===============================================
CREATE TABLE IF NOT EXISTS detox_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    detox_type VARCHAR(100),
    duration_days INTEGER,
    symptoms TEXT[],
    energy_level INTEGER CHECK (energy_level >= 1 AND energy_level <= 10),
    sleep_quality INTEGER CHECK (sleep_quality >= 1 AND sleep_quality <= 10),
    mood_changes TEXT[],
    physical_changes TEXT[],
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- ===============================================
-- 19. TABELA LONGEVITY_TRACKING
-- ===============================================
CREATE TABLE IF NOT EXISTS longevity_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    biological_age INTEGER,
    telomere_length DECIMAL(6,2),
    inflammation_markers TEXT[],
    oxidative_stress_level INTEGER CHECK (oxidative_stress_level >= 1 AND oxidative_stress_level <= 10),
    cellular_health_score INTEGER CHECK (cellular_health_score >= 1 AND cellular_health_score <= 10),
    mitochondrial_function INTEGER CHECK (mitochondrial_function >= 1 AND mitochondrial_function <= 10),
    epigenetic_age INTEGER,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- ===============================================
-- 20. TABELA BIOHACKING_TRACKING
-- ===============================================
CREATE TABLE IF NOT EXISTS biohacking_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    biohack_type VARCHAR(100),
    duration_minutes INTEGER,
    intensity_level VARCHAR(20) CHECK (intensity_level IN ('low', 'medium', 'high')),
    cognitive_performance INTEGER CHECK (cognitive_performance >= 1 AND cognitive_performance <= 10),
    physical_performance INTEGER CHECK (physical_performance >= 1 AND physical_performance <= 10),
    recovery_quality INTEGER CHECK (recovery_quality >= 1 AND recovery_quality <= 10),
    side_effects TEXT[],
    benefits_noticed TEXT[],
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date, biohack_type)
);

-- ===============================================
-- CRIAR ÍNDICES PARA PERFORMANCE
-- ===============================================
CREATE INDEX IF NOT EXISTS idx_challenge_participations_user_id ON challenge_participations(user_id);
CREATE INDEX IF NOT EXISTS idx_challenge_participations_challenge_id ON challenge_participations(challenge_id);
CREATE INDEX IF NOT EXISTS idx_water_tracking_user_date ON water_tracking(user_id, date);
CREATE INDEX IF NOT EXISTS idx_sleep_tracking_user_date ON sleep_tracking(user_id, date);
CREATE INDEX IF NOT EXISTS idx_mood_tracking_user_date ON mood_tracking(user_id, date);
CREATE INDEX IF NOT EXISTS idx_exercise_tracking_user_date ON exercise_tracking(user_id, date);

-- ===============================================
-- CRIAR TRIGGERS PARA UPDATED_AT
-- ===============================================
CREATE OR REPLACE FUNCTION update_challenge_participations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_challenge_participations_updated_at
    BEFORE UPDATE ON challenge_participations
    FOR EACH ROW
    EXECUTE FUNCTION update_challenge_participations_updated_at();

-- ===============================================
-- CRIAR POLÍTICAS RLS
-- ===============================================

-- Challenge Participations
ALTER TABLE challenge_participations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own challenge participations" ON challenge_participations
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own challenge participations" ON challenge_participations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own challenge participations" ON challenge_participations
    FOR UPDATE USING (auth.uid() = user_id);

-- Water Tracking
ALTER TABLE water_tracking ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own water tracking" ON water_tracking
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own water tracking" ON water_tracking
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own water tracking" ON water_tracking
    FOR UPDATE USING (auth.uid() = user_id);

-- Sleep Tracking
ALTER TABLE sleep_tracking ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own sleep tracking" ON sleep_tracking
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own sleep tracking" ON sleep_tracking
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own sleep tracking" ON sleep_tracking
    FOR UPDATE USING (auth.uid() = user_id);

-- Mood Tracking
ALTER TABLE mood_tracking ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own mood tracking" ON mood_tracking
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own mood tracking" ON mood_tracking
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own mood tracking" ON mood_tracking
    FOR UPDATE USING (auth.uid() = user_id);

-- Exercise Tracking
ALTER TABLE exercise_tracking ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own exercise tracking" ON exercise_tracking
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own exercise tracking" ON exercise_tracking
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own exercise tracking" ON exercise_tracking
    FOR UPDATE USING (auth.uid() = user_id);

-- ===============================================
-- INSERIR DADOS DE TESTE
-- ===============================================
INSERT INTO challenge_participations (user_id, challenge_id, target_value, current_value, progress_percentage, status)
SELECT 
    p.user_id,
    c.id,
    CASE 
        WHEN c.title LIKE '%água%' THEN 2000
        WHEN c.title LIKE '%exercício%' THEN 30
        WHEN c.title LIKE '%meditação%' THEN 10
        ELSE 100
    END as target_value,
    CASE 
        WHEN c.title LIKE '%água%' THEN 1500
        WHEN c.title LIKE '%exercício%' THEN 20
        WHEN c.title LIKE '%meditação%' THEN 7
        ELSE 60
    END as current_value,
    CASE 
        WHEN c.title LIKE '%água%' THEN 75.0
        WHEN c.title LIKE '%exercício%' THEN 66.7
        WHEN c.title LIKE '%meditação%' THEN 70.0
        ELSE 60.0
    END as progress_percentage,
    'active' as status
FROM profiles p
CROSS JOIN challenges c
WHERE p.user_id IS NOT NULL
LIMIT 10
ON CONFLICT DO NOTHING; 