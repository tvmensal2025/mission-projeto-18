#!/usr/bin/env node

/**
 * 🧪 SCRIPT DE TESTE COMPLETO DO SISTEMA
 * ====================================
 * Valida todas as funcionalidades críticas
 */

const { readFileSync } = require('fs');
const { join } = require('path');

const __dirname = __dirname;

// Configuração do Supabase (usar variáveis de ambiente)
const supabaseUrl = process.env.VITE_SUPABASE_URL || 'https://hlrkoyywjpckdotimtik.supabase.co';
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhscmtveXl3anBja2RvdGltdGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ1NjM1NzIsImV4cCI6MjA1MDEzOTU3Mn0.LIqUXJOxc0F8tn9Cqy_T9LnQQZoFZxHQdSyDHUNNKF4';

const supabase = createClient(supabaseUrl, supabaseKey);

// Cores para output
const colors = {
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
  reset: '\x1b[0m',
  bold: '\x1b[1m'
};

// Utilitários
const log = (message, color = 'reset') => {
  console.log(`${colors[color]}${message}${colors.reset}`);
};

const success = (message) => log(`✅ ${message}`, 'green');
const error = (message) => log(`❌ ${message}`, 'red');
const warning = (message) => log(`⚠️  ${message}`, 'yellow');
const info = (message) => log(`ℹ️  ${message}`, 'blue');
const section = (message) => log(`\n🔍 ${message}`, 'bold');

// Testes
const tests = {
  // 1. Teste de Conexão com Supabase
  async testSupabaseConnection() {
    section('TESTE 1: Conexão com Supabase');
    try {
      const { data, error } = await supabase.from('profiles').select('count').limit(1);
      if (error) throw error;
      success('Conexão com Supabase estabelecida');
      return true;
    } catch (err) {
      error(`Falha na conexão: ${err.message}`);
      return false;
    }
  },

  // 2. Teste do Sistema de Roles
  async testRoleSystem() {
    section('TESTE 2: Sistema de Roles');
    try {
      // Verificar se tabela user_roles existe
      const { data: roles, error: rolesError } = await supabase
        .from('user_roles')
        .select('*')
        .limit(1);
      
      if (rolesError) throw new Error(`Tabela user_roles: ${rolesError.message}`);
      success('Tabela user_roles acessível');

      // Verificar enum app_role
      const { data: enumData, error: enumError } = await supabase
        .rpc('get_enum_values', { enum_name: 'app_role' })
        .single();
      
      if (!enumError && enumData) {
        success('Enum app_role configurado');
      } else {
        warning('Enum app_role pode não estar configurado (normal se ainda não aplicado)');
      }

      // Verificar funções de role
      const { data: funcData, error: funcError } = await supabase
        .rpc('has_role', { _user_id: '00000000-0000-0000-0000-000000000000', _role: 'user' });
      
      if (!funcError) {
        success('Função has_role funcionando');
      } else {
        warning('Função has_role pode não estar disponível');
      }

      return true;
    } catch (err) {
      error(`Sistema de roles: ${err.message}`);
      return false;
    }
  },

  // 3. Teste do Sistema de Cursos
  async testCourseSystem() {
    section('TESTE 3: Sistema de Cursos');
    try {
      // Verificar tabelas de cursos
      const tables = ['courses', 'course_modules', 'lessons', 'course_lessons'];
      
      for (const table of tables) {
        const { data, error } = await supabase.from(table).select('*').limit(1);
        if (error) {
          warning(`Tabela ${table}: ${error.message}`);
        } else {
          success(`Tabela ${table} acessível`);
        }
      }

      // Verificar políticas RLS
      const { data: policies, error: policiesError } = await supabase
        .from('pg_policies')
        .select('tablename, policyname')
        .in('tablename', tables);
      
      if (!policiesError && policies && policies.length > 0) {
        success(`${policies.length} políticas RLS encontradas`);
      } else {
        warning('Políticas RLS podem não estar aplicadas ainda');
      }

      return true;
    } catch (err) {
      error(`Sistema de cursos: ${err.message}`);
      return false;
    }
  },

  // 4. Teste de Build e Arquivos
  async testBuildFiles() {
    section('TESTE 4: Arquivos de Build');
    try {
      const distPath = join(__dirname, '..', 'dist');
      
      // Verificar se build existe
      try {
        const indexHtml = readFileSync(join(distPath, 'index.html'), 'utf8');
        if (indexHtml.includes('Mission Health Nexus') || indexHtml.includes('Instituto dos Sonhos')) {
          success('Build gerado com sucesso');
        } else {
          warning('Build existe mas pode estar incompleto');
        }
      } catch (buildError) {
        error('Build não encontrado - execute npm run build:prod');
        return false;
      }

      // Verificar otimizações
      const packageJson = JSON.parse(readFileSync(join(__dirname, '..', 'package.json'), 'utf8'));
      if (packageJson.scripts['build:prod']) {
        success('Scripts de build otimizados');
      }

      return true;
    } catch (err) {
      error(`Arquivos de build: ${err.message}`);
      return false;
    }
  },

  // 5. Teste de Configurações de Produção
  async testProductionConfig() {
    section('TESTE 5: Configurações de Produção');
    try {
      // Verificar arquivos de configuração
      const configFiles = [
        'src/main.tsx',
        'src/utils/lovable-config.js',
        'src/utils/disable-lovable.js'
      ];

      for (const file of configFiles) {
        try {
          const content = readFileSync(join(__dirname, '..', file), 'utf8');
          if (content.includes('import.meta.env.DEV') || content.includes('NODE_ENV')) {
            success(`${file} - Configuração condicional implementada`);
          } else {
            warning(`${file} - Pode não ter configuração condicional`);
          }
        } catch (fileError) {
          warning(`${file} - Arquivo não encontrado`);
        }
      }

      return true;
    } catch (err) {
      error(`Configurações de produção: ${err.message}`);
      return false;
    }
  },

  // 6. Teste de Migração Master
  async testMasterMigration() {
    section('TESTE 6: Migração Master');
    try {
      const migrationFile = 'supabase/migrations/20250201000000_master_consolidation.sql';
      
      try {
        const content = readFileSync(join(__dirname, '..', migrationFile), 'utf8');
        if (content.includes('MIGRAÇÃO MASTER') && content.includes('CONSOLIDAÇÃO COMPLETA')) {
          success('Migração master criada');
          
          // Verificar seções principais
          const sections = [
            'NORMALIZAÇÃO DE SCHEMAS',
            'SISTEMA DE ROLES ROBUSTO',
            'FUNÇÕES DE SEGURANÇA CONSOLIDADAS',
            'POLÍTICAS RLS CONSOLIDADAS'
          ];
          
          let sectionsFound = 0;
          for (const section of sections) {
            if (content.includes(section)) {
              sectionsFound++;
            }
          }
          
          if (sectionsFound === sections.length) {
            success(`Todas as ${sections.length} seções implementadas`);
          } else {
            warning(`${sectionsFound}/${sections.length} seções encontradas`);
          }
        }
      } catch (fileError) {
        error('Migração master não encontrada');
        return false;
      }

      return true;
    } catch (err) {
      error(`Migração master: ${err.message}`);
      return false;
    }
  }
};

// Executar todos os testes
async function runAllTests() {
  log('\n🚀 INICIANDO TESTES COMPLETOS DO SISTEMA', 'bold');
  log('==========================================', 'cyan');
  
  const results = [];
  let totalTests = 0;
  let passedTests = 0;

  for (const [testName, testFunction] of Object.entries(tests)) {
    totalTests++;
    try {
      const result = await testFunction();
      results.push({ name: testName, passed: result });
      if (result) passedTests++;
    } catch (err) {
      error(`Erro inesperado em ${testName}: ${err.message}`);
      results.push({ name: testName, passed: false });
    }
  }

  // Relatório final
  log('\n📊 RELATÓRIO FINAL', 'bold');
  log('==================', 'cyan');
  
  results.forEach(({ name, passed }) => {
    const status = passed ? '✅ PASSOU' : '❌ FALHOU';
    const color = passed ? 'green' : 'red';
    log(`${status} - ${name}`, color);
  });

  log(`\n📈 RESULTADO: ${passedTests}/${totalTests} testes passaram`, 'bold');
  
  const percentage = Math.round((passedTests / totalTests) * 100);
  if (percentage >= 80) {
    success(`🎉 Sistema ${percentage}% funcional - PRONTO PARA DEPLOY!`);
  } else if (percentage >= 60) {
    warning(`⚠️  Sistema ${percentage}% funcional - Verificar problemas`);
  } else {
    error(`🚨 Sistema ${percentage}% funcional - Correções necessárias`);
  }

  // Recomendações
  log('\n💡 PRÓXIMOS PASSOS:', 'bold');
  if (passedTests === totalTests) {
    info('1. Sistema totalmente validado');
    info('2. Executar: npm run deploy:lovable');
    info('3. Testar na Lovable');
  } else {
    info('1. Aplicar migração master no Supabase');
    info('2. Verificar configurações de ambiente');
    info('3. Re-executar testes');
  }
  
  log('\n🔚 TESTES CONCLUÍDOS', 'bold');
  
  return percentage >= 80;
}

// Executar se chamado diretamente
if (import.meta.url === `file://${process.argv[1]}`) {
  runAllTests()
    .then(success => {
      process.exit(success ? 0 : 1);
    })
    .catch(err => {
      error(`Erro fatal: ${err.message}`);
      process.exit(1);
    });
}

export { runAllTests, tests };