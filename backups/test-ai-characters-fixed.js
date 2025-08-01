import { createClient } from '@supabase/supabase-js';

// Configurar cliente Supabase
const supabaseUrl = 'https://hlrkoyywjpckdotimtik.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhscmtveXl3anBja2RvdGltdGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMxNTMwNDcsImV4cCI6MjA2ODcyOTA0N30.kYEtg1hYG2pmcyIeXRs-vgNIVOD76Yu7KPlyFN0vdUI';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testAIFixed() {
  console.log('🎭 Testando Sofia e Dr. Vital ajustados...');
  
  try {
    // Teste 1: Sofia (dia comum)
    console.log('\n💜 Testando Sofia (dia comum)...');
    
    const { data: sofiaData, error: sofiaError } = await supabase.functions.invoke('health-chat-bot', {
      body: {
        message: 'Oi Sofia, como você está?',
        userId: 'dd77ccfd-bc48-493d-9a01-257f5e8a1f2d',
        conversationHistory: []
      }
    });

    if (sofiaError) {
      console.log('❌ Erro Sofia:', sofiaError);
    } else {
      console.log('✅ Sofia respondeu:', sofiaData.response);
      console.log('🎭 Personagem:', sofiaData.character);
      console.log('📅 É sexta?', sofiaData.isFriday);
    }

    // Simular sexta-feira alterando o contexto
    console.log('\n👨‍⚕️ Simulando Dr. Vital (sexta-feira)...');
    
    // Para simular sexta, vamos enviar no contexto que é sexta
    const { data: drVitalData, error: drVitalError } = await supabase.functions.invoke('health-chat-bot', {
      body: {
        message: 'Dr. Vital, pode me dar um resumo da minha semana?',
        userId: 'dd77ccfd-bc48-493d-9a01-257f5e8a1f2d',
        conversationHistory: []
      }
    });

    if (drVitalError) {
      console.log('❌ Erro Dr. Vital:', drVitalError);
    } else {
      console.log('✅ Dr. Vital respondeu:', drVitalData.response);
      console.log('🎭 Personagem:', drVitalData.character);
      console.log('📅 É sexta?', drVitalData.isFriday);
    }

  } catch (error) {
    console.error('❌ Erro no teste:', error);
  }
}

testAIFixed();