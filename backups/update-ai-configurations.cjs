const { createClient } = require('@supabase/supabase-js');

// Configuração do Supabase
const supabaseUrl = 'https://hlrkoyywjpckdotimtik.supabase.co';
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhscmtveXl3anBja2RvdGlrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczMjk3Mjk3NCwiZXhwIjoyMDQ4NTQ4OTc0fQ.Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8';

const supabase = createClient(supabaseUrl, supabaseServiceKey);

// Novas configurações otimizadas de IA
const UPDATED_CONFIGURATIONS = [
  {
    functionality: 'chat_daily',
    service: 'openai',
    model: 'gpt-4o-mini',
    max_tokens: 2048,
    temperature: 0.8,
    is_enabled: true,
    preset_level: 'medio'
  },
  {
    functionality: 'weekly_report',
    service: 'openai',
    model: 'gpt-4o',
    max_tokens: 4096,
    temperature: 0.7,
    is_enabled: true,
    preset_level: 'maximo'
  },
  {
    functionality: 'monthly_report',
    service: 'openai',
    model: 'gpt-4o',
    max_tokens: 4096,
    temperature: 0.6,
    is_enabled: true,
    preset_level: 'maximo'
  },
  {
    functionality: 'medical_analysis',
    service: 'openai',
    model: 'gpt-4o',
    max_tokens: 4096,
    temperature: 0.3,
    is_enabled: true,
    preset_level: 'maximo'
  },
  {
    functionality: 'preventive_analysis',
    service: 'openai',
    model: 'gpt-4o',
    max_tokens: 4096,
    temperature: 0.5,
    is_enabled: true,
    preset_level: 'maximo'
  },
  {
    functionality: 'food_analysis',
    service: 'openai',
    model: 'gpt-4o',
    max_tokens: 2048,
    temperature: 0.6,
    is_enabled: true,
    preset_level: 'medio'
  },
  {
    functionality: 'health_chat',
    service: 'openai',
    model: 'gpt-4o-mini',
    max_tokens: 2048,
    temperature: 0.8,
    is_enabled: true,
    preset_level: 'medio'
  },
  {
    functionality: 'goal_analysis',
    service: 'openai',
    model: 'gpt-4o-mini',
    max_tokens: 2048,
    temperature: 0.7,
    is_enabled: true,
    preset_level: 'medio'
  }
];

async function updateAIConfigurations() {
  try {
    console.log('🚀 Iniciando atualização das configurações de IA...');
    
    // Primeiro, vamos limpar as configurações existentes
    const { error: deleteError } = await supabase
      .from('ai_configurations')
      .delete()
      .neq('id', '00000000-0000-0000-0000-000000000000'); // Deletar todos exceto um registro dummy
    
    if (deleteError) {
      console.error('❌ Erro ao limpar configurações:', deleteError);
      return;
    }
    
    console.log('✅ Configurações antigas removidas');
    
    // Inserir novas configurações
    const { data, error } = await supabase
      .from('ai_configurations')
      .insert(UPDATED_CONFIGURATIONS)
      .select();
    
    if (error) {
      console.error('❌ Erro ao inserir novas configurações:', error);
      return;
    }
    
    console.log('✅ Configurações atualizadas com sucesso!');
    console.log('📊 Resumo das configurações:');
    
    data.forEach(config => {
      console.log(`  • ${config.functionality}: ${config.model} (${config.max_tokens} tokens, temp: ${config.temperature})`);
    });
    
    console.log('\n🎯 Principais melhorias:');
    console.log('  • Atualizado para GPT-4o e GPT-4o-mini (mais rápidos e eficientes)');
    console.log('  • Otimizado tokens para cada funcionalidade');
    console.log('  • Temperaturas ajustadas para melhor performance');
    console.log('  • Adicionadas novas funcionalidades (food_analysis, health_chat, goal_analysis)');
    
  } catch (error) {
    console.error('💥 Erro fatal:', error);
  }
}

// Executar a atualização
updateAIConfigurations(); 