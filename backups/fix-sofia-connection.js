// Script para corrigir conexão da Sofia
console.log('🔧 CORRIGINDO CONEXÃO DA SOFIA...');

// Verificar se a função está funcionando
async function fixSofiaConnection() {
  console.log('\n📋 VERIFICAÇÕES NECESSÁRIAS:');
  
  console.log('\n1. 🔑 VARIÁVEIS DE AMBIENTE (Supabase Dashboard):');
  console.log('   - GOOGLE_AI_API_KEY: Deve estar configurada');
  console.log('   - SUPABASE_URL: Deve estar configurada');
  console.log('   - SUPABASE_SERVICE_ROLE_KEY: Deve estar configurada');
  
  console.log('\n2. 🚀 REDEPLOY DA FUNÇÃO:');
  console.log('   Execute: npx supabase functions deploy health-chat-bot');
  
  console.log('\n3. 📱 TESTE NO FRONTEND:');
  console.log('   - Acesse: http://localhost:5174');
  console.log('   - Faça login na plataforma');
  console.log('   - Vá para o chat da Sofia');
  console.log('   - Teste: "Oi Sofia"');
  
  console.log('\n4. 🔍 VERIFICAR LOGS:');
  console.log('   - Abra F12 no navegador');
  console.log('   - Vá para aba Network');
  console.log('   - Envie mensagem para Sofia');
  console.log('   - Veja se há erro 401 ou outros');
  
  console.log('\n✅ SOFIA FUNCIONANDO SIGNIFICA:');
  console.log('   ✓ IA conectada permanentemente');
  console.log('   ✓ Usuários podem conversar');
  console.log('   ✓ Análise de comida funciona');
  console.log('   ✓ Dados sendo coletados');
  console.log('   ✓ Relatórios sendo gerados');
}

fixSofiaConnection();