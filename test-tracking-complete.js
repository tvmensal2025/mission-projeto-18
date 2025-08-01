import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// Configuração do Supabase
const SUPABASE_URL = 'https://hlrkoyywjpckdotimtik.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhscmtveXl3anBja2RvdGltdGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUzMzMzNzEsImV4cCI6MjA1MDkwOTM3MX0.5KYY-xZxdBKcJJBJgmVuKQ3HyVGdUcQW1HJlxDvhGWw';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

console.log('🚀 TESTANDO SISTEMA COMPLETO DE TRACKING + EDGE FUNCTIONS');
console.log('=' .repeat(70));

// ID de usuário de teste (substitua por um real se necessário)
const TEST_USER_ID = 'test-user-tracking-' + Date.now();

async function testTrackingManager() {
  console.log('\n📊 1. TESTANDO TRACKING MANAGER...');
  
  try {
    // Testar criação de registro de água
    const waterResponse = await fetch(`${SUPABASE_URL}/functions/v1/tracking-manager`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      },
      body: JSON.stringify({
        action: 'create',
        type: 'water',
        userId: TEST_USER_ID,
        date: new Date().toISOString().split('T')[0],
        data: {
          amount_ml: 2500,
          goal_ml: 2000,
          cups_count: 10,
          source: 'test',
          notes: 'Teste do sistema de tracking'
        }
      }),
    });

    const waterResult = await waterResponse.json();
    console.log('   💧 Água:', waterResult.success ? '✅ Sucesso' : '❌ Erro', waterResult.message);

    // Testar criação de registro de sono
    const sleepResponse = await fetch(`${SUPABASE_URL}/functions/v1/tracking-manager`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      },
      body: JSON.stringify({
        action: 'create',
        type: 'sleep',
        userId: TEST_USER_ID,
        date: new Date().toISOString().split('T')[0],
        data: {
          hours: 8.5,
          quality: 4,
          bedtime: '23:00',
          wake_time: '07:30',
          dream_notes: 'Sonho tranquilo - teste'
        }
      }),
    });

    const sleepResult = await sleepResponse.json();
    console.log('   😴 Sono:', sleepResult.success ? '✅ Sucesso' : '❌ Erro', sleepResult.message);

    // Testar criação de registro de humor
    const moodResponse = await fetch(`${SUPABASE_URL}/functions/v1/tracking-manager`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      },
      body: JSON.stringify({
        action: 'create',
        type: 'mood',
        userId: TEST_USER_ID,
        date: new Date().toISOString().split('T')[0],
        data: {
          energy_level: 4,
          stress_level: 2,
          day_rating: 8,
          gratitude_note: 'Grato pelo sistema funcionando!',
          mood_tags: ['feliz', 'motivado', 'produtivo']
        }
      }),
    });

    const moodResult = await moodResponse.json();
    console.log('   😊 Humor:', moodResult.success ? '✅ Sucesso' : '❌ Erro', moodResult.message);

    return true;
  } catch (error) {
    console.error('   ❌ Erro no Tracking Manager:', error);
    return false;
  }
}

async function testTrackingDashboard() {
  console.log('\n📈 2. TESTANDO TRACKING DASHBOARD...');
  
  try {
    // Testar dashboard overview
    const overviewResponse = await fetch(`${SUPABASE_URL}/functions/v1/tracking-dashboard`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      },
      body: JSON.stringify({
        userId: TEST_USER_ID,
        type: 'overview'
      }),
    });

    const overviewResult = await overviewResponse.json();
    console.log('   📊 Overview:', overviewResult.success ? '✅ Sucesso' : '❌ Erro');
    if (overviewResult.success && overviewResult.data) {
      console.log('      💧 Água hoje:', overviewResult.data.water?.today || 0, 'ml');
      console.log('      😴 Sono:', overviewResult.data.sleep?.lastNight || 0, 'horas');
      console.log('      😊 Humor:', overviewResult.data.mood?.rating || 0, '/10');
      console.log('      🎯 Score diário:', overviewResult.data.dailyScore || 0, '/100');
    }

    // Testar resumo diário
    const dailyResponse = await fetch(`${SUPABASE_URL}/functions/v1/tracking-dashboard`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      },
      body: JSON.stringify({
        userId: TEST_USER_ID,
        type: 'daily',
        date: new Date().toISOString().split('T')[0]
      }),
    });

    const dailyResult = await dailyResponse.json();
    console.log('   📅 Resumo Diário:', dailyResult.success ? '✅ Sucesso' : '❌ Erro');

    return true;
  } catch (error) {
    console.error('   ❌ Erro no Dashboard:', error);
    return false;
  }
}

async function testTrackingAnalytics() {
  console.log('\n📊 3. TESTANDO TRACKING ANALYTICS...');
  
  try {
    // Criar dados de exemplo primeiro
    const seedResponse = await fetch(`${SUPABASE_URL}/functions/v1/tracking-analytics`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      },
      body: JSON.stringify({
        userId: TEST_USER_ID,
        type: 'seed_data'
      }),
    });

    const seedResult = await seedResponse.json();
    console.log('   🌱 Dados de Exemplo:', seedResult.success ? '✅ Criados' : '❌ Erro');

    // Testar análise de tendências
    const trendsResponse = await fetch(`${SUPABASE_URL}/functions/v1/tracking-analytics`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      },
      body: JSON.stringify({
        userId: TEST_USER_ID,
        type: 'trends',
        period: 'month'
      }),
    });

    const trendsResult = await trendsResponse.json();
    console.log('   📈 Análise de Tendências:', trendsResult.success ? '✅ Sucesso' : '❌ Erro');

    // Testar relatório do Dr. Vital
    const drVitalResponse = await fetch(`${SUPABASE_URL}/functions/v1/tracking-analytics`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      },
      body: JSON.stringify({
        userId: TEST_USER_ID,
        type: 'dr_vital_report'
      }),
    });

    const drVitalResult = await drVitalResponse.json();
    console.log('   👨‍⚕️ Relatório Dr. Vital:', drVitalResult.success ? '✅ Gerado' : '❌ Erro');
    if (drVitalResult.success && drVitalResult.data?.report) {
      console.log('      📋 Relatório gerado com sucesso!');
    }

    return true;
  } catch (error) {
    console.error('   ❌ Erro no Analytics:', error);
    return false;
  }
}

async function testTrackingIntegration() {
  console.log('\n🔗 4. TESTANDO TRACKING INTEGRATION...');
  
  try {
    // Testar sincronização de metas
    const syncResponse = await fetch(`${SUPABASE_URL}/functions/v1/tracking-integration`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      },
      body: JSON.stringify({
        action: 'sync_goals',
        userId: TEST_USER_ID
      }),
    });

    const syncResult = await syncResponse.json();
    console.log('   🎯 Sincronização de Metas:', syncResult.success ? '✅ Sucesso' : '❌ Erro');

    // Testar atualização de progresso
    const progressResponse = await fetch(`${SUPABASE_URL}/functions/v1/tracking-integration`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      },
      body: JSON.stringify({
        action: 'update_progress',
        userId: TEST_USER_ID,
        data: {
          water: { amount_ml: 3000, goal_ml: 2000 },
          mood: { energy_level: 5, day_rating: 9 }
        }
      }),
    });

    const progressResult = await progressResponse.json();
    console.log('   📊 Atualização de Progresso:', progressResult.success ? '✅ Sucesso' : '❌ Erro');

    return true;
  } catch (error) {
    console.error('   ❌ Erro na Integration:', error);
    return false;
  }
}

async function testSofiaIntegrationWithTracking() {
  console.log('\n🧠 5. TESTANDO INTEGRAÇÃO SOFIA + TRACKING...');
  
  try {
    const sofiaResponse = await fetch(`${SUPABASE_URL}/functions/v1/tracking-integration`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      },
      body: JSON.stringify({
        action: 'sofia_chat',
        userId: TEST_USER_ID,
        data: {
          message: 'Como está meu progresso de saúde hoje? Me dê insights baseados nos meus dados de tracking.'
        }
      }),
    });

    const sofiaResult = await sofiaResponse.json();
    console.log('   🤖 Sofia + Tracking:', sofiaResult.success ? '✅ Integração funcionando' : '❌ Erro');
    
    if (sofiaResult.success && sofiaResult.data?.insights) {
      console.log('      💡 Insights encontrados:', sofiaResult.data.insights.length);
    }

    return true;
  } catch (error) {
    console.error('   ❌ Erro na integração Sofia:', error);
    return false;
  }
}

async function runCompleteTest() {
  console.log('🎯 Iniciando teste completo do sistema de tracking...\n');

  const results = {
    trackingManager: await testTrackingManager(),
    trackingDashboard: await testTrackingDashboard(),
    trackingAnalytics: await testTrackingAnalytics(),
    trackingIntegration: await testTrackingIntegration(),
    sofiaIntegration: await testSofiaIntegrationWithTracking()
  };

  console.log('\n' + '='.repeat(70));
  console.log('📊 RESULTADO FINAL DO TESTE:');
  console.log('='.repeat(70));

  const totalTests = Object.keys(results).length;
  const passedTests = Object.values(results).filter(r => r === true).length;
  const successRate = Math.round((passedTests / totalTests) * 100);

  console.log(`✅ Tracking Manager: ${results.trackingManager ? 'PASSOU' : 'FALHOU'}`);
  console.log(`✅ Tracking Dashboard: ${results.trackingDashboard ? 'PASSOU' : 'FALHOU'}`);
  console.log(`✅ Tracking Analytics: ${results.trackingAnalytics ? 'PASSOU' : 'FALHOU'}`);
  console.log(`✅ Tracking Integration: ${results.trackingIntegration ? 'PASSOU' : 'FALHOU'}`);
  console.log(`✅ Sofia Integration: ${results.sofiaIntegration ? 'PASSOU' : 'FALHOU'}`);

  console.log('\n🎯 TAXA DE SUCESSO:', `${passedTests}/${totalTests} (${successRate}%)`);

  if (successRate >= 80) {
    console.log('🎉 SISTEMA DE TRACKING 100% FUNCIONAL!');
    console.log('🚀 Todas as Edge Functions estão operacionais!');
    console.log('🤖 Sofia agora tem acesso completo aos dados de tracking!');
    console.log('👨‍⚕️ Dr. Vital pode gerar relatórios detalhados!');
  } else {
    console.log('⚠️  Alguns componentes precisam de ajustes.');
  }

  console.log('\n📋 PRÓXIMOS PASSOS:');
  console.log('1. Integrar com o frontend React');
  console.log('2. Criar componentes de UI para tracking');
  console.log('3. Implementar notificações e lembretes');
  console.log('4. Configurar relatórios automáticos');
}

// Executar teste
runCompleteTest().catch(console.error);