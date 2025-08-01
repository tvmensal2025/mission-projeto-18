import "https://deno.land/x/xhr@0.1.0/mod.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface KnowledgeQuery {
  query: string;
  agentName: 'sofia' | 'dr_vital';
  userId: string;
  context: {
    userProfile?: any;
    conversationHistory?: any[];
    currentTopic?: string;
    urgencyLevel?: 'low' | 'medium' | 'high' | 'critical';
    sessionType?: string;
  };
  options?: {
    maxResults?: number;
    similarityThreshold?: number;
    categories?: string[];
    priorityBoost?: boolean;
  };
}

interface KnowledgeResult {
  id: string;
  title: string;
  content: string;
  category: string;
  priorityLevel: number;
  similarityScore: number;
  tags: string[];
  applicableAgents: string[];
  usageFrequency: number;
  effectivenessScore: number;
  contextualRelevance: number;
  shouldOverrideGeneral: boolean;
}

interface ProcessedKnowledgeResponse {
  relevantKnowledge: KnowledgeResult[];
  contextualPrompt: string;
  knowledgeInstructions: string;
  confidenceScore: number;
  fallbackToGeneral: boolean;
  usageAnalytics: {
    totalResults: number;
    highPriorityResults: number;
    averageSimilarity: number;
  };
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const requestData: KnowledgeQuery = await req.json();
    console.log('📚 Knowledge Retrieval Request:', requestData);

    // Inicializar Supabase
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Buscar conhecimento relevante
    const knowledgeResponse = await retrieveRelevantKnowledge(supabase, requestData);

    // Registrar uso para analytics
    await logKnowledgeUsage(supabase, requestData, knowledgeResponse.relevantKnowledge);

    return new Response(JSON.stringify(knowledgeResponse), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('❌ Erro no Knowledge Retrieval:', error);
    
    return new Response(JSON.stringify({ 
      error: error.message,
      details: 'Erro na recuperação de conhecimento',
      fallbackToGeneral: true
    }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});

async function retrieveRelevantKnowledge(
  supabase: any, 
  query: KnowledgeQuery
): Promise<ProcessedKnowledgeResponse> {
  console.log(`🔍 Buscando conhecimento para: "${query.query}" (${query.agentName})`);

  // 1. Gerar embedding da query
  const queryEmbedding = await generateEmbedding(query.query);
  
  // 2. Configurar parâmetros de busca
  const searchOptions = {
    maxResults: query.options?.maxResults || 10,
    similarityThreshold: query.options?.similarityThreshold || 0.7,
    categories: query.options?.categories,
    priorityBoost: query.options?.priorityBoost !== false
  };

  // 3. Buscar por similaridade semântica
  const semanticResults = await searchBySimilarity(
    supabase, 
    queryEmbedding, 
    query.agentName, 
    searchOptions
  );

  // 4. Buscar por palavras-chave (fallback)
  const keywordResults = await searchByKeywords(
    supabase, 
    query.query, 
    query.agentName, 
    searchOptions
  );

  // 5. Combinar e ranquear resultados
  const combinedResults = combineAndRankResults(
    semanticResults, 
    keywordResults, 
    query
  );

  // 6. Aplicar filtros contextuais
  const contextualResults = applyContextualFiltering(
    combinedResults, 
    query.context
  );

  // 7. Gerar resposta processada
  const response = await generateProcessedResponse(
    supabase,
    contextualResults, 
    query
  );

  return response;
}

async function generateEmbedding(text: string): Promise<number[]> {
  const OPENAI_API_KEY = Deno.env.get('OPENAI_API_KEY');
  
  if (!OPENAI_API_KEY) {
    console.log('⚠️ OpenAI API Key não encontrada, usando busca por palavras-chave');
    return [];
  }

  try {
    const response = await fetch('https://api.openai.com/v1/embeddings', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        input: text,
        model: 'text-embedding-3-small',
        dimensions: 1536
      }),
    });

    if (!response.ok) {
      throw new Error(`OpenAI API error: ${response.statusText}`);
    }

    const data = await response.json();
    return data.data[0].embedding;
    
  } catch (error) {
    console.error('❌ Erro ao gerar embedding:', error);
    return [];
  }
}

async function searchBySimilarity(
  supabase: any, 
  embedding: number[], 
  agentName: string, 
  options: any
): Promise<KnowledgeResult[]> {
  
  if (!embedding.length) {
    return [];
  }

  console.log('🔍 Buscando por similaridade semântica...');

  try {
    const { data, error } = await supabase.rpc('search_knowledge_by_similarity', {
      query_embedding: embedding,
      agent_filter: agentName,
      category_filter: options.categories?.[0] || null,
      similarity_threshold: options.similarityThreshold,
      max_results: options.maxResults
    });

    if (error) {
      console.error('❌ Erro na busca por similaridade:', error);
      return [];
    }

    console.log(`✅ Encontrados ${data?.length || 0} resultados por similaridade`);
    
    return (data || []).map((item: any) => ({
      id: item.id,
      title: item.title,
      content: item.content,
      category: item.category,
      priorityLevel: item.priority_level,
      similarityScore: parseFloat(item.similarity_score),
      tags: item.tags || [],
      applicableAgents: item.applicable_agents || [],
      usageFrequency: 0,
      effectivenessScore: 0.5,
      contextualRelevance: 1.0,
      shouldOverrideGeneral: true
    }));

  } catch (error) {
    console.error('❌ Erro na busca por similaridade:', error);
    return [];
  }
}

async function searchByKeywords(
  supabase: any, 
  query: string, 
  agentName: string, 
  options: any
): Promise<KnowledgeResult[]> {
  
  console.log('🔍 Buscando por palavras-chave...');

  // Extrair palavras-chave da query
  const keywords = extractKeywords(query);
  
  if (!keywords.length) {
    return [];
  }

  try {
    const { data, error } = await supabase
      .from('knowledge_base')
      .select(`
        id, title, content, category, priority_level, tags, 
        applicable_agents, usage_frequency, effectiveness_score
      `)
      .contains('applicable_agents', [agentName])
      .eq('is_active', true)
      .or(
        keywords.map(keyword => 
          `content.ilike.%${keyword}%,title.ilike.%${keyword}%,tags.cs.{${keyword}},keywords.cs.{${keyword}}`
        ).join(',')
      )
      .order('priority_level', { ascending: false })
      .limit(options.maxResults);

    if (error) {
      console.error('❌ Erro na busca por palavras-chave:', error);
      return [];
    }

    console.log(`✅ Encontrados ${data?.length || 0} resultados por palavras-chave`);

    return (data || []).map((item: any) => ({
      id: item.id,
      title: item.title,
      content: item.content,
      category: item.category,
      priorityLevel: item.priority_level,
      similarityScore: calculateKeywordSimilarity(query, item),
      tags: item.tags || [],
      applicableAgents: item.applicable_agents || [],
      usageFrequency: item.usage_frequency || 0,
      effectivenessScore: item.effectiveness_score || 0.5,
      contextualRelevance: 1.0,
      shouldOverrideGeneral: true
    }));

  } catch (error) {
    console.error('❌ Erro na busca por palavras-chave:', error);
    return [];
  }
}

function combineAndRankResults(
  semanticResults: KnowledgeResult[], 
  keywordResults: KnowledgeResult[], 
  query: KnowledgeQuery
): KnowledgeResult[] {
  
  console.log('🔀 Combinando e ranqueando resultados...');

  // Combinar resultados evitando duplicatas
  const combinedMap = new Map<string, KnowledgeResult>();
  
  // Adicionar resultados semânticos (prioridade)
  semanticResults.forEach(result => {
    combinedMap.set(result.id, {
      ...result,
      contextualRelevance: result.similarityScore * 1.2 // Boost para similaridade semântica
    });
  });
  
  // Adicionar resultados por palavras-chave
  keywordResults.forEach(result => {
    if (combinedMap.has(result.id)) {
      // Se já existe, combinar scores
      const existing = combinedMap.get(result.id)!;
      existing.similarityScore = Math.max(existing.similarityScore, result.similarityScore);
      existing.contextualRelevance += 0.5; // Boost por aparecer em ambas as buscas
    } else {
      combinedMap.set(result.id, result);
    }
  });

  // Converter para array e aplicar ranking
  const results = Array.from(combinedMap.values());
  
  // Calcular score final considerando múltiplos fatores
  results.forEach(result => {
    result.contextualRelevance = calculateFinalScore(result, query);
  });

  // Ordenar por relevância contextual
  results.sort((a, b) => b.contextualRelevance - a.contextualRelevance);

  console.log(`✅ ${results.length} resultados combinados e ranqueados`);
  return results;
}

function applyContextualFiltering(
  results: KnowledgeResult[], 
  context: KnowledgeQuery['context']
): KnowledgeResult[] {
  
  if (!context) return results;

  console.log('🎯 Aplicando filtros contextuais...');

  return results.map(result => {
    let relevanceBoost = 1.0;

    // Boost baseado no tópico atual
    if (context.currentTopic) {
      const topicRelevance = calculateTopicRelevance(result, context.currentTopic);
      relevanceBoost *= (1 + topicRelevance * 0.3);
    }

    // Boost baseado no nível de urgência
    if (context.urgencyLevel) {
      const urgencyBoost = getUrgencyBoost(result, context.urgencyLevel);
      relevanceBoost *= urgencyBoost;
    }

    // Boost baseado no perfil do usuário
    if (context.userProfile) {
      const profileRelevance = calculateProfileRelevance(result, context.userProfile);
      relevanceBoost *= (1 + profileRelevance * 0.2);
    }

    return {
      ...result,
      contextualRelevance: result.contextualRelevance * relevanceBoost
    };
  }).sort((a, b) => b.contextualRelevance - a.contextualRelevance);
}

async function generateProcessedResponse(
  supabase: any,
  results: KnowledgeResult[], 
  query: KnowledgeQuery
): Promise<ProcessedKnowledgeResponse> {
  
  console.log('📝 Gerando resposta processada...');

  // Filtrar apenas os mais relevantes
  const topResults = results.slice(0, query.options?.maxResults || 5);
  
  // Calcular métricas
  const totalResults = results.length;
  const highPriorityResults = results.filter(r => r.priorityLevel >= 8).length;
  const averageSimilarity = results.length > 0 
    ? results.reduce((sum, r) => sum + r.similarityScore, 0) / results.length 
    : 0;

  // Gerar prompt contextual
  const contextualPrompt = generateContextualPrompt(topResults, query);
  
  // Gerar instruções de conhecimento
  const knowledgeInstructions = generateKnowledgeInstructions(topResults, query.agentName);
  
  // Calcular confiança
  const confidenceScore = calculateConfidenceScore(topResults);
  
  // Determinar se deve usar conhecimento geral como fallback
  const fallbackToGeneral = confidenceScore < 0.6 || topResults.length === 0;

  return {
    relevantKnowledge: topResults,
    contextualPrompt,
    knowledgeInstructions,
    confidenceScore,
    fallbackToGeneral,
    usageAnalytics: {
      totalResults,
      highPriorityResults,
      averageSimilarity
    }
  };
}

function generateContextualPrompt(results: KnowledgeResult[], query: KnowledgeQuery): string {
  if (!results.length) {
    return 'Nenhum conhecimento específico encontrado. Use seu conhecimento geral.';
  }

  let prompt = 'CONHECIMENTO ESPECÍFICO RELEVANTE:\n\n';
  
  results.forEach((result, index) => {
    prompt += `${index + 1}. ${result.title} (Prioridade: ${result.priorityLevel}, Similaridade: ${result.similarityScore.toFixed(2)})\n`;
    prompt += `Categoria: ${result.category}\n`;
    prompt += `Conteúdo: ${result.content.substring(0, 500)}${result.content.length > 500 ? '...' : ''}\n\n`;
  });

  prompt += 'INSTRUÇÕES:\n';
  prompt += '- Use PRIORITARIAMENTE as informações acima\n';
  prompt += '- Este conhecimento substitui informações gerais quando houver conflito\n';
  prompt += '- Combine com seu conhecimento geral apenas quando complementar\n';
  prompt += '- Mantenha a personalidade definida para seu agente\n\n';

  return prompt;
}

function generateKnowledgeInstructions(results: KnowledgeResult[], agentName: string): string {
  if (!results.length) {
    return 'Use conhecimento geral padrão.';
  }

  const protocolResults = results.filter(r => r.category === 'protocols');
  const guidelineResults = results.filter(r => r.category === 'guidelines');
  
  let instructions = 'INSTRUÇÕES DE CONHECIMENTO:\n\n';
  
  if (protocolResults.length > 0) {
    instructions += 'PROTOCOLOS A SEGUIR:\n';
    protocolResults.forEach(result => {
      instructions += `- ${result.title}: Seguir rigorosamente as diretrizes especificadas\n`;
    });
    instructions += '\n';
  }
  
  if (guidelineResults.length > 0) {
    instructions += 'DIRETRIZES DE SEGURANÇA:\n';
    guidelineResults.forEach(result => {
      instructions += `- ${result.title}: Aplicar todas as restrições mencionadas\n`;
    });
    instructions += '\n';
  }

  instructions += `Como ${agentName === 'sofia' ? 'Sofia' : 'Dr. Vital'}, você deve:\n`;
  instructions += '- Priorizar o conhecimento específico fornecido\n';
  instructions += '- Seguir todos os protocolos e diretrizes\n';
  instructions += '- Manter sua personalidade característica\n';
  instructions += '- Indicar quando o conhecimento tem limitações\n';

  return instructions;
}

// Funções auxiliares
function extractKeywords(query: string): string[] {
  // Remover palavras comuns (stop words) em português
  const stopWords = new Set([
    'a', 'o', 'e', 'de', 'do', 'da', 'em', 'um', 'uma', 'com', 'não', 'que', 'se', 'na', 'por', 'mais', 'para', 'como', 'mas', 'foi', 'ao', 'ele', 'das', 'tem', 'à', 'seu', 'sua', 'ou', 'ser', 'quando', 'muito', 'há', 'nos', 'já', 'está', 'eu', 'também', 'só', 'pelo', 'pela', 'até', 'isso', 'ela', 'entre', 'era', 'depois', 'sem', 'mesmo', 'aos', 'ter', 'seus', 'suas', 'numa', 'pelos', 'pelas', 'essa', 'esse', 'assim', 'onde', 'bem', 'são', 'dos', 'como', 'mas', 'foi', 'ao', 'ele', 'das', 'tem', 'à', 'seu', 'sua', 'ou', 'quando', 'muito', 'nos', 'já', 'está', 'também', 'só', 'pelo', 'pela', 'até', 'isso', 'ela', 'entre', 'depois', 'sem', 'mesmo', 'numa', 'pelos', 'pelas', 'essa', 'esse', 'assim', 'onde', 'bem', 'são', 'dos'
  ]);

  return query
    .toLowerCase()
    .replace(/[^\w\s]/g, ' ')
    .split(/\s+/)
    .filter(word => word.length > 2 && !stopWords.has(word))
    .slice(0, 10); // Limitar a 10 palavras-chave
}

function calculateKeywordSimilarity(query: string, item: any): number {
  const queryKeywords = extractKeywords(query);
  const itemText = `${item.title} ${item.content}`.toLowerCase();
  
  let matches = 0;
  queryKeywords.forEach(keyword => {
    if (itemText.includes(keyword)) {
      matches++;
    }
  });
  
  return queryKeywords.length > 0 ? matches / queryKeywords.length : 0;
}

function calculateFinalScore(result: KnowledgeResult, query: KnowledgeQuery): number {
  let score = result.similarityScore * 0.4; // 40% similaridade
  score += (result.priorityLevel / 10) * 0.3; // 30% prioridade
  score += result.effectivenessScore * 0.2; // 20% efetividade histórica
  score += (result.usageFrequency > 0 ? Math.min(result.usageFrequency / 100, 1) : 0) * 0.1; // 10% frequência de uso
  
  return Math.min(score, 1.0);
}

function calculateTopicRelevance(result: KnowledgeResult, topic: string): number {
  const topicLower = topic.toLowerCase();
  const contentLower = `${result.title} ${result.content}`.toLowerCase();
  const tagsLower = result.tags.join(' ').toLowerCase();
  
  let relevance = 0;
  
  if (contentLower.includes(topicLower)) relevance += 0.5;
  if (tagsLower.includes(topicLower)) relevance += 0.3;
  if (result.category.toLowerCase().includes(topicLower)) relevance += 0.2;
  
  return Math.min(relevance, 1.0);
}

function getUrgencyBoost(result: KnowledgeResult, urgencyLevel: string): number {
  const urgencyBoosts = {
    'low': 1.0,
    'medium': 1.1,
    'high': 1.3,
    'critical': 1.5
  };
  
  // Protocolos e diretrizes têm boost maior em situações urgentes
  if ((result.category === 'protocols' || result.category === 'guidelines') && urgencyLevel !== 'low') {
    return urgencyBoosts[urgencyLevel] * 1.2;
  }
  
  return urgencyBoosts[urgencyLevel] || 1.0;
}

function calculateProfileRelevance(result: KnowledgeResult, profile: any): number {
  // Implementar lógica baseada no perfil do usuário
  // Por exemplo, se o usuário tem diabetes, dar boost para conteúdo relacionado
  let relevance = 0;
  
  if (profile.health_conditions) {
    const conditions = profile.health_conditions.join(' ').toLowerCase();
    const contentLower = `${result.title} ${result.content}`.toLowerCase();
    
    if (conditions.includes('diabetes') && contentLower.includes('diabetes')) relevance += 0.3;
    if (conditions.includes('hipertensão') && contentLower.includes('pressão')) relevance += 0.3;
    // Adicionar mais condições conforme necessário
  }
  
  return Math.min(relevance, 1.0);
}

function calculateConfidenceScore(results: KnowledgeResult[]): number {
  if (!results.length) return 0;
  
  const avgSimilarity = results.reduce((sum, r) => sum + r.similarityScore, 0) / results.length;
  const avgPriority = results.reduce((sum, r) => sum + r.priorityLevel, 0) / results.length / 10;
  const hasHighPriority = results.some(r => r.priorityLevel >= 8) ? 0.2 : 0;
  
  return Math.min(avgSimilarity * 0.5 + avgPriority * 0.3 + hasHighPriority, 1.0);
}

async function logKnowledgeUsage(
  supabase: any, 
  query: KnowledgeQuery, 
  results: KnowledgeResult[]
): Promise<void> {
  
  if (!results.length) return;

  try {
    const usageLogs = results.map(result => ({
      knowledge_id: result.id,
      user_id: query.userId,
      agent_name: query.agentName,
      query_text: query.query,
      similarity_score: result.similarityScore,
      conversation_context: query.context || {},
      used_at: new Date().toISOString()
    }));

    await supabase
      .from('knowledge_usage_log')
      .insert(usageLogs);

    // Atualizar estatísticas de uso
    for (const result of results) {
      await supabase.rpc('update_knowledge_usage_stats', {
        knowledge_item_id: result.id
      });
    }

    console.log(`📊 Registrado uso de ${results.length} itens de conhecimento`);
    
  } catch (error) {
    console.error('⚠️ Erro ao registrar uso do conhecimento:', error);
    // Não falhar a requisição por erro de logging
  }
}