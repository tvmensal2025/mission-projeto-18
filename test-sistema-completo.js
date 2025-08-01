#!/usr/bin/env node

// ===============================================
// 🧪 TESTE COMPLETO DO SISTEMA MULTI-AGENTE
// ===============================================

console.log('🚀 TESTANDO SISTEMA MULTI-AGENTE COMPLETO...\n')

const supabaseUrl = 'https://hlrkoyywjpckdotimtik.supabase.co'

// ===============================================
// 1️⃣ TESTE DA SOFIA (Chat com Google AI)
// ===============================================
async function testSofia() {
  console.log('🧠 1. TESTANDO SOFIA (Health Chat Bot)...')
  
  try {
    const response = await fetch(`${supabaseUrl}/functions/v1/health-chat-bot`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhscmtveXl3anBja2RvdGltdGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjE0MjY2NjYsImV4cCI6MjAzNzAwMjY2Nn0.9M5Eo4wBqgXJQYEJr5kFGdJ5qKZJa0vZ3TuZhKPqZZA'
      },
      body: JSON.stringify({
        message: 'Olá Sofia! Como você está hoje?',
        userId: 'test-user-123'
      })
    })

    if (response.ok) {
      const data = await response.json()
      console.log('   ✅ Sofia respondeu:', data.message?.substring(0, 100) + '...')
      return true
    } else {
      console.log('   ❌ Sofia não respondeu:', response.status)
      return false
    }
  } catch (error) {
    console.log('   ❌ Erro ao testar Sofia:', error.message)
    return false
  }
}

// ===============================================
// 2️⃣ TESTE DO GOOGLE CALENDAR INTEGRATION
// ===============================================
async function testCalendar() {
  console.log('📅 2. TESTANDO GOOGLE CALENDAR INTEGRATION...')
  
  try {
    const response = await fetch(`${supabaseUrl}/functions/v1/calendar-manager`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhscmtveXl3anBja2RvdGltdGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjE0MjY2NjYsImV4cCI6MjAzNzAwMjY2Nn0.9M5Eo4wBqgXJQYEJr5kFGdJ5qKZJa0vZ3TuZhKPqZZA'
      },
      body: JSON.stringify({
        userId: 'test-user-123',
        action: 'setup_oauth'
      })
    })

    if (response.ok) {
      const data = await response.json()
      console.log('   ✅ Calendar Integration OK:', data.success)
      return true
    } else {
      console.log('   ❌ Calendar não funcionou:', response.status)
      return false
    }
  } catch (error) {
    console.log('   ❌ Erro ao testar Calendar:', error.message)
    return false
  }
}

// ===============================================
// 3️⃣ TESTE DO SISTEMA DE PERSONALIDADE
// ===============================================
async function testPersonality() {
  console.log('🎭 3. TESTANDO SISTEMA DE PERSONALIDADE...')
  
  try {
    const response = await fetch(`${supabaseUrl}/functions/v1/personality-manager`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhscmtveXl3anBja2RvdGltdGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjE0MjY2NjYsImV4cCI6MjAzNzAwMjY2Nn0.9M5Eo4wBqgXJQYEJr5kFGdJ5qKZJa0vZ3TuZhKPqZZA'
      },
      body: JSON.stringify({
        action: 'get_personality',
        userId: 'test-user-123',
        aiCharacter: 'sofia'
      })
    })

    if (response.ok) {
      const data = await response.json()
      console.log('   ✅ Sistema de Personalidade OK:', data.success)
      return true
    } else {
      console.log('   ❌ Personalidade não funcionou:', response.status)
      return false
    }
  } catch (error) {
    console.log('   ❌ Erro ao testar Personalidade:', error.message)
    return false
  }
}

// ===============================================
// 4️⃣ TESTE DO KNOWLEDGE BASE
// ===============================================
async function testKnowledgeBase() {
  console.log('📚 4. TESTANDO KNOWLEDGE BASE...')
  
  try {
    const response = await fetch(`${supabaseUrl}/functions/v1/knowledge-retrieval`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhscmtveXl3anBja2RvdGltdGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjE0MjY2NjYsImV4cCI6MjAzNzAwMjY2Nn0.9M5Eo4wBqgXJQYEJr5kFGdJ5qKZJa0vZ3TuZhKPqZZA'
      },
      body: JSON.stringify({
        action: 'search',
        query: 'protocolo de saúde',
        userId: 'test-user-123'
      })
    })

    if (response.ok) {
      const data = await response.json()
      console.log('   ✅ Knowledge Base OK:', data.success)
      return true
    } else {
      console.log('   ❌ Knowledge Base não funcionou:', response.status)
      return false
    }
  } catch (error) {
    console.log('   ❌ Erro ao testar Knowledge Base:', error.message)
    return false
  }
}

// ===============================================
// 5️⃣ EXECUTAR TODOS OS TESTES
// ===============================================
async function runAllTests() {
  console.log('=' .repeat(50))
  console.log('🧪 INICIANDO BATERIA DE TESTES COMPLETA')
  console.log('=' .repeat(50) + '\n')

  const results = {
    sofia: await testSofia(),
    calendar: await testCalendar(),
    personality: await testPersonality(),
    knowledge: await testKnowledgeBase()
  }

  console.log('\n' + '=' .repeat(50))
  console.log('📊 RESULTADOS FINAIS:')
  console.log('=' .repeat(50))
  
  console.log(`🧠 Sofia (Chat AI):           ${results.sofia ? '✅ FUNCIONANDO' : '❌ ERRO'}`)
  console.log(`📅 Google Calendar:          ${results.calendar ? '✅ FUNCIONANDO' : '❌ ERRO'}`)
  console.log(`🎭 Sistema Personalidade:    ${results.personality ? '✅ FUNCIONANDO' : '❌ ERRO'}`)
  console.log(`📚 Knowledge Base:           ${results.knowledge ? '✅ FUNCIONANDO' : '❌ ERRO'}`)

  const successCount = Object.values(results).filter(Boolean).length
  const totalTests = Object.values(results).length

  console.log('\n' + '=' .repeat(50))
  console.log(`🎯 SISTEMA MULTI-AGENTE: ${successCount}/${totalTests} MÓDULOS FUNCIONANDO`)
  
  if (successCount === totalTests) {
    console.log('🎉 PARABÉNS! SISTEMA 100% FUNCIONAL!')
  } else if (successCount >= totalTests * 0.75) {
    console.log('✅ SISTEMA MAJORITARIAMENTE FUNCIONAL!')
  } else {
    console.log('⚠️ SISTEMA PRECISA DE AJUSTES')
  }
  console.log('=' .repeat(50))
}

// Executar testes
runAllTests()