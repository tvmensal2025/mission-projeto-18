// Script para atualizar configurações de IA via API do Supabase
const SUPABASE_URL = "https://hlrkoyywjpckdotimtik.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhscmtveXl3anBja2RvdGltdGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMxNTMwNDcsImV4cCI6MjA2ODcyOTA0N30.kYEtg1hYG2pmcyIeXRs-vgNIVOD76Yu7KPlyFN0vdUI";

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
    console.log('🚀 Iniciando atualização das configurações de IA via API...');
    
    // Primeiro, vamos buscar as configurações atuais
    const { data: currentConfigs, error: fetchError } = await fetch(`${SUPABASE_URL}/rest/v1/ai_configurations`, {
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json'
      }
    }).then(res => res.json());
    
    if (fetchError) {
      console.error('❌ Erro ao buscar configurações atuais:', fetchError);
      return;
    }
    
    console.log('📊 Configurações atuais encontradas:', currentConfigs?.length || 0);
    
    // Atualizar cada configuração
    for (const config of UPDATED_CONFIGURATIONS) {
      const { data, error } = await fetch(`${SUPABASE_URL}/rest/v1/ai_configurations`, {
        method: 'POST',
        headers: {
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json',
          'Prefer': 'resolution=merge-duplicates'
        },
        body: JSON.stringify(config)
      }).then(res => res.json());
      
      if (error) {
        console.error(`❌ Erro ao atualizar ${config.functionality}:`, error);
      } else {
        console.log(`✅ ${config.functionality} atualizado: ${config.model} (${config.max_tokens} tokens)`);
      }
    }
    
    console.log('\n🎯 Atualização concluída!');
    console.log('📈 Principais melhorias:');
    console.log('  • Atualizado para GPT-4o e GPT-4o-mini');
    console.log('  • Otimizado tokens para cada funcionalidade');
    console.log('  • Temperaturas ajustadas para melhor performance');
    console.log('  • Adicionadas novas funcionalidades');
    
  } catch (error) {
    console.error('💥 Erro fatal:', error);
  }
}

// Executar a atualização
updateAIConfigurations(); 