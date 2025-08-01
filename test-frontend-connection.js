// Teste de conexão do frontend com Supabase local
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'http://127.0.0.1:54321';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testFrontendConnection() {
  try {
    console.log('🧪 Testando conexão do frontend com Supabase local...');
    console.log(`🔧 URL: ${supabaseUrl}`);

    // 1. Criar usuário de teste
    const { data: { user }, error: authError } = await supabase.auth.signUp({
      email: 'test-frontend@example.com',
      password: 'test123456'
    });

    if (authError) {
      console.log('⚠️ Usuário já existe ou erro de auth:', authError.message);
    } else {
      console.log('✅ Usuário de teste criado:', user?.id);
    }

    // 2. Fazer login
    const { data: { session }, error: signInError } = await supabase.auth.signInWithPassword({
      email: 'test-frontend@example.com',
      password: 'test123456'
    });

    if (signInError) {
      console.error('❌ Erro no login:', signInError);
      return;
    }

    console.log('✅ Login realizado com sucesso');
    console.log('👤 User ID:', session?.user?.id);

    // 3. Testar busca de desafios
    const { data: challenges, error: challengeError } = await supabase
      .from('challenges')
      .select('*')
      .limit(3);

    if (challengeError) {
      console.error('❌ Erro ao buscar desafios:', challengeError);
    } else {
      console.log('✅ Desafios encontrados:', challenges?.length || 0);
      if (challenges && challenges.length > 0) {
        console.log('📋 Primeiro desafio:', challenges[0].title);
      }
    }

    // 4. Testar inserção de participação (agora autenticado)
    const testChallenge = challenges?.[0];
    if (testChallenge && session?.user?.id) {
      const { data: participation, error: insertError } = await supabase
        .from('challenge_participations')
        .insert({
          user_id: session.user.id,
          challenge_id: testChallenge.id,
          target_value: 2000,
          current_value: 0,
          progress_percentage: 0,
          status: 'active',
          start_date: new Date().toISOString()
        })
        .select()
        .single();

      if (insertError) {
        console.error('❌ Erro ao inserir participação:', insertError);
        if (insertError.code === '23505') {
          console.log('ℹ️ Participação já existe (erro esperado)');
        }
      } else {
        console.log('✅ Participação criada com sucesso:', participation.id);
      }
    }

    // 5. Testar busca de participações (agora autenticado)
    const { data: participations, error: listError } = await supabase
      .from('challenge_participations')
      .select('*')
      .eq('user_id', session?.user?.id)
      .limit(5);

    if (listError) {
      console.error('❌ Erro ao listar participações:', listError);
    } else {
      console.log('✅ Participações encontradas:', participations?.length || 0);
      if (participations && participations.length > 0) {
        console.log('📋 Primeira participação:', {
          id: participations[0].id,
          challenge_id: participations[0].challenge_id,
          target_value: participations[0].target_value,
          current_value: participations[0].current_value,
          progress_percentage: participations[0].progress_percentage,
          status: participations[0].status
        });
      }
    }

    console.log('🎉 Teste de conexão concluído!');

  } catch (error) {
    console.error('💥 Erro geral:', error);
  }
}

testFrontendConnection(); 