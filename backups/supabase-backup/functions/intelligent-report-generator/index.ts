import "https://deno.land/x/xhr@0.1.0/mod.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface ReportRequest {
  userId: string;
  reportType: 'weekly' | 'monthly' | 'quarterly' | 'custom';
  period?: { start: string; end: string };
  templateId?: string;
  includeData: {
    weight: boolean;
    missions: boolean;
    conversations: boolean;
    emotions: boolean;
    food: boolean;
    calendar: boolean;
  };
  format: 'email' | 'whatsapp' | 'pdf' | 'dashboard' | 'all';
  personalizedInsights: boolean;
  autoSend?: boolean;
  customSettings?: {
    tone?: 'professional' | 'friendly' | 'encouraging';
    detailLevel?: 'summary' | 'standard' | 'comprehensive';
    focusAreas?: string[];
    includeCharts?: boolean;
    includeRecommendations?: boolean;
  };
}

interface HealthReport {
  reportId: string;
  metadata: {
    type: string;
    period: { start: string; end: string };
    generatedBy: string;
    generatedAt: string;
    dataQuality: number;
    confidence: number;
  };
  executiveSummary: string;
  keyMetrics: {
    weightChange: number;
    avgDailyCalories: number;
    missionCompletionRate: number;
    emotionalWellbeingScore: number;
    overallProgressScore: number;
  };
  detailedAnalysis: {
    achievements: string[];
    challenges: string[];
    trends: any;
    correlations: any;
    riskFactors: string[];
    opportunities: string[];
  };
  recommendations: {
    highPriority: string[];
    mediumPriority: string[];
    lowPriority: string[];
    immediateActions: string[];
    longTermGoals: string[];
  };
  actionPlan: {
    thisWeek: string[];
    thisMonth: string[];
    followUpNeeded: string[];
    professionalConsultation: string[];
  };
  visualizations: {
    charts: any;
    progressBars: any;
    infographics: any;
  };
  drVitalMessage: string;
  distributionUrls?: {
    pdf?: string;
    email?: string;
    whatsapp?: string;
  };
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const requestData: ReportRequest = await req.json();
    console.log('📊 Intelligent Report Generator Request:', requestData);

    // Inicializar Supabase
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Gerar relatório inteligente
    const report = await generateIntelligentReport(supabase, requestData);

    return new Response(JSON.stringify(report), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('❌ Erro no gerador de relatórios:', error);
    
    return new Response(JSON.stringify({ 
      error: error.message,
      details: 'Erro na geração de relatório inteligente'
    }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});

async function generateIntelligentReport(
  supabase: any, 
  request: ReportRequest
): Promise<HealthReport> {
  
  console.log('🔍 Iniciando geração de relatório inteligente...');

  // 1. Determinar período de análise
  const period = determinePeriod(request.reportType, request.period);
  
  // 2. Coletar dados do usuário
  const userData = await collectUserData(supabase, request.userId, period, request.includeData);
  
  // 3. Buscar template de relatório
  const template = await getReportTemplate(supabase, request.templateId, request.reportType);
  
  // 4. Buscar personalidade do Dr. Vital
  const drVitalPersonality = await getDrVitalPersonality(supabase, request.userId);
  
  // 5. Analisar dados com IA
  const aiAnalysis = await performAIAnalysis(userData, template, drVitalPersonality, request);
  
  // 6. Gerar visualizações
  const visualizations = await generateVisualizations(userData, aiAnalysis);
  
  // 7. Compilar relatório final
  const report = await compileReport(
    supabase,
    request,
    period,
    userData,
    aiAnalysis,
    visualizations,
    drVitalPersonality
  );
  
  // 8. Salvar relatório
  const savedReport = await saveReport(supabase, request.userId, report, template);
  
  // 9. Distribuir se solicitado
  if (request.autoSend) {
    await distributeReport(supabase, savedReport, request.format);
  }

  console.log('✅ Relatório inteligente gerado com sucesso');
  return report;
}

function determinePeriod(reportType: string, customPeriod?: any): { start: string; end: string } {
  const now = new Date();
  let start: Date;
  let end: Date = new Date(now);

  if (customPeriod) {
    return {
      start: customPeriod.start,
      end: customPeriod.end
    };
  }

  switch (reportType) {
    case 'weekly':
      start = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      break;
    case 'monthly':
      start = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
      break;
    case 'quarterly':
      start = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
      break;
    default:
      start = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
  }

  return {
    start: start.toISOString().split('T')[0],
    end: end.toISOString().split('T')[0]
  };
}

async function collectUserData(
  supabase: any, 
  userId: string, 
  period: any, 
  includeData: any
): Promise<any> {
  
  console.log('📊 Coletando dados do usuário...');

  const data: any = {
    userId,
    period,
    completeness: 0
  };

  let dataPoints = 0;
  let collectedPoints = 0;

  // Dados básicos do usuário
  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('user_id', userId)
    .single();
  
  data.profile = profile || {};

  // Metas do usuário
  const { data: goals } = await supabase
    .from('user_goals')
    .select('*')
    .eq('user_id', userId)
    .eq('is_active', true);
  
  data.goals = goals || [];

  // Dados de peso
  if (includeData.weight) {
    dataPoints++;
    const { data: weightData } = await supabase
      .from('weight_measurements')
      .select('*')
      .eq('user_id', userId)
      .gte('measurement_date', period.start)
      .lte('measurement_date', period.end)
      .order('measurement_date', { ascending: true });
    
    if (weightData && weightData.length > 0) {
      data.weightMeasurements = weightData;
      collectedPoints++;
    }
  }

  // Dados de missões
  if (includeData.missions) {
    dataPoints++;
    const { data: missionsData } = await supabase
      .from('daily_mission_sessions')
      .select('*')
      .eq('user_id', userId)
      .gte('date', period.start)
      .lte('date', period.end)
      .order('date', { ascending: true });
    
    if (missionsData && missionsData.length > 0) {
      data.dailyMissions = missionsData;
      collectedPoints++;
    }
  }

  // Dados de alimentação
  if (includeData.food) {
    dataPoints++;
    const { data: foodData } = await supabase
      .from('food_image_analysis')
      .select('*')
      .eq('user_id', userId)
      .gte('created_at', `${period.start}T00:00:00`)
      .lte('created_at', `${period.end}T23:59:59`)
      .order('created_at', { ascending: true });
    
    if (foodData && foodData.length > 0) {
      data.foodAnalysis = foodData;
      collectedPoints++;
    }
  }

  // Dados de conversas
  if (includeData.conversations) {
    dataPoints++;
    const { data: conversationsData } = await supabase
      .from('chat_conversations')
      .select('*')
      .eq('user_id', userId)
      .gte('created_at', `${period.start}T00:00:00`)
      .lte('created_at', `${period.end}T23:59:59`)
      .order('created_at', { ascending: true });
    
    if (conversationsData && conversationsData.length > 0) {
      data.conversations = conversationsData;
      collectedPoints++;
    }
  }

  // Dados emocionais
  if (includeData.emotions) {
    dataPoints++;
    const { data: emotionalData } = await supabase
      .from('chat_emotional_analysis')
      .select('*')
      .eq('user_id', userId)
      .gte('created_at', `${period.start}T00:00:00`)
      .lte('created_at', `${period.end}T23:59:59`)
      .order('created_at', { ascending: true });
    
    if (emotionalData && emotionalData.length > 0) {
      data.emotionalAnalysis = emotionalData;
      collectedPoints++;
    }
  }

  // Dados de calendário
  if (includeData.calendar) {
    dataPoints++;
    const { data: calendarData } = await supabase
      .from('ai_managed_events')
      .select('*')
      .eq('user_id', userId)
      .gte('start_datetime', `${period.start}T00:00:00`)
      .lte('start_datetime', `${period.end}T23:59:59`)
      .order('start_datetime', { ascending: true });
    
    if (calendarData && calendarData.length > 0) {
      data.calendarEvents = calendarData;
      collectedPoints++;
    }
  }

  // Calcular completude dos dados
  data.completeness = dataPoints > 0 ? collectedPoints / dataPoints : 0;

  console.log(`📊 Dados coletados: ${collectedPoints}/${dataPoints} (${Math.round(data.completeness * 100)}%)`);
  return data;
}

async function getReportTemplate(
  supabase: any, 
  templateId?: string, 
  reportType?: string
): Promise<any> {
  
  console.log('📋 Buscando template de relatório...');

  let template;

  if (templateId) {
    const { data } = await supabase
      .from('report_templates')
      .select('*')
      .eq('id', templateId)
      .eq('is_active', true)
      .single();
    
    template = data;
  }

  if (!template) {
    // Buscar template padrão para o tipo
    const { data } = await supabase
      .from('report_templates')
      .select('*')
      .eq('template_type', reportType || 'weekly')
      .eq('is_default', true)
      .eq('is_active', true)
      .single();
    
    template = data;
  }

  if (!template) {
    // Template básico como fallback
    template = {
      template_name: 'Template Básico',
      template_type: reportType || 'weekly',
      ai_generation_config: {
        tone: 'professional',
        detail_level: 'standard',
        focus_areas: ['progress', 'recommendations'],
        personalization_level: 'high'
      }
    };
  }

  return template;
}

async function getDrVitalPersonality(supabase: any, userId: string): Promise<any> {
  console.log('👨‍⚕️ Buscando personalidade do Dr. Vital...');

  const { data: personality } = await supabase
    .from('ai_personalities')
    .select('*')
    .eq('user_id', userId)
    .eq('agent_name', 'dr_vital')
    .eq('is_active', true)
    .single();

  return personality || {
    tone: 'professional',
    communication_style: 'analytical',
    emotional_intelligence: 0.7,
    expertise_level: 'expert',
    formality_level: 0.8
  };
}

async function performAIAnalysis(
  userData: any, 
  template: any, 
  personality: any, 
  request: ReportRequest
): Promise<any> {
  
  console.log('🤖 Realizando análise com IA...');

  // Configurar IA baseado no template e personalidade
  const aiConfig = {
    tone: request.customSettings?.tone || template.ai_generation_config?.tone || personality.tone,
    detailLevel: request.customSettings?.detailLevel || template.ai_generation_config?.detail_level || 'standard',
    focusAreas: request.customSettings?.focusAreas || template.ai_generation_config?.focus_areas || ['progress'],
    personalizationLevel: template.ai_generation_config?.personalization_level || 'high'
  };

  // Calcular métricas principais
  const keyMetrics = calculateKeyMetrics(userData);
  
  // Analisar tendências
  const trends = analyzeTrends(userData);
  
  // Identificar padrões
  const patterns = identifyPatterns(userData);
  
  // Gerar insights com IA
  const aiInsights = await generateAIInsights(userData, keyMetrics, trends, patterns, aiConfig);
  
  // Gerar recomendações
  const recommendations = await generateRecommendations(userData, aiInsights, aiConfig);
  
  // Gerar plano de ação
  const actionPlan = generateActionPlan(recommendations, userData);

  return {
    keyMetrics,
    trends,
    patterns,
    aiInsights,
    recommendations,
    actionPlan,
    dataQuality: calculateDataQuality(userData),
    confidence: calculateConfidence(userData, keyMetrics)
  };
}

function calculateKeyMetrics(userData: any): any {
  const metrics: any = {
    weightChange: 0,
    avgDailyCalories: 0,
    missionCompletionRate: 0,
    emotionalWellbeingScore: 0.5,
    overallProgressScore: 0.5
  };

  // Mudança de peso
  if (userData.weightMeasurements && userData.weightMeasurements.length >= 2) {
    const firstWeight = userData.weightMeasurements[0].peso_kg;
    const lastWeight = userData.weightMeasurements[userData.weightMeasurements.length - 1].peso_kg;
    metrics.weightChange = lastWeight - firstWeight;
  }

  // Calorias médias diárias
  if (userData.foodAnalysis && userData.foodAnalysis.length > 0) {
    const totalCalories = userData.foodAnalysis.reduce((sum: number, meal: any) => {
      return sum + (meal.nutrition_breakdown?.total_calories || 0);
    }, 0);
    metrics.avgDailyCalories = totalCalories / userData.foodAnalysis.length;
  }

  // Taxa de conclusão de missões
  if (userData.dailyMissions && userData.dailyMissions.length > 0) {
    const completedMissions = userData.dailyMissions.filter((mission: any) => mission.completed).length;
    metrics.missionCompletionRate = completedMissions / userData.dailyMissions.length;
  }

  // Score de bem-estar emocional
  if (userData.emotionalAnalysis && userData.emotionalAnalysis.length > 0) {
    const avgMood = userData.emotionalAnalysis.reduce((sum: number, analysis: any) => {
      return sum + (analysis.sentiment_score || 0.5);
    }, 0) / userData.emotionalAnalysis.length;
    metrics.emotionalWellbeingScore = avgMood;
  }

  // Score geral de progresso
  metrics.overallProgressScore = (
    (metrics.missionCompletionRate * 0.4) +
    (metrics.emotionalWellbeingScore * 0.3) +
    (userData.completeness * 0.3)
  );

  return metrics;
}

function analyzeTrends(userData: any): any {
  const trends: any = {};

  // Tendência de peso
  if (userData.weightMeasurements && userData.weightMeasurements.length >= 3) {
    const weights = userData.weightMeasurements.map((m: any) => m.peso_kg);
    trends.weight = calculateTrend(weights);
  }

  // Tendência de humor
  if (userData.emotionalAnalysis && userData.emotionalAnalysis.length >= 3) {
    const moods = userData.emotionalAnalysis.map((e: any) => e.sentiment_score || 0.5);
    trends.mood = calculateTrend(moods);
  }

  // Tendência de missões
  if (userData.dailyMissions && userData.dailyMissions.length >= 7) {
    const weeklyCompletion = [];
    for (let i = 0; i < userData.dailyMissions.length; i += 7) {
      const week = userData.dailyMissions.slice(i, i + 7);
      const completionRate = week.filter((m: any) => m.completed).length / week.length;
      weeklyCompletion.push(completionRate);
    }
    trends.missions = calculateTrend(weeklyCompletion);
  }

  return trends;
}

function calculateTrend(values: number[]): string {
  if (values.length < 2) return 'insufficient_data';
  
  const firstHalf = values.slice(0, Math.floor(values.length / 2));
  const secondHalf = values.slice(Math.floor(values.length / 2));
  
  const firstAvg = firstHalf.reduce((a, b) => a + b, 0) / firstHalf.length;
  const secondAvg = secondHalf.reduce((a, b) => a + b, 0) / secondHalf.length;
  
  const change = (secondAvg - firstAvg) / firstAvg;
  
  if (change > 0.05) return 'improving';
  if (change < -0.05) return 'declining';
  return 'stable';
}

function identifyPatterns(userData: any): any {
  const patterns: any = {};

  // Padrões de alimentação
  if (userData.foodAnalysis && userData.foodAnalysis.length > 0) {
    const mealTimes = userData.foodAnalysis.map((meal: any) => {
      const hour = new Date(meal.created_at).getHours();
      return { type: meal.meal_type, hour };
    });

    patterns.eating = {
      regularMealTimes: analyzeRegularityOfMealTimes(mealTimes),
      favoriteEatingTimes: findFavoriteEatingTimes(mealTimes),
      weekendVsWeekday: analyzeWeekendVsWeekdayEating(userData.foodAnalysis)
    };
  }

  // Padrões de humor
  if (userData.emotionalAnalysis && userData.emotionalAnalysis.length > 0) {
    patterns.emotional = {
      moodVariability: calculateMoodVariability(userData.emotionalAnalysis),
      stressPatterns: identifyStressPatterns(userData.emotionalAnalysis),
      energyPatterns: identifyEnergyPatterns(userData.emotionalAnalysis)
    };
  }

  return patterns;
}

async function generateAIInsights(
  userData: any, 
  metrics: any, 
  trends: any, 
  patterns: any, 
  aiConfig: any
): Promise<any> {
  
  console.log('🧠 Gerando insights com IA...');

  // Preparar contexto para IA
  const context = {
    userProfile: userData.profile,
    goals: userData.goals,
    metrics,
    trends,
    patterns,
    dataCompleteness: userData.completeness
  };

  // Gerar prompt para IA
  const prompt = generateAnalysisPrompt(context, aiConfig);

  try {
    // Chamar IA (Gemini)
    const aiResponse = await callGeminiForAnalysis(prompt, aiConfig);
    
    return parseAIAnalysisResponse(aiResponse);
    
  } catch (error) {
    console.error('❌ Erro na análise com IA:', error);
    
    // Fallback: análise baseada em regras
    return generateRuleBasedInsights(metrics, trends, patterns);
  }
}

function generateAnalysisPrompt(context: any, aiConfig: any): string {
  const tone = aiConfig.tone === 'professional' ? 'profissional e técnico' : 
               aiConfig.tone === 'friendly' ? 'amigável e acessível' : 'encorajador e motivacional';
  
  const detailLevel = aiConfig.detailLevel === 'comprehensive' ? 'análise muito detalhada' :
                      aiConfig.detailLevel === 'summary' ? 'resumo conciso' : 'análise padrão';

  return `
Você é o Dr. Vital, um médico especialista em análise de dados de saúde e bem-estar.

CONTEXTO DO PACIENTE:
${JSON.stringify(context, null, 2)}

CONFIGURAÇÕES DE ANÁLISE:
- Tom: ${tone}
- Nível de detalhe: ${detailLevel}
- Áreas de foco: ${aiConfig.focusAreas.join(', ')}

INSTRUÇÕES:
1. Analise os dados fornecidos com foco médico e científico
2. Identifique padrões, tendências e correlações importantes
3. Destaque conquistas e áreas que precisam de atenção
4. Seja específico e baseado em evidências
5. Mantenha tom ${tone}

FORMATO DE RESPOSTA (JSON):
{
  "executiveSummary": "Resumo executivo da análise...",
  "achievements": ["conquista 1", "conquista 2"],
  "challenges": ["desafio 1", "desafio 2"],
  "keyInsights": ["insight 1", "insight 2"],
  "riskFactors": ["risco 1", "risco 2"],
  "opportunities": ["oportunidade 1", "oportunidade 2"],
  "correlations": {
    "positive": ["correlação positiva"],
    "negative": ["correlação negativa"]
  },
  "confidence": 0.85
}`;
}

async function callGeminiForAnalysis(prompt: string, aiConfig: any): Promise<string> {
  const GOOGLE_AI_API_KEY = Deno.env.get('GOOGLE_AI_API_KEY');
  
  if (!GOOGLE_AI_API_KEY) {
    throw new Error('Google AI API Key não configurada');
  }

  const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GOOGLE_AI_API_KEY}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      contents: [{
        parts: [{ text: prompt }]
      }],
      generationConfig: {
        maxOutputTokens: aiConfig.detailLevel === 'comprehensive' ? 4000 : 
                        aiConfig.detailLevel === 'summary' ? 1000 : 2000,
        temperature: 0.3
      }
    })
  });

  if (!response.ok) {
    throw new Error(`Gemini API error: ${response.statusText}`);
  }

  const data = await response.json();
  return data.candidates?.[0]?.content?.parts?.[0]?.text || '';
}

function parseAIAnalysisResponse(aiResponse: string): any {
  try {
    const jsonMatch = aiResponse.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      return JSON.parse(jsonMatch[0]);
    }
  } catch (error) {
    console.error('❌ Erro ao parsear resposta da IA:', error);
  }
  
  // Fallback se não conseguir parsear
  return {
    executiveSummary: 'Análise baseada nos dados disponíveis.',
    achievements: ['Dados coletados com sucesso'],
    challenges: ['Necessário mais dados para análise completa'],
    keyInsights: ['Padrões identificados nos dados disponíveis'],
    riskFactors: [],
    opportunities: ['Oportunidades de melhoria identificadas'],
    correlations: { positive: [], negative: [] },
    confidence: 0.7
  };
}

function generateRuleBasedInsights(metrics: any, trends: any, patterns: any): any {
  const insights: any = {
    executiveSummary: 'Análise baseada em regras dos dados coletados.',
    achievements: [],
    challenges: [],
    keyInsights: [],
    riskFactors: [],
    opportunities: [],
    correlations: { positive: [], negative: [] },
    confidence: 0.6
  };

  // Análise de peso
  if (metrics.weightChange < -0.5) {
    insights.achievements.push('Redução de peso positiva');
  } else if (metrics.weightChange > 1) {
    insights.challenges.push('Aumento de peso significativo');
  }

  // Análise de missões
  if (metrics.missionCompletionRate > 0.8) {
    insights.achievements.push('Excelente aderência às missões diárias');
  } else if (metrics.missionCompletionRate < 0.5) {
    insights.challenges.push('Baixa conclusão de missões diárias');
  }

  // Análise emocional
  if (metrics.emotionalWellbeingScore > 0.7) {
    insights.achievements.push('Bom estado emocional geral');
  } else if (metrics.emotionalWellbeingScore < 0.4) {
    insights.riskFactors.push('Estado emocional que requer atenção');
  }

  return insights;
}

async function generateRecommendations(
  userData: any, 
  aiInsights: any, 
  aiConfig: any
): Promise<any> {
  
  const recommendations = {
    highPriority: [],
    mediumPriority: [],
    lowPriority: [],
    immediateActions: [],
    longTermGoals: []
  };

  // Recomendações baseadas nos insights
  if (aiInsights.riskFactors && aiInsights.riskFactors.length > 0) {
    recommendations.highPriority.push(
      'Atenção especial aos fatores de risco identificados'
    );
  }

  if (aiInsights.opportunities && aiInsights.opportunities.length > 0) {
    recommendations.mediumPriority.push(
      'Explorar oportunidades de melhoria identificadas'
    );
  }

  // Recomendações baseadas em métricas
  const metrics = calculateKeyMetrics(userData);
  
  if (metrics.missionCompletionRate < 0.7) {
    recommendations.immediateActions.push(
      'Revisar e ajustar estratégia para missões diárias'
    );
  }

  if (metrics.emotionalWellbeingScore < 0.5) {
    recommendations.highPriority.push(
      'Considerar suporte para bem-estar emocional'
    );
  }

  // Recomendações de longo prazo
  recommendations.longTermGoals.push(
    'Manter consistência nos hábitos saudáveis',
    'Monitorar progresso regularmente'
  );

  return recommendations;
}

function generateActionPlan(recommendations: any, userData: any): any {
  return {
    thisWeek: [
      'Revisar dados coletados',
      'Implementar uma recomendação de alta prioridade'
    ],
    thisMonth: [
      'Avaliar progresso das ações implementadas',
      'Ajustar estratégias conforme necessário'
    ],
    followUpNeeded: [
      'Acompanhar métricas principais',
      'Reavaliar em 2 semanas'
    ],
    professionalConsultation: userData.completeness < 0.5 ? [
      'Considerar consulta para melhor acompanhamento'
    ] : []
  };
}

async function generateVisualizations(userData: any, aiAnalysis: any): Promise<any> {
  console.log('📊 Gerando visualizações...');
  
  const charts: any = {};
  const progressBars: any = {};
  const infographics: any = [];

  // Gráfico de tendência de peso
  if (userData.weightMeasurements && userData.weightMeasurements.length > 0) {
    charts.weightTrend = {
      type: 'line',
      data: userData.weightMeasurements.map((m: any) => ({
        date: m.measurement_date,
        weight: m.peso_kg,
        bmi: m.imc
      })),
      title: 'Evolução do Peso',
      xAxis: 'Data',
      yAxis: 'Peso (kg)'
    };
  }

  // Gráfico de conclusão de missões
  if (userData.dailyMissions && userData.dailyMissions.length > 0) {
    const completionByWeek = groupMissionsByWeek(userData.dailyMissions);
    charts.missionCompletion = {
      type: 'bar',
      data: completionByWeek,
      title: 'Taxa de Conclusão de Missões por Semana',
      xAxis: 'Semana',
      yAxis: 'Taxa de Conclusão (%)'
    };
  }

  // Barras de progresso
  progressBars.overallProgress = {
    label: 'Progresso Geral',
    value: aiAnalysis.keyMetrics.overallProgressScore,
    max: 1,
    color: aiAnalysis.keyMetrics.overallProgressScore > 0.7 ? 'green' : 
           aiAnalysis.keyMetrics.overallProgressScore > 0.4 ? 'yellow' : 'red'
  };

  progressBars.missionCompletion = {
    label: 'Conclusão de Missões',
    value: aiAnalysis.keyMetrics.missionCompletionRate,
    max: 1,
    color: aiAnalysis.keyMetrics.missionCompletionRate > 0.8 ? 'green' : 
           aiAnalysis.keyMetrics.missionCompletionRate > 0.6 ? 'yellow' : 'red'
  };

  // Infográficos
  infographics.push({
    type: 'summary_card',
    title: 'Resumo do Período',
    metrics: [
      { label: 'Mudança de Peso', value: `${aiAnalysis.keyMetrics.weightChange.toFixed(1)}kg` },
      { label: 'Missões Concluídas', value: `${Math.round(aiAnalysis.keyMetrics.missionCompletionRate * 100)}%` },
      { label: 'Bem-estar Emocional', value: `${Math.round(aiAnalysis.keyMetrics.emotionalWellbeingScore * 100)}%` }
    ]
  });

  return {
    charts,
    progressBars,
    infographics
  };
}

async function compileReport(
  supabase: any,
  request: ReportRequest,
  period: any,
  userData: any,
  aiAnalysis: any,
  visualizations: any,
  personality: any
): Promise<HealthReport> {
  
  console.log('📝 Compilando relatório final...');

  // Gerar mensagem personalizada do Dr. Vital
  const drVitalMessage = await generateDrVitalMessage(aiAnalysis, personality, request);

  const report: HealthReport = {
    reportId: crypto.randomUUID(),
    metadata: {
      type: request.reportType,
      period,
      generatedBy: 'dr_vital',
      generatedAt: new Date().toISOString(),
      dataQuality: aiAnalysis.dataQuality,
      confidence: aiAnalysis.confidence
    },
    executiveSummary: aiAnalysis.aiInsights.executiveSummary,
    keyMetrics: aiAnalysis.keyMetrics,
    detailedAnalysis: {
      achievements: aiAnalysis.aiInsights.achievements,
      challenges: aiAnalysis.aiInsights.challenges,
      trends: aiAnalysis.trends,
      correlations: aiAnalysis.aiInsights.correlations,
      riskFactors: aiAnalysis.aiInsights.riskFactors,
      opportunities: aiAnalysis.aiInsights.opportunities
    },
    recommendations: aiAnalysis.recommendations,
    actionPlan: aiAnalysis.actionPlan,
    visualizations,
    drVitalMessage
  };

  return report;
}

async function generateDrVitalMessage(
  aiAnalysis: any, 
  personality: any, 
  request: ReportRequest
): Promise<string> {
  
  const tone = personality.tone || 'professional';
  const emotionalIntelligence = personality.emotional_intelligence || 0.7;
  
  let message = '';
  
  if (tone === 'professional') {
    message = 'Com base na análise dos seus dados de saúde, ';
  } else if (tone === 'warm') {
    message = 'Olá! Analisei cuidadosamente seus dados e ';
  } else {
    message = 'Após uma análise detalhada dos seus progressos, ';
  }

  // Destacar conquistas
  if (aiAnalysis.aiInsights.achievements.length > 0) {
    message += `observo conquistas importantes como ${aiAnalysis.aiInsights.achievements[0].toLowerCase()}. `;
  }

  // Mencionar desafios com empatia
  if (aiAnalysis.aiInsights.challenges.length > 0 && emotionalIntelligence > 0.6) {
    message += `Identifiquei algumas áreas que merecem atenção, mas lembre-se que cada passo é importante na sua jornada. `;
  }

  // Recomendações principais
  if (aiAnalysis.recommendations.highPriority.length > 0) {
    message += `Minha principal recomendação é: ${aiAnalysis.recommendations.highPriority[0].toLowerCase()}. `;
  }

  // Encorajamento final
  if (emotionalIntelligence > 0.7) {
    message += 'Continue com dedicação - você está no caminho certo para alcançar seus objetivos de saúde.';
  } else {
    message += 'Mantenha o foco nos próximos passos recomendados.';
  }

  return message;
}

async function saveReport(
  supabase: any, 
  userId: string, 
  report: HealthReport, 
  template: any
): Promise<any> {
  
  console.log('💾 Salvando relatório...');

  const { data: savedReport, error } = await supabase
    .from('health_reports')
    .insert({
      user_id: userId,
      report_type: report.metadata.type,
      period_start: report.metadata.period.start,
      period_end: report.metadata.period.end,
      generated_by: report.metadata.generatedBy,
      data_sources: {
        weight_measurements: true,
        food_analysis: true,
        daily_missions: true,
        conversations: true,
        emotional_analysis: true
      },
      metrics_analyzed: report.keyMetrics,
      executive_summary: report.executiveSummary,
      detailed_analysis: report.detailedAnalysis,
      recommendations: report.recommendations,
      action_items: report.actionPlan,
      charts_data: report.visualizations.charts,
      visual_elements: {
        progress_bars: report.visualizations.progressBars,
        infographics: report.visualizations.infographics
      },
      quality_score: report.metadata.dataQuality,
      confidence_level: report.metadata.confidence,
      is_draft: false,
      published_at: new Date().toISOString()
    })
    .select()
    .single();

  if (error) {
    throw new Error(`Erro ao salvar relatório: ${error.message}`);
  }

  return { ...savedReport, drVitalMessage: report.drVitalMessage };
}

async function distributeReport(
  supabase: any, 
  report: any, 
  format: string
): Promise<void> {
  
  console.log(`📤 Distribuindo relatório (${format})...`);

  // Implementar distribuição baseada no formato
  if (format === 'email' || format === 'all') {
    await sendReportByEmail(supabase, report);
  }

  if (format === 'whatsapp' || format === 'all') {
    await sendReportByWhatsApp(supabase, report);
  }

  if (format === 'pdf' || format === 'all') {
    await generateReportPDF(supabase, report);
  }
}

async function sendReportByEmail(supabase: any, report: any): Promise<void> {
  console.log('📧 Enviando relatório por email...');
  
  // Implementar envio por email
  // Por enquanto, apenas marcar como enviado
  await supabase
    .from('health_reports')
    .update({
      email_sent: true,
      email_sent_at: new Date().toISOString()
    })
    .eq('id', report.id);
}

async function sendReportByWhatsApp(supabase: any, report: any): Promise<void> {
  console.log('📱 Enviando relatório por WhatsApp...');
  
  // Implementar envio por WhatsApp
  await supabase
    .from('health_reports')
    .update({
      whatsapp_sent: true,
      whatsapp_sent_at: new Date().toISOString()
    })
    .eq('id', report.id);
}

async function generateReportPDF(supabase: any, report: any): Promise<void> {
  console.log('📄 Gerando PDF do relatório...');
  
  // Implementar geração de PDF
  const pdfUrl = `https://example.com/reports/${report.id}.pdf`;
  
  await supabase
    .from('health_reports')
    .update({
      pdf_generated: true,
      pdf_url: pdfUrl
    })
    .eq('id', report.id);
}

// Funções auxiliares
function calculateDataQuality(userData: any): number {
  let qualityScore = userData.completeness * 0.5;
  
  // Bonus por variedade de dados
  const dataTypes = Object.keys(userData).filter(key => 
    userData[key] && Array.isArray(userData[key]) && userData[key].length > 0
  ).length;
  
  qualityScore += Math.min(dataTypes * 0.1, 0.3);
  
  // Bonus por consistência temporal
  if (userData.dailyMissions && userData.dailyMissions.length > 7) {
    qualityScore += 0.2;
  }
  
  return Math.min(qualityScore, 1.0);
}

function calculateConfidence(userData: any, metrics: any): number {
  let confidence = 0.5;
  
  // Aumentar confiança baseado na quantidade de dados
  confidence += userData.completeness * 0.3;
  
  // Aumentar confiança se há tendências claras
  if (metrics.weightChange !== 0) {
    confidence += 0.1;
  }
  
  if (metrics.missionCompletionRate > 0) {
    confidence += 0.1;
  }
  
  return Math.min(confidence, 0.95);
}

function groupMissionsByWeek(missions: any[]): any[] {
  const weeks: any[] = [];
  const sortedMissions = missions.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
  
  for (let i = 0; i < sortedMissions.length; i += 7) {
    const week = sortedMissions.slice(i, i + 7);
    const completionRate = week.filter(m => m.completed).length / week.length;
    
    weeks.push({
      week: Math.floor(i / 7) + 1,
      completionRate: completionRate * 100,
      totalMissions: week.length,
      completedMissions: week.filter(m => m.completed).length
    });
  }
  
  return weeks;
}

function analyzeRegularityOfMealTimes(mealTimes: any[]): string {
  // Implementar análise de regularidade
  return mealTimes.length > 10 ? 'regular' : 'irregular';
}

function findFavoriteEatingTimes(mealTimes: any[]): number[] {
  const hourCounts: { [key: number]: number } = {};
  
  mealTimes.forEach(meal => {
    hourCounts[meal.hour] = (hourCounts[meal.hour] || 0) + 1;
  });
  
  return Object.entries(hourCounts)
    .sort(([,a], [,b]) => b - a)
    .slice(0, 3)
    .map(([hour]) => parseInt(hour));
}

function analyzeWeekendVsWeekdayEating(foodAnalysis: any[]): any {
  const weekdayMeals = foodAnalysis.filter(meal => {
    const day = new Date(meal.created_at).getDay();
    return day >= 1 && day <= 5;
  });
  
  const weekendMeals = foodAnalysis.filter(meal => {
    const day = new Date(meal.created_at).getDay();
    return day === 0 || day === 6;
  });
  
  return {
    weekdayCount: weekdayMeals.length,
    weekendCount: weekendMeals.length,
    difference: weekendMeals.length > 0 ? 'different_patterns' : 'similar_patterns'
  };
}

function calculateMoodVariability(emotionalData: any[]): number {
  if (emotionalData.length < 2) return 0;
  
  const moods = emotionalData.map(e => e.sentiment_score || 0.5);
  const mean = moods.reduce((a, b) => a + b, 0) / moods.length;
  const variance = moods.reduce((acc, mood) => acc + Math.pow(mood - mean, 2), 0) / moods.length;
  
  return Math.sqrt(variance);
}

function identifyStressPatterns(emotionalData: any[]): string[] {
  const patterns: string[] = [];
  
  const highStressDays = emotionalData.filter(e => (e.stress_level || 5) > 7).length;
  const totalDays = emotionalData.length;
  
  if (highStressDays / totalDays > 0.3) {
    patterns.push('Frequentes episódios de stress elevado');
  }
  
  return patterns;
}

function identifyEnergyPatterns(emotionalData: any[]): string[] {
  const patterns: string[] = [];
  
  const lowEnergyDays = emotionalData.filter(e => (e.energy_level || 5) < 4).length;
  const totalDays = emotionalData.length;
  
  if (lowEnergyDays / totalDays > 0.4) {
    patterns.push('Padrão de baixa energia frequente');
  }
  
  return patterns;
}