// Teste do sistema de aprovação de metas
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'http://127.0.0.1:54321';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testGoalApproval() {
  try {
    console.log('🧪 Testando sistema de aprovação de metas...');

    // 1. Criar usuário admin
    const { data: { user: adminUser }, error: adminError } = await supabase.auth.signUp({
      email: 'admin@test.com',
      password: 'admin123456'
    });

    if (adminError) {
      console.log('⚠️ Admin já existe ou erro:', adminError.message);
    } else {
      console.log('✅ Admin criado:', adminUser?.id);
    }

    // 2. Fazer login como admin
    const { data: { session: adminSession }, error: adminSignInError } = await supabase.auth.signInWithPassword({
      email: 'admin@test.com',
      password: 'admin123456'
    });

    if (adminSignInError) {
      console.error('❌ Erro no login do admin:', adminSignInError);
      return;
    }

    console.log('✅ Login como admin realizado');

    // 3. Definir role de admin
    const { error: roleError } = await supabase
      .from('user_roles')
      .upsert({
        user_id: adminSession.user.id,
        role: 'admin',
        is_active: true,
        assigned_at: new Date().toISOString()
      });

    if (roleError) {
      console.error('❌ Erro ao definir role de admin:', roleError);
    } else {
      console.log('✅ Role de admin definido');
    }

    // 4. Criar usuário normal
    const { data: { user: normalUser }, error: userError } = await supabase.auth.signUp({
      email: 'user@test.com',
      password: 'user123456'
    });

    if (userError) {
      console.log('⚠️ Usuário já existe ou erro:', userError.message);
    } else {
      console.log('✅ Usuário normal criado:', normalUser?.id);
    }

    // 5. Fazer login como usuário normal
    const { data: { session: userSession }, error: userSignInError } = await supabase.auth.signInWithPassword({
      email: 'user@test.com',
      password: 'user123456'
    });

    if (userSignInError) {
      console.error('❌ Erro no login do usuário:', userSignInError);
      return;
    }

    console.log('✅ Login como usuário normal realizado');

    // 6. Criar uma meta para aprovação
    const { data: goal, error: goalError } = await supabase
      .from('user_goals')
      .insert({
        user_id: userSession.user.id,
        title: 'Meta de Teste',
        description: 'Meta para testar aprovação',
        target_value: 100,
        current_value: 0,
        unit: 'pontos',
        status: 'pending',
        admin_approval_status: 'pending'
      })
      .select()
      .single();

    if (goalError) {
      console.error('❌ Erro ao criar meta:', goalError);
    } else {
      console.log('✅ Meta criada:', goal.id);
    }

    // 7. Fazer login novamente como admin para aprovar
    const { data: { session: adminSession2 }, error: adminSignInError2 } = await supabase.auth.signInWithPassword({
      email: 'admin@test.com',
      password: 'admin123456'
    });

    if (adminSignInError2) {
      console.error('❌ Erro no login do admin:', adminSignInError2);
      return;
    }

    // 8. Aprovar a meta
    if (goal) {
      const { data: approvedGoal, error: approvalError } = await supabase
        .from('user_goals')
        .update({
          admin_approval_status: 'approved',
          admin_notes: 'Meta aprovada para teste',
          admin_id: adminSession2.user.id,
          approved_at: new Date().toISOString()
        })
        .eq('id', goal.id)
        .select()
        .single();

      if (approvalError) {
        console.error('❌ Erro ao aprovar meta:', approvalError);
      } else {
        console.log('✅ Meta aprovada com sucesso:', approvedGoal.id);
        console.log('📋 Status:', approvedGoal.admin_approval_status);
        console.log('📋 Notas:', approvedGoal.admin_notes);
      }
    }

    // 9. Listar metas para verificar
    const { data: goals, error: listError } = await supabase
      .from('user_goals')
      .select('*')
      .limit(5);

    if (listError) {
      console.error('❌ Erro ao listar metas:', listError);
    } else {
      console.log('✅ Metas encontradas:', goals?.length || 0);
      if (goals && goals.length > 0) {
        console.log('📋 Primeira meta:', {
          id: goals[0].id,
          title: goals[0].title,
          status: goals[0].status,
          admin_approval_status: goals[0].admin_approval_status,
          admin_notes: goals[0].admin_notes
        });
      }
    }

    console.log('🎉 Teste de aprovação de metas concluído!');

  } catch (error) {
    console.error('💥 Erro geral:', error);
  }
}

testGoalApproval(); 