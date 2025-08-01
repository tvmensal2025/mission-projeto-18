import "https://deno.land/x/xhr@0.1.0/mod.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface PersonalityRequest {
  userId: string;
  agentName: 'sofia' | 'dr_vital';
  action: 'get' | 'update' | 'adapt';
  context?: {
    timeOfDay?: 'morning' | 'afternoon' | 'evening';
    userMood?: string;
    recentInteractions?: any[];
    conversationTopic?: string;
    userFeedback?: {
      satisfaction: number; // 0-1
      feedback_type: 'positive' | 'negative' | 'neutral';
      specific_comment?: string;
    };
  };
  personalityUpdates?: Partial<PersonalityConfig>;
}

interface PersonalityConfig {
  id: string;
  userId: string;
  agentName: string;
  
  // Personalidade Base
  tone: string;
  communicationStyle: string;
  emotionalIntelligence: number;
  energyLevel: string;
  
  // Contexto Comportamental
  rolePreference: string;
  responseLength: string;
  useEmojis: boolean;
  formalityLevel: number;
  
  // Especialização
  focusAreas: string[];
  expertiseLevel: string;
  
  // Adaptação Temporal
  morningPersonality: any;
  afternoonPersonality: any;
  eveningPersonality: any;
  
  // Configurações Avançadas
  contextMemoryDepth: number;
  proactivityLevel: number;
  learningRate: number;
  
  // Preferências
  preferredLanguage: string;
  culturalContext: string;
  humorLevel: number;
  
  // Configurações Específicas
  agentSpecificConfig: any;
}

interface AdaptivePersonalityResult {
  basePersonality: PersonalityConfig;
  adaptedPersonality: PersonalityConfig;
  adaptationReasons: string[];
  contextualPrompts: {
    systemPrompt: string;
    personalityInstructions: string;
    contextualGuidance: string;
  };
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const requestData: PersonalityRequest = await req.json();
    console.log('🧠 Personality Manager Request:', requestData);

    // Inicializar Supabase
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    let result: any;

    switch (requestData.action) {
      case 'get':
        result = await getPersonality(supabase, requestData);
        break;
      case 'update':
        result = await updatePersonality(supabase, requestData);
        break;
      case 'adapt':
        result = await adaptPersonality(supabase, requestData);
        break;
      default:
        throw new Error(`Ação não suportada: ${requestData.action}`);
    }

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('❌ Erro no Personality Manager:', error);
    
    return new Response(JSON.stringify({ 
      error: error.message,
      details: 'Erro no gerenciamento de personalidade'
    }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});

async function getPersonality(supabase: any, request: PersonalityRequest): Promise<AdaptivePersonalityResult> {
  console.log(`🔍 Buscando personalidade: ${request.agentName} para usuário ${request.userId}`);
  
  // Buscar personalidade base
  const { data: personality, error } = await supabase
    .from('ai_personalities')
    .select('*')
    .eq('user_id', request.userId)
    .eq('agent_name', request.agentName)
    .eq('is_active', true)
    .single();

  if (error || !personality) {
    console.log('⚠️ Personalidade não encontrada, criando padrão...');
    return await createDefaultPersonality(supabase, request);
  }

  // Aplicar adaptações contextuais
  const adaptedPersonality = await applyContextualAdaptations(personality, request.context);
  
  // Gerar prompts contextuais
  const contextualPrompts = generateContextualPrompts(adaptedPersonality, request.context);

  return {
    basePersonality: personality,
    adaptedPersonality,
    adaptationReasons: getAdaptationReasons(personality, adaptedPersonality, request.context),
    contextualPrompts
  };
}

async function updatePersonality(supabase: any, request: PersonalityRequest): Promise<{ success: boolean; personality: PersonalityConfig }> {
  console.log(`📝 Atualizando personalidade: ${request.agentName}`);
  
  if (!request.personalityUpdates) {
    throw new Error('personalityUpdates é obrigatório para ação update');
  }

  // Converter camelCase para snake_case para o banco
  const dbUpdates = convertToSnakeCase(request.personalityUpdates);
  dbUpdates.updated_at = new Date().toISOString();

  const { data, error } = await supabase
    .from('ai_personalities')
    .update(dbUpdates)
    .eq('user_id', request.userId)
    .eq('agent_name', request.agentName)
    .select()
    .single();

  if (error) {
    throw new Error(`Erro ao atualizar personalidade: ${error.message}`);
  }

  console.log('✅ Personalidade atualizada com sucesso');
  
  return {
    success: true,
    personality: convertToCamelCase(data)
  };
}

async function adaptPersonality(supabase: any, request: PersonalityRequest): Promise<AdaptivePersonalityResult> {
  console.log(`🔄 Adaptando personalidade baseada no contexto...`);
  
  // Buscar personalidade atual
  const currentResult = await getPersonality(supabase, request);
  
  if (!request.context) {
    return currentResult;
  }

  // Aplicar aprendizado baseado em feedback
  if (request.context.userFeedback) {
    await applyFeedbackLearning(supabase, currentResult.basePersonality, request.context.userFeedback);
  }

  // Registrar adaptação
  await logPersonalityAdaptation(supabase, currentResult.basePersonality.id, request.context);

  return currentResult;
}

async function createDefaultPersonality(supabase: any, request: PersonalityRequest): Promise<AdaptivePersonalityResult> {
  console.log(`🆕 Criando personalidade padrão para ${request.agentName}`);
  
  const defaultConfig = getDefaultPersonalityConfig(request.agentName);
  
  const { data, error } = await supabase
    .from('ai_personalities')
    .insert({
      user_id: request.userId,
      agent_name: request.agentName,
      ...defaultConfig
    })
    .select()
    .single();

  if (error) {
    throw new Error(`Erro ao criar personalidade padrão: ${error.message}`);
  }

  const personality = convertToCamelCase(data);
  const adaptedPersonality = await applyContextualAdaptations(personality, request.context);
  const contextualPrompts = generateContextualPrompts(adaptedPersonality, request.context);

  return {
    basePersonality: personality,
    adaptedPersonality,
    adaptationReasons: ['Personalidade padrão criada'],
    contextualPrompts
  };
}

async function applyContextualAdaptations(personality: PersonalityConfig, context?: any): Promise<PersonalityConfig> {
  if (!context) return personality;

  const adapted = { ...personality };
  const adaptations: string[] = [];

  // Adaptação por horário do dia
  if (context.timeOfDay) {
    const timeConfig = personality[`${context.timeOfDay}Personality`] || {};
    
    if (timeConfig.energy_boost) {
      adapted.energyLevel = adjustEnergyLevel(personality.energyLevel, timeConfig.energy_boost);
      adaptations.push(`Energia ajustada para ${context.timeOfDay}`);
    }
    
    if (timeConfig.focus_areas) {
      adapted.focusAreas = [...new Set([...personality.focusAreas, ...timeConfig.focus_areas])];
      adaptations.push(`Foco ajustado para ${context.timeOfDay}`);
    }
  }

  // Adaptação baseada no humor do usuário
  if (context.userMood) {
    adapted.emotionalIntelligence = Math.min(1.0, personality.emotionalIntelligence + 0.1);
    adapted.tone = adaptToneToMood(personality.tone, context.userMood);
    adaptations.push(`Tom adaptado ao humor: ${context.userMood}`);
  }

  // Adaptação baseada no tópico da conversa
  if (context.conversationTopic) {
    adapted.focusAreas = prioritizeFocusAreas(personality.focusAreas, context.conversationTopic);
    adaptations.push(`Foco priorizado para: ${context.conversationTopic}`);
  }

  return adapted;
}

function generateContextualPrompts(personality: PersonalityConfig, context?: any): any {
  const basePrompt = generateBasePersonalityPrompt(personality);
  const contextualGuidance = generateContextualGuidance(context);
  
  return {
    systemPrompt: `${basePrompt}\n\n${contextualGuidance}`,
    personalityInstructions: generatePersonalityInstructions(personality),
    contextualGuidance
  };
}

function generateBasePersonalityPrompt(personality: PersonalityConfig): string {
  const agentName = personality.agentName === 'sofia' ? 'Sofia' : 'Dr. Vital';
  
  let prompt = `Você é ${agentName}, um assistente de saúde e bem-estar com as seguintes características:\n\n`;
  
  prompt += `PERSONALIDADE:\n`;
  prompt += `- Tom: ${personality.tone} (${getPersonalityDescription(personality.tone)})\n`;
  prompt += `- Estilo de comunicação: ${personality.communicationStyle}\n`;
  prompt += `- Inteligência emocional: ${Math.round(personality.emotionalIntelligence * 100)}%\n`;
  prompt += `- Nível de energia: ${personality.energyLevel}\n`;
  prompt += `- Papel preferido: ${personality.rolePreference}\n`;
  prompt += `- Nível de formalidade: ${Math.round(personality.formalityLevel * 100)}%\n`;
  prompt += `- Usar emojis: ${personality.useEmojis ? 'Sim' : 'Não'}\n`;
  prompt += `- Nível de humor: ${Math.round(personality.humorLevel * 100)}%\n\n`;
  
  prompt += `ESPECIALIZAÇÃO:\n`;
  prompt += `- Áreas de foco: ${personality.focusAreas.join(', ')}\n`;
  prompt += `- Nível de expertise: ${personality.expertiseLevel}\n\n`;
  
  prompt += `CONFIGURAÇÕES:\n`;
  prompt += `- Tamanho de resposta: ${personality.responseLength}\n`;
  prompt += `- Profundidade de contexto: ${personality.contextMemoryDepth} conversas\n`;
  prompt += `- Nível de proatividade: ${Math.round(personality.proactivityLevel * 100)}%\n`;
  prompt += `- Idioma preferido: ${personality.preferredLanguage}\n`;
  prompt += `- Contexto cultural: ${personality.culturalContext}\n\n`;

  // Adicionar configurações específicas do agente
  if (personality.agentSpecificConfig) {
    prompt += `CONFIGURAÇÕES ESPECÍFICAS:\n`;
    prompt += JSON.stringify(personality.agentSpecificConfig, null, 2) + '\n\n';
  }

  return prompt;
}

function generatePersonalityInstructions(personality: PersonalityConfig): string {
  let instructions = 'INSTRUÇÕES COMPORTAMENTAIS:\n\n';
  
  if (personality.agentName === 'sofia') {
    instructions += `Como Sofia, você deve:\n`;
    instructions += `- Ser calorosa, empática e motivacional\n`;
    instructions += `- Usar linguagem acessível e amigável\n`;
    instructions += `- Focar no bem-estar emocional e físico\n`;
    instructions += `- Ser encorajadora mesmo quando há pontos a melhorar\n`;
    instructions += `- Usar expressões brasileiras quando apropriado\n`;
    instructions += `- Fazer perguntas de acompanhamento para entender melhor\n`;
  } else {
    instructions += `Como Dr. Vital, você deve:\n`;
    instructions += `- Ser preciso, objetivo e baseado em evidências\n`;
    instructions += `- Focar em análise médica e prevenção\n`;
    instructions += `- Usar terminologia técnica quando necessário, mas explicar\n`;
    instructions += `- Priorizar segurança e recomendações claras\n`;
    instructions += `- Manter tom profissional mas empático\n`;
    instructions += `- Basear recomendações em dados e padrões\n`;
  }
  
  return instructions;
}

function generateContextualGuidance(context?: any): string {
  if (!context) return '';
  
  let guidance = 'CONTEXTO ATUAL:\n';
  
  if (context.timeOfDay) {
    guidance += `- Horário: ${context.timeOfDay}\n`;
    guidance += getTimeOfDayGuidance(context.timeOfDay);
  }
  
  if (context.userMood) {
    guidance += `- Humor do usuário: ${context.userMood}\n`;
    guidance += getMoodGuidance(context.userMood);
  }
  
  if (context.conversationTopic) {
    guidance += `- Tópico da conversa: ${context.conversationTopic}\n`;
    guidance += getTopicGuidance(context.conversationTopic);
  }
  
  return guidance;
}

// Funções auxiliares
function getDefaultPersonalityConfig(agentName: string): any {
  if (agentName === 'sofia') {
    return {
      tone: 'warm',
      communication_style: 'supportive',
      emotional_intelligence: 0.9,
      energy_level: 'dynamic',
      role_preference: 'friend',
      response_length: 'medium',
      use_emojis: true,
      formality_level: 0.3,
      focus_areas: ['nutrition', 'mental_health', 'habits', 'motivation'],
      expertise_level: 'specialized',
      context_memory_depth: 10,
      proactivity_level: 0.7,
      learning_rate: 0.1,
      preferred_language: 'pt-BR',
      cultural_context: 'brazilian',
      humor_level: 0.7
    };
  } else {
    return {
      tone: 'professional',
      communication_style: 'analytical',
      emotional_intelligence: 0.7,
      energy_level: 'balanced',
      role_preference: 'advisor',
      response_length: 'long',
      use_emojis: false,
      formality_level: 0.8,
      focus_areas: ['medical_analysis', 'preventive_health', 'data_interpretation'],
      expertise_level: 'expert',
      context_memory_depth: 15,
      proactivity_level: 0.6,
      learning_rate: 0.05,
      preferred_language: 'pt-BR',
      cultural_context: 'brazilian',
      humor_level: 0.3
    };
  }
}

function getPersonalityDescription(tone: string): string {
  const descriptions = {
    'warm': 'caloroso e acolhedor',
    'friendly': 'amigável e acessível',
    'professional': 'profissional e competente',
    'casual': 'descontraído e informal',
    'energetic': 'energético e entusiasmado',
    'analytical': 'analítico e objetivo'
  };
  return descriptions[tone] || tone;
}

function adjustEnergyLevel(currentLevel: string, boost: number): string {
  const levels = ['low', 'balanced', 'high', 'dynamic'];
  const currentIndex = levels.indexOf(currentLevel);
  const newIndex = Math.max(0, Math.min(levels.length - 1, currentIndex + Math.round(boost * 2)));
  return levels[newIndex];
}

function adaptToneToMood(currentTone: string, mood: string): string {
  const moodAdaptations = {
    'sad': 'warm',
    'stressed': 'supportive',
    'excited': 'energetic',
    'tired': 'gentle',
    'anxious': 'calming'
  };
  return moodAdaptations[mood] || currentTone;
}

function prioritizeFocusAreas(areas: string[], topic: string): string[] {
  const topicMappings = {
    'nutrition': ['nutrition', 'food_analysis', 'meal_planning'],
    'exercise': ['fitness', 'exercise', 'physical_activity'],
    'mental_health': ['mental_health', 'stress', 'emotional_wellbeing'],
    'weight': ['weight_management', 'body_composition', 'metabolism']
  };
  
  const priorityAreas = topicMappings[topic] || [topic];
  const reorderedAreas = [...priorityAreas];
  
  areas.forEach(area => {
    if (!reorderedAreas.includes(area)) {
      reorderedAreas.push(area);
    }
  });
  
  return reorderedAreas;
}

function getTimeOfDayGuidance(timeOfDay: string): string {
  const guidance = {
    'morning': '- Foque em energia, motivação e planejamento do dia\n- Seja mais entusiasmado e inspirador\n',
    'afternoon': '- Mantenha tom equilibrado e produtivo\n- Foque em progresso e ajustes\n',
    'evening': '- Use tom mais calmo e reflexivo\n- Foque em relaxamento e preparação para amanhã\n'
  };
  return guidance[timeOfDay] || '';
}

function getMoodGuidance(mood: string): string {
  const guidance = {
    'sad': '- Use tom mais empático e acolhedor\n- Ofereça apoio emocional\n',
    'stressed': '- Seja mais calmo e tranquilizador\n- Foque em soluções práticas\n',
    'excited': '- Combine a energia do usuário\n- Canalize o entusiasmo positivamente\n',
    'tired': '- Use tom mais suave e compreensivo\n- Sugira descanso quando apropriado\n'
  };
  return guidance[mood] || '';
}

function getTopicGuidance(topic: string): string {
  const guidance = {
    'nutrition': '- Foque em educação nutricional\n- Use linguagem acessível para conceitos técnicos\n',
    'exercise': '- Seja motivacional mas realista\n- Considere limitações físicas\n',
    'mental_health': '- Seja extra empático e cuidadoso\n- Sugira recursos profissionais quando necessário\n'
  };
  return guidance[topic] || '';
}

function getAdaptationReasons(base: PersonalityConfig, adapted: PersonalityConfig, context?: any): string[] {
  const reasons: string[] = [];
  
  if (base.tone !== adapted.tone) {
    reasons.push(`Tom ajustado de ${base.tone} para ${adapted.tone}`);
  }
  
  if (base.energyLevel !== adapted.energyLevel) {
    reasons.push(`Energia ajustada de ${base.energyLevel} para ${adapted.energyLevel}`);
  }
  
  if (JSON.stringify(base.focusAreas) !== JSON.stringify(adapted.focusAreas)) {
    reasons.push('Áreas de foco reordenadas baseadas no contexto');
  }
  
  if (context?.timeOfDay) {
    reasons.push(`Adaptação para período: ${context.timeOfDay}`);
  }
  
  if (context?.userMood) {
    reasons.push(`Adaptação para humor: ${context.userMood}`);
  }
  
  return reasons;
}

async function applyFeedbackLearning(supabase: any, personality: PersonalityConfig, feedback: any): Promise<void> {
  console.log('📚 Aplicando aprendizado baseado em feedback...');
  
  // Calcular ajustes baseados no feedback
  const adjustments: any = {};
  
  if (feedback.satisfaction < 0.5) {
    // Feedback negativo - ajustar personalidade
    if (feedback.feedback_type === 'negative') {
      adjustments.learning_rate = Math.min(1.0, personality.learningRate * 1.1);
      
      // Ajustar baseado no comentário específico se disponível
      if (feedback.specific_comment) {
        if (feedback.specific_comment.includes('formal')) {
          adjustments.formality_level = Math.max(0.0, personality.formalityLevel - 0.1);
        }
        if (feedback.specific_comment.includes('informal')) {
          adjustments.formality_level = Math.min(1.0, personality.formalityLevel + 0.1);
        }
      }
    }
  } else if (feedback.satisfaction > 0.8) {
    // Feedback positivo - reforçar configuração atual
    adjustments.learning_rate = Math.max(0.01, personality.learningRate * 0.95);
  }
  
  if (Object.keys(adjustments).length > 0) {
    await supabase
      .from('ai_personalities')
      .update({
        ...adjustments,
        updated_at: new Date().toISOString()
      })
      .eq('id', personality.id);
    
    console.log('✅ Personalidade ajustada baseada no feedback');
  }
}

async function logPersonalityAdaptation(supabase: any, personalityId: string, context: any): Promise<void> {
  await supabase
    .from('personality_adaptations')
    .insert({
      personality_id: personalityId,
      adaptation_trigger: 'context_based',
      context_data: context,
      applied_at: new Date().toISOString()
    });
}

function convertToSnakeCase(obj: any): any {
  const converted: any = {};
  for (const [key, value] of Object.entries(obj)) {
    const snakeKey = key.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`);
    converted[snakeKey] = value;
  }
  return converted;
}

function convertToCamelCase(obj: any): any {
  const converted: any = {};
  for (const [key, value] of Object.entries(obj)) {
    const camelKey = key.replace(/_([a-z])/g, (match, letter) => letter.toUpperCase());
    converted[camelKey] = value;
  }
  return converted;
}