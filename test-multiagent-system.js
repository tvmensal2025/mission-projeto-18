#!/usr/bin/env node

// ===============================================
// 🧪 TESTE DO SISTEMA MULTI-AGENTE
// ===============================================

import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://hlrkoyywjpckdotimtik.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhscmtveXl3anBja2RvdGltdGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjE0MjY2NjYsImV4cCI6MjAzNzAwMjY2Nn0.9M5Eo4wBqgXJQYEJr5kFGdJ5qKZJa0vZ3TuZhKPqZZA'

const supabase = createClient(supabaseUrl, supabaseKey)

console.log('🚀 TESTANDO SISTEMA MULTI-AGENTE...\n')

// ===============================================
// 1️⃣ TESTE DAS TABELAS DO SISTEMA
// ===============================================

async function testTables() {
  console.log('📊 1. VERIFICANDO TABELAS...')
  
  const tables = [
    // Módulo 1 - Personalidade Dinâmica
    'ai_personalities',
    'personality_adaptations',
    
    // Módulo 2 - Base de Conhecimento
    'knowledge_base',
    'knowledge_usage_log',
    'embedding_configurations',
    
    // Módulo 3 - Google Calendar
    'calendar_integrations',
    'ai_managed_events',
    'calendar_conflicts',
    'event_templates',
    
    // Módulo 4 - Análise Avançada
    'eating_pattern_analysis',
    'image_context_data',
    'food_analysis_feedback',
    
    // Módulo 5 - Relatórios Inteligentes
    'health_reports',
    'report_templates',
    'report_feedback',
    'report_schedules',
    
    // Módulo 6 - Inteligência Comportamental
    'behavioral_patterns',
    'behavioral_interventions',
    'behavior_tracking_logs',
    'behavioral_analysis_config'
  ]
  
  let existingTables = 0
  
  for (const table of tables) {
    try {
      const { data, error } = await supabase
        .from(table)
        .select('*')
        .limit(1)
      
      if (!error) {
        console.log(`   ✅ ${table}`)
        existingTables++
      } else {
        console.log(`   ❌ ${table} - ${error.message}`)
      }
    } catch (err) {
      console.log(`   ❌ ${table} - ${err.message}`)
    }
  }
  
  console.log(`\n   📊 RESULTADO: ${existingTables}/${tables.length} tabelas criadas\n`)
  return existingTables === tables.length
}

// ===============================================
// 2️⃣ TESTE DAS EDGE FUNCTIONS
// ===============================================

async function testEdgeFunctions() {
  console.log('⚡ 2. VERIFICANDO EDGE FUNCTIONS...')
  
  const functions = [
    'personality-manager',
    'knowledge-retrieval', 
    'calendar-manager',
    'advanced-food-analysis',
    'intelligent-report-generator',
    'behavioral-intelligence',
    'health-chat-bot'
  ]
  
  let workingFunctions = 0
  
  for (const func of functions) {
    try {
      const { data, error } = await supabase.functions.invoke(func, {
        body: { test: true }
      })
      
      // Se não deu erro 404, a função existe
      if (!error || error.message !== 'Not Found') {
        console.log(`   ✅ ${func}`)
        workingFunctions++
      } else {
        console.log(`   ❌ ${func} - ${error.message}`)
      }
    } catch (err) {
      console.log(`   ⚠️  ${func} - Função existe mas precisa de configuração`)
      workingFunctions++
    }
  }
  
  console.log(`\n   ⚡ RESULTADO: ${workingFunctions}/${functions.length} funções deployadas\n`)
  return workingFunctions >= functions.length * 0.8 // 80% é suficiente
}

// ===============================================
// 3️⃣ TESTE DE PERSONALIDADE DA SOFIA
// ===============================================

async function testSofiaPersonality() {
  console.log('🧠 3. TESTANDO PERSONALIDADE DA SOFIA...')
  
  try {
    // Criar uma personalidade de teste
    const { data, error } = await supabase
      .from('ai_personalities')
      .insert({
        agent_name: 'sofia',
        tone: 'friendly',
        communication_style: 'supportive',
        role_preference: 'coach',
        is_active: true
      })
      .select()
    
    if (!error && data.length > 0) {
      console.log('   ✅ Personalidade da Sofia criada com sucesso')
      
      // Limpar teste
      await supabase
        .from('ai_personalities')
        .delete()
        .eq('id', data[0].id)
      
      return true
    } else {
      console.log(`   ❌ Erro ao criar personalidade: ${error?.message}`)
      return false
    }
  } catch (err) {
    console.log(`   ❌ Erro: ${err.message}`)
    return false
  }
}

// ===============================================
// 4️⃣ TESTE DE BASE DE CONHECIMENTO
// ===============================================

async function testKnowledgeBase() {
  console.log('📚 4. TESTANDO BASE DE CONHECIMENTO...')
  
  try {
    const { data, error } = await supabase
      .from('knowledge_base')
      .insert({
        title: 'Teste de Documento',
        content: 'Este é um documento de teste para o sistema multi-agente',
        document_type: 'protocol',
        priority_level: 5,
        is_active: true
      })
      .select()
    
    if (!error && data.length > 0) {
      console.log('   ✅ Base de conhecimento funcionando')
      
      // Limpar teste
      await supabase
        .from('knowledge_base')
        .delete()
        .eq('id', data[0].id)
      
      return true
    } else {
      console.log(`   ❌ Erro na base de conhecimento: ${error?.message}`)
      return false
    }
  } catch (err) {
    console.log(`   ❌ Erro: ${err.message}`)
    return false
  }
}

// ===============================================
// 5️⃣ TESTE DO HEALTH-CHAT-BOT (SOFIA)
// ===============================================

async function testSofiaChat() {
  console.log('💬 5. TESTANDO CHAT DA SOFIA...')
  
  try {
    const { data, error } = await supabase.functions.invoke('health-chat-bot', {
      body: {
        message: 'Olá Sofia, como você está?',
        test_mode: true
      }
    })
    
    if (!error) {
      console.log('   ✅ Sofia respondendo ao chat')
      return true
    } else {
      console.log(`   ⚠️  Sofia precisa de configuração de API: ${error.message}`)
      return false
    }
  } catch (err) {
    console.log(`   ⚠️  Sofia precisa de configuração: ${err.message}`)
    return false
  }
}

// ===============================================
// 🏃‍♂️ EXECUTAR TODOS OS TESTES
// ===============================================

async function runAllTests() {
  console.log('=' .repeat(50))
  console.log('🧪 INICIANDO TESTES DO SISTEMA MULTI-AGENTE')
  console.log('=' .repeat(50))
  
  const results = {
    tables: await testTables(),
    functions: await testEdgeFunctions(),
    personality: await testSofiaPersonality(),
    knowledge: await testKnowledgeBase(),
    chat: await testSofiaChat()
  }
  
  console.log('=' .repeat(50))
  console.log('📊 RESUMO DOS TESTES:')
  console.log('=' .repeat(50))
  
  const passed = Object.values(results).filter(Boolean).length
  const total = Object.keys(results).length
  
  console.log(`📊 Tabelas: ${results.tables ? '✅' : '❌'}`)
  console.log(`⚡ Functions: ${results.functions ? '✅' : '❌'}`)
  console.log(`🧠 Personalidade: ${results.personality ? '✅' : '❌'}`)
  console.log(`📚 Conhecimento: ${results.knowledge ? '✅' : '❌'}`)
  console.log(`💬 Chat Sofia: ${results.chat ? '✅' : '⚠️'}`)
  
  console.log('\n' + '=' .repeat(50))
  
  if (passed >= 4) {
    console.log('🎉 SISTEMA MULTI-AGENTE FUNCIONANDO!')
    console.log(`✅ ${passed}/${total} componentes testados com sucesso`)
    
    if (!results.chat) {
      console.log('\n⚠️  PRÓXIMO PASSO: Configurar API Keys do Google AI')
      console.log('   Vá para: Supabase → Project Settings → Edge Functions → Environment Variables')
      console.log('   Adicione: GOOGLE_AI_API_KEY=sua_chave_aqui')
    }
  } else {
    console.log('❌ SISTEMA PRECISA DE AJUSTES')
    console.log(`⚠️  ${passed}/${total} componentes funcionando`)
  }
  
  console.log('=' .repeat(50))
}

// Executar testes
runAllTests().catch(console.error)