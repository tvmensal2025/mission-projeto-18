// Teste de criação de módulos
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'http://127.0.0.1:54321';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testModuleCreation() {
  try {
    console.log('🧪 Testando criação de módulos...');

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
    let { data: courses, error: coursesError } = await supabase
      .from('courses')
      .select('*')
      .limit(1);

    if (coursesError) {
      console.error('❌ Erro ao buscar cursos:', coursesError);
      return;
    }

    if (!courses || courses.length === 0) {
      console.log('⚠️ Nenhum curso encontrado. Criando um curso...');
      
      const { data: newCourse, error: createCourseError } = await supabase
        .from('courses')
        .insert({
          title: 'Curso de Teste',
          description: 'Curso para testar criação de módulos',
          category: 'teste',
          difficulty_level: 'beginner',
          duration_minutes: 60,
          instructor_name: 'Admin Teste',
          is_premium: false,
          is_published: true,
          structure_type: 'course_module_lesson'
        })
        .select()
        .single();

      if (createCourseError) {
        console.error('❌ Erro ao criar curso:', createCourseError);
        return;
      }

      console.log('✅ Curso criado:', newCourse.id);
      courses = [newCourse];
    }

    const courseId = courses[0].id;
    console.log('📋 Curso selecionado:', courses[0].title);

    // 3. Testar criação de módulo com dados mínimos
    console.log('🔍 Testando criação de módulo com dados mínimos...');
    
    const minimalModuleData = {
      course_id: courseId,
      title: 'Módulo de Teste',
      description: 'Módulo para teste',
      order_index: 1
    };

    console.log('📋 Dados do módulo:', minimalModuleData);

    const { data: newModule, error: createModuleError } = await supabase
      .from('course_modules')
      .insert([minimalModuleData])
      .select()
      .single();

    if (createModuleError) {
      console.error('❌ Erro ao criar módulo:', createModuleError);
      console.error('📋 Detalhes do erro:', {
        code: createModuleError.code,
        message: createModuleError.message,
        details: createModuleError.details,
        hint: createModuleError.hint
      });
      return;
    }

    console.log('✅ Módulo criado com sucesso!');
    console.log('📋 Módulo criado:', {
      id: newModule.id,
      title: newModule.title,
      course_id: newModule.course_id,
      order_index: newModule.order_index
    });

    // 4. Testar criação de módulo com dados completos
    console.log('🔍 Testando criação de módulo com dados completos...');
    
    const completeModuleData = {
      course_id: courseId,
      title: 'Módulo Completo',
      description: 'Módulo com todos os campos preenchidos',
      order_index: 2,
      is_active: true
    };

    const { data: completeModule, error: completeModuleError } = await supabase
      .from('course_modules')
      .insert([completeModuleData])
      .select()
      .single();

    if (completeModuleError) {
      console.error('❌ Erro ao criar módulo completo:', completeModuleError);
    } else {
      console.log('✅ Módulo completo criado com sucesso!');
      console.log('📋 Módulo completo:', {
        id: completeModule.id,
        title: completeModule.title,
        is_active: completeModule.is_active
      });
    }

    // 5. Listar módulos do curso
    const { data: modules, error: listError } = await supabase
      .from('course_modules')
      .select('*')
      .eq('course_id', courseId)
      .order('order_index', { ascending: true });

    if (listError) {
      console.error('❌ Erro ao listar módulos:', listError);
    } else {
      console.log('✅ Módulos encontrados:', modules?.length || 0);
      modules?.forEach((module, index) => {
        console.log(`📋 Módulo ${index + 1}:`, {
          id: module.id,
          title: module.title,
          order_index: module.order_index,
          is_active: module.is_active
        });
      });
    }

    console.log('🎉 Teste de criação de módulos concluído!');

  } catch (error) {
    console.error('💥 Erro geral:', error);
  }
}

testModuleCreation(); 