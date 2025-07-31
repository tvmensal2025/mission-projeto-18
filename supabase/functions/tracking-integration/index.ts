import "https://deno.land/x/xhr@0.1.0/mod.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface IntegrationRequest {
  action: 'sofia_chat' | 'dr_vital_report' | 'sync_goals' | 'update_progress' | 'batch_update';
  userId: string;
  data?: any;
  options?: any;
}

interface IntegrationResponse {
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
    const requestData: IntegrationRequest = await req.json();
    console.log('🔗 Integration Request:', requestData);

    // Inicializar Supabase
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    let result: IntegrationResponse;

    switch (requestData.action) {
      case 'sofia_chat':
        result = await integrateSofiaChat(supabase, requestData);
        break;
      case 'dr_vital_report':
        result = await integrateDrVitalReport(supabase, requestData);
        break;
      case 'sync_goals':
        result = await syncUserGoals(supabase, requestData);
        break;
      case 'update_progress':
        result = await updateUserProgress(supabase, requestData);
        break;
      case 'batch_update':
        result = await batchUpdateTracking(supabase, requestData);
        break;
      default:
        throw new Error(`Ação de integração não suportada: ${requestData.action}`);
    }

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('❌ Erro na Integração:', error);
    
    return new Response(JSON.stringify({ 
      success: false,
      error: error.message,
      message: 'Erro na integração com tracking'
    }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});

// =====================================================
// INTEGRAÇÃO COM SOFIA (CHAT INTELIGENTE)
// =====================================================

async function integrateSofiaChat(supabase: any, request: IntegrationRequest): Promise<IntegrationResponse> {
  const { userId, data } = request;
  
  try {
    // Buscar contexto de tracking para Sofia
    const trackingContext = await getTrackingContextForSofia(supabase, userId);
    
    // Buscar insights automáticos
    const { data: insights, error: insightsError } = await supabase
      .rpc('get_sofia_insights', { user_uuid: userId });

    if (insightsError) throw insightsError;

    // Preparar contexto completo para Sofia
    const sofiaContext = {
      userMessage: data.message,
      trackingData: trackingContext,
      insights: insights || [],
      timestamp: new Date().toISOString()
    };

    // Chamar a função de chat da Sofia com contexto enriquecido
    const { data: chatResponse, error: chatError } = await supabase.functions.invoke('health-chat-bot', {
      body: {
        message: data.message,
        userId: userId,
        trackingContext: sofiaContext,
        enhancedMode: true
      }
    });

    if (chatError) throw chatError;

    return {
      success: true,
      data: {
        response: chatResponse,
        context: trackingContext,
        insights: insights || [],
        enhancedWithTracking: true
      }
    };

  } catch (error) {
    console.error('Erro na integração com Sofia:', error);
    throw error;
  }
}

// =====================================================
// INTEGRAÇÃO COM DR. VITAL (RELATÓRIOS MÉDICOS)
// =====================================================

async function integrateDrVitalReport(supabase: any, request: IntegrationRequest): Promise<IntegrationResponse> {
  const { userId, options } = request;
  
  try {
    // Gerar relatório completo do Dr. Vital
    const { data: report, error: reportError } = await supabase
      .rpc('generate_dr_vital_report', { user_uuid: userId });

    if (reportError) throw reportError;

    // Buscar dados adicionais para o relatório
    const { data: monthlyData, error: monthlyError } = await supabase
      .rpc('get_monthly_report', { 
        user_uuid: userId,
        report_month: new Date().toISOString().split('T')[0]
      });

    if (monthlyError) throw monthlyError;

    // Buscar correlações para insights médicos
    const { data: correlations, error: correlationsError } = await supabase
      .rpc('analyze_user_correlations', { 
        user_uuid: userId,
        days_back: 30
      });

    if (correlationsError) throw correlationsError;

    // Preparar relatório completo
    const completeReport = {
      textReport: report,
      monthlyStats: monthlyData[0] || {},
      correlations: correlations || [],
      generatedAt: new Date().toISOString(),
      reportType: 'comprehensive_health_analysis'
    };

    // Se solicitado, enviar por email/WhatsApp
    if (options?.sendReport) {
      await sendDrVitalReport(supabase, userId, completeReport);
    }

    return {
      success: true,
      data: completeReport
    };

  } catch (error) {
    console.error('Erro na integração com Dr. Vital:', error);
    throw error;
  }
}

// =====================================================
// SINCRONIZAÇÃO DE METAS
// =====================================================

async function syncUserGoals(supabase: any, request: IntegrationRequest): Promise<IntegrationResponse> {
  const { userId } = request;
  
  try {
    // Buscar metas ativas
    const { data: goals, error: goalsError } = await supabase
      .from('health_goals')
      .select('*')
      .eq('user_id', userId)
      .eq('is_active', true);

    if (goalsError) throw goalsError;

    // Atualizar progresso de cada meta baseado nos dados de tracking
    const updatedGoals = [];
    
    for (const goal of goals || []) {
      const progress = await calculateGoalProgress(supabase, userId, goal);
      
      // Atualizar meta no banco
      const { error: updateError } = await supabase
        .from('health_goals')
        .update({
          current_value: progress.currentValue,
          progress_percentage: progress.percentage,
          achieved_at: progress.achieved ? new Date().toISOString() : null,
          updated_at: new Date().toISOString()
        })
        .eq('id', goal.id);

      if (updateError) throw updateError;

      updatedGoals.push({
        ...goal,
        current_value: progress.currentValue,
        progress_percentage: progress.percentage,
        achieved: progress.achieved
      });
    }

    return {
      success: true,
      data: {
        goals: updatedGoals,
        totalGoals: updatedGoals.length,
        achievedGoals: updatedGoals.filter(g => g.achieved).length,
        syncedAt: new Date().toISOString()
      }
    };

  } catch (error) {
    console.error('Erro na sincronização de metas:', error);
    throw error;
  }
}

// =====================================================
// ATUALIZAÇÃO DE PROGRESSO
// =====================================================

async function updateUserProgress(supabase: any, request: IntegrationRequest): Promise<IntegrationResponse> {
  const { userId, data } = request;
  
  try {
    // Atualizar múltiplos tipos de tracking de uma vez
    const updates = [];

    if (data.water) {
      const waterUpdate = await updateWaterProgress(supabase, userId, data.water);
      updates.push({ type: 'water', ...waterUpdate });
    }

    if (data.sleep) {
      const sleepUpdate = await updateSleepProgress(supabase, userId, data.sleep);
      updates.push({ type: 'sleep', ...sleepUpdate });
    }

    if (data.mood) {
      const moodUpdate = await updateMoodProgress(supabase, userId, data.mood);
      updates.push({ type: 'mood', ...moodUpdate });
    }

    if (data.exercise) {
      const exerciseUpdate = await updateExerciseProgress(supabase, userId, data.exercise);
      updates.push({ type: 'exercise', ...exerciseUpdate });
    }

    // Sincronizar metas após atualizações
    await syncUserGoals(supabase, { action: 'sync_goals', userId });

    return {
      success: true,
      data: {
        updates,
        totalUpdates: updates.length,
        updatedAt: new Date().toISOString()
      }
    };

  } catch (error) {
    console.error('Erro na atualização de progresso:', error);
    throw error;
  }
}

// =====================================================
// ATUALIZAÇÃO EM LOTE
// =====================================================

async function batchUpdateTracking(supabase: any, request: IntegrationRequest): Promise<IntegrationResponse> {
  const { userId, data } = request;
  
  try {
    const results = [];

    // Processar cada item do lote
    for (const item of data.items || []) {
      try {
        let result;
        
        switch (item.type) {
          case 'water':
            result = await supabase.from('water_tracking').upsert({
              user_id: userId,
              date: item.date,
              ...item.data
            });
            break;
          case 'sleep':
            result = await supabase.from('sleep_tracking').upsert({
              user_id: userId,
              date: item.date,
              ...item.data
            });
            break;
          case 'mood':
            result = await supabase.from('mood_tracking').upsert({
              user_id: userId,
              date: item.date,
              ...item.data
            });
            break;
          case 'exercise':
            result = await supabase.from('exercise_tracking').insert({
              user_id: userId,
              date: item.date,
              ...item.data
            });
            break;
        }

        results.push({
          type: item.type,
          date: item.date,
          success: !result.error,
          error: result.error?.message
        });

      } catch (itemError) {
        results.push({
          type: item.type,
          date: item.date,
          success: false,
          error: itemError.message
        });
      }
    }

    const successCount = results.filter(r => r.success).length;

    return {
      success: true,
      data: {
        results,
        totalItems: results.length,
        successCount,
        failureCount: results.length - successCount,
        processedAt: new Date().toISOString()
      }
    };

  } catch (error) {
    console.error('Erro na atualização em lote:', error);
    throw error;
  }
}

// =====================================================
// FUNÇÕES AUXILIARES
// =====================================================

async function getTrackingContextForSofia(supabase: any, userId: string): Promise<any> {
  // Buscar dados de contexto para Sofia
  const today = new Date().toISOString().split('T')[0];
  
  const [dashboardData, weeklyStats, recentExercises] = await Promise.all([
    supabase.rpc('get_user_dashboard', { user_uuid: userId }),
    supabase.from('weekly_tracking_stats').select('*').eq('user_id', userId).single(),
    supabase.from('exercise_tracking').select('*').eq('user_id', userId)
      .gte('date', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0])
      .order('created_at', { ascending: false }).limit(5)
  ]);

  return {
    dashboard: dashboardData.data?.[0] || {},
    weeklyStats: weeklyStats.data || {},
    recentExercises: recentExercises.data || [],
    contextDate: today
  };
}

async function calculateGoalProgress(supabase: any, userId: string, goal: any): Promise<any> {
  const today = new Date().toISOString().split('T')[0];
  let currentValue = 0;

  switch (goal.goal_type) {
    case 'water':
      const { data: waterData } = await supabase
        .from('water_tracking')
        .select('amount_ml')
        .eq('user_id', userId)
        .eq('date', today)
        .single();
      currentValue = waterData?.amount_ml || 0;
      break;

    case 'sleep':
      const { data: sleepData } = await supabase
        .from('sleep_tracking')
        .select('hours')
        .eq('user_id', userId)
        .eq('date', today)
        .single();
      currentValue = sleepData?.hours || 0;
      break;

    case 'exercise':
      const { data: exerciseData } = await supabase
        .from('exercise_tracking')
        .select('duration_minutes')
        .eq('user_id', userId)
        .eq('date', today);
      currentValue = exerciseData?.reduce((sum: number, ex: any) => sum + (ex.duration_minutes || 0), 0) || 0;
      break;
  }

  const percentage = Math.min((currentValue / goal.target_value) * 100, 100);
  const achieved = percentage >= 100;

  return {
    currentValue,
    percentage: Math.round(percentage),
    achieved
  };
}

async function updateWaterProgress(supabase: any, userId: string, data: any): Promise<any> {
  const today = new Date().toISOString().split('T')[0];
  
  const { error } = await supabase
    .from('water_tracking')
    .upsert({
      user_id: userId,
      date: today,
      amount_ml: data.amount_ml,
      goal_ml: data.goal_ml || 2000,
      cups_count: data.cups_count || 0,
      updated_at: new Date().toISOString()
    });

  return { success: !error, error: error?.message };
}

async function updateSleepProgress(supabase: any, userId: string, data: any): Promise<any> {
  const date = data.date || new Date().toISOString().split('T')[0];
  
  const { error } = await supabase
    .from('sleep_tracking')
    .upsert({
      user_id: userId,
      date,
      hours: data.hours,
      quality: data.quality,
      bedtime: data.bedtime,
      wake_time: data.wake_time,
      updated_at: new Date().toISOString()
    });

  return { success: !error, error: error?.message };
}

async function updateMoodProgress(supabase: any, userId: string, data: any): Promise<any> {
  const today = new Date().toISOString().split('T')[0];
  
  const { error } = await supabase
    .from('mood_tracking')
    .upsert({
      user_id: userId,
      date: today,
      energy_level: data.energy_level,
      stress_level: data.stress_level,
      day_rating: data.day_rating,
      gratitude_note: data.gratitude_note,
      mood_tags: data.mood_tags || [],
      updated_at: new Date().toISOString()
    });

  return { success: !error, error: error?.message };
}

async function updateExerciseProgress(supabase: any, userId: string, data: any): Promise<any> {
  const today = new Date().toISOString().split('T')[0];
  
  const { error } = await supabase
    .from('exercise_tracking')
    .insert({
      user_id: userId,
      date: today,
      exercise_type: data.exercise_type,
      exercise_name: data.exercise_name,
      duration_minutes: data.duration_minutes,
      calories_burned: data.calories_burned,
      intensity: data.intensity,
      notes: data.notes
    });

  return { success: !error, error: error?.message };
}

async function sendDrVitalReport(supabase: any, userId: string, report: any): Promise<void> {
  // Integração com sistema de email/WhatsApp
  try {
    await supabase.functions.invoke('send-weekly-email-report', {
      body: {
        userId,
        reportType: 'dr_vital_health_analysis',
        reportData: report
      }
    });
  } catch (error) {
    console.error('Erro ao enviar relatório:', error);
  }
}