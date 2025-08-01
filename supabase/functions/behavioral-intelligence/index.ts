import "https://deno.land/x/xhr@0.1.0/mod.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface BehaviorAnalysisRequest {
  userId: string;
  analysisType: 'pattern_detection' | 'intervention_suggestion' | 'progress_prediction' | 'comprehensive_analysis';
  timeframe: 'week' | 'month' | 'quarter' | 'custom';
  customPeriod?: { start: string; end: string };
  focusAreas: string[]; // nutrition, exercise, sleep, emotions, goals, social
  options?: {
    sensitivityLevel?: 'low' | 'medium' | 'high';
    includeInterventions?: boolean;
    generatePredictions?: boolean;
    detailLevel?: 'summary' | 'detailed' | 'comprehensive';
  };
}

interface BehaviorInsights {
  analysisId: string;
  userId: string;
  analysisType: string;
  period: { start: string; end: string };
  
  detectedPatterns: Array<{
    id: string;
    type: string;
    name: string;
    description: string;
    confidence: number;
    strength: number;
    frequency: any;
    impact: {
      health: number;
      goals: number;
      emotional: number;
      overall: number;
    };
    triggers: any;
    responses: any;
    isBeneficial: boolean;
  }>;
  
  behavioralTrends: {
    improving: string[];
    declining: string[];
    stable: string[];
    emerging: string[];
  };
  
  correlations: Array<{
    factor1: string;
    factor2: string;
    correlation: number;
    significance: number;
    interpretation: string;
  }>;
  
  riskFactors: Array<{
    factor: string;
    severity: 'low' | 'medium' | 'high' | 'critical';
    description: string;
    recommendations: string[];
  }>;
  
  interventionOpportunities: Array<{
    patternId: string;
    interventionType: string;
    name: string;
    description: string;
    successProbability: number;
    effort: 'low' | 'medium' | 'high';
    timeframe: string;
    strategy: any;
  }>;
  
  predictions: {
    shortTerm: Array<{ metric: string; prediction: number; confidence: number }>;
    longTerm: Array<{ metric: string; prediction: number; confidence: number }>;
    scenarios: Array<{ scenario: string; probability: number; outcomes: string[] }>;
  };
  
  personalizedRecommendations: {
    immediate: string[];
    shortTerm: string[];
    longTerm: string[];
    professional: string[];
  };
  
  confidenceMetrics: {
    dataQuality: number;
    patternReliability: number;
    predictionAccuracy: number;
    overallConfidence: number;
  };
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const requestData: BehaviorAnalysisRequest = await req.json();
    console.log('🧠 Behavioral Intelligence Request:', requestData);

    // Inicializar Supabase
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Executar análise comportamental
    const insights = await analyzeBehavioralPatterns(supabase, requestData);

    return new Response(JSON.stringify(insights), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('❌ Erro na análise comportamental:', error);
    
    return new Response(JSON.stringify({ 
      error: error.message,
      details: 'Erro na análise de inteligência comportamental'
    }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});

async function analyzeBehavioralPatterns(
  supabase: any, 
  request: BehaviorAnalysisRequest
): Promise<BehaviorInsights> {
  
  console.log('🔍 Iniciando análise comportamental...');

  // 1. Determinar período de análise
  const period = determinePeriod(request.timeframe, request.customPeriod);
  
  // 2. Buscar configurações do usuário
  const userConfig = await getUserBehaviorConfig(supabase, request.userId);
  
  // 3. Coletar dados comportamentais
  const behaviorData = await collectBehaviorData(supabase, request.userId, period, request.focusAreas);
  
  // 4. Detectar padrões comportamentais
  const detectedPatterns = await detectPatterns(supabase, behaviorData, userConfig, request.options);
  
  // 5. Analisar tendências
  const behavioralTrends = await analyzeTrends(behaviorData, detectedPatterns);
  
  // 6. Identificar correlações
  const correlations = await identifyCorrelations(behaviorData);
  
  // 7. Avaliar fatores de risco
  const riskFactors = await assessRiskFactors(detectedPatterns, behaviorData);
  
  // 8. Sugerir intervenções
  const interventionOpportunities = await suggestInterventions(supabase, detectedPatterns, userConfig);
  
  // 9. Gerar predições
  const predictions = await generatePredictions(behaviorData, detectedPatterns);
  
  // 10. Criar recomendações personalizadas
  const personalizedRecommendations = await generatePersonalizedRecommendations(
    detectedPatterns, 
    riskFactors, 
    interventionOpportunities,
    userConfig
  );
  
  // 11. Calcular métricas de confiança
  const confidenceMetrics = calculateConfidenceMetrics(behaviorData, detectedPatterns);

  // 12. Salvar análise
  const analysisId = await saveAnalysis(supabase, request.userId, {
    detectedPatterns,
    behavioralTrends,
    correlations,
    riskFactors,
    interventionOpportunities
  });

  // 13. Compilar resultado final
  const insights: BehaviorInsights = {
    analysisId,
    userId: request.userId,
    analysisType: request.analysisType,
    period,
    detectedPatterns,
    behavioralTrends,
    correlations,
    riskFactors,
    interventionOpportunities,
    predictions,
    personalizedRecommendations,
    confidenceMetrics
  };

  console.log('✅ Análise comportamental concluída');
  return insights;
}

function determinePeriod(timeframe: string, customPeriod?: any): { start: string; end: string } {
  const now = new Date();
  let start: Date;
  let end: Date = new Date(now);

  if (customPeriod) {
    return {
      start: customPeriod.start,
      end: customPeriod.end
    };
  }

  switch (timeframe) {
    case 'week':
      start = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      break;
    case 'month':
      start = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
      break;
    case 'quarter':
      start = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
      break;
    default:
      start = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
  }

  return {
    start: start.toISOString().split('T')[0],
    end: end.toISOString().split('T')[0]
  };
}

async function getUserBehaviorConfig(supabase: any, userId: string): Promise<any> {
  console.log('⚙️ Buscando configurações comportamentais...');

  const { data: config } = await supabase
    .from('behavioral_analysis_config')
    .select('*')
    .eq('user_id', userId)
    .eq('is_active', true)
    .single();

  return config || {
    detection_sensitivity: 0.7,
    minimum_pattern_occurrences: 3,
    analysis_window_days: 30,
    confidence_threshold: 0.6,
    enabled_pattern_types: ['eating_habits', 'exercise_patterns', 'emotional_triggers', 'goal_adherence']
  };
}

async function collectBehaviorData(
  supabase: any, 
  userId: string, 
  period: any, 
  focusAreas: string[]
): Promise<any> {
  
  console.log('📊 Coletando dados comportamentais...');

  const data: any = {
    userId,
    period,
    focusAreas,
    completeness: {}
  };

  // Dados de peso e medições
  if (focusAreas.includes('nutrition') || focusAreas.includes('goals')) {
    const { data: weightData } = await supabase
      .from('weight_measurements')
      .select('*')
      .eq('user_id', userId)
      .gte('measurement_date', period.start)
      .lte('measurement_date', period.end)
      .order('measurement_date', { ascending: true });
    
    data.weightMeasurements = weightData || [];
    data.completeness.weight = (weightData?.length || 0) > 0 ? 1 : 0;
  }

  // Dados de alimentação
  if (focusAreas.includes('nutrition')) {
    const { data: foodData } = await supabase
      .from('food_image_analysis')
      .select('*')
      .eq('user_id', userId)
      .gte('created_at', `${period.start}T00:00:00`)
      .lte('created_at', `${period.end}T23:59:59`)
      .order('created_at', { ascending: true });
    
    data.foodAnalysis = foodData || [];
    data.completeness.food = (foodData?.length || 0) > 0 ? 1 : 0;
  }

  // Dados de exercícios/missões
  if (focusAreas.includes('exercise') || focusAreas.includes('goals')) {
    const { data: missionsData } = await supabase
      .from('daily_mission_sessions')
      .select('*')
      .eq('user_id', userId)
      .gte('date', period.start)
      .lte('date', period.end)
      .order('date', { ascending: true });
    
    data.dailyMissions = missionsData || [];
    data.completeness.missions = (missionsData?.length || 0) > 0 ? 1 : 0;
  }

  // Dados emocionais
  if (focusAreas.includes('emotions')) {
    const { data: emotionalData } = await supabase
      .from('chat_emotional_analysis')
      .select('*')
      .eq('user_id', userId)
      .gte('created_at', `${period.start}T00:00:00`)
      .lte('created_at', `${period.end}T23:59:59`)
      .order('created_at', { ascending: true });
    
    data.emotionalAnalysis = emotionalData || [];
    data.completeness.emotions = (emotionalData?.length || 0) > 0 ? 1 : 0;
  }

  // Dados de conversas
  const { data: conversationsData } = await supabase
    .from('chat_conversations')
    .select('*')
    .eq('user_id', userId)
    .gte('created_at', `${period.start}T00:00:00`)
    .lte('created_at', `${period.end}T23:59:59`)
    .order('created_at', { ascending: true });
  
  data.conversations = conversationsData || [];
  data.completeness.conversations = (conversationsData?.length || 0) > 0 ? 1 : 0;

  // Dados de calendário (se disponível)
  if (focusAreas.includes('social') || focusAreas.includes('goals')) {
    const { data: calendarData } = await supabase
      .from('ai_managed_events')
      .select('*')
      .eq('user_id', userId)
      .gte('start_datetime', `${period.start}T00:00:00`)
      .lte('start_datetime', `${period.end}T23:59:59`)
      .order('start_datetime', { ascending: true });
    
    data.calendarEvents = calendarData || [];
    data.completeness.calendar = (calendarData?.length || 0) > 0 ? 1 : 0;
  }

  // Calcular completude geral
  const completenessValues = Object.values(data.completeness);
  data.overallCompleteness = completenessValues.length > 0 
    ? completenessValues.reduce((a: number, b: number) => a + b, 0) / completenessValues.length 
    : 0;

  console.log(`📊 Dados coletados com ${Math.round(data.overallCompleteness * 100)}% de completude`);
  return data;
}

async function detectPatterns(
  supabase: any, 
  behaviorData: any, 
  userConfig: any, 
  options?: any
): Promise<any[]> {
  
  console.log('🔍 Detectando padrões comportamentais...');

  const patterns: any[] = [];
  const sensitivity = options?.sensitivityLevel === 'high' ? 0.8 : 
                     options?.sensitivityLevel === 'low' ? 0.5 : 0.7;

  // 1. Padrões de alimentação
  if (behaviorData.foodAnalysis && behaviorData.foodAnalysis.length >= 3) {
    const foodPatterns = await detectFoodPatterns(behaviorData.foodAnalysis, sensitivity);
    patterns.push(...foodPatterns);
  }

  // 2. Padrões de exercício
  if (behaviorData.dailyMissions && behaviorData.dailyMissions.length >= 5) {
    const exercisePatterns = await detectExercisePatterns(behaviorData.dailyMissions, sensitivity);
    patterns.push(...exercisePatterns);
  }

  // 3. Padrões emocionais
  if (behaviorData.emotionalAnalysis && behaviorData.emotionalAnalysis.length >= 3) {
    const emotionalPatterns = await detectEmotionalPatterns(
      behaviorData.emotionalAnalysis, 
      behaviorData.conversations,
      sensitivity
    );
    patterns.push(...emotionalPatterns);
  }

  // 4. Padrões de peso
  if (behaviorData.weightMeasurements && behaviorData.weightMeasurements.length >= 3) {
    const weightPatterns = await detectWeightPatterns(behaviorData.weightMeasurements, sensitivity);
    patterns.push(...weightPatterns);
  }

  // 5. Padrões sociais/temporais
  if (behaviorData.calendarEvents && behaviorData.calendarEvents.length >= 2) {
    const socialPatterns = await detectSocialPatterns(behaviorData.calendarEvents, sensitivity);
    patterns.push(...socialPatterns);
  }

  // 6. Padrões cruzados (correlações entre diferentes tipos de dados)
  const crossPatterns = await detectCrossPatterns(behaviorData, sensitivity);
  patterns.push(...crossPatterns);

  // Filtrar padrões por confiança
  const filteredPatterns = patterns.filter(pattern => 
    pattern.confidence >= userConfig.confidence_threshold
  );

  // Salvar padrões detectados no banco
  for (const pattern of filteredPatterns) {
    await saveDetectedPattern(supabase, behaviorData.userId, pattern);
  }

  console.log(`🔍 ${filteredPatterns.length} padrões detectados`);
  return filteredPatterns;
}

async function detectFoodPatterns(foodData: any[], sensitivity: number): Promise<any[]> {
  const patterns: any[] = [];

  // Padrão de alimentação emocional
  const emotionalEatingEvents = foodData.filter(meal => 
    meal.emotional_context && meal.emotional_context !== 'neutral' && 
    meal.goal_alignment_score < 0.5
  );

  if (emotionalEatingEvents.length >= 3) {
    patterns.push({
      id: crypto.randomUUID(),
      type: 'emotional_eating',
      name: 'Alimentação Emocional',
      description: 'Tendência a comer alimentos menos saudáveis durante estados emocionais alterados',
      confidence: Math.min(0.95, 0.6 + (emotionalEatingEvents.length / foodData.length)),
      strength: emotionalEatingEvents.length / foodData.length,
      frequency: {
        occurrences_per_week: (emotionalEatingEvents.length / foodData.length) * 7,
        duration_minutes: 30,
        contexts: emotionalEatingEvents.map(e => e.emotional_context)
      },
      impact: {
        health: -0.6,
        goals: -0.7,
        emotional: -0.4,
        overall: -0.57
      },
      triggers: {
        emotional_based: [...new Set(emotionalEatingEvents.map(e => e.emotional_context))],
        time_based: identifyCommonTimes(emotionalEatingEvents)
      },
      responses: {
        actions: ['unhealthy_food_choices', 'portion_control_issues'],
        emotional_state: 'seeking_comfort'
      },
      isBeneficial: false
    });
  }

  // Padrão de refeições regulares
  const regularMealTimes = analyzeRegularMealTimes(foodData);
  if (regularMealTimes.regularity > 0.7) {
    patterns.push({
      id: crypto.randomUUID(),
      type: 'regular_eating',
      name: 'Horários Regulares de Alimentação',
      description: 'Consistência nos horários das refeições',
      confidence: regularMealTimes.regularity,
      strength: regularMealTimes.regularity,
      frequency: {
        occurrences_per_week: 7,
        duration_minutes: 45,
        time_distribution: regularMealTimes.timeDistribution
      },
      impact: {
        health: 0.6,
        goals: 0.5,
        emotional: 0.3,
        overall: 0.47
      },
      triggers: {
        time_based: regularMealTimes.commonTimes
      },
      responses: {
        actions: ['consistent_meal_timing', 'routine_adherence']
      },
      isBeneficial: true
    });
  }

  return patterns;
}

async function detectExercisePatterns(missionsData: any[], sensitivity: number): Promise<any[]> {
  const patterns: any[] = [];

  // Padrão de exercícios em dias específicos
  const dayOfWeekDistribution = analyzeDayOfWeekDistribution(missionsData.filter(m => m.completed));
  const consistentDays = Object.entries(dayOfWeekDistribution)
    .filter(([day, frequency]) => frequency > 0.6)
    .map(([day]) => parseInt(day));

  if (consistentDays.length >= 2) {
    patterns.push({
      id: crypto.randomUUID(),
      type: 'exercise_routine',
      name: 'Rotina de Exercícios Semanal',
      description: `Exercícios consistentes em dias específicos da semana`,
      confidence: 0.8,
      strength: consistentDays.length / 7,
      frequency: {
        occurrences_per_week: consistentDays.length,
        duration_minutes: 45,
        day_of_week_distribution: dayOfWeekDistribution
      },
      impact: {
        health: 0.8,
        goals: 0.9,
        emotional: 0.6,
        overall: 0.77
      },
      triggers: {
        time_based: consistentDays.map(day => getDayName(day))
      },
      responses: {
        actions: ['exercise_completion', 'goal_achievement'],
        emotional_state: 'motivated'
      },
      isBeneficial: true
    });
  }

  // Padrão de baixa aderência
  const completionRate = missionsData.filter(m => m.completed).length / missionsData.length;
  if (completionRate < 0.4) {
    patterns.push({
      id: crypto.randomUUID(),
      type: 'low_adherence',
      name: 'Baixa Aderência às Missões',
      description: 'Dificuldade consistente em completar missões diárias',
      confidence: 0.9,
      strength: 1 - completionRate,
      frequency: {
        occurrences_per_week: 7 * (1 - completionRate),
        duration_minutes: 0
      },
      impact: {
        health: -0.5,
        goals: -0.9,
        emotional: -0.3,
        overall: -0.57
      },
      triggers: {
        behavioral_based: ['lack_of_motivation', 'time_constraints', 'difficulty_level']
      },
      responses: {
        actions: ['mission_skipping', 'goal_avoidance'],
        emotional_state: 'frustrated'
      },
      isBeneficial: false
    });
  }

  return patterns;
}

async function detectEmotionalPatterns(
  emotionalData: any[], 
  conversationsData: any[], 
  sensitivity: number
): Promise<any[]> {
  const patterns: any[] = [];

  // Padrão de variabilidade emocional alta
  const moodVariability = calculateMoodVariability(emotionalData);
  if (moodVariability > 0.3) {
    patterns.push({
      id: crypto.randomUUID(),
      type: 'mood_volatility',
      name: 'Alta Variabilidade Emocional',
      description: 'Flutuações significativas no estado emocional',
      confidence: Math.min(0.9, moodVariability * 2),
      strength: moodVariability,
      frequency: {
        occurrences_per_week: emotionalData.length / 4, // Estimativa
        duration_minutes: 60
      },
      impact: {
        health: -0.3,
        goals: -0.4,
        emotional: -0.8,
        overall: -0.5
      },
      triggers: {
        emotional_based: ['stress', 'external_factors', 'hormonal_changes']
      },
      responses: {
        actions: ['mood_swings', 'emotional_instability'],
        emotional_state: 'variable'
      },
      isBeneficial: false
    });
  }

  // Padrão de stress elevado
  const highStressEvents = emotionalData.filter(e => (e.stress_level || 5) > 7);
  if (highStressEvents.length / emotionalData.length > 0.3) {
    patterns.push({
      id: crypto.randomUUID(),
      type: 'chronic_stress',
      name: 'Níveis Elevados de Stress',
      description: 'Frequentes episódios de stress alto',
      confidence: 0.85,
      strength: highStressEvents.length / emotionalData.length,
      frequency: {
        occurrences_per_week: (highStressEvents.length / emotionalData.length) * 7,
        duration_minutes: 120
      },
      impact: {
        health: -0.7,
        goals: -0.5,
        emotional: -0.9,
        overall: -0.7
      },
      triggers: {
        context_based: identifyStressTriggers(highStressEvents, conversationsData)
      },
      responses: {
        actions: ['stress_behaviors', 'coping_mechanisms'],
        emotional_state: 'overwhelmed'
      },
      isBeneficial: false
    });
  }

  return patterns;
}

async function detectWeightPatterns(weightData: any[], sensitivity: number): Promise<any[]> {
  const patterns: any[] = [];

  // Calcular tendência de peso
  const weightTrend = calculateWeightTrend(weightData);
  
  if (Math.abs(weightTrend.slope) > 0.1) { // Mudança significativa
    const isIncreasing = weightTrend.slope > 0;
    
    patterns.push({
      id: crypto.randomUUID(),
      type: isIncreasing ? 'weight_gain' : 'weight_loss',
      name: isIncreasing ? 'Tendência de Ganho de Peso' : 'Tendência de Perda de Peso',
      description: `${isIncreasing ? 'Aumento' : 'Redução'} consistente no peso corporal`,
      confidence: Math.min(0.95, Math.abs(weightTrend.correlation)),
      strength: Math.abs(weightTrend.slope),
      frequency: {
        occurrences_per_week: 1, // Medição semanal típica
        rate_of_change: weightTrend.slope
      },
      impact: {
        health: isIncreasing ? -0.5 : 0.7,
        goals: isIncreasing ? -0.6 : 0.8,
        emotional: isIncreasing ? -0.3 : 0.5,
        overall: isIncreasing ? -0.47 : 0.67
      },
      triggers: {
        behavioral_based: isIncreasing ? 
          ['caloric_surplus', 'reduced_activity'] : 
          ['caloric_deficit', 'increased_activity']
      },
      responses: {
        actions: [isIncreasing ? 'weight_gain' : 'weight_loss'],
        physical_changes: ['body_composition_change']
      },
      isBeneficial: !isIncreasing
    });
  }

  return patterns;
}

async function detectSocialPatterns(calendarData: any[], sensitivity: number): Promise<any[]> {
  const patterns: any[] = [];

  // Padrão de eventos sociais vs. saúde
  const healthEvents = calendarData.filter(event => 
    event.title && (
      event.title.toLowerCase().includes('exerc') ||
      event.title.toLowerCase().includes('treino') ||
      event.title.toLowerCase().includes('caminhada') ||
      event.title.toLowerCase().includes('academia')
    )
  );

  if (healthEvents.length >= 2) {
    patterns.push({
      id: crypto.randomUUID(),
      type: 'scheduled_health_activities',
      name: 'Atividades de Saúde Agendadas',
      description: 'Tendência a agendar e seguir atividades relacionadas à saúde',
      confidence: 0.8,
      strength: healthEvents.length / calendarData.length,
      frequency: {
        occurrences_per_week: healthEvents.length / 4, // Estimativa mensal para semanal
        duration_minutes: 60
      },
      impact: {
        health: 0.7,
        goals: 0.8,
        emotional: 0.4,
        overall: 0.63
      },
      triggers: {
        time_based: ['scheduled_time'],
        social_based: ['commitment_device']
      },
      responses: {
        actions: ['health_activity_participation', 'goal_oriented_behavior'],
        emotional_state: 'committed'
      },
      isBeneficial: true
    });
  }

  return patterns;
}

async function detectCrossPatterns(behaviorData: any, sensitivity: number): Promise<any[]> {
  const patterns: any[] = [];

  // Padrão: Stress alto → Alimentação emocional
  if (behaviorData.emotionalAnalysis && behaviorData.foodAnalysis) {
    const stressEatingCorrelation = analyzeStressEatingCorrelation(
      behaviorData.emotionalAnalysis,
      behaviorData.foodAnalysis
    );

    if (stressEatingCorrelation.correlation > 0.5) {
      patterns.push({
        id: crypto.randomUUID(),
        type: 'stress_eating_correlation',
        name: 'Correlação Stress-Alimentação',
        description: 'Tendência a comer emocionalmente durante períodos de stress',
        confidence: stressEatingCorrelation.confidence,
        strength: stressEatingCorrelation.correlation,
        frequency: {
          occurrences_per_week: stressEatingCorrelation.frequency,
          duration_minutes: 45
        },
        impact: {
          health: -0.6,
          goals: -0.7,
          emotional: -0.5,
          overall: -0.6
        },
        triggers: {
          emotional_based: ['high_stress', 'anxiety', 'overwhelm']
        },
        responses: {
          actions: ['emotional_eating', 'poor_food_choices'],
          emotional_state: 'seeking_comfort'
        },
        isBeneficial: false
      });
    }
  }

  // Padrão: Exercício → Melhor humor
  if (behaviorData.dailyMissions && behaviorData.emotionalAnalysis) {
    const exerciseMoodCorrelation = analyzeExerciseMoodCorrelation(
      behaviorData.dailyMissions,
      behaviorData.emotionalAnalysis
    );

    if (exerciseMoodCorrelation.correlation > 0.4) {
      patterns.push({
        id: crypto.randomUUID(),
        type: 'exercise_mood_boost',
        name: 'Exercício Melhora o Humor',
        description: 'Exercícios regulares correlacionam com melhor estado emocional',
        confidence: exerciseMoodCorrelation.confidence,
        strength: exerciseMoodCorrelation.correlation,
        frequency: {
          occurrences_per_week: exerciseMoodCorrelation.frequency,
          duration_minutes: 60
        },
        impact: {
          health: 0.8,
          goals: 0.7,
          emotional: 0.9,
          overall: 0.8
        },
        triggers: {
          behavioral_based: ['exercise_completion', 'physical_activity']
        },
        responses: {
          actions: ['improved_mood', 'increased_energy'],
          emotional_state: 'positive'
        },
        isBeneficial: true
      });
    }
  }

  return patterns;
}

async function analyzeTrends(behaviorData: any, detectedPatterns: any[]): Promise<any> {
  console.log('📈 Analisando tendências comportamentais...');

  const trends = {
    improving: [],
    declining: [],
    stable: [],
    emerging: []
  };

  // Analisar tendências baseadas nos padrões detectados
  for (const pattern of detectedPatterns) {
    if (pattern.isBeneficial) {
      if (pattern.strength > 0.7) {
        trends.improving.push(pattern.name);
      } else if (pattern.strength > 0.4) {
        trends.stable.push(pattern.name);
      } else {
        trends.emerging.push(pattern.name);
      }
    } else {
      if (pattern.strength > 0.7) {
        trends.declining.push(pattern.name);
      } else if (pattern.strength > 0.4) {
        trends.stable.push(pattern.name);
      } else {
        trends.emerging.push(pattern.name);
      }
    }
  }

  return trends;
}

async function identifyCorrelations(behaviorData: any): Promise<any[]> {
  console.log('🔗 Identificando correlações...');

  const correlations: any[] = [];

  // Correlação peso vs. atividade física
  if (behaviorData.weightMeasurements && behaviorData.dailyMissions) {
    const weightActivityCorr = calculateWeightActivityCorrelation(
      behaviorData.weightMeasurements,
      behaviorData.dailyMissions
    );

    if (Math.abs(weightActivityCorr) > 0.3) {
      correlations.push({
        factor1: 'weight_change',
        factor2: 'exercise_frequency',
        correlation: weightActivityCorr,
        significance: Math.abs(weightActivityCorr),
        interpretation: weightActivityCorr < 0 ? 
          'Mais exercício correlaciona com perda de peso' :
          'Menos exercício correlaciona com ganho de peso'
      });
    }
  }

  // Correlação humor vs. alimentação
  if (behaviorData.emotionalAnalysis && behaviorData.foodAnalysis) {
    const moodFoodCorr = calculateMoodFoodCorrelation(
      behaviorData.emotionalAnalysis,
      behaviorData.foodAnalysis
    );

    if (Math.abs(moodFoodCorr) > 0.3) {
      correlations.push({
        factor1: 'emotional_state',
        factor2: 'food_quality',
        correlation: moodFoodCorr,
        significance: Math.abs(moodFoodCorr),
        interpretation: moodFoodCorr > 0 ? 
          'Melhor humor correlaciona com escolhas alimentares mais saudáveis' :
          'Pior humor correlaciona com escolhas alimentares menos saudáveis'
      });
    }
  }

  return correlations;
}

async function assessRiskFactors(detectedPatterns: any[], behaviorData: any): Promise<any[]> {
  console.log('⚠️ Avaliando fatores de risco...');

  const riskFactors: any[] = [];

  // Identificar padrões prejudiciais
  const harmfulPatterns = detectedPatterns.filter(p => !p.isBeneficial && p.confidence > 0.7);

  for (const pattern of harmfulPatterns) {
    let severity: 'low' | 'medium' | 'high' | 'critical' = 'medium';
    
    if (pattern.impact.overall < -0.7) severity = 'critical';
    else if (pattern.impact.overall < -0.5) severity = 'high';
    else if (pattern.impact.overall < -0.3) severity = 'medium';
    else severity = 'low';

    riskFactors.push({
      factor: pattern.name,
      severity,
      description: pattern.description,
      recommendations: generateRiskRecommendations(pattern)
    });
  }

  // Avaliar riscos baseados em dados ausentes
  if (behaviorData.overallCompleteness < 0.5) {
    riskFactors.push({
      factor: 'Dados Insuficientes',
      severity: 'medium' as const,
      description: 'Falta de dados pode impedir detecção precoce de problemas',
      recommendations: [
        'Aumentar frequência de registros',
        'Usar mais funcionalidades da plataforma',
        'Considerar dispositivos de monitoramento'
      ]
    });
  }

  return riskFactors;
}

async function suggestInterventions(
  supabase: any, 
  detectedPatterns: any[], 
  userConfig: any
): Promise<any[]> {
  
  console.log('💡 Sugerindo intervenções...');

  const interventions: any[] = [];

  for (const pattern of detectedPatterns) {
    if (!pattern.isBeneficial && pattern.confidence > 0.6) {
      // Buscar intervenções sugeridas do banco
      const { data: suggestions } = await supabase.rpc('suggest_behavioral_interventions', {
        pattern_id_param: pattern.id
      });

      if (suggestions && suggestions.length > 0) {
        for (const suggestion of suggestions) {
          interventions.push({
            patternId: pattern.id,
            interventionType: suggestion.intervention_type,
            name: suggestion.intervention_name,
            description: suggestion.description,
            successProbability: suggestion.success_probability,
            effort: classifyEffortLevel(suggestion.intervention_type),
            timeframe: estimateTimeframe(suggestion.intervention_type),
            strategy: generateInterventionStrategy(pattern, suggestion)
          });
        }
      } else {
        // Gerar intervenção padrão
        interventions.push(generateDefaultIntervention(pattern));
      }
    }
  }

  return interventions;
}

async function generatePredictions(behaviorData: any, detectedPatterns: any[]): Promise<any> {
  console.log('🔮 Gerando predições...');

  const predictions = {
    shortTerm: [],
    longTerm: [],
    scenarios: []
  };

  // Predições de curto prazo (próximas 2 semanas)
  if (behaviorData.weightMeasurements && behaviorData.weightMeasurements.length >= 3) {
    const weightTrend = calculateWeightTrend(behaviorData.weightMeasurements);
    const predictedWeightChange = weightTrend.slope * 2; // 2 semanas
    
    predictions.shortTerm.push({
      metric: 'weight_change',
      prediction: predictedWeightChange,
      confidence: Math.min(0.8, Math.abs(weightTrend.correlation))
    });
  }

  // Predições de longo prazo (próximos 3 meses)
  const beneficialPatterns = detectedPatterns.filter(p => p.isBeneficial);
  const harmfulPatterns = detectedPatterns.filter(p => !p.isBeneficial);

  if (beneficialPatterns.length > harmfulPatterns.length) {
    predictions.longTerm.push({
      metric: 'overall_health_score',
      prediction: 0.15, // Melhoria de 15%
      confidence: 0.7
    });
  } else {
    predictions.longTerm.push({
      metric: 'overall_health_score',
      prediction: -0.1, // Declínio de 10%
      confidence: 0.6
    });
  }

  // Cenários
  predictions.scenarios.push({
    scenario: 'Manutenção dos padrões atuais',
    probability: 0.6,
    outcomes: detectedPatterns.map(p => 
      `${p.name}: ${p.isBeneficial ? 'continua positivo' : 'continua negativo'}`
    )
  });

  if (interventions.length > 0) {
    predictions.scenarios.push({
      scenario: 'Implementação de intervenções sugeridas',
      probability: 0.4,
      outcomes: ['Melhoria gradual nos padrões identificados', 'Redução de comportamentos prejudiciais']
    });
  }

  return predictions;
}

async function generatePersonalizedRecommendations(
  detectedPatterns: any[],
  riskFactors: any[],
  interventionOpportunities: any[],
  userConfig: any
): Promise<any> {
  
  console.log('📝 Gerando recomendações personalizadas...');

  const recommendations = {
    immediate: [],
    shortTerm: [],
    longTerm: [],
    professional: []
  };

  // Recomendações imediatas baseadas em riscos críticos
  const criticalRisks = riskFactors.filter(r => r.severity === 'critical');
  for (const risk of criticalRisks) {
    recommendations.immediate.push(
      `Atenção urgente necessária: ${risk.factor.toLowerCase()}`
    );
    recommendations.professional.push(
      `Considerar consulta profissional para ${risk.factor.toLowerCase()}`
    );
  }

  // Recomendações de curto prazo
  const highPriorityInterventions = interventionOpportunities
    .filter(i => i.successProbability > 0.7 && i.effort === 'low')
    .slice(0, 3);

  for (const intervention of highPriorityInterventions) {
    recommendations.shortTerm.push(
      `Implementar: ${intervention.name.toLowerCase()}`
    );
  }

  // Recomendações de longo prazo
  const beneficialPatterns = detectedPatterns.filter(p => p.isBeneficial);
  if (beneficialPatterns.length > 0) {
    recommendations.longTerm.push(
      'Fortalecer e manter padrões positivos identificados'
    );
  }

  recommendations.longTerm.push(
    'Desenvolver sistema de monitoramento contínuo',
    'Estabelecer metas específicas e mensuráveis'
  );

  // Recomendações profissionais baseadas em padrões complexos
  const complexPatterns = detectedPatterns.filter(p => 
    !p.isBeneficial && p.confidence > 0.8 && p.impact.overall < -0.6
  );

  if (complexPatterns.length >= 2) {
    recommendations.professional.push(
      'Considerar acompanhamento psicológico para padrões comportamentais complexos'
    );
  }

  return recommendations;
}

function calculateConfidenceMetrics(behaviorData: any, detectedPatterns: any[]): any {
  const metrics = {
    dataQuality: behaviorData.overallCompleteness || 0.5,
    patternReliability: 0.5,
    predictionAccuracy: 0.5,
    overallConfidence: 0.5
  };

  // Calcular confiabilidade dos padrões
  if (detectedPatterns.length > 0) {
    const avgConfidence = detectedPatterns.reduce((sum, p) => sum + p.confidence, 0) / detectedPatterns.length;
    metrics.patternReliability = avgConfidence;
  }

  // Calcular precisão de predições (baseado na quantidade e qualidade dos dados)
  const dataPoints = Object.values(behaviorData.completeness || {}).reduce((sum: number, val: number) => sum + val, 0);
  metrics.predictionAccuracy = Math.min(0.9, 0.3 + (dataPoints * 0.1));

  // Calcular confiança geral
  metrics.overallConfidence = (
    metrics.dataQuality * 0.4 +
    metrics.patternReliability * 0.4 +
    metrics.predictionAccuracy * 0.2
  );

  return metrics;
}

async function saveDetectedPattern(supabase: any, userId: string, pattern: any): Promise<void> {
  try {
    await supabase
      .from('behavioral_patterns')
      .insert({
        user_id: userId,
        pattern_type: pattern.type,
        pattern_name: pattern.name,
        description: pattern.description,
        confidence_score: pattern.confidence,
        pattern_strength: pattern.strength,
        trigger_conditions: pattern.triggers,
        behavioral_response: pattern.responses,
        frequency_data: pattern.frequency,
        impact_assessment: pattern.impact,
        first_observed: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        last_observed: new Date().toISOString().split('T')[0],
        is_beneficial: pattern.isBeneficial,
        auto_detected: true
      });
  } catch (error) {
    console.error('❌ Erro ao salvar padrão:', error);
  }
}

async function saveAnalysis(supabase: any, userId: string, analysisData: any): Promise<string> {
  const analysisId = crypto.randomUUID();
  
  try {
    // Salvar análise principal seria em uma tabela específica
    // Por enquanto, apenas retornar o ID gerado
    console.log('💾 Análise salva:', analysisId);
  } catch (error) {
    console.error('❌ Erro ao salvar análise:', error);
  }
  
  return analysisId;
}

// Funções auxiliares de análise
function identifyCommonTimes(events: any[]): string[] {
  const hours = events.map(e => new Date(e.created_at).getHours());
  const hourCounts: { [key: number]: number } = {};
  
  hours.forEach(hour => {
    hourCounts[hour] = (hourCounts[hour] || 0) + 1;
  });
  
  return Object.entries(hourCounts)
    .filter(([hour, count]) => count >= 2)
    .map(([hour]) => `${hour}:00`);
}

function analyzeRegularMealTimes(foodData: any[]): any {
  const mealTimes = foodData.map(meal => ({
    hour: new Date(meal.created_at).getHours(),
    type: meal.meal_type
  }));

  const typeGroups = mealTimes.reduce((acc, meal) => {
    if (!acc[meal.type]) acc[meal.type] = [];
    acc[meal.type].push(meal.hour);
    return acc;
  }, {} as { [key: string]: number[] });

  let totalRegularity = 0;
  let typeCount = 0;

  const timeDistribution: { [key: string]: number } = {};

  for (const [type, hours] of Object.entries(typeGroups)) {
    const avgHour = hours.reduce((a, b) => a + b, 0) / hours.length;
    const variance = hours.reduce((acc, hour) => acc + Math.pow(hour - avgHour, 2), 0) / hours.length;
    const regularity = Math.max(0, 1 - variance / 12); // Normalizar para 0-1
    
    totalRegularity += regularity;
    typeCount++;
    
    timeDistribution[type] = avgHour;
  }

  return {
    regularity: typeCount > 0 ? totalRegularity / typeCount : 0,
    timeDistribution,
    commonTimes: Object.values(timeDistribution).map(hour => `${Math.round(hour)}:00`)
  };
}

function analyzeDayOfWeekDistribution(missions: any[]): { [key: number]: number } {
  const dayDistribution: { [key: number]: number } = {};
  const dayCounts: { [key: number]: number } = {};
  
  missions.forEach(mission => {
    const day = new Date(mission.date).getDay();
    dayCounts[day] = (dayCounts[day] || 0) + 1;
  });

  const totalMissions = missions.length;
  for (let day = 0; day < 7; day++) {
    dayDistribution[day] = totalMissions > 0 ? (dayCounts[day] || 0) / totalMissions : 0;
  }

  return dayDistribution;
}

function getDayName(dayNumber: number): string {
  const days = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
  return days[dayNumber] || 'Desconhecido';
}

function calculateMoodVariability(emotionalData: any[]): number {
  if (emotionalData.length < 2) return 0;
  
  const sentiments = emotionalData.map(e => e.sentiment_score || 0.5);
  const mean = sentiments.reduce((a, b) => a + b, 0) / sentiments.length;
  const variance = sentiments.reduce((acc, sentiment) => acc + Math.pow(sentiment - mean, 2), 0) / sentiments.length;
  
  return Math.sqrt(variance);
}

function identifyStressTriggers(stressEvents: any[], conversations: any[]): string[] {
  const triggers: string[] = [];
  
  // Análise simplificada - na prática seria mais complexa
  const stressDays = stressEvents.map(e => new Date(e.created_at).toDateString());
  const stressConversations = conversations.filter(c => 
    stressDays.includes(new Date(c.created_at).toDateString())
  );

  const commonWords = extractCommonWords(stressConversations.map(c => c.message || ''));
  triggers.push(...commonWords.slice(0, 3));

  return triggers;
}

function extractCommonWords(messages: string[]): string[] {
  const allWords = messages.join(' ').toLowerCase().split(/\s+/);
  const wordCounts: { [key: string]: number } = {};
  
  allWords.forEach(word => {
    if (word.length > 3) { // Ignorar palavras muito curtas
      wordCounts[word] = (wordCounts[word] || 0) + 1;
    }
  });
  
  return Object.entries(wordCounts)
    .sort(([,a], [,b]) => b - a)
    .slice(0, 5)
    .map(([word]) => word);
}

function calculateWeightTrend(weightData: any[]): any {
  if (weightData.length < 2) return { slope: 0, correlation: 0 };
  
  const weights = weightData.map(w => w.peso_kg);
  const n = weights.length;
  
  // Calcular regressão linear simples
  const xSum = (n * (n - 1)) / 2; // 0 + 1 + 2 + ... + (n-1)
  const ySum = weights.reduce((a, b) => a + b, 0);
  const xySum = weights.reduce((sum, weight, index) => sum + weight * index, 0);
  const xxSum = (n * (n - 1) * (2 * n - 1)) / 6; // 0² + 1² + 2² + ... + (n-1)²
  
  const slope = (n * xySum - xSum * ySum) / (n * xxSum - xSum * xSum);
  
  // Calcular correlação
  const meanX = xSum / n;
  const meanY = ySum / n;
  
  let numerator = 0;
  let denomX = 0;
  let denomY = 0;
  
  for (let i = 0; i < n; i++) {
    const dx = i - meanX;
    const dy = weights[i] - meanY;
    numerator += dx * dy;
    denomX += dx * dx;
    denomY += dy * dy;
  }
  
  const correlation = numerator / Math.sqrt(denomX * denomY);
  
  return { slope, correlation };
}

function analyzeStressEatingCorrelation(emotionalData: any[], foodData: any[]): any {
  // Correlacionar dias de stress alto com qualidade alimentar baixa
  const stressDays = emotionalData
    .filter(e => (e.stress_level || 5) > 7)
    .map(e => new Date(e.created_at).toDateString());
  
  const foodOnStressDays = foodData.filter(f => 
    stressDays.includes(new Date(f.created_at).toDateString())
  );
  
  if (foodOnStressDays.length === 0) {
    return { correlation: 0, confidence: 0, frequency: 0 };
  }
  
  const avgQualityOnStressDays = foodOnStressDays.reduce((sum, f) => 
    sum + (f.goal_alignment_score || 0.5), 0) / foodOnStressDays.length;
  
  const avgQualityOverall = foodData.reduce((sum, f) => 
    sum + (f.goal_alignment_score || 0.5), 0) / foodData.length;
  
  const correlation = avgQualityOverall - avgQualityOnStressDays;
  
  return {
    correlation: Math.max(0, correlation * 2), // Amplificar para 0-1
    confidence: Math.min(0.9, foodOnStressDays.length / 10),
    frequency: foodOnStressDays.length / 4 // Estimativa semanal
  };
}

function analyzeExerciseMoodCorrelation(missionsData: any[], emotionalData: any[]): any {
  const exerciseDays = missionsData
    .filter(m => m.completed)
    .map(m => new Date(m.date).toDateString());
  
  const moodOnExerciseDays = emotionalData.filter(e => 
    exerciseDays.includes(new Date(e.created_at).toDateString())
  );
  
  if (moodOnExerciseDays.length === 0) {
    return { correlation: 0, confidence: 0, frequency: 0 };
  }
  
  const avgMoodOnExerciseDays = moodOnExerciseDays.reduce((sum, e) => 
    sum + (e.sentiment_score || 0.5), 0) / moodOnExerciseDays.length;
  
  const avgMoodOverall = emotionalData.reduce((sum, e) => 
    sum + (e.sentiment_score || 0.5), 0) / emotionalData.length;
  
  const correlation = avgMoodOnExerciseDays - avgMoodOverall;
  
  return {
    correlation: Math.max(0, correlation * 2),
    confidence: Math.min(0.9, moodOnExerciseDays.length / 10),
    frequency: moodOnExerciseDays.length / 4
  };
}

function calculateWeightActivityCorrelation(weightData: any[], missionsData: any[]): number {
  // Implementação simplificada
  const weightTrend = calculateWeightTrend(weightData);
  const activityRate = missionsData.filter(m => m.completed).length / missionsData.length;
  
  // Correlação negativa esperada: mais atividade = menos peso
  return -0.5 * activityRate * Math.abs(weightTrend.slope);
}

function calculateMoodFoodCorrelation(emotionalData: any[], foodData: any[]): number {
  // Implementação simplificada
  const avgMood = emotionalData.reduce((sum, e) => sum + (e.sentiment_score || 0.5), 0) / emotionalData.length;
  const avgFoodQuality = foodData.reduce((sum, f) => sum + (f.goal_alignment_score || 0.5), 0) / foodData.length;
  
  // Correlação positiva esperada: melhor humor = melhor alimentação
  return (avgMood - 0.5) * (avgFoodQuality - 0.5) * 4; // Normalizar para -1 a 1
}

function generateRiskRecommendations(pattern: any): string[] {
  const recommendations: string[] = [];
  
  switch (pattern.type) {
    case 'emotional_eating':
      recommendations.push(
        'Praticar técnicas de mindfulness antes das refeições',
        'Identificar e registrar triggers emocionais',
        'Desenvolver estratégias alternativas de manejo emocional'
      );
      break;
    case 'chronic_stress':
      recommendations.push(
        'Implementar técnicas de relaxamento diárias',
        'Considerar exercícios de respiração',
        'Avaliar necessidade de suporte profissional'
      );
      break;
    case 'low_adherence':
      recommendations.push(
        'Revisar metas e torná-las mais realistas',
        'Implementar sistema de recompensas',
        'Identificar barreiras específicas'
      );
      break;
    default:
      recommendations.push(
        'Monitorar padrão de perto',
        'Buscar estratégias de modificação comportamental'
      );
  }
  
  return recommendations;
}

function generateDefaultIntervention(pattern: any): any {
  return {
    patternId: pattern.id,
    interventionType: 'behavioral_modification',
    name: `Intervenção para ${pattern.name}`,
    description: `Estratégia personalizada para modificar ${pattern.name.toLowerCase()}`,
    successProbability: 0.6,
    effort: 'medium',
    timeframe: '4-6 semanas',
    strategy: {
      approach: 'gradual_change',
      phases: ['awareness', 'preparation', 'action', 'maintenance'],
      tools: ['self_monitoring', 'goal_setting', 'progress_tracking']
    }
  };
}

function classifyEffortLevel(interventionType: string): 'low' | 'medium' | 'high' {
  const lowEffort = ['environmental_design', 'habit_stacking'];
  const highEffort = ['cognitive_reframing', 'social_support'];
  
  if (lowEffort.includes(interventionType)) return 'low';
  if (highEffort.includes(interventionType)) return 'high';
  return 'medium';
}

function estimateTimeframe(interventionType: string): string {
  const timeframes = {
    'environmental_design': '1-2 semanas',
    'habit_replacement': '3-4 semanas',
    'cognitive_reframing': '6-8 semanas',
    'social_support': '4-6 semanas'
  };
  
  return timeframes[interventionType] || '4-6 semanas';
}

function generateInterventionStrategy(pattern: any, suggestion: any): any {
  return {
    approach: 'evidence_based',
    duration_weeks: 4,
    phases: [
      { name: 'assessment', duration: '1 week', activities: ['baseline_measurement', 'trigger_identification'] },
      { name: 'preparation', duration: '1 week', activities: ['strategy_planning', 'resource_gathering'] },
      { name: 'implementation', duration: '2 weeks', activities: ['active_intervention', 'progress_monitoring'] }
    ],
    success_metrics: ['frequency_reduction', 'intensity_decrease', 'user_satisfaction'],
    contingency_plans: ['alternative_strategies', 'professional_referral']
  };
}