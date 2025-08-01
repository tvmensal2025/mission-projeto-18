// Teste de visibilidade das aulas
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'http://127.0.0.1:54321';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testLessonVisibility() {
  try {
    console.log('🧪 Testando visibilidade das aulas...');

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

    // 2. Buscar um módulo existente
    const { data: modules, error: modulesError } = await supabase
      .from('course_modules')
      .select('*')
      .limit(1);

    if (modulesError) {
      console.error('❌ Erro ao buscar módulos:', modulesError);
      return;
    }

    if (!modules || modules.length === 0) {
      console.log('⚠️ Nenhum módulo encontrado');
      return;
    }

    const moduleId = modules[0].id;
    console.log('📋 Módulo selecionado:', modules[0].title);

    // 3. Verificar aulas existentes ANTES de criar
    console.log('🔍 Verificando aulas existentes ANTES...');
    const { data: lessonsBefore, error: lessonsBeforeError } = await supabase
      .from('lessons')
      .select('*')
      .eq('module_id', moduleId)
      .order('order_index', { ascending: true });

    if (lessonsBeforeError) {
      console.error('❌ Erro ao buscar aulas:', lessonsBeforeError);
    } else {
      console.log('📋 Aulas existentes ANTES:', lessonsBefore?.length || 0);
      lessonsBefore?.forEach((lesson, index) => {
        console.log(`📋 Aula ${index + 1}:`, {
          id: lesson.id,
          title: lesson.title,
          module_id: lesson.module_id,
          created_at: lesson.created_at
        });
      });
    }

    // 4. Criar uma nova aula
    console.log('🔍 Criando nova aula...');
    const newLessonData = {
      module_id: moduleId,
      title: 'Aula Teste Visibilidade',
      description: 'Aula para testar visibilidade',
      content: 'Conteúdo da aula de teste',
      video_url: '',
      duration_minutes: 30,
      order_index: 999, // Ordem alta para ficar no final
      is_free: true,
      is_active: true,
      course_id: modules[0].course_id
    };

    const { data: newLesson, error: createError } = await supabase
      .from('lessons')
      .insert([newLessonData])
      .select()
      .single();

    if (createError) {
      console.error('❌ Erro ao criar aula:', createError);
      return;
    }

    console.log('✅ Aula criada:', {
      id: newLesson.id,
      title: newLesson.title,
      module_id: newLesson.module_id
    });

    // 5. Verificar aulas existentes DEPOIS de criar
    console.log('🔍 Verificando aulas existentes DEPOIS...');
    const { data: lessonsAfter, error: lessonsAfterError } = await supabase
      .from('lessons')
      .select('*')
      .eq('module_id', moduleId)
      .order('order_index', { ascending: true });

    if (lessonsAfterError) {
      console.error('❌ Erro ao buscar aulas:', lessonsAfterError);
    } else {
      console.log('📋 Aulas existentes DEPOIS:', lessonsAfter?.length || 0);
      lessonsAfter?.forEach((lesson, index) => {
        console.log(`📋 Aula ${index + 1}:`, {
          id: lesson.id,
          title: lesson.title,
          module_id: lesson.module_id,
          order_index: lesson.order_index,
          created_at: lesson.created_at
        });
      });
    }

    // 6. Verificar se a nova aula está na lista
    const newLessonInList = lessonsAfter?.find(lesson => lesson.id === newLesson.id);
    if (newLessonInList) {
      console.log('✅ Nova aula encontrada na lista!');
    } else {
      console.log('❌ Nova aula NÃO encontrada na lista!');
    }

    // 7. Testar busca específica da nova aula
    console.log('🔍 Testando busca específica da nova aula...');
    const { data: specificLesson, error: specificError } = await supabase
      .from('lessons')
      .select('*')
      .eq('id', newLesson.id)
      .single();

    if (specificError) {
      console.error('❌ Erro ao buscar aula específica:', specificError);
    } else {
      console.log('✅ Aula específica encontrada:', {
        id: specificLesson.id,
        title: specificLesson.title,
        module_id: specificLesson.module_id
      });
    }

    // 8. Verificar se há problemas de RLS
    console.log('🔍 Testando RLS...');
    const { data: rlsTest, error: rlsError } = await supabase
      .from('lessons')
      .select('count')
      .eq('module_id', moduleId);

    if (rlsError) {
      console.error('❌ Erro de RLS:', rlsError);
    } else {
      console.log('✅ RLS funcionando corretamente');
    }

    console.log('🎉 Teste de visibilidade concluído!');

  } catch (error) {
    console.error('💥 Erro geral:', error);
  }
}

testLessonVisibility(); 