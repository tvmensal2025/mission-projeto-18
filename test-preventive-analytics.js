import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'http://127.0.0.1:54321';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';
const supabase = createClient(supabaseUrl, supabaseKey);

async function testPreventiveAnalytics() {
  try {
    console.log('🧪 Testando análises preventivas...');
    
    // 1. Criar usuário de teste
    console.log('🔍 Criando usuário de teste...');
    const { data: { user }, error: signUpError } = await supabase.auth.signUp({
      email: 'teste-preventivo@institutodossonhos.com',
      password: 'teste123456'
    });
    
    if (signUpError) {
      console.error('❌ Erro ao criar usuário:', signUpError);
      return;
    }
    
    console.log('✅ Usuário criado:', user?.email);
    
    // 2. Fazer login
    console.log('🔍 Fazendo login...');
    const { data: { session }, error: signInError } = await supabase.auth.signInWithPassword({
      email: 'teste-preventivo@institutodossonhos.com',
      password: 'teste123456'
    });
    
    if (signInError) {
      console.error('❌ Erro no login:', signInError);
      return;
    }
    
    console.log('✅ Login realizado');
    
    // 3. Testar busca de análises preventivas
    console.log('🔍 Buscando análises preventivas...');
    const { data: analyses, error: fetchError } = await supabase
      .from('preventive_health_analyses')
      .select('*')
      .eq('user_id', session.user.id)
      .order('analysis_date', { ascending: false });
    
    if (fetchError) {
      console.error('❌ Erro ao buscar análises:', fetchError);
    } else {
      console.log('✅ Análises encontradas:', analyses?.length || 0);
    }
    
    // 4. Criar uma análise de teste
    console.log('🔍 Criando análise de teste...');
    const testAnalysis = {
      user_id: session.user.id,
      analysis_type: 'quinzenal',
      risk_level: 'medio',
      health_score: 7.5,
      analysis_data: {
        weight_trend: 'stable',
        exercise_frequency: 'moderate',
        sleep_quality: 'good',
        stress_level: 'medium'
      },
      recommendations: [
        'Aumentar frequência de exercícios',
        'Melhorar qualidade do sono',
        'Reduzir níveis de estresse'
      ],
      risk_factors: [
        'Sedentarismo moderado',
        'Estresse elevado'
      ],
      improvement_areas: [
        'Atividade física',
        'Gestão do estresse'
      ],
      next_analysis_date: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000).toISOString()
    };
    
    const { data: newAnalysis, error: createError } = await supabase
      .from('preventive_health_analyses')
      .insert([testAnalysis])
      .select()
      .single();
    
    if (createError) {
      console.error('❌ Erro ao criar análise:', createError);
    } else {
      console.log('✅ Análise criada com sucesso!');
      console.log('📋 Análise:', {
        id: newAnalysis.id,
        type: newAnalysis.analysis_type,
        risk_level: newAnalysis.risk_level,
        health_score: newAnalysis.health_score,
        created_at: newAnalysis.created_at
      });
    }
    
    // 5. Testar busca de personalidades de IA
    console.log('🔍 Buscando personalidades de IA...');
    const { data: personalities, error: personalityError } = await supabase
      .from('ai_personalities')
      .select('*')
      .eq('is_active', true);
    
    if (personalityError) {
      console.error('❌ Erro ao buscar personalidades:', personalityError);
    } else {
      console.log('✅ Personalidades encontradas:', personalities?.length || 0);
      personalities?.forEach(p => {
        console.log(`📋 ${p.agent_name} (${p.personality_type}): ${p.description?.substring(0, 50)}...`);
      });
    }
    
    // 6. Testar busca de base de conhecimento
    console.log('🔍 Buscando base de conhecimento...');
    const { data: knowledge, error: knowledgeError } = await supabase
      .from('knowledge_base')
      .select('*')
      .order('priority_level', { ascending: false });
    
    if (knowledgeError) {
      console.error('❌ Erro ao buscar base de conhecimento:', knowledgeError);
    } else {
      console.log('✅ Itens de conhecimento encontrados:', knowledge?.length || 0);
      knowledge?.forEach(k => {
        console.log(`📋 ${k.title} (${k.category}): ${k.content?.substring(0, 50)}...`);
      });
    }
    
    console.log('🎉 Teste de análises preventivas concluído!');
    
  } catch (error) {
    console.error('💥 Erro geral:', error);
  }
}

testPreventiveAnalytics(); 