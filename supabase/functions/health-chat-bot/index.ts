import "https://deno.land/x/xhr@0.1.0/mod.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { message, userId, conversationHistory = [], imageUrl } = await req.json();
    
    console.log('📨 Mensagem recebida:', message);
    console.log('👤 Usuário:', userId);
    console.log('📸 Imagem URL:', imageUrl);

    // Configurar Supabase
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Configurar chaves de API
    const GOOGLE_AI_API_KEY = Deno.env.get('GOOGLE_AI_API_KEY');
    console.log('🔑 Google AI (Gemini):', GOOGLE_AI_API_KEY ? '✅ Configurada' : '❌ Não encontrada');

    // 🔍 Buscar dados do usuário
    console.log('👤 Buscando dados do usuário...');
    let userProfile = null;
    let userSummary = {
      name: 'Usuário',
      currentWeight: 'N/A',
      weightTrend: 0,
      streak: 0,
      missionsCompleted: 0
    };

    try {
      // Buscar perfil do usuário
      const { data: profile } = await supabase
        .from('profiles')
        .select('*')
        .eq('user_id', userId)
        .single();
      
      if (profile) {
        userProfile = profile;
        userSummary.name = profile.full_name || 'Usuário';
        console.log('👤 Perfil encontrado:', profile.full_name);
      }

      // Buscar último peso
      const { data: weightData } = await supabase
        .from('weight_measurements')
        .select('peso_kg')
        .eq('user_id', userId)
        .order('measurement_date', { ascending: false })
        .limit(1)
        .single();
      
      if (weightData) {
        userSummary.currentWeight = `${weightData.peso_kg}kg`;
        console.log('⚖️ Peso atual:', weightData.peso_kg);
      }

      // Buscar streak de missões
      const { data: streakData } = await supabase
        .from('daily_mission_sessions')
        .select('streak_days')
        .eq('user_id', userId)
        .order('date', { ascending: false })
        .limit(1)
        .single();
      
      if (streakData) {
        userSummary.streak = streakData.streak_days || 0;
        console.log('🔥 Streak atual:', streakData.streak_days);
      }

    } catch (error) {
      console.log('⚠️ Erro ao buscar dados do usuário:', error.message);
    }

    // 🔍 Análise de imagem (se houver)
    let foodAnalysis = null;
    let isImageAnalysis = false;

    if (imageUrl && GOOGLE_AI_API_KEY) {
      console.log('🖼️ Iniciando análise de imagem com Gemini Flash...');
      isImageAnalysis = true;
      
      try {
        // Prompt especializado para análise de comida com Gemini Flash
        const imageAnalysisPrompt = `
Analise esta imagem e determine se contém comida/alimentos.

Se for comida, forneça uma análise detalhada em formato JSON:

{
  "is_food": true,
  "foods_detected": ["alimento1", "alimento2"],
  "meal_type": "café da manhã|almoço|jantar|lanche",
  "nutritional_assessment": "score de 0-100",
  "estimated_calories": "calorias estimadas",
  "positive_points": ["ponto1", "ponto2"],
  "suggestions": ["sugestão1", "sugestão2"],
  "nutrients": {
    "protein": "estimativa em gramas",
    "carbs": "estimativa em gramas", 
    "fat": "estimativa em gramas",
    "fiber": "estimativa em gramas"
  },
  "health_benefits": ["benefício1", "benefício2"],
  "calorie_density": "baixa|média|alta",
  "portion_size": "pequena|média|grande"
}

Se não for comida, responda apenas: "Não é comida"

Use a base de dados nutricional brasileira para estimativas precisas.`;

        const imageAnalysisResponse = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GOOGLE_AI_API_KEY}`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            contents: [{
              parts: [
                { text: imageAnalysisPrompt },
                {
                  inline_data: {
                    mime_type: "image/jpeg",
                    data: imageUrl.split(',')[1] || imageUrl
                  }
                }
              ]
            }],
            generationConfig: {
              temperature: 0.6,
              maxOutputTokens: 1024,
              topP: 0.8,
              topK: 40
            }
          })
        });

        const imageAnalysisData = await imageAnalysisResponse.json();
        
        if (imageAnalysisData.candidates && imageAnalysisData.candidates[0]) {
          const analysisText = imageAnalysisData.candidates[0].content.parts[0].text;
          console.log('🍽️ Análise de comida:', analysisText);
          
          // Parse da análise de comida
          if (analysisText.includes('Não é comida')) {
            foodAnalysis = { is_food: false };
          } else {
            foodAnalysis = {
              is_food: true,
              analysis: analysisText,
              foods_detected: extractFoods(analysisText),
              meal_type: extractMealType(analysisText),
              nutritional_assessment: extractNutritionalScore(analysisText),
              estimated_calories: extractCalories(analysisText),
              positive_points: extractPositivePoints(analysisText),
              suggestions: extractSuggestions(analysisText),
              nutrients: extractNutrients(analysisText),
              health_benefits: extractHealthBenefits(analysisText),
              calorie_density: extractCalorieDensity(analysisText),
              portion_size: extractPortionSize(analysisText)
            };
          }
        }
      } catch (error) {
        console.error('❌ Erro na análise de imagem:', error);
        foodAnalysis = { is_food: false, error: error.message };
      }
    }

    // 🤖 Determinar personagem baseado no dia da semana
    const currentDay = new Date().getDay();
    const isFriday = currentDay === 5;
    
    let character = isFriday ? 'Dr. Vital' : 'Sofia';
    let characterDescription = isFriday 
      ? 'Dr. Vital, médico especialista em saúde e bem-estar'
      : 'Sofia, assistente virtual amigável e coach de saúde';

    // 🤖 Gerar resposta personalizada com Gemini Flash
    let response = '';

    if (GOOGLE_AI_API_KEY) {
      console.log(`🤖 Gerando resposta personalizada como ${character} com Gemini Flash...`);
      
      try {
        // Construir contexto rico
        let contextPrompt = `
Você é ${characterDescription}.

${isFriday ? `
SEXTA-FEIRA - DR. VITAL:
- Você é um médico experiente e atencioso
- Foque em análises médicas e resumos semanais
- Use linguagem profissional mas calorosa
- Emoji recomendado: 👨‍⚕️
` : `
SOFIA - ASSISTENTE DE SAÚDE:
- Você é uma coach de saúde amigável e motivacional
- Foque em apoio emocional e incentivo
- Use linguagem carinhosa e empática
- Emoji recomendado: 💜
`}

DADOS DO USUÁRIO:
- Nome: ${userSummary.name}
- Peso atual: ${userSummary.currentWeight}
- Streak de missões: ${userSummary.streak} dias
- Perfil: ${userProfile ? JSON.stringify(userProfile, null, 2) : 'Não disponível'}

HISTÓRICO DA CONVERSA:
${conversationHistory.map(msg => `${msg.role}: ${msg.content}`).join('\n')}

MENSAGEM ATUAL: "${message}"`;

        // Adicionar análise de comida se houver
        if (foodAnalysis && foodAnalysis.is_food) {
          contextPrompt += `

ANÁLISE DE COMIDA DETECTADA:
- Alimentos: ${foodAnalysis.foods_detected?.join(', ')}
- Tipo de refeição: ${foodAnalysis.meal_type}
- Avaliação nutricional: ${foodAnalysis.nutritional_assessment}/100
- Calorias estimadas: ${foodAnalysis.estimated_calories}
- Densidade calórica: ${foodAnalysis.calorie_density || 'N/A'}
- Tamanho da porção: ${foodAnalysis.portion_size || 'N/A'}
- Nutrientes: ${foodAnalysis.nutrients ? `Proteína: ${foodAnalysis.nutrients.protein}g, Carboidratos: ${foodAnalysis.nutrients.carbs}g, Gorduras: ${foodAnalysis.nutrients.fat}g, Fibras: ${foodAnalysis.nutrients.fiber}g` : 'N/A'}
- Benefícios para saúde: ${foodAnalysis.health_benefits?.join(', ') || 'N/A'}
- Pontos positivos: ${foodAnalysis.positive_points?.join(', ')}
- Sugestões: ${foodAnalysis.suggestions?.join(', ')}

Como Sofia, analise esta refeição considerando:
1. Balanceamento nutricional (proteínas, carboidratos, gorduras)
2. Densidade calórica e tamanho da porção
3. Benefícios para saúde dos alimentos
4. Sugestões práticas para melhorar a refeição
5. Mensagem motivacional personalizada

Responda de forma carinhosa e educativa, sempre incentivando escolhas saudáveis.`;
        } else if (isImageAnalysis && foodAnalysis && !foodAnalysis.is_food) {
          contextPrompt += `

ANÁLISE DE IMAGEM:
A imagem enviada não contém comida/alimentos.

Responda de forma amigável explicando que a imagem não parece ser de comida.`;
        }

        // Chamar Gemini Flash
        const geminiResponse = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GOOGLE_AI_API_KEY}`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            contents: [{
              parts: [{ text: contextPrompt }]
            }],
            generationConfig: {
              temperature: isFriday ? 0.6 : 0.8,
              maxOutputTokens: isFriday ? 4096 : 2048,
              topP: 0.8,
              topK: 40
            }
          })
        });

        const geminiData = await geminiResponse.json();
        
        if (geminiData.candidates && geminiData.candidates[0]) {
          response = geminiData.candidates[0].content.parts[0].text;
          console.log('✅ Resposta do Gemini Flash gerada com sucesso');
        } else {
          throw new Error('Resposta vazia do Gemini Flash');
        }

      } catch (error) {
        console.error('❌ Erro ao gerar resposta com Gemini Flash:', error);
        response = 'Desculpe, tive um problema técnico. Pode tentar novamente?';
      }
    } else {
      console.log('⚠️ Google AI API não configurada, usando resposta padrão');
      response = 'Olá! Sou a Sofia, sua assistente de saúde. Como posso te ajudar hoje?';
    }

    // 🔍 ANÁLISE EMOCIONAL AUTOMÁTICA
    let emotionalAnalysis = null;
    
    if (GOOGLE_AI_API_KEY) {
      try {
        console.log('🧠 Iniciando análise emocional automática...');
        
        const emotionalAnalysisPrompt = `
Analise a mensagem do usuário e extraia informações emocionais e físicas.

MENSAGEM: "${message}"

Responda em formato JSON com os seguintes campos:
{
  "sentiment_score": -1.0 a 1.0 (negativo a positivo),
  "emotions_detected": ["emoção1", "emoção2"],
  "pain_level": 0-10 (se mencionado, null se não),
  "stress_level": 0-10 (se mencionado, null se não),
  "energy_level": 0-10 (se mencionado, null se não),
  "mood_keywords": ["palavra1", "palavra2"],
  "physical_symptoms": ["sintoma1", "sintoma2"],
  "emotional_topics": ["tópico1", "tópico2"],
  "concerns_mentioned": ["preocupação1", "preocupação2"],
  "goals_mentioned": ["objetivo1", "objetivo2"],
  "achievements_mentioned": ["conquista1", "conquista2"],
  "trauma_indicators": ["indicador1", "indicador2"],
  "body_locations": ["local1", "local2"],
  "intensity_level": 0-10,
  "eating_impact": "texto sobre impacto na alimentação",
  "triggers_mentioned": ["gatilho1", "gatilho2"]
}

Seja preciso e objetivo. Se não houver informação sobre um campo, use null ou array vazio.`;

        const emotionalResponse = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GOOGLE_AI_API_KEY}`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            contents: [{
              parts: [{ text: emotionalAnalysisPrompt }]
            }],
            generationConfig: {
              temperature: 0.3,
              maxOutputTokens: 1024,
              topP: 0.8,
              topK: 40
            }
          })
        });

        const emotionalData = await emotionalResponse.json();
        
        if (emotionalData.candidates && emotionalData.candidates[0]) {
          const analysisText = emotionalData.candidates[0].content.parts[0].text;
          console.log('🧠 Análise emocional:', analysisText);
          
          try {
            // Extrair JSON da resposta
            const jsonMatch = analysisText.match(/\{[\s\S]*\}/);
            if (jsonMatch) {
              emotionalAnalysis = JSON.parse(jsonMatch[0]);
              console.log('✅ Análise emocional processada com sucesso');
            }
          } catch (parseError) {
            console.error('❌ Erro ao parsear análise emocional:', parseError);
            emotionalAnalysis = {
              sentiment_score: 0,
              emotions_detected: [],
              pain_level: null,
              stress_level: null,
              energy_level: null,
              mood_keywords: [],
              physical_symptoms: [],
              emotional_topics: [],
              concerns_mentioned: [],
              goals_mentioned: [],
              achievements_mentioned: [],
              trauma_indicators: [],
              body_locations: [],
              intensity_level: null,
              eating_impact: null,
              triggers_mentioned: []
            };
          }
        }
      } catch (error) {
        console.error('❌ Erro na análise emocional:', error);
        emotionalAnalysis = {
          sentiment_score: 0,
          emotions_detected: [],
          pain_level: null,
          stress_level: null,
          energy_level: null,
          mood_keywords: [],
          physical_symptoms: [],
          emotional_topics: [],
          concerns_mentioned: [],
          goals_mentioned: [],
          achievements_mentioned: [],
          trauma_indicators: [],
          body_locations: [],
          intensity_level: null,
          eating_impact: null,
          triggers_mentioned: []
        };
      }
    }

    // Salvar conversa no banco
    let conversationId = null;
    try {
      const { data: conversationData, error: conversationError } = await supabase
        .from('chat_conversations')
        .insert({
          user_id: userId,
          message: message,
          response: response,
          character: character,
          has_image: !!imageUrl,
          image_url: imageUrl,
          food_analysis: foodAnalysis,
          sentiment_score: emotionalAnalysis?.sentiment_score || 0,
          emotion_tags: emotionalAnalysis?.emotions_detected || [],
          topic_tags: emotionalAnalysis?.emotional_topics || [],
          pain_level: emotionalAnalysis?.pain_level,
          stress_level: emotionalAnalysis?.stress_level,
          energy_level: emotionalAnalysis?.energy_level,
          ai_analysis: {
            emotional_analysis: emotionalAnalysis,
            food_analysis: foodAnalysis,
            user_summary: userSummary
          }
        })
        .select('id')
        .single();
      
      if (conversationError) {
        console.error('❌ Erro ao salvar conversa:', conversationError);
      } else {
        conversationId = conversationData.id;
        console.log('💾 Conversa salva no banco de dados');
      }
    } catch (error) {
      console.error('❌ Erro ao salvar conversa:', error);
    }

    // Salvar análise emocional separadamente
    if (emotionalAnalysis && conversationId) {
      try {
        await supabase
          .from('chat_emotional_analysis')
          .insert({
            user_id: userId,
            conversation_id: conversationId,
            sentiment_score: emotionalAnalysis.sentiment_score,
            emotions_detected: emotionalAnalysis.emotions_detected,
            pain_level: emotionalAnalysis.pain_level,
            stress_level: emotionalAnalysis.stress_level,
            energy_level: emotionalAnalysis.energy_level,
            mood_keywords: emotionalAnalysis.mood_keywords,
            physical_symptoms: emotionalAnalysis.physical_symptoms,
            emotional_topics: emotionalAnalysis.emotional_topics,
            concerns_mentioned: emotionalAnalysis.concerns_mentioned,
            goals_mentioned: emotionalAnalysis.goals_mentioned,
            achievements_mentioned: emotionalAnalysis.achievements_mentioned,
            analysis_metadata: {
              trauma_indicators: emotionalAnalysis.trauma_indicators,
              body_locations: emotionalAnalysis.body_locations,
              intensity_level: emotionalAnalysis.intensity_level,
              eating_impact: emotionalAnalysis.eating_impact,
              triggers_mentioned: emotionalAnalysis.triggers_mentioned
            }
          });
        
        console.log('🧠 Análise emocional salva separadamente');
      } catch (error) {
        console.error('❌ Erro ao salvar análise emocional:', error);
      }
    }

    return new Response(
      JSON.stringify({
        response,
        character,
        foodAnalysis,
        emotionalAnalysis,
        userSummary
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    );

  } catch (error) {
    console.error('💥 Erro na Edge Function:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    );
  }
});

// Funções auxiliares para extrair dados da análise de comida
function extractFoods(text: string): string[] {
  // Tentar extrair do JSON primeiro
  try {
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      const jsonData = JSON.parse(jsonMatch[0]);
      if (jsonData.foods_detected && Array.isArray(jsonData.foods_detected)) {
        return jsonData.foods_detected;
      }
    }
  } catch (e) {
    // Fallback para regex
  }
  
  const foodMatch = text.match(/alimentos?[:\s]+([^.\n]+)/i);
  return foodMatch ? foodMatch[1].split(',').map(f => f.trim()) : [];
}

function extractMealType(text: string): string {
  try {
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      const jsonData = JSON.parse(jsonMatch[0]);
      if (jsonData.meal_type) {
        return jsonData.meal_type;
      }
    }
  } catch (e) {
    // Fallback para regex
  }
  
  const mealMatch = text.match(/tipo de refeição[:\s]+([^.\n]+)/i);
  return mealMatch ? mealMatch[1].trim() : 'Não identificado';
}

function extractNutritionalScore(text: string): string {
  try {
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      const jsonData = JSON.parse(jsonMatch[0]);
      if (jsonData.nutritional_assessment) {
        return jsonData.nutritional_assessment;
      }
    }
  } catch (e) {
    // Fallback para regex
  }
  
  const scoreMatch = text.match(/avaliação nutricional[:\s]+(\d+)/i);
  return scoreMatch ? scoreMatch[1] : 'N/A';
}

function extractCalories(text: string): string {
  try {
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      const jsonData = JSON.parse(jsonMatch[0]);
      if (jsonData.estimated_calories) {
        return jsonData.estimated_calories;
      }
    }
  } catch (e) {
    // Fallback para regex
  }
  
  const calMatch = text.match(/calorias estimadas[:\s]+([^.\n]+)/i);
  return calMatch ? calMatch[1].trim() : 'N/A';
}

function extractPositivePoints(text: string): string[] {
  try {
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      const jsonData = JSON.parse(jsonMatch[0]);
      if (jsonData.positive_points && Array.isArray(jsonData.positive_points)) {
        return jsonData.positive_points;
      }
    }
  } catch (e) {
    // Fallback para regex
  }
  
  const pointsMatch = text.match(/pontos positivos[:\s]+([^.\n]+)/i);
  return pointsMatch ? pointsMatch[1].split(',').map(p => p.trim()) : [];
}

function extractSuggestions(text: string): string[] {
  try {
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      const jsonData = JSON.parse(jsonMatch[0]);
      if (jsonData.suggestions && Array.isArray(jsonData.suggestions)) {
        return jsonData.suggestions;
      }
    }
  } catch (e) {
    // Fallback para regex
  }
  
  const suggMatch = text.match(/sugestões[:\s]+([^.\n]+)/i);
  return suggMatch ? suggMatch[1].split(',').map(s => s.trim()) : [];
}

function extractNutrients(text: string): any {
  try {
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      const jsonData = JSON.parse(jsonMatch[0]);
      if (jsonData.nutrients) {
        return jsonData.nutrients;
      }
    }
  } catch (e) {
    // Fallback para regex
  }
  
  return {
    protein: 'N/A',
    carbs: 'N/A',
    fat: 'N/A',
    fiber: 'N/A'
  };
}

function extractHealthBenefits(text: string): string[] {
  try {
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      const jsonData = JSON.parse(jsonMatch[0]);
      if (jsonData.health_benefits && Array.isArray(jsonData.health_benefits)) {
        return jsonData.health_benefits;
      }
    }
  } catch (e) {
    // Fallback para regex
  }
  
  return [];
}

function extractCalorieDensity(text: string): string {
  try {
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      const jsonData = JSON.parse(jsonMatch[0]);
      if (jsonData.calorie_density) {
        return jsonData.calorie_density;
      }
    }
  } catch (e) {
    // Fallback para regex
  }
  
  return 'N/A';
}

function extractPortionSize(text: string): string {
  try {
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      const jsonData = JSON.parse(jsonMatch[0]);
      if (jsonData.portion_size) {
        return jsonData.portion_size;
      }
    }
  } catch (e) {
    // Fallback para regex
  }
  
  return 'N/A';
}