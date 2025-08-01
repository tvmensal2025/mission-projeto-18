// Simulação exata do que o frontend faz ao criar uma aula
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'http://127.0.0.1:54321';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testLessonFrontendSimulation() {
  try {
    console.log('🧪 Simulando criação de aula como o frontend...');

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

    // 2. Buscar cursos (como o frontend faz)
    const { data: courses, error: coursesError } = await supabase
      .from('courses')
      .select('*')
      .order('created_at', { ascending: false });

    if (coursesError) {
      console.error('❌ Erro ao buscar cursos:', coursesError);
      return;
    }

    console.log('📋 Cursos encontrados:', courses?.length || 0);
    if (courses && courses.length > 0) {
      console.log('📋 Primeiro curso:', courses[0].title);
    }

    // 3. Buscar módulos (como o frontend faz)
    const { data: modules, error: modulesError } = await supabase
      .from('course_modules')
      .select('*')
      .eq('course_id', courses[0].id)
      .order('order_index', { ascending: true });

    if (modulesError) {
      console.error('❌ Erro ao buscar módulos:', modulesError);
      return;
    }

    if (!modules || modules.length === 0) {
      console.log('⚠️ Nenhum módulo encontrado');
      return;
    }

    console.log('📋 Módulos encontrados:', modules?.length || 0);
    console.log('📋 Primeiro módulo:', modules[0].title);

    // 4. Simular dados do formulário (como o LessonModal faz)
    const lessonData = {
      title: "Aula Teste Frontend",
      description: "Aula criada automaticamente", // Default do frontend
      videoUrl: "https://example.com/video.mp4",
      richTextContent: "Conteúdo rico da aula com formatação",
      mixedContent: "",
      duration: 45,
      order: 1,
      isActive: true,
      moduleId: modules[0].id,
      courseId: courses[0].id
    };

    console.log('📋 Dados do formulário:', lessonData);

    // 5. Simular processamento (como handleCreateLesson faz)
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

    console.log('📋 Payload final:', lessonToInsert);

    // 6. Tentar inserir (como o frontend faz)
    const { data: newLesson, error: createLessonError } = await supabase
      .from('lessons')
      .insert([lessonToInsert])
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
      course_id: newLesson.course_id,
      duration_minutes: newLesson.duration_minutes,
      is_free: newLesson.is_free
    });

    // 7. Simular busca de aulas (como fetchLessons faz)
    const { data: lessons, error: lessonsError } = await supabase
      .from('lessons')
      .select('*')
      .eq('module_id', modules[0].id)
      .order('order_index', { ascending: true });

    if (lessonsError) {
      console.error('❌ Erro ao buscar aulas:', lessonsError);
    } else {
      console.log('✅ Aulas do módulo:', lessons?.length || 0);
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

    console.log('🎉 Simulação do frontend concluída!');

  } catch (error) {
    console.error('💥 Erro geral:', error);
  }
}

testLessonFrontendSimulation(); 