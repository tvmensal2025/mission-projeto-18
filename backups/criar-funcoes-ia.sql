-- ===============================================
-- 🤖 CRIAR FUNÇÕES DE IA FALTANTES
-- ===============================================

-- ===============================================
-- 1. FUNÇÃO GET_USER_DASHBOARD
-- ===============================================
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

-- ===============================================
-- 2. FUNÇÃO GET_SOFIA_INSIGHTS
-- ===============================================
CREATE OR REPLACE FUNCTION get_sofia_insights(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    insights JSONB;
    health_trends JSONB;
    recommendations JSONB;
    mood_analysis JSONB;
    sleep_analysis JSONB;
    exercise_analysis JSONB;
    nutrition_analysis JSONB;
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

    -- Análise de nutrição
    SELECT jsonb_build_object(
        'total_calories', SUM(nt.calories),
        'protein_avg', AVG(nt.protein_g),
        'carbs_avg', AVG(nt.carbs_g),
        'fat_avg', AVG(nt.fat_g),
        'recommendations', CASE 
            WHEN AVG(nt.protein_g) < 50 THEN 
                '["Aumente proteínas", "Consuma mais ovos, frango, peixe"]'::jsonb
            WHEN AVG(nt.carbs_g) > 300 THEN 
                '["Reduza carboidratos", "Prefira grãos integrais"]'::jsonb
            ELSE '["Continue alimentação balanceada", "Mantenha variedade"]'::jsonb
        END
    ) INTO nutrition_analysis
    FROM nutrition_tracking nt
    WHERE nt.user_id = p_user_id
    AND nt.date >= CURRENT_DATE - INTERVAL '7 days';

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
        'nutrition_analysis', nutrition_analysis,
        'recommendations', recommendations,
        'generated_at', NOW(),
        'ai_assistant', 'Sofia'
    );

    RETURN insights;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===============================================
-- 3. FUNÇÃO GENERATE_DR_VITAL_REPORT
-- ===============================================
CREATE OR REPLACE FUNCTION generate_dr_vital_report(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    report JSONB;
    health_summary JSONB;
    risk_assessment JSONB;
    recommendations JSONB;
    lab_results JSONB;
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

    -- Sinais vitais
    SELECT jsonb_build_object(
        'blood_pressure', (
            SELECT jsonb_build_object(
                'systolic', bpt.systolic,
                'diastolic', bpt.diastolic,
                'pulse', bpt.pulse,
                'status', 
                    CASE 
                        WHEN bpt.systolic >= 140 OR bpt.diastolic >= 90 THEN 'Elevada'
                        WHEN bpt.systolic >= 120 OR bpt.diastolic >= 80 THEN 'Pré-hipertensão'
                        ELSE 'Normal'
                    END
            )
            FROM blood_pressure_tracking bpt
            WHERE bpt.user_id = p_user_id
            ORDER BY bpt.date DESC, bpt.time DESC
            LIMIT 1
        ),
        'blood_glucose', (
            SELECT jsonb_build_object(
                'level', bgt.glucose_level,
                'type', bgt.measurement_type,
                'status',
                    CASE 
                        WHEN bgt.glucose_level >= 126 THEN 'Elevada'
                        WHEN bgt.glucose_level >= 100 THEN 'Pré-diabetes'
                        ELSE 'Normal'
                    END
            )
            FROM blood_glucose_tracking bgt
            WHERE bgt.user_id = p_user_id
            ORDER BY bgt.date DESC, bgt.time DESC
            LIMIT 1
        ),
        'heart_rate', (
            SELECT jsonb_build_object(
                'average', AVG(et.heart_rate_avg),
                'max', MAX(et.heart_rate_max),
                'status',
                    CASE 
                        WHEN AVG(et.heart_rate_avg) > 100 THEN 'Elevada'
                        WHEN AVG(et.heart_rate_avg) < 60 THEN 'Baixa'
                        ELSE 'Normal'
                    END
            )
            FROM exercise_tracking et
            WHERE et.user_id = p_user_id
            AND et.date >= CURRENT_DATE - INTERVAL '7 days'
        )
    ) INTO vital_signs;

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
        'nutrition_pattern', jsonb_build_object(
            'average_calories', AVG(nt.calories),
            'protein_adequacy', 
                CASE 
                    WHEN AVG(nt.protein_g) >= 50 THEN 'Adequada'
                    ELSE 'Inadequada'
                END,
            'meal_frequency', COUNT(DISTINCT nt.date)
        ),
        'stress_management', jsonb_build_object(
            'average_stress', AVG(mt.stress_level),
            'coping_strategies', 'Recomendadas: meditação, exercícios, respiração'
        )
    ) INTO lifestyle_analysis
    FROM sleep_tracking st
    FULL OUTER JOIN exercise_tracking et ON et.user_id = st.user_id AND et.date = st.date
    FULL OUTER JOIN nutrition_tracking nt ON nt.user_id = st.user_id AND nt.date = st.date
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
        'vital_signs', vital_signs,
        'lifestyle_analysis', lifestyle_analysis,
        'recommendations', recommendations,
        'generated_by', 'Dr. Vital',
        'next_review', CURRENT_DATE + INTERVAL '3 months'
    );

    RETURN report;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===============================================
-- CRIAR POLÍTICAS DE ACESSO PARA AS FUNÇÕES
-- ===============================================

-- Permitir que usuários autenticados acessem suas próprias funções
GRANT EXECUTE ON FUNCTION get_user_dashboard(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_sofia_insights(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION generate_dr_vital_report(UUID) TO authenticated;

-- Permitir que admins acessem todas as funções
GRANT EXECUTE ON FUNCTION get_user_dashboard(UUID) TO service_role;
GRANT EXECUTE ON FUNCTION get_sofia_insights(UUID) TO service_role;
GRANT EXECUTE ON FUNCTION generate_dr_vital_report(UUID) TO service_role; 