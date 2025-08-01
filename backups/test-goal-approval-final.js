// Teste final do sistema de aprovação de metas
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'http://127.0.0.1:54321';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testGoalApprovalFinal() {
  try {
    console.log('🧪 Teste FINAL do sistema de aprovação de metas...');

    // 1. Fazer login como admin
    const { data: { session: adminSession }, error: adminSignInError } = await supabase.auth.signInWithPassword({
      email: 'admin@test.com',
      password: 'admin123456'
    });

    if (adminSignInError) {
      console.error('❌ Erro no login do admin:', adminSignInError);
      return;
    }

    console.log('✅ Login como admin realizado');
    console.log('👤 Admin ID:', adminSession.user.id);

    // 2. Buscar uma meta existente para aprovar
    let { data: goals, error: goalsError } = await supabase
      .from('user_goals')
      .select('*')
      .eq('status', 'pending')
      .limit(1);

    if (goalsError) {
      console.error('❌ Erro ao buscar metas:', goalsError);
      return;
    }

    if (!goals || goals.length === 0) {
      console.log('⚠️ Nenhuma meta pendente encontrada. Criando uma...');
      
      // Criar uma meta de teste
      const { data: newGoal, error: createError } = await supabase
        .from('user_goals')
        .insert({
          user_id: adminSession.user.id,
          title: 'Meta de Teste Final',
          description: 'Meta para testar aprovação completa',
          target_value: 100,
          current_value: 0,
          unit: 'pontos',
          status: 'pending',
          admin_approval_status: 'pending'
        })
        .select()
        .single();

      if (createError) {
        console.error('❌ Erro ao criar meta:', createError);
        return;
      }

      console.log('✅ Meta criada:', newGoal.id);
      goals = [newGoal];
    }

    const goalToApprove = goals[0];
    console.log('📋 Meta para aprovar:', goalToApprove.title);

    // 3. Aprovar a meta com todos os campos
    const approvalData = {
      status: 'aprovada',
      approved_by: adminSession.user.id,
      approved_at: new Date().toISOString(),
      admin_notes: 'Meta aprovada no teste final',
      final_points: 150,
      updated_at: new Date().toISOString()
    };

    console.log('🔍 Dados de aprovação:', approvalData);

    const { data: approvedGoal, error: approvalError } = await supabase
      .from('user_goals')
      .update(approvalData)
      .eq('id', goalToApprove.id)
      .select()
      .single();

    if (approvalError) {
      console.error('❌ Erro ao aprovar meta:', approvalError);
      console.error('📋 Detalhes do erro:', {
        code: approvalError.code,
        message: approvalError.message,
        details: approvalError.details
      });
      return;
    }

    console.log('✅ Meta aprovada com sucesso!');
    console.log('📋 Meta aprovada:', {
      id: approvedGoal.id,
      title: approvedGoal.title,
      status: approvedGoal.status,
      approved_by: approvedGoal.approved_by,
      approved_at: approvedGoal.approved_at,
      admin_notes: approvedGoal.admin_notes,
      final_points: approvedGoal.final_points
    });

    // 4. Testar rejeição de uma meta
    const { data: goalsToReject, error: rejectGoalsError } = await supabase
      .from('user_goals')
      .select('*')
      .eq('status', 'pending')
      .limit(1);

    if (!rejectGoalsError && goalsToReject && goalsToReject.length > 0) {
      const goalToReject = goalsToReject[0];
      
      const rejectionData = {
        status: 'rejeitada',
        approved_by: adminSession.user.id,
        approved_at: new Date().toISOString(),
        admin_notes: 'Meta rejeitada no teste final',
        rejection_reason: 'Não atende aos critérios',
        updated_at: new Date().toISOString()
      };

      const { data: rejectedGoal, error: rejectionError } = await supabase
        .from('user_goals')
        .update(rejectionData)
        .eq('id', goalToReject.id)
        .select()
        .single();

      if (rejectionError) {
        console.error('❌ Erro ao rejeitar meta:', rejectionError);
      } else {
        console.log('✅ Meta rejeitada com sucesso!');
        console.log('📋 Meta rejeitada:', {
          id: rejectedGoal.id,
          title: rejectedGoal.title,
          status: rejectedGoal.status,
          rejection_reason: rejectedGoal.rejection_reason
        });
      }
    }

    // 5. Listar todas as metas para verificar
    const { data: allGoals, error: listError } = await supabase
      .from('user_goals')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(5);

    if (listError) {
      console.error('❌ Erro ao listar metas:', listError);
    } else {
      console.log('✅ Metas encontradas:', allGoals?.length || 0);
      if (allGoals && allGoals.length > 0) {
        console.log('📋 Primeira meta:', {
          id: allGoals[0].id,
          title: allGoals[0].title,
          status: allGoals[0].status,
          approved_by: allGoals[0].approved_by,
          admin_notes: allGoals[0].admin_notes
        });
      }
    }

    console.log('🎉 Teste FINAL de aprovação de metas concluído!');

  } catch (error) {
    console.error('💥 Erro geral:', error);
  }
}

testGoalApprovalFinal(); 