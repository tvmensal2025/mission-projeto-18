import "https://deno.land/x/xhr@0.1.0/mod.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface TrackingRequest {
  action: 'create' | 'update' | 'delete' | 'get' | 'list';
  type: 'water' | 'sleep' | 'mood' | 'exercise' | 'medication' | 'symptoms' | 'habits' | 'goals';
  data?: any;
  userId?: string;
  date?: string;
  filters?: any;
}

interface TrackingResponse {
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
    const requestData: TrackingRequest = await req.json();
    console.log('📊 Tracking Manager Request:', requestData);

    // Inicializar Supabase
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    let result: TrackingResponse;

    // Roteamento baseado no tipo e ação
    switch (requestData.type) {
      case 'water':
        result = await handleWaterTracking(supabase, requestData);
        break;
      case 'sleep':
        result = await handleSleepTracking(supabase, requestData);
        break;
      case 'mood':
        result = await handleMoodTracking(supabase, requestData);
        break;
      case 'exercise':
        result = await handleExerciseTracking(supabase, requestData);
        break;
      case 'medication':
        result = await handleMedicationTracking(supabase, requestData);
        break;
      case 'symptoms':
        result = await handleSymptomsTracking(supabase, requestData);
        break;
      case 'habits':
        result = await handleHabitsTracking(supabase, requestData);
        break;
      case 'goals':
        result = await handleGoalsTracking(supabase, requestData);
        break;
      default:
        throw new Error(`Tipo de tracking não suportado: ${requestData.type}`);
    }

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('❌ Erro no Tracking Manager:', error);
    
    return new Response(JSON.stringify({ 
      success: false,
      error: error.message,
      message: 'Erro no gerenciamento de tracking'
    }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});

// =====================================================
// HANDLERS ESPECÍFICOS POR TIPO DE TRACKING
// =====================================================

async function handleWaterTracking(supabase: any, request: TrackingRequest): Promise<TrackingResponse> {
  const { action, data, userId, date, filters } = request;

  switch (action) {
    case 'create':
      const { error: createError } = await supabase
        .from('water_tracking')
        .insert({
          user_id: userId,
          date: date || new Date().toISOString().split('T')[0],
          amount_ml: data.amount_ml || 0,
          goal_ml: data.goal_ml || 2000,
          cups_count: data.cups_count || 0,
          source: data.source || 'manual',
          notes: data.notes
        });

      if (createError) throw createError;
      return { success: true, message: 'Registro de água criado com sucesso!' };

    case 'update':
      const { error: updateError } = await supabase
        .from('water_tracking')
        .update({
          amount_ml: data.amount_ml,
          goal_ml: data.goal_ml,
          cups_count: data.cups_count,
          notes: data.notes,
          updated_at: new Date().toISOString()
        })
        .eq('user_id', userId)
        .eq('date', date);

      if (updateError) throw updateError;
      return { success: true, message: 'Registro de água atualizado!' };

    case 'get':
      const { data: waterData, error: getError } = await supabase
        .from('water_tracking')
        .select('*')
        .eq('user_id', userId)
        .eq('date', date)
        .single();

      if (getError && getError.code !== 'PGRST116') throw getError;
      return { success: true, data: waterData };

    case 'list':
      const { data: waterList, error: listError } = await supabase
        .from('water_tracking')
        .select('*')
        .eq('user_id', userId)
        .gte('date', filters?.startDate || new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0])
        .lte('date', filters?.endDate || new Date().toISOString().split('T')[0])
        .order('date', { ascending: false });

      if (listError) throw listError;
      return { success: true, data: waterList };

    default:
      throw new Error(`Ação não suportada para água: ${action}`);
  }
}

async function handleSleepTracking(supabase: any, request: TrackingRequest): Promise<TrackingResponse> {
  const { action, data, userId, date, filters } = request;

  switch (action) {
    case 'create':
      const { error: createError } = await supabase
        .from('sleep_tracking')
        .insert({
          user_id: userId,
          date: date || new Date().toISOString().split('T')[0],
          hours: data.hours,
          quality: data.quality,
          bedtime: data.bedtime,
          wake_time: data.wake_time,
          dream_notes: data.dream_notes,
          source: data.source || 'manual'
        });

      if (createError) throw createError;
      return { success: true, message: 'Registro de sono criado com sucesso!' };

    case 'update':
      const { error: updateError } = await supabase
        .from('sleep_tracking')
        .update({
          hours: data.hours,
          quality: data.quality,
          bedtime: data.bedtime,
          wake_time: data.wake_time,
          dream_notes: data.dream_notes,
          updated_at: new Date().toISOString()
        })
        .eq('user_id', userId)
        .eq('date', date);

      if (updateError) throw updateError;
      return { success: true, message: 'Registro de sono atualizado!' };

    case 'get':
      const { data: sleepData, error: getError } = await supabase
        .from('sleep_tracking')
        .select('*')
        .eq('user_id', userId)
        .eq('date', date)
        .single();

      if (getError && getError.code !== 'PGRST116') throw getError;
      return { success: true, data: sleepData };

    case 'list':
      const { data: sleepList, error: listError } = await supabase
        .from('sleep_tracking')
        .select('*')
        .eq('user_id', userId)
        .gte('date', filters?.startDate || new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0])
        .lte('date', filters?.endDate || new Date().toISOString().split('T')[0])
        .order('date', { ascending: false });

      if (listError) throw listError;
      return { success: true, data: sleepList };

    default:
      throw new Error(`Ação não suportada para sono: ${action}`);
  }
}

async function handleMoodTracking(supabase: any, request: TrackingRequest): Promise<TrackingResponse> {
  const { action, data, userId, date, filters } = request;

  switch (action) {
    case 'create':
      const { error: createError } = await supabase
        .from('mood_tracking')
        .insert({
          user_id: userId,
          date: date || new Date().toISOString().split('T')[0],
          energy_level: data.energy_level,
          stress_level: data.stress_level,
          day_rating: data.day_rating,
          gratitude_note: data.gratitude_note,
          mood_tags: data.mood_tags || [],
          source: data.source || 'manual'
        });

      if (createError) throw createError;
      return { success: true, message: 'Registro de humor criado com sucesso!' };

    case 'update':
      const { error: updateError } = await supabase
        .from('mood_tracking')
        .update({
          energy_level: data.energy_level,
          stress_level: data.stress_level,
          day_rating: data.day_rating,
          gratitude_note: data.gratitude_note,
          mood_tags: data.mood_tags,
          updated_at: new Date().toISOString()
        })
        .eq('user_id', userId)
        .eq('date', date);

      if (updateError) throw updateError;
      return { success: true, message: 'Registro de humor atualizado!' };

    case 'get':
      const { data: moodData, error: getError } = await supabase
        .from('mood_tracking')
        .select('*')
        .eq('user_id', userId)
        .eq('date', date)
        .single();

      if (getError && getError.code !== 'PGRST116') throw getError;
      return { success: true, data: moodData };

    case 'list':
      const { data: moodList, error: listError } = await supabase
        .from('mood_tracking')
        .select('*')
        .eq('user_id', userId)
        .gte('date', filters?.startDate || new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0])
        .lte('date', filters?.endDate || new Date().toISOString().split('T')[0])
        .order('date', { ascending: false });

      if (listError) throw listError;
      return { success: true, data: moodList };

    default:
      throw new Error(`Ação não suportada para humor: ${action}`);
  }
}

async function handleExerciseTracking(supabase: any, request: TrackingRequest): Promise<TrackingResponse> {
  const { action, data, userId, date, filters } = request;

  switch (action) {
    case 'create':
      const { error: createError } = await supabase
        .from('exercise_tracking')
        .insert({
          user_id: userId,
          date: date || new Date().toISOString().split('T')[0],
          exercise_type: data.exercise_type,
          exercise_name: data.exercise_name,
          duration_minutes: data.duration_minutes,
          calories_burned: data.calories_burned,
          intensity: data.intensity,
          notes: data.notes,
          source: data.source || 'manual'
        });

      if (createError) throw createError;
      return { success: true, message: 'Registro de exercício criado com sucesso!' };

    case 'list':
      const { data: exerciseList, error: listError } = await supabase
        .from('exercise_tracking')
        .select('*')
        .eq('user_id', userId)
        .gte('date', filters?.startDate || new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0])
        .lte('date', filters?.endDate || new Date().toISOString().split('T')[0])
        .order('created_at', { ascending: false });

      if (listError) throw listError;
      return { success: true, data: exerciseList };

    case 'delete':
      const { error: deleteError } = await supabase
        .from('exercise_tracking')
        .delete()
        .eq('id', data.id)
        .eq('user_id', userId);

      if (deleteError) throw deleteError;
      return { success: true, message: 'Exercício removido com sucesso!' };

    default:
      throw new Error(`Ação não suportada para exercício: ${action}`);
  }
}

async function handleMedicationTracking(supabase: any, request: TrackingRequest): Promise<TrackingResponse> {
  const { action, data, userId, filters } = request;

  switch (action) {
    case 'create':
      const { error: createError } = await supabase
        .from('medication_tracking')
        .insert({
          user_id: userId,
          medication_name: data.medication_name,
          dosage: data.dosage,
          frequency: data.frequency,
          taken_at: data.taken_at || new Date().toISOString(),
          notes: data.notes
        });

      if (createError) throw createError;
      return { success: true, message: 'Medicação registrada com sucesso!' };

    case 'list':
      const { data: medicationList, error: listError } = await supabase
        .from('medication_tracking')
        .select('*')
        .eq('user_id', userId)
        .gte('taken_at', filters?.startDate || new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString())
        .lte('taken_at', filters?.endDate || new Date().toISOString())
        .order('taken_at', { ascending: false });

      if (listError) throw listError;
      return { success: true, data: medicationList };

    default:
      throw new Error(`Ação não suportada para medicação: ${action}`);
  }
}

async function handleSymptomsTracking(supabase: any, request: TrackingRequest): Promise<TrackingResponse> {
  const { action, data, userId, date, filters } = request;

  switch (action) {
    case 'create':
      const { error: createError } = await supabase
        .from('symptoms_tracking')
        .insert({
          user_id: userId,
          date: date || new Date().toISOString().split('T')[0],
          symptom_name: data.symptom_name,
          severity: data.severity,
          description: data.description,
          triggers: data.triggers || [],
          duration_hours: data.duration_hours
        });

      if (createError) throw createError;
      return { success: true, message: 'Sintoma registrado com sucesso!' };

    case 'list':
      const { data: symptomsList, error: listError } = await supabase
        .from('symptoms_tracking')
        .select('*')
        .eq('user_id', userId)
        .gte('date', filters?.startDate || new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0])
        .lte('date', filters?.endDate || new Date().toISOString().split('T')[0])
        .order('date', { ascending: false });

      if (listError) throw listError;
      return { success: true, data: symptomsList };

    default:
      throw new Error(`Ação não suportada para sintomas: ${action}`);
  }
}

async function handleHabitsTracking(supabase: any, request: TrackingRequest): Promise<TrackingResponse> {
  const { action, data, userId, filters } = request;

  switch (action) {
    case 'create':
      const { error: createError } = await supabase
        .from('custom_habits_tracking')
        .insert({
          user_id: userId,
          habit_name: data.habit_name,
          habit_category: data.habit_category || 'personal',
          target_frequency: data.target_frequency || 1,
          target_period: data.target_period || 'daily',
          completed_at: data.completed_at || new Date().toISOString(),
          completion_value: data.completion_value || 1,
          notes: data.notes
        });

      if (createError) throw createError;
      return { success: true, message: 'Hábito registrado com sucesso!' };

    case 'list':
      const { data: habitsList, error: listError } = await supabase
        .from('custom_habits_tracking')
        .select('*')
        .eq('user_id', userId)
        .gte('completed_at', filters?.startDate || new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString())
        .lte('completed_at', filters?.endDate || new Date().toISOString())
        .order('completed_at', { ascending: false });

      if (listError) throw listError;
      return { success: true, data: habitsList };

    default:
      throw new Error(`Ação não suportada para hábitos: ${action}`);
  }
}

async function handleGoalsTracking(supabase: any, request: TrackingRequest): Promise<TrackingResponse> {
  const { action, data, userId, filters } = request;

  switch (action) {
    case 'create':
      const { error: createError } = await supabase
        .from('health_goals')
        .insert({
          user_id: userId,
          goal_type: data.goal_type,
          goal_name: data.goal_name,
          target_value: data.target_value,
          target_unit: data.target_unit,
          target_period: data.target_period || 'daily',
          target_date: data.target_date,
          notes: data.notes
        });

      if (createError) throw createError;
      return { success: true, message: 'Meta criada com sucesso!' };

    case 'update':
      const { error: updateError } = await supabase
        .from('health_goals')
        .update({
          current_value: data.current_value,
          progress_percentage: data.progress_percentage,
          is_active: data.is_active,
          achieved_at: data.achieved_at,
          notes: data.notes,
          updated_at: new Date().toISOString()
        })
        .eq('id', data.id)
        .eq('user_id', userId);

      if (updateError) throw updateError;
      return { success: true, message: 'Meta atualizada com sucesso!' };

    case 'list':
      const { data: goalsList, error: listError } = await supabase
        .from('health_goals')
        .select('*')
        .eq('user_id', userId)
        .eq('is_active', filters?.active !== false)
        .order('created_at', { ascending: false });

      if (listError) throw listError;
      return { success: true, data: goalsList };

    default:
      throw new Error(`Ação não suportada para metas: ${action}`);
  }
}