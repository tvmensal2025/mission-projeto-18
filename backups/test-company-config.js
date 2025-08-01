// Teste de configuração da empresa
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'http://127.0.0.1:54321';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testCompanyConfig() {
  try {
    console.log('🧪 Testando configuração da empresa...');

    // 1. Fazer login como admin
    const { data: { session }, error: signInError } = await supabase.auth.signInWithPassword({
      email: 'admin@test.com',
      password: 'admin123456'
    });

    if (signInError) {
      console.error('❌ Erro no login:', signInError);
      return;
    }

    console.log('✅ Login realizado');

    // 2. Testar busca de dados da empresa (como o frontend faz)
    console.log('🔍 Buscando dados da empresa...');
    const { data: companyData, error: fetchError } = await supabase
      .from('company_data')
      .select('*')
      .limit(1)
      .single();

    if (fetchError) {
      console.log('⚠️ Dados da empresa não encontrados (esperado na primeira vez)');
    } else {
      console.log('✅ Dados da empresa encontrados:', companyData);
    }

    // 3. Criar dados da empresa
    console.log('🔍 Criando dados da empresa...');
    const companyDataToInsert = {
      company_name: 'Instituto dos Sonhos',
      mission: 'Guiar pessoas na transformação integral para saúde física e emocional, promovendo emagrecimento sustentável, alta autoestima, bem-estar e qualidade de vida.',
      company_values: '1. Humanização e empatia\n2. Ética e transparência\n3. Inovação constante',
      about_us: 'O Instituto dos Sonhos, fundado por Rafael Ferreira e Sirlene Freitas, especializado em emagrecimento, saúde emocional e estética integrativa.',
      target_audience: 'Homens e principalmente mulheres acima de 35 anos, que sofrem com sobrepeso, obesidade',
      vision: 'Ser um centro de referência em saúde integral, emagrecimento e bem-estar, combinando ciência, tecnologia, estética e inteligência emocional.',
      main_services: 'Programas de emagrecimento (Desafio 7D, Limpeza Hepática, Detox)\nCoaching e inteligência emocional\nPsicoterapia e hipnose\nEstética avançada',
      differentials: 'Serviço humanizado\nEquipe multidisciplinar completa\nCuidado 360°\nMétodo exclusivo',
      company_culture: 'Acolhimento e empatia\nTransformação real\nEducação contínua da equipe\nAmbiente inspirador',
      health_philosophy: 'A saúde é a soma de pequenos hábitos diários, nutrição natural e equilibrada, atividade física prazerosa, gestão emocional, prevenção e autocuidado.'
    };

    const { data: newCompanyData, error: insertError } = await supabase
      .from('company_data')
      .insert([companyDataToInsert])
      .select()
      .single();

    if (insertError) {
      console.error('❌ Erro ao criar dados da empresa:', insertError);
      return;
    }

    console.log('✅ Dados da empresa criados com sucesso!');
    console.log('📋 Dados criados:', {
      id: newCompanyData.id,
      company_name: newCompanyData.company_name,
      created_at: newCompanyData.created_at
    });

    // 4. Testar busca novamente
    console.log('🔍 Buscando dados da empresa novamente...');
    const { data: updatedCompanyData, error: fetchError2 } = await supabase
      .from('company_data')
      .select('*')
      .limit(1)
      .single();

    if (fetchError2) {
      console.error('❌ Erro ao buscar dados da empresa:', fetchError2);
    } else {
      console.log('✅ Dados da empresa encontrados após criação:', {
        id: updatedCompanyData.id,
        company_name: updatedCompanyData.company_name,
        mission: updatedCompanyData.mission?.substring(0, 50) + '...',
        created_at: updatedCompanyData.created_at
      });
    }

    // 5. Testar atualização
    console.log('🔍 Testando atualização dos dados...');
    const { data: updatedData, error: updateError } = await supabase
      .from('company_data')
      .update({
        company_name: 'Instituto dos Sonhos - Atualizado',
        updated_at: new Date().toISOString()
      })
      .eq('id', newCompanyData.id)
      .select()
      .single();

    if (updateError) {
      console.error('❌ Erro ao atualizar dados da empresa:', updateError);
    } else {
      console.log('✅ Dados da empresa atualizados com sucesso!');
      console.log('📋 Dados atualizados:', {
        id: updatedData.id,
        company_name: updatedData.company_name,
        updated_at: updatedData.updated_at
      });
    }

    // 6. Testar busca de perfis (para verificar se a coluna email foi adicionada)
    console.log('🔍 Testando busca de perfis...');
    const { data: profiles, error: profilesError } = await supabase
      .from('profiles')
      .select('*')
      .limit(5);

    if (profilesError) {
      console.error('❌ Erro ao buscar perfis:', profilesError);
    } else {
      console.log('✅ Perfis encontrados:', profiles?.length || 0);
      if (profiles && profiles.length > 0) {
        console.log('📋 Primeiro perfil:', {
          id: profiles[0].id,
          email: profiles[0].email || 'N/A',
          full_name: profiles[0].full_name || 'N/A'
        });
      }
    }

    console.log('🎉 Teste de configuração da empresa concluído!');

  } catch (error) {
    console.error('💥 Erro geral:', error);
  }
}

testCompanyConfig(); 