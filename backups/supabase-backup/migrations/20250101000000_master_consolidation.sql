-- ===============================================
-- 🏗️ MIGRAÇÃO MASTER CONSOLIDADA
-- ===============================================
-- Esta migração consolida toda a estrutura do projeto
-- ===============================================

-- ===============================================
-- 1. TABELAS PRINCIPAIS
-- ===============================================

-- Profiles
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255),
    email VARCHAR(255),
    role VARCHAR(50) DEFAULT 'user',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Courses
CREATE TABLE IF NOT EXISTS courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    is_published BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Course Modules
CREATE TABLE IF NOT EXISTS course_modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Lessons
CREATE TABLE IF NOT EXISTS lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID REFERENCES course_modules(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Challenges
CREATE TABLE IF NOT EXISTS challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    points INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Challenge Participations
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
-- 2. TABELAS DE TRACKING
-- ===============================================

-- Water Tracking
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

-- Sleep Tracking
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

-- Mood Tracking
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

-- Exercise Tracking
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
-- 3. TABELAS DE DADOS EXISTENTES
-- ===============================================

-- Daily Mission Sessions
CREATE TABLE IF NOT EXISTS daily_mission_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    is_completed BOOLEAN DEFAULT false,
    total_points INTEGER DEFAULT 0,
    streak_days INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- Daily Responses
CREATE TABLE IF NOT EXISTS daily_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    question_id VARCHAR(100),
    answer TEXT,
    points INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Goals
CREATE TABLE IF NOT EXISTS user_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    target_value DECIMAL(10,2),
    current_value DECIMAL(10,2) DEFAULT 0,
    unit VARCHAR(50),
    status VARCHAR(50) DEFAULT 'pendente',
    deadline DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Weight Measurements
CREATE TABLE IF NOT EXISTS weight_measurements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    measurement_date DATE NOT NULL,
    peso_kg DECIMAL(5,2),
    altura_cm INTEGER,
    imc DECIMAL(4,2),
    tendencia VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sessions
CREATE TABLE IF NOT EXISTS sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(100),
    duration_minutes INTEGER,
    target_saboteurs TEXT[],
    content JSONB,
    created_by UUID REFERENCES auth.users(id),
    is_template BOOLEAN DEFAULT false,
    template_category VARCHAR(100),
    objectives TEXT[],
    prerequisites TEXT[],
    materials_needed TEXT[],
    session_date DATE,
    notes TEXT,
    is_completed BOOLEAN DEFAULT false,
    progress_percentage INTEGER DEFAULT 0,
    feedback TEXT,
    mood_before INTEGER,
    mood_after INTEGER,
    energy_level INTEGER,
    stress_level INTEGER,
    session_data JSONB,
    is_favorite BOOLEAN DEFAULT false,
    reminder_time TIMESTAMP WITH TIME ZONE,
    location VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===============================================
-- 4. TABELAS DE SISTEMA
-- ===============================================

-- AI Configurations
CREATE TABLE IF NOT EXISTS ai_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    model VARCHAR(100),
    temperature DECIMAL(3,2) DEFAULT 0.7,
    max_tokens INTEGER DEFAULT 1000,
    functionality TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===============================================
-- 5. ÍNDICES
-- ===============================================
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_course_modules_course_id ON course_modules(course_id);
CREATE INDEX IF NOT EXISTS idx_lessons_module_id ON lessons(module_id);
CREATE INDEX IF NOT EXISTS idx_challenge_participations_user_id ON challenge_participations(user_id);
CREATE INDEX IF NOT EXISTS idx_challenge_participations_challenge_id ON challenge_participations(challenge_id);
CREATE INDEX IF NOT EXISTS idx_water_tracking_user_date ON water_tracking(user_id, date);
CREATE INDEX IF NOT EXISTS idx_sleep_tracking_user_date ON sleep_tracking(user_id, date);
CREATE INDEX IF NOT EXISTS idx_mood_tracking_user_date ON mood_tracking(user_id, date);
CREATE INDEX IF NOT EXISTS idx_exercise_tracking_user_date ON exercise_tracking(user_id, date);
CREATE INDEX IF NOT EXISTS idx_daily_mission_sessions_user_date ON daily_mission_sessions(user_id, date);
CREATE INDEX IF NOT EXISTS idx_daily_responses_user_date ON daily_responses(user_id, date);
CREATE INDEX IF NOT EXISTS idx_user_goals_user_id ON user_goals(user_id);
CREATE INDEX IF NOT EXISTS idx_weight_measurements_user_date ON weight_measurements(user_id, measurement_date);
CREATE INDEX IF NOT EXISTS idx_sessions_created_by ON sessions(created_by);

-- ===============================================
-- 6. FUNÇÕES
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
    RETURN (
        auth.uid() IS NOT NULL AND (
            EXISTS (
                SELECT 1 FROM public.profiles
                WHERE user_id = auth.uid()
                AND role IN ('admin', 'super_admin')
            )
            OR
            NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles')
        )
    );
END;
$$ LANGUAGE plpgsql;

-- Função para dashboard do usuário
CREATE OR REPLACE FUNCTION get_user_dashboard(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    dashboard_data JSONB;
    user_profile JSONB;
    recent_activities JSONB;
    health_metrics JSONB;
    goals_progress JSONB;
    challenges_data JSONB;
BEGIN
    -- Buscar perfil do usuário
    SELECT jsonb_build_object(
        'id', p.id,
        'name', p.name,
        'email', p.email,
        'role', p.role,
        'created_at', p.created_at
    ) INTO user_profile
    FROM profiles p
    WHERE p.user_id = p_user_id;

    -- Buscar atividades recentes
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', dr.id,
            'date', dr.date,
            'question_id', dr.question_id,
            'answer', dr.answer,
            'points', dr.points
        )
    ) INTO recent_activities
    FROM daily_responses dr
    WHERE dr.user_id = p_user_id
    AND dr.date >= CURRENT_DATE - INTERVAL '7 days'
    ORDER BY dr.date DESC, dr.created_at DESC
    LIMIT 10;

    -- Buscar métricas de saúde
    SELECT jsonb_build_object(
        'weight', (
            SELECT jsonb_build_object(
                'current', wm.peso_kg,
                'trend', wm.tendencia,
                'last_measurement', wm.measurement_date
            )
            FROM weight_measurements wm
            WHERE wm.user_id = p_user_id
            ORDER BY wm.measurement_date DESC
            LIMIT 1
        ),
        'water', (
            SELECT jsonb_build_object(
                'consumed', wt.consumed_ml,
                'target', wt.target_ml,
                'percentage', ROUND((wt.consumed_ml::DECIMAL / wt.target_ml) * 100, 2)
            )
            FROM water_tracking wt
            WHERE wt.user_id = p_user_id
            AND wt.date = CURRENT_DATE
        ),
        'sleep', (
            SELECT jsonb_build_object(
                'duration', st.sleep_duration_hours,
                'quality', st.sleep_quality,
                'date', st.date
            )
            FROM sleep_tracking st
            WHERE st.user_id = p_user_id
            ORDER BY st.date DESC
            LIMIT 1
        ),
        'mood', (
            SELECT jsonb_build_object(
                'score', mt.mood_score,
                'energy', mt.energy_level,
                'stress', mt.stress_level,
                'date', mt.date
            )
            FROM mood_tracking mt
            WHERE mt.user_id = p_user_id
            ORDER BY mt.date DESC
            LIMIT 1
        )
    ) INTO health_metrics;

    -- Buscar progresso das metas
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', ug.id,
            'title', ug.title,
            'current_value', ug.current_value,
            'target_value', ug.target_value,
            'progress_percentage', 
                CASE 
                    WHEN ug.target_value > 0 THEN 
                        ROUND((ug.current_value::DECIMAL / ug.target_value) * 100, 2)
                    ELSE 0
                END,
            'status', ug.status,
            'deadline', ug.deadline
        )
    ) INTO goals_progress
    FROM user_goals ug
    WHERE ug.user_id = p_user_id
    AND ug.status IN ('em_progresso', 'pendente');

    -- Buscar dados dos desafios
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', cp.challenge_id,
            'title', c.title,
            'description', c.description,
            'target_value', cp.target_value,
            'current_value', cp.current_value,
            'progress_percentage', cp.progress_percentage,
            'status', cp.status
        )
    ) INTO challenges_data
    FROM challenge_participations cp
    JOIN challenges c ON c.id = cp.challenge_id
    WHERE cp.user_id = p_user_id
    AND cp.status = 'active';

    -- Montar dashboard completo
    dashboard_data := jsonb_build_object(
        'user_profile', user_profile,
        'recent_activities', COALESCE(recent_activities, '[]'::jsonb),
        'health_metrics', health_metrics,
        'goals_progress', COALESCE(goals_progress, '[]'::jsonb),
        'challenges_data', COALESCE(challenges_data, '[]'::jsonb),
        'generated_at', NOW()
    );

    RETURN dashboard_data;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para insights da Sofia
CREATE OR REPLACE FUNCTION get_sofia_insights(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    insights JSONB;
    health_trends JSONB;
    recommendations JSONB;
    mood_analysis JSONB;
    sleep_analysis JSONB;
    exercise_analysis JSONB;
BEGIN
    -- Análise de tendências de saúde
    SELECT jsonb_build_object(
        'weight_trend', (
            SELECT jsonb_build_object(
                'trend', wm.tendencia,
                'change_kg', (wm.peso_kg - LAG(wm.peso_kg) OVER (ORDER BY wm.measurement_date)),
                'period_days', EXTRACT(DAYS FROM (MAX(wm.measurement_date) - MIN(wm.measurement_date)))
            )
            FROM weight_measurements wm
            WHERE wm.user_id = p_user_id
            AND wm.measurement_date >= CURRENT_DATE - INTERVAL '30 days'
        ),
        'water_consistency', (
            SELECT ROUND(
                (COUNT(CASE WHEN wt.consumed_ml >= wt.target_ml THEN 1 END)::DECIMAL / COUNT(*)) * 100, 2
            )
            FROM water_tracking wt
            WHERE wt.user_id = p_user_id
            AND wt.date >= CURRENT_DATE - INTERVAL '7 days'
        ),
        'sleep_quality_avg', (
            SELECT AVG(st.sleep_quality)
            FROM sleep_tracking st
            WHERE st.user_id = p_user_id
            AND st.date >= CURRENT_DATE - INTERVAL '7 days'
        ),
        'mood_avg', (
            SELECT AVG(mt.mood_score)
            FROM mood_tracking mt
            WHERE mt.user_id = p_user_id
            AND mt.date >= CURRENT_DATE - INTERVAL '7 days'
        )
    ) INTO health_trends;

    -- Análise de humor
    SELECT jsonb_build_object(
        'average_score', AVG(mt.mood_score),
        'trend', CASE 
            WHEN AVG(mt.mood_score) > 7 THEN 'melhorando'
            WHEN AVG(mt.mood_score) < 5 THEN 'precisa_atenção'
            ELSE 'estável'
        END,
        'stress_level', AVG(mt.stress_level),
        'energy_level', AVG(mt.energy_level),
        'recommendations', CASE 
            WHEN AVG(mt.mood_score) < 5 THEN 
                '["Considere praticar meditação", "Faça exercícios leves", "Conecte-se com amigos"]'::jsonb
            WHEN AVG(mt.stress_level) > 7 THEN 
                '["Técnicas de respiração", "Atividades relaxantes", "Reduza cafeína"]'::jsonb
            ELSE '["Continue suas atividades", "Mantenha rotina saudável"]'::jsonb
        END
    ) INTO mood_analysis
    FROM mood_tracking mt
    WHERE mt.user_id = p_user_id
    AND mt.date >= CURRENT_DATE - INTERVAL '7 days';

    -- Análise de sono
    SELECT jsonb_build_object(
        'average_duration', AVG(st.sleep_duration_hours),
        'average_quality', AVG(st.sleep_quality),
        'recommendations', CASE 
            WHEN AVG(st.sleep_duration_hours) < 7 THEN 
                '["Estabeleça horário fixo", "Evite telas antes de dormir", "Crie ambiente relaxante"]'::jsonb
            WHEN AVG(st.sleep_quality) < 6 THEN 
                '["Reduza cafeína", "Exercite-se mais cedo", "Considere suplementos naturais"]'::jsonb
            ELSE '["Continue bons hábitos", "Mantenha rotina"]'::jsonb
        END
    ) INTO sleep_analysis
    FROM sleep_tracking st
    WHERE st.user_id = p_user_id
    AND st.date >= CURRENT_DATE - INTERVAL '7 days';

    -- Análise de exercício
    SELECT jsonb_build_object(
        'total_sessions', COUNT(*),
        'average_duration', AVG(et.duration_minutes),
        'total_calories', SUM(et.calories_burned),
        'recommendations', CASE 
            WHEN COUNT(*) < 3 THEN 
                '["Aumente frequência", "Comece com 20 min/dia", "Encontre atividade que goste"]'::jsonb
            WHEN AVG(et.duration_minutes) < 30 THEN 
                '["Aumente duração gradualmente", "Adicione intensidade", "Varie atividades"]'::jsonb
            ELSE '["Continue excelente trabalho", "Considere novos desafios"]'::jsonb
        END
    ) INTO exercise_analysis
    FROM exercise_tracking et
    WHERE et.user_id = p_user_id
    AND et.date >= CURRENT_DATE - INTERVAL '7 days';

    -- Recomendações gerais
    SELECT jsonb_build_object(
        'priority_actions', (
            SELECT jsonb_agg(action)
            FROM (
                VALUES 
                    ('Hidrate-se adequadamente'),
                    ('Mantenha rotina de sono'),
                    ('Pratique exercícios regularmente'),
                    ('Monitore seu humor'),
                    ('Alimente-se de forma balanceada')
            ) AS actions(action)
        ),
        'weekly_goals', (
            SELECT jsonb_agg(goal)
            FROM (
                VALUES 
                    ('Beber 2L de água por dia'),
                    ('Dormir 8h por noite'),
                    ('Exercitar-se 3x por semana'),
                    ('Meditar 10 min por dia'),
                    ('Comer 5 porções de frutas/verduras')
            ) AS goals(goal)
        ),
        'motivational_message', 'Você está no caminho certo! Continue focado nos seus objetivos de saúde.'
    ) INTO recommendations;

    -- Montar insights completos
    insights := jsonb_build_object(
        'health_trends', health_trends,
        'mood_analysis', mood_analysis,
        'sleep_analysis', sleep_analysis,
        'exercise_analysis', exercise_analysis,
        'recommendations', recommendations,
        'generated_at', NOW(),
        'ai_assistant', 'Sofia'
    );

    RETURN insights;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para relatório do Dr. Vital
CREATE OR REPLACE FUNCTION generate_dr_vital_report(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    report JSONB;
    health_summary JSONB;
    risk_assessment JSONB;
    recommendations JSONB;
    vital_signs JSONB;
    lifestyle_analysis JSONB;
BEGIN
    -- Resumo de saúde
    SELECT jsonb_build_object(
        'overall_health_score', (
            SELECT ROUND(
                (
                    COALESCE(AVG(mt.mood_score), 5) * 0.2 +
                    COALESCE(AVG(st.sleep_quality), 5) * 0.2 +
                    CASE 
                        WHEN AVG(wt.consumed_ml) >= 2000 THEN 10
                        WHEN AVG(wt.consumed_ml) >= 1500 THEN 7
                        ELSE 5
                    END * 0.2 +
                    CASE 
                        WHEN COUNT(et.id) >= 3 THEN 10
                        WHEN COUNT(et.id) >= 1 THEN 7
                        ELSE 5
                    END * 0.2 +
                    CASE 
                        WHEN AVG(wm.peso_kg) IS NOT NULL THEN 10
                        ELSE 5
                    END * 0.2
                ), 2
            )
            FROM mood_tracking mt
            FULL OUTER JOIN sleep_tracking st ON st.user_id = mt.user_id AND st.date = mt.date
            FULL OUTER JOIN water_tracking wt ON wt.user_id = mt.user_id AND wt.date = mt.date
            FULL OUTER JOIN exercise_tracking et ON et.user_id = mt.user_id AND et.date >= CURRENT_DATE - INTERVAL '7 days'
            FULL OUTER JOIN weight_measurements wm ON wm.user_id = mt.user_id
            WHERE mt.user_id = p_user_id
            AND mt.date >= CURRENT_DATE - INTERVAL '7 days'
        ),
        'weight_status', (
            SELECT jsonb_build_object(
                'current_weight', wm.peso_kg,
                'bmi', wm.imc,
                'bmi_category', 
                    CASE 
                        WHEN wm.imc < 18.5 THEN 'Abaixo do peso'
                        WHEN wm.imc < 25 THEN 'Peso normal'
                        WHEN wm.imc < 30 THEN 'Sobrepeso'
                        ELSE 'Obesidade'
                    END,
                'trend', wm.tendencia
            )
            FROM weight_measurements wm
            WHERE wm.user_id = p_user_id
            ORDER BY wm.measurement_date DESC
            LIMIT 1
        ),
        'hydration_status', (
            SELECT jsonb_build_object(
                'average_consumption', AVG(wt.consumed_ml),
                'target_consumption', 2000,
                'adequacy_percentage', ROUND((AVG(wt.consumed_ml) / 2000.0) * 100, 2)
            )
            FROM water_tracking wt
            WHERE wt.user_id = p_user_id
            AND wt.date >= CURRENT_DATE - INTERVAL '7 days'
        )
    ) INTO health_summary;

    -- Avaliação de riscos
    SELECT jsonb_build_object(
        'high_risk_factors', (
            SELECT jsonb_agg(factor)
            FROM (
                VALUES 
                    (CASE WHEN AVG(mt.stress_level) > 8 THEN 'Estresse elevado' END),
                    (CASE WHEN AVG(st.sleep_duration_hours) < 6 THEN 'Sono insuficiente' END),
                    (CASE WHEN AVG(wt.consumed_ml) < 1500 THEN 'Hidratação inadequada' END),
                    (CASE WHEN COUNT(et.id) < 2 THEN 'Sedentarismo' END),
                    (CASE WHEN AVG(mt.mood_score) < 5 THEN 'Humor comprometido' END)
            ) AS factors(factor)
            WHERE factor IS NOT NULL
        ),
        'moderate_risk_factors', (
            SELECT jsonb_agg(factor)
            FROM (
                VALUES 
                    (CASE WHEN AVG(st.sleep_quality) < 6 THEN 'Qualidade do sono' END),
                    (CASE WHEN AVG(mt.energy_level) < 5 THEN 'Baixa energia' END)
            ) AS factors(factor)
            WHERE factor IS NOT NULL
        ),
        'overall_risk_level', 
            CASE 
                WHEN COUNT(*) > 3 THEN 'Alto'
                WHEN COUNT(*) > 1 THEN 'Moderado'
                ELSE 'Baixo'
            END
    ) INTO risk_assessment
    FROM (
        SELECT 1 WHERE AVG(mt.stress_level) > 8
        UNION ALL SELECT 1 WHERE AVG(st.sleep_duration_hours) < 6
        UNION ALL SELECT 1 WHERE AVG(wt.consumed_ml) < 1500
        UNION ALL SELECT 1 WHERE COUNT(et.id) < 2
        UNION ALL SELECT 1 WHERE AVG(mt.mood_score) < 5
    ) risk_factors;

    -- Análise de estilo de vida
    SELECT jsonb_build_object(
        'sleep_pattern', jsonb_build_object(
            'average_duration', AVG(st.sleep_duration_hours),
            'average_quality', AVG(st.sleep_quality),
            'consistency_score', ROUND(
                (COUNT(*) / 7.0) * 100, 2
            )
        ),
        'exercise_pattern', jsonb_build_object(
            'frequency', COUNT(*),
            'average_duration', AVG(et.duration_minutes),
            'intensity_distribution', jsonb_build_object(
                'low', COUNT(CASE WHEN et.intensity_level = 'low' THEN 1 END),
                'medium', COUNT(CASE WHEN et.intensity_level = 'medium' THEN 1 END),
                'high', COUNT(CASE WHEN et.intensity_level = 'high' THEN 1 END)
            )
        ),
        'stress_management', jsonb_build_object(
            'average_stress', AVG(mt.stress_level),
            'coping_strategies', 'Recomendadas: meditação, exercícios, respiração'
        )
    ) INTO lifestyle_analysis
    FROM sleep_tracking st
    FULL OUTER JOIN exercise_tracking et ON et.user_id = st.user_id AND et.date = st.date
    FULL OUTER JOIN mood_tracking mt ON mt.user_id = st.user_id AND mt.date = st.date
    WHERE st.user_id = p_user_id
    AND st.date >= CURRENT_DATE - INTERVAL '7 days';

    -- Recomendações médicas
    SELECT jsonb_build_object(
        'immediate_actions', (
            SELECT jsonb_agg(action)
            FROM (
                VALUES 
                    ('Monitore pressão arterial regularmente'),
                    ('Mantenha hidratação adequada'),
                    ('Pratique exercícios moderados'),
                    ('Estabeleça rotina de sono')
            ) AS actions(action)
        ),
        'lifestyle_changes', (
            SELECT jsonb_agg(change)
            FROM (
                VALUES 
                    ('Reduza consumo de sal'),
                    ('Aumente atividade física'),
                    ('Melhore qualidade do sono'),
                    ('Gerencie estresse')
            ) AS changes(change)
        ),
        'follow_up', 'Agende consulta de acompanhamento em 3 meses',
        'emergency_contact', 'Em caso de sintomas graves, procure atendimento médico imediatamente'
    ) INTO recommendations;

    -- Montar relatório completo
    report := jsonb_build_object(
        'patient_id', p_user_id,
        'report_date', CURRENT_DATE,
        'health_summary', health_summary,
        'risk_assessment', risk_assessment,
        'lifestyle_analysis', lifestyle_analysis,
        'recommendations', recommendations,
        'generated_by', 'Dr. Vital',
        'next_review', CURRENT_DATE + INTERVAL '3 months'
    );

    RETURN report;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===============================================
-- 7. TRIGGERS
-- ===============================================
CREATE TRIGGER trigger_update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_courses_updated_at
    BEFORE UPDATE ON courses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_challenges_updated_at
    BEFORE UPDATE ON challenges
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_challenge_participations_updated_at
    BEFORE UPDATE ON challenge_participations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ===============================================
-- 8. POLÍTICAS RLS
-- ===============================================

-- Profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own profile" ON profiles
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update their own profile" ON profiles
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can create their own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Courses
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view published courses" ON courses
    FOR SELECT USING ((is_published = true) OR (auth.uid() IS NOT NULL));
CREATE POLICY "Authenticated users can manage all courses" ON courses
    FOR ALL USING (auth.uid() IS NOT NULL);

-- Challenges
ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view all challenges" ON challenges
    FOR SELECT USING (true);
CREATE POLICY "Authenticated users can manage all challenges" ON challenges
    FOR ALL USING (auth.uid() IS NOT NULL);

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

-- Daily Mission Sessions
ALTER TABLE daily_mission_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own mission sessions" ON daily_mission_sessions
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create their own mission sessions" ON daily_mission_sessions
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own mission sessions" ON daily_mission_sessions
    FOR UPDATE USING (auth.uid() = user_id);

-- Daily Responses
ALTER TABLE daily_responses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own responses" ON daily_responses
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create their own responses" ON daily_responses
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own responses" ON daily_responses
    FOR UPDATE USING (auth.uid() = user_id);

-- User Goals
ALTER TABLE user_goals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can manage goals" ON user_goals
    FOR ALL USING (auth.uid() IS NOT NULL);

-- Weight Measurements
ALTER TABLE weight_measurements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own weight measurements" ON weight_measurements
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own weight measurements" ON weight_measurements
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own weight measurements" ON weight_measurements
    FOR UPDATE USING (auth.uid() = user_id);

-- Sessions
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view sessions" ON sessions
    FOR SELECT USING (true);
CREATE POLICY "Authenticated users can manage sessions" ON sessions
    FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Users can create sessions" ON sessions
    FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can delete their own sessions" ON sessions
    FOR DELETE USING (auth.uid() = created_by);

-- AI Configurations
ALTER TABLE ai_configurations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view ai configurations" ON ai_configurations
    FOR SELECT USING (true);
CREATE POLICY "Authenticated users can manage ai configurations" ON ai_configurations
    FOR ALL USING (auth.uid() IS NOT NULL);

-- ===============================================
-- 9. PERMISSÕES
-- ===============================================
GRANT EXECUTE ON FUNCTION get_user_dashboard(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_sofia_insights(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION generate_dr_vital_report(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION is_admin_user() TO authenticated;

GRANT EXECUTE ON FUNCTION get_user_dashboard(UUID) TO service_role;
GRANT EXECUTE ON FUNCTION get_sofia_insights(UUID) TO service_role;
GRANT EXECUTE ON FUNCTION generate_dr_vital_report(UUID) TO service_role;
GRANT EXECUTE ON FUNCTION is_admin_user() TO service_role; 