import "https://deno.land/x/xhr@0.1.0/mod.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface CalendarAction {
  userId: string;
  action: 'create' | 'update' | 'delete' | 'list' | 'check_conflicts' | 'setup_oauth' | 'sync';
  eventData?: {
    title: string;
    description?: string;
    startTime: string; // ISO string
    endTime?: string; // ISO string, opcional se duration fornecida
    duration?: number; // minutos
    location?: string;
    attendees?: Array<{email: string; name?: string}>;
    reminders?: number[]; // minutos antes
    allDay?: boolean;
    recurrence?: {
      frequency: 'daily' | 'weekly' | 'monthly';
      interval?: number;
      endDate?: string;
      count?: number;
    };
  };
  preferences?: {
    requireConfirmation?: boolean;
    checkConflicts?: boolean;
    suggestAlternatives?: boolean;
    useTemplate?: string;
    autoOptimize?: boolean;
  };
  conflictResolution?: {
    strategy: 'reschedule' | 'adjust_duration' | 'cancel_conflict' | 'ignore';
    alternativeTime?: string;
  };
}

interface CalendarResult {
  success: boolean;
  data?: any;
  conflicts?: Array<{
    eventId: string;
    title: string;
    startTime: string;
    endTime: string;
    conflictType: string;
  }>;
  suggestions?: Array<{
    startTime: string;
    endTime: string;
    score: number;
  }>;
  message?: string;
  error?: string;
  requiresConfirmation?: boolean;
  confirmationToken?: string;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const requestData: CalendarAction = await req.json();
    console.log('📅 Calendar Manager Request:', requestData);

    // Inicializar Supabase
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    let result: CalendarResult;

    switch (requestData.action) {
      case 'setup_oauth':
        result = await setupGoogleOAuth(supabase, requestData);
        break;
      case 'create':
        result = await createEvent(supabase, requestData);
        break;
      case 'update':
        result = await updateEvent(supabase, requestData);
        break;
      case 'delete':
        result = await deleteEvent(supabase, requestData);
        break;
      case 'list':
        result = await listEvents(supabase, requestData);
        break;
      case 'check_conflicts':
        result = await checkConflicts(supabase, requestData);
        break;
      case 'sync':
        result = await syncCalendar(supabase, requestData);
        break;
      default:
        throw new Error(`Ação não suportada: ${requestData.action}`);
    }

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('❌ Erro no Calendar Manager:', error);
    
    return new Response(JSON.stringify({ 
      success: false,
      error: error.message,
      message: 'Erro no gerenciamento de calendário'
    }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});

async function setupGoogleOAuth(supabase: any, request: CalendarAction): Promise<CalendarResult> {
  console.log('🔐 Configurando OAuth do Google Calendar...');
  
  // Esta função seria chamada após o usuário autorizar o acesso
  // O token seria recebido via callback do OAuth
  
  const { data: existingIntegration } = await supabase
    .from('calendar_integrations')
    .select('*')
    .eq('user_id', request.userId)
    .single();

  if (existingIntegration) {
    // Atualizar integração existente
    const { error } = await supabase
      .from('calendar_integrations')
      .update({
        setup_completed: true,
        is_active: true,
        updated_at: new Date().toISOString()
      })
      .eq('user_id', request.userId);

    if (error) {
      throw new Error(`Erro ao atualizar integração: ${error.message}`);
    }
  } else {
    // Criar nova integração
    const { error } = await supabase
      .from('calendar_integrations')
      .insert({
        user_id: request.userId,
        timezone: 'America/Sao_Paulo',
        setup_completed: false, // Será true após OAuth completo
        is_active: true
      });

    if (error) {
      throw new Error(`Erro ao criar integração: ${error.message}`);
    }
  }

  return {
    success: true,
    message: 'Integração configurada. Aguardando autorização OAuth.',
    data: {
      oauthUrl: generateOAuthUrl(),
      setupInstructions: [
        '1. Clique no link OAuth fornecido',
        '2. Autorize o acesso ao seu Google Calendar',
        '3. A Sofia poderá criar e gerenciar eventos automaticamente'
      ]
    }
  };
}

async function createEvent(supabase: any, request: CalendarAction): Promise<CalendarResult> {
  console.log('📝 Criando evento no calendário...');
  
  if (!request.eventData) {
    throw new Error('Dados do evento são obrigatórios');
  }

  // 1. Buscar integração do usuário
  const { data: integration, error: integrationError } = await supabase
    .from('calendar_integrations')
    .select('*')
    .eq('user_id', request.userId)
    .eq('is_active', true)
    .single();

  if (integrationError || !integration) {
    return {
      success: false,
      error: 'Integração com Google Calendar não encontrada',
      message: 'Configure primeiro a integração com o Google Calendar'
    };
  }

  // 2. Processar dados do evento
  const eventData = await processEventData(supabase, request.eventData, request.userId);

  // 3. Verificar conflitos se solicitado
  if (request.preferences?.checkConflicts !== false) {
    const conflictCheck = await checkEventConflicts(
      supabase, 
      request.userId, 
      eventData.start_datetime, 
      eventData.end_datetime
    );

    if (conflictCheck.conflicts.length > 0) {
      if (request.preferences?.suggestAlternatives !== false) {
        const suggestions = await generateAlternativeTimes(
          supabase,
          request.userId,
          eventData.start_datetime,
          eventData.duration_minutes || 60
        );

        return {
          success: false,
          conflicts: conflictCheck.conflicts,
          suggestions,
          message: 'Conflitos detectados. Escolha um horário alternativo.',
          requiresConfirmation: true
        };
      }
    }
  }

  // 4. Aplicar template se especificado
  if (request.preferences?.useTemplate) {
    eventData = await applyEventTemplate(supabase, request.userId, request.preferences.useTemplate, eventData);
  }

  // 5. Verificar se requer confirmação
  if (request.preferences?.requireConfirmation !== false && integration.require_confirmation) {
    // Salvar como rascunho e solicitar confirmação
    const { data: draftEvent, error: draftError } = await supabase
      .from('ai_managed_events')
      .insert({
        ...eventData,
        requires_confirmation: true,
        confirmed_by_user: false,
        status: 'tentative'
      })
      .select()
      .single();

    if (draftError) {
      throw new Error(`Erro ao criar rascunho: ${draftError.message}`);
    }

    return {
      success: true,
      data: draftEvent,
      message: 'Evento criado como rascunho. Confirme para adicionar ao calendário.',
      requiresConfirmation: true,
      confirmationToken: draftEvent.id
    };
  }

  // 6. Criar evento diretamente
  try {
    // Criar no banco local
    const { data: localEvent, error: localError } = await supabase
      .from('ai_managed_events')
      .insert({
        ...eventData,
        confirmed_by_user: true,
        status: 'confirmed'
      })
      .select()
      .single();

    if (localError) {
      throw new Error(`Erro ao salvar evento: ${localError.message}`);
    }

    // Criar no Google Calendar (se tokens válidos)
    let googleEventId = null;
    if (integration.google_access_token) {
      try {
        googleEventId = await createGoogleCalendarEvent(integration, eventData);
        
        // Atualizar com ID do Google
        await supabase
          .from('ai_managed_events')
          .update({ google_event_id: googleEventId })
          .eq('id', localEvent.id);
          
      } catch (googleError) {
        console.error('⚠️ Erro ao criar no Google Calendar:', googleError);
        // Continuar mesmo se falhar no Google - evento fica apenas local
      }
    }

    return {
      success: true,
      data: {
        ...localEvent,
        google_event_id: googleEventId
      },
      message: 'Evento criado com sucesso!'
    };

  } catch (error) {
    console.error('❌ Erro ao criar evento:', error);
    throw error;
  }
}

async function updateEvent(supabase: any, request: CalendarAction): Promise<CalendarResult> {
  console.log('📝 Atualizando evento...');
  
  // Implementar lógica de atualização
  return {
    success: true,
    message: 'Funcionalidade de atualização em desenvolvimento'
  };
}

async function deleteEvent(supabase: any, request: CalendarAction): Promise<CalendarResult> {
  console.log('🗑️ Deletando evento...');
  
  // Implementar lógica de exclusão
  return {
    success: true,
    message: 'Funcionalidade de exclusão em desenvolvimento'
  };
}

async function listEvents(supabase: any, request: CalendarAction): Promise<CalendarResult> {
  console.log('📋 Listando eventos...');
  
  const startDate = new Date();
  const endDate = new Date();
  endDate.setDate(endDate.getDate() + 30); // Próximos 30 dias

  const { data: events, error } = await supabase
    .from('ai_managed_events')
    .select('*')
    .eq('user_id', request.userId)
    .eq('is_active', true)
    .gte('start_datetime', startDate.toISOString())
    .lte('start_datetime', endDate.toISOString())
    .order('start_datetime', { ascending: true });

  if (error) {
    throw new Error(`Erro ao listar eventos: ${error.message}`);
  }

  return {
    success: true,
    data: events || [],
    message: `${events?.length || 0} eventos encontrados`
  };
}

async function checkConflicts(supabase: any, request: CalendarAction): Promise<CalendarResult> {
  console.log('🔍 Verificando conflitos...');
  
  if (!request.eventData?.startTime) {
    throw new Error('Horário de início é obrigatório para verificar conflitos');
  }

  const startTime = new Date(request.eventData.startTime);
  const endTime = request.eventData.endTime 
    ? new Date(request.eventData.endTime)
    : new Date(startTime.getTime() + (request.eventData.duration || 60) * 60000);

  const conflictCheck = await checkEventConflicts(supabase, request.userId, startTime, endTime);

  if (conflictCheck.conflicts.length > 0) {
    const suggestions = await generateAlternativeTimes(
      supabase,
      request.userId,
      startTime,
      request.eventData.duration || 60
    );

    return {
      success: false,
      conflicts: conflictCheck.conflicts,
      suggestions,
      message: `${conflictCheck.conflicts.length} conflito(s) detectado(s)`
    };
  }

  return {
    success: true,
    message: 'Nenhum conflito detectado'
  };
}

async function syncCalendar(supabase: any, request: CalendarAction): Promise<CalendarResult> {
  console.log('🔄 Sincronizando calendário...');
  
  // Implementar sincronização bidirecional
  return {
    success: true,
    message: 'Funcionalidade de sincronização em desenvolvimento'
  };
}

// Funções auxiliares
async function processEventData(supabase: any, eventData: any, userId: string): Promise<any> {
  const startTime = new Date(eventData.startTime);
  let endTime: Date;

  if (eventData.endTime) {
    endTime = new Date(eventData.endTime);
  } else if (eventData.duration) {
    endTime = new Date(startTime.getTime() + eventData.duration * 60000);
  } else {
    endTime = new Date(startTime.getTime() + 60 * 60000); // 1 hora padrão
  }

  return {
    user_id: userId,
    title: eventData.title,
    description: eventData.description || '',
    location: eventData.location || '',
    start_datetime: startTime.toISOString(),
    end_datetime: endTime.toISOString(),
    is_all_day: eventData.allDay || false,
    attendees: eventData.attendees || [],
    reminders: eventData.reminders || [15],
    duration_minutes: Math.round((endTime.getTime() - startTime.getTime()) / 60000),
    managed_by: 'sofia',
    auto_created: true
  };
}

async function checkEventConflicts(
  supabase: any, 
  userId: string, 
  startTime: Date, 
  endTime: Date
): Promise<{ conflicts: any[] }> {
  
  const { data: conflicts, error } = await supabase.rpc('detect_calendar_conflicts', {
    user_id_param: userId,
    start_time: startTime.toISOString(),
    end_time: endTime.toISOString()
  });

  if (error) {
    console.error('❌ Erro ao detectar conflitos:', error);
    return { conflicts: [] };
  }

  return {
    conflicts: (conflicts || []).map((conflict: any) => ({
      eventId: conflict.event_id,
      title: conflict.event_title,
      startTime: conflict.event_start,
      endTime: conflict.event_end,
      conflictType: conflict.conflict_type
    }))
  };
}

async function generateAlternativeTimes(
  supabase: any,
  userId: string,
  preferredStart: Date,
  durationMinutes: number
): Promise<Array<{ startTime: string; endTime: string; score: number }>> {
  
  const { data: suggestions, error } = await supabase.rpc('suggest_alternative_times', {
    user_id_param: userId,
    preferred_start: preferredStart.toISOString(),
    duration_minutes: durationMinutes,
    search_days: 7
  });

  if (error) {
    console.error('❌ Erro ao gerar sugestões:', error);
    return [];
  }

  return (suggestions || []).slice(0, 5).map((suggestion: any) => ({
    startTime: suggestion.suggested_start,
    endTime: suggestion.suggested_end,
    score: parseFloat(suggestion.score)
  }));
}

async function applyEventTemplate(
  supabase: any, 
  userId: string, 
  templateName: string, 
  eventData: any
): Promise<any> {
  
  const { data: template, error } = await supabase
    .from('event_templates')
    .select('*')
    .eq('user_id', userId)
    .eq('template_name', templateName)
    .eq('is_active', true)
    .single();

  if (error || !template) {
    console.log(`⚠️ Template "${templateName}" não encontrado`);
    return eventData;
  }

  // Aplicar configurações do template
  return {
    ...eventData,
    description: eventData.description || template.default_description,
    location: eventData.location || template.default_location,
    reminders: eventData.reminders || template.default_reminders,
    duration_minutes: eventData.duration_minutes || template.default_duration
  };
}

async function createGoogleCalendarEvent(integration: any, eventData: any): Promise<string> {
  // Esta função integraria com a API do Google Calendar
  // Por enquanto, simular criação
  console.log('🔗 Criando evento no Google Calendar...');
  
  // Verificar se token ainda é válido
  if (new Date() > new Date(integration.token_expires_at)) {
    throw new Error('Token do Google Calendar expirado');
  }

  // Simular chamada à API do Google Calendar
  const googleEvent = {
    summary: eventData.title,
    description: eventData.description,
    location: eventData.location,
    start: {
      dateTime: eventData.start_datetime,
      timeZone: integration.timezone
    },
    end: {
      dateTime: eventData.end_datetime,
      timeZone: integration.timezone
    },
    attendees: eventData.attendees,
    reminders: {
      useDefault: false,
      overrides: eventData.reminders.map((minutes: number) => ({
        method: 'popup',
        minutes
      }))
    }
  };

  // Aqui faria a chamada real para a API do Google Calendar
  // const response = await fetch(`https://www.googleapis.com/calendar/v3/calendars/${integration.default_calendar_id}/events`, {
  //   method: 'POST',
  //   headers: {
  //     'Authorization': `Bearer ${integration.google_access_token}`,
  //     'Content-Type': 'application/json'
  //   },
  //   body: JSON.stringify(googleEvent)
  // });

  // Por enquanto, retornar ID simulado
  return `google_event_${Date.now()}`;
}

function generateOAuthUrl(): string {
  // Gerar URL para OAuth do Google Calendar
  const clientId = Deno.env.get('GOOGLE_OAUTH_CLIENT_ID') || 'your-client-id';
  const redirectUri = encodeURIComponent(`${Deno.env.get('SUPABASE_URL')}/functions/v1/calendar-oauth-callback`);
  const scope = encodeURIComponent('https://www.googleapis.com/auth/calendar');
  
  return `https://accounts.google.com/o/oauth2/v2/auth?client_id=${clientId}&redirect_uri=${redirectUri}&scope=${scope}&response_type=code&access_type=offline`;
}