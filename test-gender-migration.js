import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'http://127.0.0.1:54321';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';
const supabase = createClient(supabaseUrl, supabaseKey);

async function testGenderMigration() {
  try {
    console.log('🧪 Testando migração de gender...');
    
    // 1. Fazer login como usuário existente
    const { data: { session }, error: signInError } = await supabase.auth.signInWithPassword({
      email: 'teste@institutodossonhos.com',
      password: 'teste123456'
    });
    
    if (signInError) {
      console.error('❌ Erro no login:', signInError);
      return;
    }
    
    console.log('✅ Login realizado');
    
    // 2. Testar busca de gender na tabela profiles
    console.log('🔍 Buscando gender na tabela profiles...');
    const { data: profileData, error: profileError } = await supabase
      .from('profiles')
      .select('gender, full_name, email')
      .eq('user_id', session.user.id)
      .single();
    
    if (profileError) {
      console.error('❌ Erro ao buscar profile:', profileError);
    } else {
      console.log('✅ Profile encontrado:', {
        full_name: profileData.full_name,
        email: profileData.email,
        gender: profileData.gender
      });
    }
    
    // 3. Testar busca de sexo na tabela user_physical_data
    console.log('🔍 Buscando sexo na tabela user_physical_data...');
    const { data: physicalData, error: physicalError } = await supabase
      .from('user_physical_data')
      .select('sexo, altura_cm, idade')
      .eq('user_id', session.user.id)
      .single();
    
    if (physicalError) {
      console.error('❌ Erro ao buscar dados físicos:', physicalError);
    } else {
      console.log('✅ Dados físicos encontrados:', {
        sexo: physicalData.sexo,
        altura_cm: physicalData.altura_cm,
        idade: physicalData.idade
      });
    }
    
    // 4. Verificar se os dados estão sincronizados
    console.log('🔍 Verificando sincronização...');
    if (profileData?.gender && physicalData?.sexo) {
      const genderMap = {
        'masculino': 'male',
        'feminino': 'female'
      };
      const expectedGender = genderMap[physicalData.sexo];
      
      if (profileData.gender === expectedGender) {
        console.log('✅ Dados sincronizados corretamente!');
      } else {
        console.log('⚠️ Dados não sincronizados:', {
          profile_gender: profileData.gender,
          physical_sexo: physicalData.sexo,
          expected_gender: expectedGender
        });
      }
    }
    
    console.log('🎉 Teste de migração de gender concluído!');
    
  } catch (error) {
    console.error('💥 Erro geral:', error);
  }
}

testGenderMigration(); 