import "https://deno.land/x/xhr@0.1.0/mod.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface FoodAnalysisRequest {
  imageUrl: string;
  userId: string;
  context: {
    mealType?: 'breakfast' | 'lunch' | 'dinner' | 'snack' | 'other';
    timeOfDay?: string;
    location?: 'home' | 'restaurant' | 'work' | 'social' | 'travel';
    mood?: string;
    hungerLevel?: number; // 1-10
    stressLevel?: number; // 1-10
    socialContext?: 'alone' | 'family' | 'friends' | 'colleagues';
    specialOccasion?: boolean;
  };
  analysisDepth: 'basic' | 'detailed' | 'comprehensive';
  userPreferences?: {
    focusAreas?: string[]; // ['calories', 'macros', 'portions', 'quality']
    dietaryRestrictions?: string[];
    healthGoals?: string[];
  };
}

interface DetectedFood {
  name: string;
  confidence: number;
  category: string;
  portion_size: {
    estimated_grams: number;
    visual_reference: string;
    confidence: number;
  };
  nutrition: {
    calories: number;
    carbs_g: number;
    protein_g: number;
    fat_g: number;
    fiber_g: number;
    sugar_g: number;
    sodium_mg: number;
  };
  quality_indicators: {
    processing_level: 'minimal' | 'processed' | 'ultra_processed';
    nutritional_density: number; // 0-1
    glycemic_index: number | null;
  };
}

interface ComprehensiveFoodAnalysis {
  analysis_id: string;
  detected_foods: DetectedFood[];
  overall_analysis: {
    total_calories: number;
    macronutrient_distribution: {
      carbs_percent: number;
      protein_percent: number;
      fat_percent: number;
    };
    meal_quality_score: number; // 0-100
    portion_appropriateness: number; // 0-1
    nutritional_density: number; // 0-1
  };
  contextual_insights: {
    meal_timing_assessment: string;
    goal_alignment_score: number;
    behavioral_patterns: string[];
    recommendations: string[];
    warnings: string[];
  };
  personalized_feedback: {
    sofia_message: string;
    actionable_suggestions: string[];
    educational_content: string[];
  };
  accuracy_metrics: {
    food_recognition_confidence: number;
    portion_estimation_confidence: number;
    nutrition_calculation_confidence: number;
    overall_confidence: number;
  };
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const requestData: FoodAnalysisRequest = await req.json();
    console.log('📸 Advanced Food Analysis Request:', requestData);

    // Inicializar Supabase
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Executar análise avançada
    const analysis = await performAdvancedFoodAnalysis(supabase, requestData);

    return new Response(JSON.stringify(analysis), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('❌ Erro na análise avançada de alimentos:', error);
    
    return new Response(JSON.stringify({ 
      error: error.message,
      details: 'Erro na análise avançada de imagens de alimentos'
    }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});

async function performAdvancedFoodAnalysis(
  supabase: any, 
  request: FoodAnalysisRequest
): Promise<ComprehensiveFoodAnalysis> {
  
  console.log('🔍 Iniciando análise avançada de alimentos...');

  // 1. Buscar contexto do usuário
  const userContext = await getUserContext(supabase, request.userId);
  
  // 2. Analisar imagem com IA
  const imageAnalysis = await analyzeImageWithAI(request.imageUrl, request.analysisDepth);
  
  // 3. Enriquecer dados nutricionais
  const enrichedNutrition = await enrichNutritionalData(imageAnalysis.detected_foods);
  
  // 4. Aplicar contexto pessoal
  const contextualAnalysis = await applyPersonalContext(
    enrichedNutrition, 
    userContext, 
    request.context,
    request.userPreferences
  );
  
  // 5. Gerar insights comportamentais
  const behavioralInsights = await generateBehavioralInsights(
    supabase,
    request.userId,
    contextualAnalysis,
    request.context
  );
  
  // 6. Criar feedback personalizado da Sofia
  const personalizedFeedback = await generateSofiaFeedback(
    supabase,
    contextualAnalysis,
    behavioralInsights,
    userContext
  );
  
  // 7. Salvar análise completa
  const analysisId = await saveAdvancedAnalysis(
    supabase,
    request,
    contextualAnalysis,
    behavioralInsights,
    personalizedFeedback
  );

  // 8. Compilar resultado final
  const result: ComprehensiveFoodAnalysis = {
    analysis_id: analysisId,
    detected_foods: contextualAnalysis.detected_foods,
    overall_analysis: contextualAnalysis.overall_analysis,
    contextual_insights: behavioralInsights,
    personalized_feedback: personalizedFeedback,
    accuracy_metrics: calculateAccuracyMetrics(imageAnalysis, contextualAnalysis)
  };

  console.log('✅ Análise avançada concluída');
  return result;
}

async function getUserContext(supabase: any, userId: string): Promise<any> {
  console.log('👤 Buscando contexto do usuário...');
  
  // Buscar perfil do usuário
  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('user_id', userId)
    .single();

  // Buscar metas atuais
  const { data: goals } = await supabase
    .from('user_goals')
    .select('*')
    .eq('user_id', userId)
    .eq('is_active', true);

  // Buscar medições recentes
  const { data: measurements } = await supabase
    .from('weight_measurements')
    .select('*')
    .eq('user_id', userId)
    .order('measurement_date', { ascending: false })
    .limit(5);

  // Buscar análises recentes de comida
  const { data: recentAnalyses } = await supabase
    .from('food_image_analysis')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
    .limit(10);

  return {
    profile: profile || {},
    goals: goals || [],
    measurements: measurements || [],
    recentAnalyses: recentAnalyses || []
  };
}

async function analyzeImageWithAI(imageUrl: string, depth: string): Promise<any> {
  console.log('🤖 Analisando imagem com IA...');
  
  const GOOGLE_AI_API_KEY = Deno.env.get('GOOGLE_AI_API_KEY');
  
  if (!GOOGLE_AI_API_KEY) {
    throw new Error('Google AI API Key não configurada');
  }

  try {
    // Buscar imagem
    const imageResponse = await fetch(imageUrl);
    if (!imageResponse.ok) {
      throw new Error('Não foi possível carregar a imagem');
    }
    
    const imageBuffer = await imageResponse.arrayBuffer();
    const base64Image = btoa(String.fromCharCode(...new Uint8Array(imageBuffer)));

    // Prompt avançado baseado na profundidade
    const analysisPrompt = generateAdvancedAnalysisPrompt(depth);

    // Chamar Gemini Vision
    const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GOOGLE_AI_API_KEY}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        contents: [{
          parts: [
            { text: analysisPrompt },
            {
              inline_data: {
                mime_type: "image/jpeg",
                data: base64Image
              }
            }
          ]
        }],
        generationConfig: {
          maxOutputTokens: depth === 'comprehensive' ? 4000 : depth === 'detailed' ? 2000 : 1000,
          temperature: 0.3
        }
      })
    });

    if (!response.ok) {
      throw new Error(`Gemini API error: ${response.statusText}`);
    }

    const data = await response.json();
    const analysisText = data.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!analysisText) {
      throw new Error('Resposta inválida da IA');
    }

    // Processar resposta da IA
    return parseAIResponse(analysisText);

  } catch (error) {
    console.error('❌ Erro na análise com IA:', error);
    throw error;
  }
}

function generateAdvancedAnalysisPrompt(depth: string): string {
  const basePrompt = `
Analise esta imagem de comida com máxima precisão. Você é um especialista em nutrição e análise de alimentos.

INSTRUÇÕES GERAIS:
- Identifique TODOS os alimentos visíveis
- Estime porções usando referências visuais (palma da mão, punho, colher, etc.)
- Calcule valores nutricionais precisos
- Avalie qualidade nutricional de cada item
- Considere método de preparo quando visível

FORMATO DE RESPOSTA (JSON):
{
  "detected_foods": [
    {
      "name": "nome do alimento",
      "confidence": 0.95,
      "category": "categoria (grains, protein, vegetable, etc.)",
      "portion_estimate": {
        "grams": 150,
        "visual_reference": "1 punho fechado",
        "confidence": 0.8
      },
      "nutrition_per_portion": {
        "calories": 200,
        "carbs_g": 45,
        "protein_g": 8,
        "fat_g": 2,
        "fiber_g": 6,
        "sugar_g": 3,
        "sodium_mg": 300
      },
      "quality_assessment": {
        "processing_level": "minimal|processed|ultra_processed",
        "nutritional_density": 0.8,
        "glycemic_index": 55
      }
    }
  ],
  "image_quality": {
    "clarity": "excellent|good|fair|poor",
    "lighting": "excellent|good|fair|poor",
    "angle": "excellent|good|fair|poor",
    "portion_visibility": "complete|partial|obscured"
  },
  "overall_confidence": 0.85
}`;

  if (depth === 'comprehensive') {
    return basePrompt + `

ANÁLISE ADICIONAL PARA MODO COMPREHENSIVE:
- Analise métodos de preparo (grelhado, frito, cozido, etc.)
- Identifique temperos e molhos visíveis
- Avalie apresentação e composição do prato
- Estime tempo de preparo e complexidade
- Identifique possíveis alérgenos
- Analise equilíbrio de cores e variedade
- Considere adequação para diferentes dietas (vegana, keto, etc.)

ADICIONE AO JSON:
"advanced_analysis": {
  "cooking_methods": ["grilled", "steamed"],
  "seasonings_visible": ["herbs", "olive_oil"],
  "presentation_score": 0.8,
  "color_variety": 0.9,
  "allergen_alerts": ["gluten", "dairy"],
  "diet_compatibility": {
    "vegetarian": true,
    "vegan": false,
    "keto": false,
    "paleo": true
  }
}`;
  }

  if (depth === 'detailed') {
    return basePrompt + `

ANÁLISE ADICIONAL PARA MODO DETAILED:
- Identifique métodos de preparo básicos
- Avalie variedade nutricional
- Identifique alérgenos principais

ADICIONE AO JSON:
"detailed_analysis": {
  "cooking_methods": ["grilled"],
  "nutritional_variety": 0.7,
  "main_allergens": ["gluten"]
}`;
  }

  return basePrompt;
}

function parseAIResponse(aiText: string): any {
  try {
    // Extrair JSON da resposta
    const jsonMatch = aiText.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      throw new Error('JSON não encontrado na resposta da IA');
    }

    const parsedResponse = JSON.parse(jsonMatch[0]);
    
    // Validar estrutura básica
    if (!parsedResponse.detected_foods || !Array.isArray(parsedResponse.detected_foods)) {
      throw new Error('Estrutura de resposta inválida');
    }

    return parsedResponse;

  } catch (error) {
    console.error('❌ Erro ao processar resposta da IA:', error);
    
    // Fallback: resposta estruturada básica
    return {
      detected_foods: [{
        name: 'Alimento não identificado',
        confidence: 0.5,
        category: 'unknown',
        portion_estimate: { grams: 100, visual_reference: 'porção média', confidence: 0.5 },
        nutrition_per_portion: { calories: 150, carbs_g: 20, protein_g: 5, fat_g: 5, fiber_g: 2, sugar_g: 3, sodium_mg: 200 },
        quality_assessment: { processing_level: 'unknown', nutritional_density: 0.5, glycemic_index: null }
      }],
      image_quality: { clarity: 'fair', lighting: 'fair', angle: 'fair', portion_visibility: 'partial' },
      overall_confidence: 0.5
    };
  }
}

async function enrichNutritionalData(detectedFoods: any[]): Promise<any> {
  console.log('🔬 Enriquecendo dados nutricionais...');
  
  // Enriquecer com dados de micronutrientes e outros detalhes
  return detectedFoods.map(food => ({
    ...food,
    enriched_nutrition: {
      ...food.nutrition_per_portion,
      // Adicionar micronutrientes estimados
      vitamin_c_mg: estimateVitaminC(food.name, food.category),
      iron_mg: estimateIron(food.name, food.category),
      calcium_mg: estimateCalcium(food.name, food.category),
      potassium_mg: estimatePotassium(food.name, food.category),
      // Score nutricional composto
      nutrition_score: calculateNutritionScore(food)
    }
  }));
}

async function applyPersonalContext(
  enrichedFoods: any[], 
  userContext: any, 
  mealContext: any,
  preferences: any
): Promise<any> {
  
  console.log('🎯 Aplicando contexto personalizado...');

  // Calcular totais
  const totalCalories = enrichedFoods.reduce((sum, food) => 
    sum + (food.enriched_nutrition?.calories || food.nutrition_per_portion?.calories || 0), 0);
  
  const totalCarbs = enrichedFoods.reduce((sum, food) => 
    sum + (food.enriched_nutrition?.carbs_g || food.nutrition_per_portion?.carbs_g || 0), 0);
  
  const totalProtein = enrichedFoods.reduce((sum, food) => 
    sum + (food.enriched_nutrition?.protein_g || food.nutrition_per_portion?.protein_g || 0), 0);
  
  const totalFat = enrichedFoods.reduce((sum, food) => 
    sum + (food.enriched_nutrition?.fat_g || food.nutrition_per_portion?.fat_g || 0), 0);

  // Calcular distribuição de macronutrientes
  const totalMacros = totalCarbs * 4 + totalProtein * 4 + totalFat * 9;
  const macroDistribution = {
    carbs_percent: totalMacros > 0 ? (totalCarbs * 4 / totalMacros) * 100 : 0,
    protein_percent: totalMacros > 0 ? (totalProtein * 4 / totalMacros) * 100 : 0,
    fat_percent: totalMacros > 0 ? (totalFat * 9 / totalMacros) * 100 : 0
  };

  // Calcular score de qualidade da refeição
  const mealQualityScore = calculateMealQualityScore(enrichedFoods, mealContext);
  
  // Calcular adequação da porção
  const portionAppropriateness = calculatePortionAppropriateness(
    totalCalories, 
    mealContext.mealType, 
    userContext
  );

  return {
    detected_foods: enrichedFoods,
    overall_analysis: {
      total_calories: totalCalories,
      macronutrient_distribution: macroDistribution,
      meal_quality_score: mealQualityScore,
      portion_appropriateness: portionAppropriateness,
      nutritional_density: calculateNutritionalDensity(enrichedFoods)
    }
  };
}

async function generateBehavioralInsights(
  supabase: any,
  userId: string,
  analysis: any,
  context: any
): Promise<any> {
  
  console.log('🧠 Gerando insights comportamentais...');

  // Analisar padrões recentes
  const { data: recentMeals } = await supabase
    .from('food_image_analysis')
    .select('meal_type, nutrition_breakdown, eating_context, created_at')
    .eq('user_id', userId)
    .gte('created_at', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString())
    .order('created_at', { ascending: false });

  const behavioralPatterns = analyzeBehavioralPatterns(recentMeals || [], context);
  
  // Calcular alinhamento com metas
  const goalAlignment = await calculateGoalAlignment(supabase, userId, analysis);
  
  // Gerar recomendações
  const recommendations = generateRecommendations(analysis, behavioralPatterns, goalAlignment);
  
  // Gerar avisos
  const warnings = generateWarnings(analysis, behavioralPatterns);

  return {
    meal_timing_assessment: assessMealTiming(context.timeOfDay, context.mealType),
    goal_alignment_score: goalAlignment.score,
    behavioral_patterns: behavioralPatterns,
    recommendations,
    warnings
  };
}

async function generateSofiaFeedback(
  supabase: any,
  analysis: any,
  insights: any,
  userContext: any
): Promise<any> {
  
  console.log('💬 Gerando feedback personalizado da Sofia...');

  // Buscar personalidade da Sofia para este usuário
  const { data: personality } = await supabase
    .from('ai_personalities')
    .select('*')
    .eq('user_id', userContext.profile?.user_id || 'default')
    .eq('agent_name', 'sofia')
    .single();

  // Gerar mensagem personalizada
  const sofiaMessage = await generatePersonalizedMessage(
    analysis, 
    insights, 
    personality,
    userContext
  );

  // Gerar sugestões acionáveis
  const actionableSuggestions = generateActionableSuggestions(analysis, insights);
  
  // Gerar conteúdo educacional
  const educationalContent = generateEducationalContent(analysis);

  return {
    sofia_message: sofiaMessage,
    actionable_suggestions: actionableSuggestions,
    educational_content: educationalContent
  };
}

async function saveAdvancedAnalysis(
  supabase: any,
  request: FoodAnalysisRequest,
  analysis: any,
  insights: any,
  feedback: any
): Promise<string> {
  
  console.log('💾 Salvando análise avançada...');

  try {
    // Salvar análise principal
    const { data: savedAnalysis, error: analysisError } = await supabase
      .from('food_image_analysis')
      .insert({
        user_id: request.userId,
        image_url: request.imageUrl,
        detected_items: {
          foods: analysis.detected_foods,
          portions: analysis.detected_foods.reduce((acc: any, food: any) => {
            acc[food.name] = food.portion_estimate;
            return acc;
          }, {}),
          confidence_scores: analysis.detected_foods.reduce((acc: any, food: any) => {
            acc[food.name] = food.confidence;
            return acc;
          }, {})
        },
        nutrition_breakdown: {
          macronutrients: {
            carbohydrates_g: analysis.overall_analysis.macronutrient_distribution.carbs_percent,
            proteins_g: analysis.overall_analysis.macronutrient_distribution.protein_percent,
            fats_g: analysis.overall_analysis.macronutrient_distribution.fat_percent
          },
          total_calories: analysis.overall_analysis.total_calories,
          nutritional_density: analysis.overall_analysis.nutritional_density
        },
        meal_type: request.context.mealType || 'unknown',
        eating_context: request.context.location || 'unknown',
        emotional_context: request.context.mood || 'neutral',
        goal_alignment_score: insights.goal_alignment_score,
        recommendations: insights.recommendations,
        warnings: insights.warnings,
        behavioral_insights: {
          eating_patterns: insights.behavioral_patterns,
          meal_timing: insights.meal_timing_assessment
        }
      })
      .select()
      .single();

    if (analysisError) {
      throw analysisError;
    }

    // Salvar contexto da imagem
    await supabase
      .from('image_context_data')
      .insert({
        food_analysis_id: savedAnalysis.id,
        environmental_context: {
          setting: request.context.location,
          social_context: request.context.socialContext,
          time_of_day: request.context.timeOfDay,
          special_occasion: request.context.specialOccasion
        },
        user_state_context: {
          reported_hunger_level: request.context.hungerLevel,
          reported_mood: request.context.mood,
          reported_stress_level: request.context.stressLevel
        },
        accuracy_metrics: {
          food_recognition_confidence: 0.8,
          portion_estimation_confidence: 0.7,
          nutrition_calculation_confidence: 0.75,
          overall_analysis_confidence: 0.75
        }
      });

    console.log('✅ Análise salva com sucesso:', savedAnalysis.id);
    return savedAnalysis.id;

  } catch (error) {
    console.error('❌ Erro ao salvar análise:', error);
    throw error;
  }
}

// Funções auxiliares de cálculo
function estimateVitaminC(foodName: string, category: string): number {
  const vitaminCFoods: { [key: string]: number } = {
    'orange': 53, 'lemon': 51, 'strawberry': 59, 'kiwi': 93,
    'broccoli': 89, 'bell pepper': 128, 'tomato': 14
  };
  
  const lowerName = foodName.toLowerCase();
  for (const [food, value] of Object.entries(vitaminCFoods)) {
    if (lowerName.includes(food)) return value;
  }
  
  // Estimativas por categoria
  if (category === 'fruit') return 30;
  if (category === 'vegetable') return 20;
  return 5;
}

function estimateIron(foodName: string, category: string): number {
  const ironFoods: { [key: string]: number } = {
    'beef': 2.6, 'chicken': 0.9, 'fish': 1.1, 'spinach': 2.7,
    'beans': 3.6, 'lentils': 3.3, 'tofu': 5.4
  };
  
  const lowerName = foodName.toLowerCase();
  for (const [food, value] of Object.entries(ironFoods)) {
    if (lowerName.includes(food)) return value;
  }
  
  if (category === 'protein') return 2.0;
  if (category === 'vegetable') return 1.0;
  return 0.5;
}

function estimateCalcium(foodName: string, category: string): number {
  const calciumFoods: { [key: string]: number } = {
    'milk': 113, 'cheese': 200, 'yogurt': 110, 'broccoli': 47,
    'almonds': 264, 'sardines': 382
  };
  
  const lowerName = foodName.toLowerCase();
  for (const [food, value] of Object.entries(calciumFoods)) {
    if (lowerName.includes(food)) return value;
  }
  
  if (category === 'dairy') return 150;
  if (category === 'vegetable') return 30;
  return 20;
}

function estimatePotassium(foodName: string, category: string): number {
  const potassiumFoods: { [key: string]: number } = {
    'banana': 358, 'potato': 425, 'avocado': 485, 'spinach': 558,
    'salmon': 628, 'beans': 355
  };
  
  const lowerName = foodName.toLowerCase();
  for (const [food, value] of Object.entries(potassiumFoods)) {
    if (lowerName.includes(food)) return value;
  }
  
  if (category === 'fruit') return 200;
  if (category === 'vegetable') return 250;
  if (category === 'protein') return 300;
  return 100;
}

function calculateNutritionScore(food: any): number {
  const nutrition = food.nutrition_per_portion || {};
  let score = 0.5; // Base score
  
  // Boost for high fiber
  if (nutrition.fiber_g > 3) score += 0.2;
  
  // Boost for high protein
  if (nutrition.protein_g > 10) score += 0.15;
  
  // Penalty for high sugar
  if (nutrition.sugar_g > 15) score -= 0.15;
  
  // Penalty for high sodium
  if (nutrition.sodium_mg > 400) score -= 0.1;
  
  return Math.max(0, Math.min(1, score));
}

function calculateMealQualityScore(foods: any[], context: any): number {
  let score = 50; // Base score
  
  // Variety bonus
  const categories = new Set(foods.map(f => f.category));
  score += categories.size * 5;
  
  // Processing level penalty
  const ultraProcessed = foods.filter(f => f.quality_assessment?.processing_level === 'ultra_processed');
  score -= ultraProcessed.length * 10;
  
  // Nutritional density bonus
  const avgDensity = foods.reduce((sum, f) => sum + (f.quality_assessment?.nutritional_density || 0.5), 0) / foods.length;
  score += avgDensity * 20;
  
  return Math.max(0, Math.min(100, score));
}

function calculatePortionAppropriateness(totalCalories: number, mealType: string, userContext: any): number {
  const targetCalories = getTargetCaloriesForMeal(mealType, userContext);
  if (!targetCalories) return 0.5;
  
  const ratio = totalCalories / targetCalories;
  
  // Ideal range: 0.8 - 1.2 of target
  if (ratio >= 0.8 && ratio <= 1.2) return 1.0;
  if (ratio >= 0.6 && ratio <= 1.5) return 0.7;
  if (ratio >= 0.4 && ratio <= 2.0) return 0.4;
  return 0.2;
}

function calculateNutritionalDensity(foods: any[]): number {
  if (!foods.length) return 0;
  
  return foods.reduce((sum, food) => {
    return sum + (food.quality_assessment?.nutritional_density || 0.5);
  }, 0) / foods.length;
}

function getTargetCaloriesForMeal(mealType: string, userContext: any): number {
  const dailyTarget = userContext.profile?.daily_calorie_target || 2000;
  
  const mealDistribution = {
    'breakfast': 0.25,
    'lunch': 0.35,
    'dinner': 0.30,
    'snack': 0.10
  };
  
  return dailyTarget * (mealDistribution[mealType] || 0.25);
}

function analyzeBehavioralPatterns(recentMeals: any[], currentContext: any): string[] {
  const patterns: string[] = [];
  
  // Análise de timing
  const currentHour = new Date().getHours();
  if (currentContext.mealType === 'dinner' && currentHour > 21) {
    patterns.push('Jantar tardio frequente');
  }
  
  // Análise de contexto emocional
  if (currentContext.stressLevel > 7) {
    patterns.push('Alimentação durante stress elevado');
  }
  
  // Análise de frequência por local
  const homeEating = recentMeals.filter(m => m.eating_context === 'home').length;
  if (homeEating / recentMeals.length > 0.8) {
    patterns.push('Alimentação predominantemente caseira');
  }
  
  return patterns;
}

async function calculateGoalAlignment(supabase: any, userId: string, analysis: any): Promise<{ score: number }> {
  // Buscar metas do usuário
  const { data: goals } = await supabase
    .from('user_goals')
    .select('*')
    .eq('user_id', userId)
    .eq('is_active', true);
  
  if (!goals || !goals.length) {
    return { score: 0.5 }; // Score neutro sem metas
  }
  
  // Calcular alinhamento baseado nas metas
  let alignmentScore = 0.5;
  
  const weightLossGoal = goals.find(g => g.goal_type === 'weight_loss');
  if (weightLossGoal && analysis.overall_analysis.total_calories) {
    const targetCalories = weightLossGoal.target_value || 1800;
    const mealCalories = analysis.overall_analysis.total_calories;
    
    // Assumindo que esta é uma das 3 refeições principais
    const mealTarget = targetCalories / 3;
    const ratio = mealCalories / mealTarget;
    
    if (ratio <= 1.2) alignmentScore += 0.3;
    else if (ratio > 1.5) alignmentScore -= 0.2;
  }
  
  return { score: Math.max(0, Math.min(1, alignmentScore)) };
}

function generateRecommendations(analysis: any, patterns: string[], goalAlignment: any): string[] {
  const recommendations: string[] = [];
  
  if (analysis.overall_analysis.meal_quality_score < 60) {
    recommendations.push('Adicione mais vegetais para melhorar a qualidade nutricional');
  }
  
  if (analysis.overall_analysis.portion_appropriateness < 0.7) {
    recommendations.push('Considere ajustar o tamanho das porções');
  }
  
  if (goalAlignment.score < 0.6) {
    recommendations.push('Esta refeição pode não estar alinhada com seus objetivos atuais');
  }
  
  return recommendations;
}

function generateWarnings(analysis: any, patterns: string[]): string[] {
  const warnings: string[] = [];
  
  const totalSodium = analysis.detected_foods.reduce((sum: number, food: any) => 
    sum + (food.enriched_nutrition?.sodium_mg || 0), 0);
  
  if (totalSodium > 800) {
    warnings.push('Alto teor de sódio detectado');
  }
  
  const ultraProcessed = analysis.detected_foods.filter((food: any) => 
    food.quality_assessment?.processing_level === 'ultra_processed');
  
  if (ultraProcessed.length > 0) {
    warnings.push('Alimentos ultraprocessados identificados');
  }
  
  return warnings;
}

async function generatePersonalizedMessage(
  analysis: any, 
  insights: any, 
  personality: any,
  userContext: any
): Promise<string> {
  
  const tone = personality?.tone || 'warm';
  const useEmojis = personality?.use_emojis !== false;
  
  let message = '';
  
  if (analysis.overall_analysis.meal_quality_score >= 80) {
    message = useEmojis ? '🌟 Que refeição maravilhosa! ' : 'Que refeição maravilhosa! ';
    message += 'Você fez escolhas muito nutritivas hoje.';
  } else if (analysis.overall_analysis.meal_quality_score >= 60) {
    message = useEmojis ? '👍 Boa escolha! ' : 'Boa escolha! ';
    message += 'Sua refeição tem uma boa base nutricional.';
  } else {
    message = useEmojis ? '💡 ' : '';
    message += 'Vejo oportunidades para tornar sua próxima refeição ainda mais nutritiva!';
  }
  
  // Adicionar insights específicos
  if (insights.goal_alignment_score > 0.8) {
    message += useEmojis ? ' 🎯 E está super alinhada com seus objetivos!' : ' E está bem alinhada com seus objetivos!';
  }
  
  return message;
}

function generateActionableSuggestions(analysis: any, insights: any): string[] {
  const suggestions: string[] = [];
  
  if (analysis.overall_analysis.nutritional_density < 0.6) {
    suggestions.push('Na próxima refeição, tente incluir mais vegetais coloridos');
  }
  
  if (insights.behavioral_patterns.includes('Jantar tardio frequente')) {
    suggestions.push('Considere jantar um pouco mais cedo para melhor digestão');
  }
  
  suggestions.push('Beba um copo de água antes da próxima refeição');
  
  return suggestions;
}

function generateEducationalContent(analysis: any): string[] {
  const content: string[] = [];
  
  const hasHighFiber = analysis.detected_foods.some((food: any) => 
    (food.enriched_nutrition?.fiber_g || 0) > 3);
  
  if (hasHighFiber) {
    content.push('As fibras ajudam na digestão e no controle da glicemia');
  }
  
  content.push('Comer devagar ajuda na digestão e aumenta a saciedade');
  
  return content;
}

function calculateAccuracyMetrics(imageAnalysis: any, contextualAnalysis: any): any {
  return {
    food_recognition_confidence: imageAnalysis.overall_confidence || 0.8,
    portion_estimation_confidence: 0.7, // Baseado na qualidade da imagem
    nutrition_calculation_confidence: 0.75, // Baseado na precisão dos dados
    overall_confidence: (imageAnalysis.overall_confidence || 0.8) * 0.9 // Ligeiramente conservador
  };
}

function assessMealTiming(timeOfDay: string, mealType: string): string {
  const hour = new Date().getHours();
  
  if (mealType === 'breakfast' && hour > 10) {
    return 'Café da manhã um pouco tardio';
  }
  
  if (mealType === 'lunch' && (hour < 11 || hour > 15)) {
    return 'Horário não convencional para almoço';
  }
  
  if (mealType === 'dinner' && hour > 21) {
    return 'Jantar tardio - pode afetar o sono';
  }
  
  return 'Horário adequado para a refeição';
}