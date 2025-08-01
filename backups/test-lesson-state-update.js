// Teste de atualização do estado após criar aula
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'http://127.0.0.1:54321';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testLessonStateUpdate() {
  try {
    console.log('🧪 Testando atualização do estado após criar aula...');

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

    // 3. Simular fetchLessons (como o frontend faz)
    console.log('🔍 Simulando fetchLessons ANTES...');
    const { data: lessonsBefore, error: lessonsBeforeError } = await supabase
      .from('lessons')
      .select('*')
      .eq('module_id', moduleId)
      .order('order_index', { ascending: true });

    if (lessonsBeforeError) {
      console.error('❌ Erro ao buscar aulas:', lessonsBeforeError);
    } else {
      console.log('📋 Aulas ANTES (simulando estado):', lessonsBefore?.length || 0);
      lessonsBefore?.forEach((lesson, index) => {
        console.log(`📋 Aula ${index + 1}:`, {
          id: lesson.id,
          title: lesson.title,
          order_index: lesson.order_index
        });
      });
    }

    // 4. Criar uma nova aula (como handleCreateLesson faz)
    console.log('🔍 Criando nova aula...');
    const lessonData = {
      title: "Aula Teste Estado",
      description: "Aula para testar atualização de estado",
      videoUrl: "",
      richTextContent: "Conteúdo da aula",
      mixedContent: "",
      duration: 25,
      order: 999,
      isActive: true,
      moduleId: moduleId,
      courseId: modules[0].course_id
    };

    // Simular processamento (como handleCreateLesson faz)
    const lessonToInsert = {
      title: lessonData.title,
      description: lessonData.description || "Aula criada automaticamente",
      video_url: lessonData.videoUrl || "",
      content: lessonData.richTextContent || lessonData.mixedContent || "",
      duration_minutes: lessonData.duration || 0,
      order_index: lessonData.order || 1,
      is_free: !lessonData.isActive ? false : true,
      module_id: lessonData.moduleId,
      course_id: lessonData.courseId
    };

    console.log('📋 Payload para inserção:', lessonToInsert);

    const { data: newLesson, error: createError } = await supabase
      .from('lessons')
      .insert([lessonToInsert])
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

    // 5. Simular fetchLessons DEPOIS (como o frontend faz após criar)
    console.log('🔍 Simulando fetchLessons DEPOIS...');
    const { data: lessonsAfter, error: lessonsAfterError } = await supabase
      .from('lessons')
      .select('*')
      .eq('module_id', moduleId)
      .order('order_index', { ascending: true });

    if (lessonsAfterError) {
      console.error('❌ Erro ao buscar aulas:', lessonsAfterError);
    } else {
      console.log('📋 Aulas DEPOIS (simulando estado atualizado):', lessonsAfter?.length || 0);
      lessonsAfter?.forEach((lesson, index) => {
        console.log(`📋 Aula ${index + 1}:`, {
          id: lesson.id,
          title: lesson.title,
          order_index: lesson.order_index
        });
      });
    }

    // 6. Verificar se a nova aula está na lista atualizada
    const newLessonInList = lessonsAfter?.find(lesson => lesson.id === newLesson.id);
    if (newLessonInList) {
      console.log('✅ Nova aula encontrada na lista atualizada!');
      console.log('📋 Nova aula na lista:', {
        id: newLessonInList.id,
        title: newLessonInList.title,
        order_index: newLessonInList.order_index
      });
    } else {
      console.log('❌ Nova aula NÃO encontrada na lista atualizada!');
    }

    // 7. Verificar se o número de aulas aumentou
    const beforeCount = lessonsBefore?.length || 0;
    const afterCount = lessonsAfter?.length || 0;
    
    console.log('📊 Comparação:');
    console.log(`📋 Aulas ANTES: ${beforeCount}`);
    console.log(`📋 Aulas DEPOIS: ${afterCount}`);
    console.log(`📋 Diferença: ${afterCount - beforeCount}`);

    if (afterCount > beforeCount) {
      console.log('✅ Número de aulas aumentou corretamente!');
    } else {
      console.log('❌ Número de aulas não aumentou!');
    }

    // 8. Verificar se há problemas com o módulo_id
    console.log('🔍 Verificando se há aulas com module_id diferente...');
    const { data: allLessons, error: allLessonsError } = await supabase
      .from('lessons')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(10);

    if (allLessonsError) {
      console.error('❌ Erro ao buscar todas as aulas:', allLessonsError);
    } else {
      console.log('📋 Últimas 10 aulas criadas:');
      allLessons?.forEach((lesson, index) => {
        console.log(`📋 Aula ${index + 1}:`, {
          id: lesson.id,
          title: lesson.title,
          module_id: lesson.module_id,
          created_at: lesson.created_at
        });
      });
    }

    console.log('🎉 Teste de atualização do estado concluído!');

  } catch (error) {
    console.error('💥 Erro geral:', error);
  }
}

testLessonStateUpdate(); 