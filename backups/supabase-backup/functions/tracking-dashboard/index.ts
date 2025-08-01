import "https://deno.land/x/xhr@0.1.0/mod.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface DashboardRequest {
  userId: string;
  type: 'overview' | 'daily' | 'weekly' | 'monthly' | 'insights' | 'correlations' | 'ranking';
  date?: string;
  period?: string;
}

interface DashboardResponse {
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
    const requestData: DashboardRequest = await req.json();
    console.log('📊 Dashboard Request:', requestData);

    // Inicializar Supabase
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    let result: DashboardResponse;

    switch (requestData.type) {
      case 'overview':
        result = await getDashboardOverview(supabase, requestData.userId);
        break;
      case 'daily':
        result = await getDailySummary(supabase, requestData.userId, requestData.date);
        break;
      case 'weekly':
        result = await getWeeklyStats(supabase, requestData.userId);
        break;
      case 'monthly':
        result = await getMonthlyReport(supabase, requestData.userId, requestData.date);
        break;
      case 'insights':
        result = await getSofiaInsights(supabase, requestData.userId);
        break;
      case 'correlations':
        result = await getCorrelationAnalysis(supabase, requestData.userId);
        break;
      case 'ranking':
        result = await getUserRanking(supabase, requestData.userId);
        break;
      default:
        throw new Error(`Tipo de dashboard não suportado: ${requestData.type}`);
    }

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('❌ Erro no Dashboard:', error);
    
    return new Response(JSON.stringify({ 
      success: false,
      error: error.message,
      message: 'Erro ao carregar dashboard'
    }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});

// =====================================================
// FUNÇÕES DE DASHBOARD ESPECÍFICAS
// =====================================================

async function getDashboardOverview(supabase: any, userId: string): Promise<DashboardResponse> {
  try {
    // Usar a função SQL get_user_dashboard
    const { data, error } = await supabase
      .rpc('get_user_dashboard', { user_uuid: userId });

    if (error) throw error;

    // Buscar dados adicionais
    const today = new Date().toISOString().split('T')[0];
    
    // Exercícios de hoje
    const { data: todayExercises, error: exerciseError } = await supabase
      .from('exercise_tracking')
      .select('*')
      .eq('user_id', userId)
      .eq('date', today);

    if (exerciseError) throw exerciseError;

    // Metas ativas
    const { data: activeGoals, error: goalsError } = await supabase
      .from('health_goals')
      .select('*')
      .eq('user_id', userId)
      .eq('is_active', true);

    if (goalsError) throw goalsError;

    const overview = data[0] || {};
    
    return {
      success: true,
      data: {
        // Dados principais do dashboard
        water: {
          today: overview.water_today || 0,
          goal: overview.water_goal || 2000,
          percentage: overview.water_percentage || 0,
          weeklyAvg: overview.weekly_water_avg || 0
        },
        sleep: {
          lastNight: overview.sleep_hours || 0,
          quality: overview.sleep_quality || 0,
          weeklyAvg: overview.weekly_sleep_avg || 0
        },
        mood: {
          energy: overview.energy_today || 0,
          stress: overview.stress_today || 0,
          rating: overview.mood_rating || 0,
          weeklyAvg: overview.weekly_mood_avg || 0
        },
        exercise: {
          todayCount: todayExercises?.length || 0,
          todayMinutes: todayExercises?.reduce((sum: number, ex: any) => sum + (ex.duration_minutes || 0), 0) || 0,
          weeklyMinutes: overview.exercise_minutes_week || 0,
          todayExercises: todayExercises || []
        },
        goals: {
          active: activeGoals?.length || 0,
          list: activeGoals || []
        },
        // Score geral do dia (calculado)
        dailyScore: calculateDailyScore(overview, todayExercises?.length || 0)
      }
    };

  } catch (error) {
    console.error('Erro no overview:', error);
    throw error;
  }
}

async function getDailySummary(supabase: any, userId: string, date?: string): Promise<DashboardResponse> {
  const targetDate = date || new Date().toISOString().split('T')[0];

  try {
    // Buscar todos os dados do dia específico
    const [waterResult, sleepResult, moodResult, exerciseResult] = await Promise.all([
      supabase.from('water_tracking').select('*').eq('user_id', userId).eq('date', targetDate).single(),
      supabase.from('sleep_tracking').select('*').eq('user_id', userId).eq('date', targetDate).single(),
      supabase.from('mood_tracking').select('*').eq('user_id', userId).eq('date', targetDate).single(),
      supabase.from('exercise_tracking').select('*').eq('user_id', userId).eq('date', targetDate)
    ]);

    return {
      success: true,
      data: {
        date: targetDate,
        water: waterResult.data || null,
        sleep: sleepResult.data || null,
        mood: moodResult.data || null,
        exercises: exerciseResult.data || [],
        hasData: !!(waterResult.data || sleepResult.data || moodResult.data || exerciseResult.data?.length)
      }
    };

  } catch (error) {
    console.error('Erro no resumo diário:', error);
    throw error;
  }
}

async function getWeeklyStats(supabase: any, userId: string): Promise<DashboardResponse> {
  try {
    // Usar a view weekly_tracking_stats
    const { data, error } = await supabase
      .from('weekly_tracking_stats')
      .select('*')
      .eq('user_id', userId)
      .single();

    if (error && error.code !== 'PGRST116') throw error;

    // Buscar dados dos últimos 7 dias para gráficos
    const weekStart = new Date();
    weekStart.setDate(weekStart.getDate() - 6);
    const weekStartStr = weekStart.toISOString().split('T')[0];
    const todayStr = new Date().toISOString().split('T')[0];

    const { data: dailyData, error: dailyError } = await supabase
      .from('daily_tracking_summary')
      .select('*')
      .eq('user_id', userId)
      .gte('date_day', weekStartStr)
      .lte('date_day', todayStr)
      .order('date_day', { ascending: true });

    if (dailyError) throw dailyError;

    return {
      success: true,
      data: {
        stats: data || {},
        dailyData: dailyData || [],
        period: 'week'
      }
    };

  } catch (error) {
    console.error('Erro nas estatísticas semanais:', error);
    throw error;
  }
}

async function getMonthlyReport(supabase: any, userId: string, date?: string): Promise<DashboardResponse> {
  const reportDate = date ? new Date(date) : new Date();
  
  try {
    // Usar a função SQL get_monthly_report
    const { data, error } = await supabase
      .rpc('get_monthly_report', { 
        user_uuid: userId,
        report_month: reportDate.toISOString().split('T')[0]
      });

    if (error) throw error;

    const monthlyData = data[0] || {};

    return {
      success: true,
      data: {
        ...monthlyData,
        month: reportDate.getMonth() + 1,
        year: reportDate.getFullYear(),
        period: 'month'
      }
    };

  } catch (error) {
    console.error('Erro no relatório mensal:', error);
    throw error;
  }
}

async function getSofiaInsights(supabase: any, userId: string): Promise<DashboardResponse> {
  try {
    // Usar a função SQL get_sofia_insights
    const { data, error } = await supabase
      .rpc('get_sofia_insights', { user_uuid: userId });

    if (error) throw error;

    return {
      success: true,
      data: {
        insights: data || [],
        generatedAt: new Date().toISOString()
      }
    };

  } catch (error) {
    console.error('Erro nos insights da Sofia:', error);
    throw error;
  }
}

async function getCorrelationAnalysis(supabase: any, userId: string): Promise<DashboardResponse> {
  try {
    // Usar a função SQL analyze_user_correlations
    const { data, error } = await supabase
      .rpc('analyze_user_correlations', { 
        user_uuid: userId,
        days_back: 30
      });

    if (error) throw error;

    return {
      success: true,
      data: {
        correlations: data || [],
        analysisDate: new Date().toISOString(),
        period: 30
      }
    };

  } catch (error) {
    console.error('Erro na análise de correlações:', error);
    throw error;
  }
}

async function getUserRanking(supabase: any, userId: string): Promise<DashboardResponse> {
  try {
    // Buscar ranking completo
    const { data: allRankings, error: rankingError } = await supabase
      .from('user_engagement_ranking')
      .select('*')
      .order('engagement_score', { ascending: false })
      .limit(100);

    if (rankingError) throw rankingError;

    // Encontrar posição do usuário
    const userPosition = allRankings?.findIndex((user: any) => user.user_id === userId) + 1 || 0;
    const userData = allRankings?.find((user: any) => user.user_id === userId);

    return {
      success: true,
      data: {
        userPosition,
        userData: userData || null,
        topUsers: allRankings?.slice(0, 10) || [],
        totalUsers: allRankings?.length || 0
      }
    };

  } catch (error) {
    console.error('Erro no ranking:', error);
    throw error;
  }
}

// =====================================================
// FUNÇÕES AUXILIARES
// =====================================================

function calculateDailyScore(overview: any, exerciseCount: number): number {
  const waterScore = Math.min((overview.water_today || 0) / (overview.water_goal || 2000) * 25, 25);
  const sleepScore = Math.min((overview.sleep_hours || 0) / 8 * 25, 25);
  const moodScore = (overview.mood_rating || 0) * 2.5;
  const exerciseScore = exerciseCount > 0 ? 25 : 0;

  return Math.round(waterScore + sleepScore + moodScore + exerciseScore);
}