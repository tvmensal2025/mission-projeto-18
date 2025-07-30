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

Se for comida, forneça:
1. Lista de alimentos identificados
2. Tipo de refeição (café da manhã, almoço, jantar, lanche)
3. Avaliação nutricional (0-100)
4. Calorias estimadas
5. Pontos positivos da refeição
6. Sugestões de melhoria

Se não for comida, responda apenas: "Não é comida"

Responda em português brasileiro de forma clara e objetiva.`;

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
              suggestions: extractSuggestions(analysisText)
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
- Avaliação: ${foodAnalysis.nutritional_assessment}
- Calorias estimadas: ${foodAnalysis.estimated_calories}
- Pontos positivos: ${foodAnalysis.positive_points?.join(', ')}
- Sugestões: ${foodAnalysis.suggestions?.join(', ')}

Responda como Sofia analisando a comida enviada de forma personalizada e motivacional.`;
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

    // Salvar conversa no banco
    try {
      await supabase
        .from('chat_conversations')
        .insert({
          user_id: userId,
          message: message,
          response: response,
          character: character,
          has_image: !!imageUrl,
          image_url: imageUrl,
          food_analysis: foodAnalysis
        });
      
      console.log('💾 Conversa salva no banco de dados');
    } catch (error) {
      console.error('❌ Erro ao salvar conversa:', error);
    }

    return new Response(
      JSON.stringify({
        response,
        character,
        foodAnalysis,
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
  const foodMatch = text.match(/alimentos?[:\s]+([^.\n]+)/i);
  return foodMatch ? foodMatch[1].split(',').map(f => f.trim()) : [];
}

function extractMealType(text: string): string {
  const mealMatch = text.match(/tipo de refeição[:\s]+([^.\n]+)/i);
  return mealMatch ? mealMatch[1].trim() : 'Não identificado';
}

function extractNutritionalScore(text: string): string {
  const scoreMatch = text.match(/avaliação nutricional[:\s]+(\d+)/i);
  return scoreMatch ? scoreMatch[1] : 'N/A';
}

function extractCalories(text: string): string {
  const calMatch = text.match(/calorias estimadas[:\s]+([^.\n]+)/i);
  return calMatch ? calMatch[1].trim() : 'N/A';
}

function extractPositivePoints(text: string): string[] {
  const pointsMatch = text.match(/pontos positivos[:\s]+([^.\n]+)/i);
  return pointsMatch ? pointsMatch[1].split(',').map(p => p.trim()) : [];
}

function extractSuggestions(text: string): string[] {
  const suggMatch = text.match(/sugestões[:\s]+([^.\n]+)/i);
  return suggMatch ? suggMatch[1].split(',').map(s => s.trim()) : [];
}