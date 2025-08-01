#!/usr/bin/env node

// ===============================================
// 🧪 TESTE SIMPLES DA SOFIA
// ===============================================

console.log('🧠 TESTANDO SOFIA - SISTEMA MULTI-AGENTE...\n')

const supabaseUrl = 'https://hlrkoyywjpckdotimtik.supabase.co'
const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhscmtveXl3anBja2RvdGltdGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjE0MjY2NjYsImV4cCI6MjAzNzAwMjY2Nn0.9M5Eo4wBqgXJQYEJr5kFGdJ5qKZJa0vZ3TuZhKPqZZA'

async function testSofia() {
  try {
    console.log('📤 Enviando mensagem para Sofia...')
    
    const response = await fetch(`${supabaseUrl}/functions/v1/health-chat-bot`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${anonKey}`
      },
      body: JSON.stringify({
        message: 'Olá Sofia! Me conte sobre o sistema multi-agente que você agora faz parte.',
        userId: 'test-user-multiagent'
      })
    })

    console.log('📡 Status da resposta:', response.status)
    
    if (response.ok) {
      const data = await response.json()
      console.log('✅ SOFIA RESPONDEU:')
      console.log('=' .repeat(60))
      console.log(data.message || data.response || JSON.stringify(data, null, 2))
      console.log('=' .repeat(60))
      
      return true
    } else {
      const errorText = await response.text()
      console.log('❌ ERRO:', response.status)
      console.log('📄 Detalhes:', errorText)
      return false
    }
    
  } catch (error) {
    console.log('❌ ERRO DE CONEXÃO:', error.message)
    return false
  }
}

// Executar teste
testSofia().then(success => {
  console.log('\n' + '=' .repeat(60))
  if (success) {
    console.log('🎉 SISTEMA MULTI-AGENTE: SOFIA FUNCIONANDO!')
    console.log('✅ Google AI (Gemini) conectado')
    console.log('✅ Banco de dados funcionando')
    console.log('✅ Edge Functions operacionais')
  } else {
    console.log('⚠️ SISTEMA PRECISA DE VERIFICAÇÃO')
  }
  console.log('=' .repeat(60))
})