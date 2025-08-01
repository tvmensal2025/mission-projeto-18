import { createClient } from '@supabase/supabase-js';

// Configurar cliente Supabase
const supabaseUrl = 'https://hlrkoyywjpckdotimtik.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhscmtveXl3anBja2RvdGltdGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU2NzI2NzAsImV4cCI6MjA1MTI0ODY3MH0.80f8f319d66e7e9e0ab9bc4deb8201d07649b9327356caaa441b7603d1f4358a';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testAIConfiguration() {
  console.log('🔧 Testando configuração da IA...');
  
  try {
    // Testar a edge function health-chat-bot
    console.log('📤 Testando Sofia...');
    
    const { data, error } = await supabase.functions.invoke('health-chat-bot', {
      body: {
        message: 'Olá Sofia, me ajude!',
        userId: 'dd77ccfd-bc48-493d-9a01-257f5e8a1f2d', // ID de teste
        conversationHistory: []
      }
    });

    if (error) {
      console.log('❌ Erro na Sofia:', error);
    } else {
      console.log('✅ Sofia funcionando:', data.response);
      console.log('🤖 Personagem:', data.character);
      console.log('📊 Dados do usuário:', data.userSummary);
      
      if (data.response.includes('temporariamente indisponível')) {
        console.log('⚠️ IA sem chave do Google configurada');
      } else {
        console.log('🎉 IA do Google funcionando!');
      }
    }

  } catch (error) {
    console.error('❌ Erro no teste:', error);
  }
}

testAIConfiguration();