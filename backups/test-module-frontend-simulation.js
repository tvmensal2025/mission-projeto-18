// Simulação exata do que o frontend faz ao criar um módulo
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'http://127.0.0.1:54321';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testModuleFrontendSimulation() {
  try {
    console.log('🧪 Simulando criação de módulo como o frontend...');

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

    // 3. Simular dados do formulário (como o ModuleModal faz)
    const formData = {
      title: "Módulo Teste Frontend",
      description: "Módulo criado automaticamente", // Default do frontend
      course_id: courses?.[0]?.id || "",
      order_index: 1,
      is_active: true,
      thumbnail_url: undefined
    };

    console.log('📋 Dados do formulário:', formData);

    // 4. Simular validação (como o frontend faz)
    const errors = {};
    if (!formData.title.trim()) {
      errors.title = "Título é obrigatório";
    }
    if (!formData.course_id) {
      errors.course_id = "Curso é obrigatório";
    }
    if (formData.order_index < 1) {
      errors.order_index = "Ordem deve ser maior que 0";
    }

    if (Object.keys(errors).length > 0) {
      console.error('❌ Erros de validação:', errors);
      return;
    }

    console.log('✅ Validação passou');

    // 5. Simular processamento (como handleCreateModule faz)
    const { order, structure_type, ...modulePayload } = formData;
    
    const finalPayload = {
      ...modulePayload,
      order_index: formData.order_index || 1,
    };

    console.log('📋 Payload final:', finalPayload);

    // 6. Tentar inserir (como o frontend faz)
    const { data: newModule, error: createModuleError } = await supabase
      .from('course_modules')
      .insert([finalPayload])
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
      order_index: newModule.order_index,
      is_active: newModule.is_active
    });

    // 7. Simular busca de módulos (como fetchModules faz)
    const { data: modules, error: modulesError } = await supabase
      .from('course_modules')
      .select('*')
      .eq('course_id', courses[0].id)
      .order('order_index', { ascending: true });

    if (modulesError) {
      console.error('❌ Erro ao buscar módulos:', modulesError);
    } else {
      console.log('✅ Módulos do curso:', modules?.length || 0);
      modules?.forEach((module, index) => {
        console.log(`📋 Módulo ${index + 1}:`, {
          id: module.id,
          title: module.title,
          order_index: module.order_index
        });
      });
    }

    console.log('🎉 Simulação do frontend concluída!');

  } catch (error) {
    console.error('💥 Erro geral:', error);
  }
}

testModuleFrontendSimulation(); 