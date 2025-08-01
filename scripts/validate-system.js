#!/usr/bin/env node

/**
 * 🧪 VALIDADOR COMPLETO DO SISTEMA
 * ===============================
 * Valida estrutura e configurações do projeto
 */

const fs = require('fs');
const path = require('path');

// Cores para output
const colors = {
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  bold: '\x1b[1m',
  reset: '\x1b[0m'
};

const log = (message, color = 'reset') => {
  console.log(`${colors[color]}${message}${colors.reset}`);
};

const success = (message) => log(`✅ ${message}`, 'green');
const error = (message) => log(`❌ ${message}`, 'red');
const warning = (message) => log(`⚠️  ${message}`, 'yellow');
const info = (message) => log(`ℹ️  ${message}`, 'blue');
const section = (message) => log(`\n🔍 ${message}`, 'bold');

// Testes de validação
const validators = {
  // 1. Validar estrutura de arquivos
  validateFileStructure() {
    section('TESTE 1: Estrutura de Arquivos');
    
    const requiredFiles = [
      'src/main.tsx',
      'src/App.tsx',
      'src/hooks/useAdminMode.ts',
      'src/components/admin/RoleManagement.tsx',
      'src/pages/AdminPage.tsx',
      'src/pages/AuthPage.tsx',
      'supabase/migrations/20250201000000_master_consolidation.sql',
      'package.json'
    ];

    let filesOk = 0;
    for (const file of requiredFiles) {
      try {
        if (fs.existsSync(file)) {
          success(`${file} - Existe`);
          filesOk++;
        } else {
          error(`${file} - Não encontrado`);
        }
      } catch (err) {
        error(`${file} - Erro ao verificar: ${err.message}`);
      }
    }

    return filesOk === requiredFiles.length;
  },

  // 2. Validar migração master
  validateMasterMigration() {
    section('TESTE 2: Migração Master');
    
    try {
      const migrationPath = 'supabase/migrations/20250201000000_master_consolidation.sql';
      const content = fs.readFileSync(migrationPath, 'utf8');
      
      const requiredSections = [
        'MIGRAÇÃO MASTER - CONSOLIDAÇÃO COMPLETA',
        'NORMALIZAÇÃO DE SCHEMAS',
        'SISTEMA DE ROLES ROBUSTO',
        'FUNÇÕES DE SEGURANÇA CONSOLIDADAS',
        'POLÍTICAS RLS CONSOLIDADAS',
        'CREATE TABLE IF NOT EXISTS public.profiles',
        'CREATE TYPE public.app_role',
        'CREATE OR REPLACE FUNCTION public.has_role'
      ];

      let sectionsFound = 0;
      for (const section of requiredSections) {
        if (content.includes(section)) {
          success(`Seção encontrada: ${section.substring(0, 50)}...`);
          sectionsFound++;
        } else {
          warning(`Seção faltando: ${section.substring(0, 50)}...`);
        }
      }

      const percentage = Math.round((sectionsFound / requiredSections.length) * 100);
      info(`Migração master: ${percentage}% completa (${sectionsFound}/${requiredSections.length})`);
      
      return sectionsFound >= requiredSections.length * 0.8; // 80% mínimo
    } catch (err) {
      error(`Erro ao validar migração: ${err.message}`);
      return false;
    }
  },

  // 3. Validar sistema de roles
  validateRoleSystem() {
    section('TESTE 3: Sistema de Roles');
    
    try {
      // Verificar useAdminMode.ts
      const useAdminPath = 'src/hooks/useAdminMode.ts';
      const useAdminContent = fs.readFileSync(useAdminPath, 'utf8');
      
      const roleFeatures = [
        'export type UserRole',
        'test\' | \'user\' | \'admin',
        'switchRole',
        'user_roles',
        'isTestUser'
      ];

      let featuresFound = 0;
      for (const feature of roleFeatures) {
        if (useAdminContent.includes(feature)) {
          success(`Feature encontrada: ${feature}`);
          featuresFound++;
        } else {
          warning(`Feature faltando: ${feature}`);
        }
      }

      // Verificar RoleManagement.tsx
      const roleManagementPath = 'src/components/admin/RoleManagement.tsx';
      const roleManagementContent = fs.readFileSync(roleManagementPath, 'utf8');
      
      if (roleManagementContent.includes('RoleManagement') && 
          roleManagementContent.includes('switchRole')) {
        success('Componente RoleManagement implementado');
        featuresFound++;
      } else {
        warning('Componente RoleManagement pode estar incompleto');
      }

      return featuresFound >= roleFeatures.length * 0.8;
    } catch (err) {
      error(`Erro ao validar sistema de roles: ${err.message}`);
      return false;
    }
  },

  // 4. Validar configurações de produção
  validateProductionConfig() {
    section('TESTE 4: Configurações de Produção');
    
    try {
      // Verificar main.tsx
      const mainPath = 'src/main.tsx';
      const mainContent = fs.readFileSync(mainPath, 'utf8');
      
      if (mainContent.includes('import.meta.env.DEV') && 
          mainContent.includes('data-env')) {
        success('main.tsx - Configuração condicional implementada');
      } else {
        warning('main.tsx - Configuração condicional pode estar faltando');
      }

      // Verificar package.json
      const packagePath = 'package.json';
      const packageContent = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
      
      if (packageContent.scripts['build:prod'] && 
          packageContent.scripts['deploy:lovable']) {
        success('package.json - Scripts de produção configurados');
      } else {
        warning('package.json - Scripts de produção podem estar faltando');
      }

      // Verificar CSS
      const cssPath = 'src/index.css';
      const cssContent = fs.readFileSync(cssPath, 'utf8');
      
      if (cssContent.includes('data-env="development"') && 
          !cssContent.includes('display: none !important;')) {
        success('CSS - Configuração condicional implementada');
      } else if (cssContent.includes('data-env')) {
        warning('CSS - Configuração condicional parcial');
      } else {
        warning('CSS - Configuração condicional faltando');
      }

      return true;
    } catch (err) {
      error(`Erro ao validar configurações: ${err.message}`);
      return false;
    }
  },

  // 5. Validar build
  validateBuild() {
    section('TESTE 5: Build de Produção');
    
    try {
      const distPath = 'dist';
      
      if (!fs.existsSync(distPath)) {
        warning('Build não encontrado - execute: npm run build:prod');
        return false;
      }

      const indexPath = path.join(distPath, 'index.html');
      if (fs.existsSync(indexPath)) {
        const indexContent = fs.readFileSync(indexPath, 'utf8');
        if (indexContent.includes('Mission') || indexContent.includes('Instituto')) {
          success('Build gerado com sucesso');
        } else {
          warning('Build existe mas pode estar incompleto');
        }
      } else {
        error('index.html não encontrado no build');
        return false;
      }

      // Verificar tamanho dos chunks
      const assetsPath = path.join(distPath, 'assets');
      if (fs.existsSync(assetsPath)) {
        const files = fs.readdirSync(assetsPath);
        const jsFiles = files.filter(f => f.endsWith('.js'));
        const cssFiles = files.filter(f => f.endsWith('.css'));
        
        success(`Build contém ${jsFiles.length} arquivos JS e ${cssFiles.length} arquivos CSS`);
      }

      return true;
    } catch (err) {
      error(`Erro ao validar build: ${err.message}`);
      return false;
    }
  },

  // 6. Validar limpeza de código
  validateCodeCleanup() {
    section('TESTE 6: Limpeza de Código');
    
    try {
      // Verificar se arquivos de teste foram removidos
      const testFiles = [
        'check-sofia-config.js',
        'test-sofia-frontend.js',
        'lovable.config.js.backup'
      ];

      let cleanupOk = 0;
      for (const file of testFiles) {
        if (!fs.existsSync(file)) {
          success(`${file} - Removido corretamente`);
          cleanupOk++;
        } else {
          warning(`${file} - Ainda existe (deveria ser removido)`);
        }
      }

      // Verificar scripts no package.json
      const packageContent = JSON.parse(fs.readFileSync('package.json', 'utf8'));
      const scripts = Object.keys(packageContent.scripts);
      
      if (scripts.length <= 10) {
        success('Scripts do package.json limpos e organizados');
      } else {
        warning(`${scripts.length} scripts no package.json - considere limpar`);
      }

      return cleanupOk === testFiles.length;
    } catch (err) {
      error(`Erro ao validar limpeza: ${err.message}`);
      return false;
    }
  }
};

// Executar todas as validações
async function runValidation() {
  log('\n🚀 INICIANDO VALIDAÇÃO COMPLETA DO SISTEMA', 'bold');
  log('============================================', 'blue');
  
  const results = [];
  let totalTests = 0;
  let passedTests = 0;

  for (const [testName, validator] of Object.entries(validators)) {
    totalTests++;
    try {
      const result = validator();
      results.push({ name: testName, passed: result });
      if (result) passedTests++;
    } catch (err) {
      error(`Erro inesperado em ${testName}: ${err.message}`);
      results.push({ name: testName, passed: false });
    }
  }

  // Relatório final
  log('\n📊 RELATÓRIO DE VALIDAÇÃO', 'bold');
  log('==========================', 'blue');
  
  results.forEach(({ name, passed }) => {
    const status = passed ? '✅ PASSOU' : '❌ FALHOU';
    const color = passed ? 'green' : 'red';
    log(`${status} - ${name}`, color);
  });

  const percentage = Math.round((passedTests / totalTests) * 100);
  log(`\n📈 RESULTADO FINAL: ${passedTests}/${totalTests} testes passaram (${percentage}%)`, 'bold');
  
  if (percentage >= 90) {
    success('🎉 SISTEMA EXCELENTE - PRONTO PARA DEPLOY NA LOVABLE!');
  } else if (percentage >= 80) {
    success('✅ SISTEMA BOM - PODE FAZER DEPLOY COM MONITORAMENTO');
  } else if (percentage >= 60) {
    warning('⚠️  SISTEMA PARCIAL - RECOMENDA-SE CORREÇÕES ANTES DO DEPLOY');
  } else {
    error('🚨 SISTEMA CRÍTICO - CORREÇÕES OBRIGATÓRIAS ANTES DO DEPLOY');
  }

  // Instruções finais
  log('\n💡 PRÓXIMOS PASSOS:', 'bold');
  if (percentage >= 80) {
    info('1. Aplicar migração master no Supabase:');
    info('   - Acesse: https://supabase.com/dashboard');
    info('   - SQL Editor > Execute: 20250201000000_master_consolidation.sql');
    info('2. Fazer deploy:');
    info('   - npm run deploy:lovable');
    info('3. Testar na Lovable');
  } else {
    info('1. Corrigir problemas identificados');
    info('2. Re-executar validação');
    info('3. Aplicar migração quando ≥80%');
  }
  
  log('\n🏁 VALIDAÇÃO CONCLUÍDA', 'bold');
  return percentage >= 80;
}

// Executar validação
if (require.main === module) {
  runValidation()
    .then(success => {
      process.exit(success ? 0 : 1);
    })
    .catch(err => {
      error(`Erro fatal: ${err.message}`);
      process.exit(1);
    });
}

module.exports = { runValidation, validators };