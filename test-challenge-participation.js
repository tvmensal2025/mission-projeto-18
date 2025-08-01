// Teste da tabela challenge_participations
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'http://127.0.0.1:54321';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testChallengeParticipation() {
  try {
    console.log('🧪 Testando challenge_participations...');

    // 1. Verificar se a tabela existe
    const { data: tableExists, error: tableError } = await supabase
      .from('challenge_participations')
      .select('count')
      .limit(1);

    if (tableError) {
      console.error('❌ Erro ao verificar tabela:', tableError);
      return;
    }

    console.log('✅ Tabela challenge_participations existe');

    // 2. Buscar um desafio existente
    const { data: challenges, error: challengeError } = await supabase
      .from('challenges')
      .select('id, title')
      .limit(1);

    if (challengeError || !challenges || challenges.length === 0) {
      console.error('❌ Erro ao buscar desafios:', challengeError);
      return;
    }

    const challenge = challenges[0];
    console.log('✅ Desafio encontrado:', challenge.title);

    // 3. Criar um usuário de teste (se necessário)
    const { data: { user }, error: authError } = await supabase.auth.signUp({
      email: 'test@example.com',
      password: 'test123456'
    });

    if (authError) {
      console.log('⚠️ Usuário já existe ou erro de auth:', authError.message);
    } else {
      console.log('✅ Usuário de teste criado:', user?.id);
    }

    // 4. Tentar inserir uma participação
    const { data: participation, error: insertError } = await supabase
      .from('challenge_participations')
      .insert({
        user_id: user?.id || '00000000-0000-0000-0000-000000000000', // fallback
        challenge_id: challenge.id,
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
      
      // Se for erro de constraint única, tentar buscar participação existente
      if (insertError.code === '23505') {
        console.log('ℹ️ Participação já existe, buscando...');
        const { data: existingParticipation, error: fetchError } = await supabase
          .from('challenge_participations')
          .select('*')
          .eq('user_id', user?.id || '00000000-0000-0000-0000-000000000000')
          .eq('challenge_id', challenge.id)
          .single();

        if (fetchError) {
          console.error('❌ Erro ao buscar participação existente:', fetchError);
        } else {
          console.log('✅ Participação existente encontrada:', existingParticipation);
        }
      }
    } else {
      console.log('✅ Participação criada com sucesso:', participation);
    }

    // 5. Listar todas as participações
    const { data: allParticipations, error: listError } = await supabase
      .from('challenge_participations')
      .select('*')
      .limit(5);

    if (listError) {
      console.error('❌ Erro ao listar participações:', listError);
    } else {
      console.log('✅ Participações encontradas:', allParticipations?.length || 0);
      if (allParticipations && allParticipations.length > 0) {
        console.log('📋 Primeira participação:', allParticipations[0]);
      }
    }

    console.log('🎉 Teste concluído!');

  } catch (error) {
    console.error('💥 Erro geral:', error);
  }
}

testChallengeParticipation(); 