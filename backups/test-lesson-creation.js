// Teste de criação de aulas
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'http://127.0.0.1:54321';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testLessonCreation() {
  try {
    console.log('🧪 Testando criação de aulas...');

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

    // 2. Buscar um curso existente
    const { data: courses, error: coursesError } = await supabase
      .from('courses')
      .select('*')
      .limit(1);

    if (coursesError) {
      console.error('❌ Erro ao buscar cursos:', coursesError);
      return;
    }

    if (!courses || courses.length === 0) {
      console.log('⚠️ Nenhum curso encontrado');
      return;
    }

    const courseId = courses[0].id;
    console.log('📋 Curso selecionado:', courses[0].title);

    // 3. Buscar um módulo existente
    const { data: modules, error: modulesError } = await supabase
      .from('course_modules')
      .select('*')
      .eq('course_id', courseId)
      .limit(1);

    if (modulesError) {
      console.error('❌ Erro ao buscar módulos:', modulesError);
      return;
    }

    if (!modules || modules.length === 0) {
      console.log('⚠️ Nenhum módulo encontrado. Criando um módulo...');
      
      const { data: newModule, error: createModuleError } = await supabase
        .from('course_modules')
        .insert({
          course_id: courseId,
          title: 'Módulo para Teste',
          description: 'Módulo para testar criação de aulas',
          order_index: 1,
          is_active: true
        })
        .select()
        .single();

      if (createModuleError) {
        console.error('❌ Erro ao criar módulo:', createModuleError);
        return;
      }

      console.log('✅ Módulo criado:', newModule.id);
      modules = [newModule];
    }

    const moduleId = modules[0].id;
    console.log('📋 Módulo selecionado:', modules[0].title);

    // 4. Testar criação de aula com dados mínimos
    console.log('🔍 Testando criação de aula com dados mínimos...');
    
    const minimalLessonData = {
      module_id: moduleId,
      title: 'Aula de Teste',
      description: 'Aula para teste',
      content: 'Conteúdo da aula de teste',
      video_url: '',
      duration_minutes: 30,
      order_index: 1,
      is_free: true,
      is_active: true
    };

    console.log('📋 Dados da aula:', minimalLessonData);

    const { data: newLesson, error: createLessonError } = await supabase
      .from('lessons')
      .insert([minimalLessonData])
      .select()
      .single();

    if (createLessonError) {
      console.error('❌ Erro ao criar aula:', createLessonError);
      console.error('📋 Detalhes do erro:', {
        code: createLessonError.code,
        message: createLessonError.message,
        details: createLessonError.details,
        hint: createLessonError.hint
      });
      return;
    }

    console.log('✅ Aula criada com sucesso!');
    console.log('📋 Aula criada:', {
      id: newLesson.id,
      title: newLesson.title,
      module_id: newLesson.module_id,
      duration_minutes: newLesson.duration_minutes,
      is_free: newLesson.is_free
    });

    // 5. Testar criação de aula com dados completos
    console.log('🔍 Testando criação de aula com dados completos...');
    
    const completeLessonData = {
      module_id: moduleId,
      title: 'Aula Completa',
      description: 'Aula com todos os campos preenchidos',
      content: 'Conteúdo completo da aula com formatação rica',
      video_url: 'https://example.com/video.mp4',
      duration_minutes: 45,
      order_index: 2,
      is_free: false,
      is_active: true,
      thumbnail_url: 'https://example.com/thumbnail.jpg'
    };

    const { data: completeLesson, error: completeLessonError } = await supabase
      .from('lessons')
      .insert([completeLessonData])
      .select()
      .single();

    if (completeLessonError) {
      console.error('❌ Erro ao criar aula completa:', completeLessonError);
    } else {
      console.log('✅ Aula completa criada com sucesso!');
      console.log('📋 Aula completa:', {
        id: completeLesson.id,
        title: completeLesson.title,
        content: completeLesson.content?.substring(0, 50) + '...',
        video_url: completeLesson.video_url
      });
    }

    // 6. Listar aulas do módulo
    const { data: lessons, error: listError } = await supabase
      .from('lessons')
      .select('*')
      .eq('module_id', moduleId)
      .order('order_index', { ascending: true });

    if (listError) {
      console.error('❌ Erro ao listar aulas:', listError);
    } else {
      console.log('✅ Aulas encontradas:', lessons?.length || 0);
      lessons?.forEach((lesson, index) => {
        console.log(`📋 Aula ${index + 1}:`, {
          id: lesson.id,
          title: lesson.title,
          duration_minutes: lesson.duration_minutes,
          is_free: lesson.is_free,
          order_index: lesson.order_index
        });
      });
    }

    console.log('🎉 Teste de criação de aulas concluído!');

  } catch (error) {
    console.error('💥 Erro geral:', error);
  }
}

testLessonCreation(); 