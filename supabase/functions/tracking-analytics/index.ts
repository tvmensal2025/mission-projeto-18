import "https://deno.land/x/xhr@0.1.0/mod.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface AnalyticsRequest {
  userId: string;
  type: 'trends' | 'patterns' | 'predictions' | 'recommendations' | 'dr_vital_report' | 'seed_data';
  period?: 'week' | 'month' | 'quarter' | 'year';
  startDate?: string;
  endDate?: string;
  options?: any;
}

interface AnalyticsResponse {
  success: boolean;
  data?: any;
  error?: string;
  message?: string;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const requestData: AnalyticsRequest = await req.json();
    console.log('📈 Analytics Request:', requestData);

    // Inicializar Supabase
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    let result: AnalyticsResponse;

    switch (requestData.type) {
      case 'trends':
        result = await analyzeTrends(supabase, requestData);
        break;
      case 'patterns':
        result = await analyzePatterns(supabase, requestData);
        break;
      case 'predictions':
        result = await generatePredictions(supabase, requestData);
        break;
      case 'recommendations':
        result = await generateRecommendations(supabase, requestData);
        break;
      case 'dr_vital_report':
        result = await generateDrVitalReport(supabase, requestData.userId);
        break;
      case 'seed_data':
        result = await seedUserData(supabase, requestData.userId);
        break;
      default:
        throw new Error(`Tipo de análise não suportado: ${requestData.type}`);
    }

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('❌ Erro no Analytics:', error);
    
    return new Response(JSON.stringify({ 
      success: false,
      error: error.message,
      message: 'Erro na análise de dados'
    }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});

// =====================================================
// FUNÇÕES DE ANÁLISE ESPECÍFICAS
// =====================================================

async function analyzeTrends(supabase: any, request: AnalyticsRequest): Promise<AnalyticsResponse> {
  const { userId, period = 'month', startDate, endDate } = request;
  
  try {
    // Calcular período
    const end = endDate ? new Date(endDate) : new Date();
    const start = startDate ? new Date(startDate) : new Date();
    
    if (!startDate) {
      switch (period) {
        case 'week':
          start.setDate(end.getDate() - 7);
          break;
        case 'month':
          start.setMonth(end.getMonth() - 1);
          break;
        case 'quarter':
          start.setMonth(end.getMonth() - 3);
          break;
        case 'year':
          start.setFullYear(end.getFullYear() - 1);
          break;
      }
    }

    const startStr = start.toISOString().split('T')[0];
    const endStr = end.toISOString().split('T')[0];

    // Buscar dados históricos
    const { data: dailyData, error } = await supabase
      .from('daily_tracking_summary')
      .select('*')
      .eq('user_id', userId)
      .gte('date_day', startStr)
      .lte('date_day', endStr)
      .order('date_day', { ascending: true });

    if (error) throw error;

    // Calcular tendências
    const trends = calculateTrends(dailyData || []);

    return {
      success: true,
      data: {
        period: { start: startStr, end: endStr },
        trends,
        dataPoints: dailyData?.length || 0,
        summary: generateTrendsSummary(trends)
      }
    };

  } catch (error) {
    console.error('Erro na análise de tendências:', error);
    throw error;
  }
}

async function analyzePatterns(supabase: any, request: AnalyticsRequest): Promise<AnalyticsResponse> {
  const { userId, period = 'month' } = request;
  
  try {
    // Buscar dados dos últimos 30 dias
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    const startStr = thirtyDaysAgo.toISOString().split('T')[0];
    const endStr = new Date().toISOString().split('T')[0];

    const { data: dailyData, error } = await supabase
      .from('daily_tracking_summary')
      .select('*')
      .eq('user_id', userId)
      .gte('date_day', startStr)
      .lte('date_day', endStr)
      .order('date_day', { ascending: true });

    if (error) throw error;

    // Analisar padrões
    const patterns = analyzeUserPatterns(dailyData || []);

    return {
      success: true,
      data: {
        patterns,
        period: { start: startStr, end: endStr },
        insights: generatePatternInsights(patterns)
      }
    };

  } catch (error) {
    console.error('Erro na análise de padrões:', error);
    throw error;
  }
}

async function generatePredictions(supabase: any, request: AnalyticsRequest): Promise<AnalyticsResponse> {
  const { userId } = request;
  
  try {
    // Buscar dados históricos para predições
    const { data: weeklyStats, error } = await supabase
      .from('weekly_tracking_stats')
      .select('*')
      .eq('user_id', userId)
      .single();

    if (error && error.code !== 'PGRST116') throw error;

    // Gerar predições baseadas nos dados atuais
    const predictions = generateHealthPredictions(weeklyStats || {});

    return {
      success: true,
      data: {
        predictions,
        basedOn: 'weekly_stats',
        confidence: calculatePredictionConfidence(weeklyStats || {}),
        generatedAt: new Date().toISOString()
      }
    };

  } catch (error) {
    console.error('Erro na geração de predições:', error);
    throw error;
  }
}

async function generateRecommendations(supabase: any, request: AnalyticsRequest): Promise<AnalyticsResponse> {
  const { userId } = request;
  
  try {
    // Usar a função SQL get_sofia_insights para recomendações
    const { data: insights, error } = await supabase
      .rpc('get_sofia_insights', { user_uuid: userId });

    if (error) throw error;

    // Buscar dados adicionais para recomendações mais específicas
    const { data: weeklyStats, error: statsError } = await supabase
      .from('weekly_tracking_stats')
      .select('*')
      .eq('user_id', userId)
      .single();

    if (statsError && statsError.code !== 'PGRST116') throw statsError;

    // Gerar recomendações personalizadas
    const recommendations = generatePersonalizedRecommendations(insights || [], weeklyStats || {});

    return {
      success: true,
      data: {
        recommendations,
        insights: insights || [],
        priority: 'high',
        generatedAt: new Date().toISOString()
      }
    };

  } catch (error) {
    console.error('Erro na geração de recomendações:', error);
    throw error;
  }
}

async function generateDrVitalReport(supabase: any, userId: string): Promise<AnalyticsResponse> {
  try {
    // Usar a função SQL generate_dr_vital_report
    const { data, error } = await supabase
      .rpc('generate_dr_vital_report', { user_uuid: userId });

    if (error) throw error;

    return {
      success: true,
      data: {
        report: data,
        generatedAt: new Date().toISOString(),
        type: 'dr_vital_report'
      }
    };

  } catch (error) {
    console.error('Erro no relatório do Dr. Vital:', error);
    throw error;
  }
}

async function seedUserData(supabase: any, userId: string): Promise<AnalyticsResponse> {
  try {
    // Usar a função SQL create_realistic_tracking_data
    const { data, error } = await supabase
      .rpc('create_realistic_tracking_data', { user_uuid: userId });

    if (error) throw error;

    return {
      success: true,
      data: {
        message: 'Dados de exemplo criados com sucesso!',
        userId,
        daysCreated: 30,
        createdAt: new Date().toISOString()
      }
    };

  } catch (error) {
    console.error('Erro ao criar dados de exemplo:', error);
    throw error;
  }
}

// =====================================================
// FUNÇÕES AUXILIARES DE ANÁLISE
// =====================================================

function calculateTrends(data: any[]): any {
  if (data.length < 2) return null;

  const waterTrend = calculateLinearTrend(data.map(d => d.water_ml || 0));
  const sleepTrend = calculateLinearTrend(data.map(d => d.sleep_hours || 0));
  const moodTrend = calculateLinearTrend(data.map(d => d.day_rating || 0));
  const exerciseTrend = calculateLinearTrend(data.map(d => d.exercise_sessions || 0));

  return {
    water: waterTrend,
    sleep: sleepTrend,
    mood: moodTrend,
    exercise: exerciseTrend
  };
}

function calculateLinearTrend(values: number[]): any {
  if (values.length < 2) return { direction: 'stable', change: 0 };

  const n = values.length;
  const sumX = n * (n - 1) / 2;
  const sumY = values.reduce((sum, val) => sum + val, 0);
  const sumXY = values.reduce((sum, val, index) => sum + val * index, 0);
  const sumX2 = n * (n - 1) * (2 * n - 1) / 6;

  const slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
  const direction = slope > 0.1 ? 'improving' : slope < -0.1 ? 'declining' : 'stable';

  return {
    direction,
    change: slope,
    confidence: Math.min(Math.abs(slope) * 10, 1)
  };
}

function analyzeUserPatterns(data: any[]): any {
  const patterns = {
    bestDayOfWeek: findBestDayOfWeek(data),
    worstDayOfWeek: findWorstDayOfWeek(data),
    consistencyScore: calculateConsistencyScore(data),
    streaks: findStreaks(data),
    correlations: findSimpleCorrelations(data)
  };

  return patterns;
}

function findBestDayOfWeek(data: any[]): any {
  const dayScores: { [key: number]: number[] } = {};
  
  data.forEach(d => {
    const date = new Date(d.date_day);
    const dayOfWeek = date.getDay();
    const score = d.daily_score || 0;
    
    if (!dayScores[dayOfWeek]) dayScores[dayOfWeek] = [];
    dayScores[dayOfWeek].push(score);
  });

  const dayNames = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
  let bestDay = 0;
  let bestAverage = 0;

  Object.keys(dayScores).forEach(day => {
    const dayNum = parseInt(day);
    const average = dayScores[dayNum].reduce((sum, score) => sum + score, 0) / dayScores[dayNum].length;
    if (average > bestAverage) {
      bestAverage = average;
      bestDay = dayNum;
    }
  });

  return {
    day: dayNames[bestDay],
    average: Math.round(bestAverage),
    dayOfWeek: bestDay
  };
}

function findWorstDayOfWeek(data: any[]): any {
  const dayScores: { [key: number]: number[] } = {};
  
  data.forEach(d => {
    const date = new Date(d.date_day);
    const dayOfWeek = date.getDay();
    const score = d.daily_score || 0;
    
    if (!dayScores[dayOfWeek]) dayScores[dayOfWeek] = [];
    dayScores[dayOfWeek].push(score);
  });

  const dayNames = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
  let worstDay = 0;
  let worstAverage = 100;

  Object.keys(dayScores).forEach(day => {
    const dayNum = parseInt(day);
    const average = dayScores[dayNum].reduce((sum, score) => sum + score, 0) / dayScores[dayNum].length;
    if (average < worstAverage) {
      worstAverage = average;
      worstDay = dayNum;
    }
  });

  return {
    day: dayNames[worstDay],
    average: Math.round(worstAverage),
    dayOfWeek: worstDay
  };
}

function calculateConsistencyScore(data: any[]): number {
  if (data.length < 7) return 0;

  const scores = data.map(d => d.daily_score || 0);
  const average = scores.reduce((sum, score) => sum + score, 0) / scores.length;
  const variance = scores.reduce((sum, score) => sum + Math.pow(score - average, 2), 0) / scores.length;
  const standardDeviation = Math.sqrt(variance);

  // Consistência é inversamente proporcional ao desvio padrão
  return Math.max(0, Math.min(100, 100 - standardDeviation));
}

function findStreaks(data: any[]): any {
  // Encontrar sequências de dias bons (score >= 70)
  let currentStreak = 0;
  let longestStreak = 0;
  let streakStart = null;

  data.forEach((d, index) => {
    const score = d.daily_score || 0;
    if (score >= 70) {
      if (currentStreak === 0) streakStart = d.date_day;
      currentStreak++;
      longestStreak = Math.max(longestStreak, currentStreak);
    } else {
      currentStreak = 0;
    }
  });

  return {
    current: currentStreak,
    longest: longestStreak,
    threshold: 70
  };
}

function findSimpleCorrelations(data: any[]): any {
  // Correlações simples entre métricas
  const waterScores = data.map(d => d.water_ml || 0);
  const sleepScores = data.map(d => d.sleep_hours || 0);
  const moodScores = data.map(d => d.day_rating || 0);

  return {
    sleepMood: calculateSimpleCorrelation(sleepScores, moodScores),
    waterMood: calculateSimpleCorrelation(waterScores, moodScores)
  };
}

function calculateSimpleCorrelation(x: number[], y: number[]): number {
  if (x.length !== y.length || x.length < 3) return 0;

  const n = x.length;
  const sumX = x.reduce((sum, val) => sum + val, 0);
  const sumY = y.reduce((sum, val) => sum + val, 0);
  const sumXY = x.reduce((sum, val, i) => sum + val * y[i], 0);
  const sumX2 = x.reduce((sum, val) => sum + val * val, 0);
  const sumY2 = y.reduce((sum, val) => sum + val * val, 0);

  const numerator = n * sumXY - sumX * sumY;
  const denominator = Math.sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY));

  return denominator === 0 ? 0 : numerator / denominator;
}

function generateTrendsSummary(trends: any): string[] {
  const summary: string[] = [];

  if (trends?.water?.direction === 'improving') {
    summary.push('📈 Sua hidratação está melhorando!');
  } else if (trends?.water?.direction === 'declining') {
    summary.push('📉 Atenção: sua hidratação está diminuindo');
  }

  if (trends?.sleep?.direction === 'improving') {
    summary.push('😴 Qualidade do sono em melhora!');
  } else if (trends?.sleep?.direction === 'declining') {
    summary.push('⚠️ Seu sono precisa de atenção');
  }

  if (trends?.mood?.direction === 'improving') {
    summary.push('😊 Humor em alta!');
  } else if (trends?.mood?.direction === 'declining') {
    summary.push('💙 Que tal cuidar mais do seu bem-estar?');
  }

  return summary;
}

function generatePatternInsights(patterns: any): string[] {
  const insights: string[] = [];

  if (patterns.bestDayOfWeek) {
    insights.push(`🌟 Seu melhor dia da semana é ${patterns.bestDayOfWeek.day}`);
  }

  if (patterns.consistencyScore > 80) {
    insights.push('🎯 Você é muito consistente com seus hábitos!');
  } else if (patterns.consistencyScore < 50) {
    insights.push('📈 Tente ser mais consistente com seus hábitos');
  }

  if (patterns.streaks?.longest > 7) {
    insights.push(`🔥 Sua maior sequência foi de ${patterns.streaks.longest} dias!`);
  }

  return insights;
}

function generateHealthPredictions(stats: any): any {
  const predictions = [];

  // Predição baseada na tendência atual
  if (stats.water_success_rate > 80) {
    predictions.push({
      metric: 'hydration',
      prediction: 'excellent',
      message: 'Você continuará bem hidratado se mantiver o ritmo',
      confidence: 0.9
    });
  }

  if (stats.avg_sleep_hours > 7.5) {
    predictions.push({
      metric: 'sleep',
      prediction: 'good',
      message: 'Seu sono está no caminho certo para melhorar sua energia',
      confidence: 0.8
    });
  }

  if (stats.total_exercise_minutes > 150) {
    predictions.push({
      metric: 'fitness',
      prediction: 'improving',
      message: 'Continue assim e verá melhorias na condição física',
      confidence: 0.85
    });
  }

  return predictions;
}

function calculatePredictionConfidence(stats: any): number {
  // Confiança baseada na quantidade de dados disponíveis
  const dataPoints = Object.values(stats).filter(val => val !== null && val !== undefined).length;
  return Math.min(dataPoints / 10, 1);
}

function generatePersonalizedRecommendations(insights: any[], stats: any): any[] {
  const recommendations = [];

  // Recomendações baseadas nos insights da Sofia
  insights.forEach((insight: any) => {
    if (insight.priority === 3) {
      recommendations.push({
        type: 'urgent',
        title: insight.insight_type,
        message: insight.message,
        action: insight.action_suggested,
        priority: 'high'
      });
    }
  });

  // Recomendações baseadas nas estatísticas
  if (stats.water_success_rate < 70) {
    recommendations.push({
      type: 'habit',
      title: 'Hidratação',
      message: 'Configure lembretes para beber água a cada 2 horas',
      action: 'set_water_reminders',
      priority: 'medium'
    });
  }

  if (stats.avg_sleep_hours < 7) {
    recommendations.push({
      type: 'lifestyle',
      title: 'Sono',
      message: 'Tente ir para a cama 30 minutos mais cedo',
      action: 'adjust_bedtime',
      priority: 'high'
    });
  }

  return recommendations;
}