import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'http://127.0.0.1:54321';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';
const supabase = createClient(supabaseUrl, supabaseKey);

async function testSignupWithGender() {
  try {
    console.log('🧪 Testando cadastro com gênero...');
    
    const testEmail = `teste-gender-${Date.now()}@example.com`;
    
    // 1. Fazer signup
    console.log('🔍 Fazendo signup...');
    const { data, error } = await supabase.auth.signUp({
      email: testEmail,
      password: 'teste123456',
      options: {
        data: {
          full_name: 'Teste Gênero',
          phone: '11999999999',
          birth_date: '1990-01-01',
          gender: 'male',
          city: 'São Paulo',
          state: 'SP',
          height: 175,
        },
      },
    });

    if (error) {
      console.error('❌ Erro no signup:', error);
      return;
    }

    console.log('✅ Signup realizado com sucesso!');
    console.log('📋 Usuário criado:', data.user?.id);
    
    // 2. Verificar se perfil foi criado
    console.log('🔍 Verificando perfil criado...');
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('user_id', data.user?.id)
      .single();

    if (profileError) {
      console.error('❌ Erro ao buscar perfil:', profileError);
    } else {
      console.log('✅ Perfil encontrado:', {
        user_id: profile.user_id,
        full_name: profile.full_name,
        email: profile.email,
        gender: profile.gender,
        altura_cm: profile.altura_cm,
        city: profile.city,
        estado: profile.estado
      });
    }
    
    console.log('🎉 Teste de cadastro com gênero concluído!');
    
  } catch (error) {
    console.error('💥 Erro geral:', error);
  }
}

testSignupWithGender(); 