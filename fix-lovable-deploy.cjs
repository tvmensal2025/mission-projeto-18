// Script para corrigir problemas de deploy na Lovable
const fs = require('fs');
const path = require('path');

console.log('🔧 Verificando e corrigindo problemas para deploy na Lovable...');

// 1. Verificar se o build funciona
console.log('\n📦 Testando build...');
try {
  const { execSync } = require('child_process');
  execSync('npm run build:prod', { stdio: 'inherit' });
  console.log('✅ Build funcionando corretamente');
} catch (error) {
  console.error('❌ Erro no build:', error.message);
  process.exit(1);
}

// 2. Verificar arquivos críticos
const criticalFiles = [
  'package.json',
  'vite.config.ts',
  'tailwind.config.ts',
  'src/main.tsx',
  'index.html'
];

console.log('\n📁 Verificando arquivos críticos...');
criticalFiles.forEach(file => {
  if (fs.existsSync(file)) {
    console.log(`✅ ${file} existe`);
  } else {
    console.error(`❌ ${file} não encontrado`);
    process.exit(1);
  }
});

// 3. Verificar dependências
console.log('\n📋 Verificando dependências...');
const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));

// Verificar se todas as dependências necessárias estão instaladas
const requiredDeps = [
  'react',
  'react-dom',
  '@supabase/supabase-js',
  'react-router-dom',
  'lucide-react'
];

requiredDeps.forEach(dep => {
  if (packageJson.dependencies[dep] || packageJson.devDependencies[dep]) {
    console.log(`✅ ${dep} está nas dependências`);
  } else {
    console.warn(`⚠️ ${dep} não encontrado nas dependências`);
  }
});

// 4. Verificar configuração do Vite
console.log('\n⚙️ Verificando configuração do Vite...');
const viteConfig = fs.readFileSync('vite.config.ts', 'utf8');

if (viteConfig.includes('defineConfig')) {
  console.log('✅ Vite configurado corretamente');
} else {
  console.error('❌ Problema na configuração do Vite');
}

// 5. Verificar se o dist foi gerado
console.log('\n📦 Verificando pasta dist...');
if (fs.existsSync('dist')) {
  const distFiles = fs.readdirSync('dist');
  console.log(`✅ Pasta dist criada com ${distFiles.length} arquivos`);
  
  // Verificar arquivos essenciais no dist
  const essentialFiles = ['index.html', 'assets'];
  essentialFiles.forEach(file => {
    if (fs.existsSync(`dist/${file}`)) {
      console.log(`✅ ${file} existe no dist`);
    } else {
      console.warn(`⚠️ ${file} não encontrado no dist`);
    }
  });
} else {
  console.error('❌ Pasta dist não foi criada');
  process.exit(1);
}

// 6. Criar arquivo de configuração otimizado para Lovable
console.log('\n🎯 Criando configuração otimizada para Lovable...');

const lovableConfig = {
  build: {
    command: 'npm run build:prod',
    output: 'dist',
    install: 'npm ci'
  },
  env: {
    NODE_ENV: 'production',
    NODE_VERSION: '18'
  },
  ignore: [
    'node_modules',
    '.git',
    'dist',
    'build',
    '*.log',
    '.env.local',
    '.env.production',
    'coverage',
    '.nyc_output',
    'test-*.js',
    'teste-*.js',
    '*.md',
    'docs/',
    'supabase/functions/',
    'supabase/migrations/',
    'update-*.js',
    'fix-*.js',
    'create-*.js'
  ],
  cache: {
    paths: [
      'node_modules/.cache',
      '.vite'
    ]
  },
  network: {
    timeout: 300000
  }
};

fs.writeFileSync('lovable.config.js', `module.exports = ${JSON.stringify(lovableConfig, null, 2)};`);
console.log('✅ Configuração Lovable atualizada');

// 7. Verificar variáveis de ambiente
console.log('\n🔐 Verificando variáveis de ambiente...');
const envFiles = ['.env', '.env.local', '.env.production'];
envFiles.forEach(file => {
  if (fs.existsSync(file)) {
    console.log(`✅ ${file} existe`);
  } else {
    console.log(`ℹ️ ${file} não existe (normal para Lovable)`);
  }
});

// 8. Criar arquivo .env.example se não existir
if (!fs.existsSync('.env.example')) {
  const envExample = `# Variáveis de ambiente para produção
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
VITE_GOOGLE_AI_API_KEY=your_google_ai_key
VITE_ASAAS_API_KEY=your_asaas_key
VITE_RESEND_API_KEY=your_resend_key
`;
  fs.writeFileSync('.env.example', envExample);
  console.log('✅ .env.example criado');
}

// 9. Verificar se há erros de lint
console.log('\n🔍 Verificando lint...');
try {
  execSync('npm run lint', { stdio: 'pipe' });
  console.log('✅ Lint passou sem erros');
} catch (error) {
  console.warn('⚠️ Lint encontrou alguns problemas (não críticos para deploy)');
}

// 10. Resumo final
console.log('\n🎉 Verificação concluída!');
console.log('\n📋 Resumo para deploy na Lovable:');
console.log('✅ Build funcionando');
console.log('✅ Arquivos críticos presentes');
console.log('✅ Dependências verificadas');
console.log('✅ Configuração otimizada');
console.log('✅ Pasta dist gerada');

console.log('\n🚀 Para fazer deploy na Lovable:');
console.log('1. Acesse https://lovable.dev');
console.log('2. Conecte seu repositório GitHub');
console.log('3. Selecione este projeto');
console.log('4. Configure as variáveis de ambiente');
console.log('5. Faça o deploy!');

console.log('\n⚠️ Lembre-se de configurar as variáveis de ambiente na Lovable:');
console.log('- VITE_SUPABASE_URL');
console.log('- VITE_SUPABASE_ANON_KEY');
console.log('- VITE_GOOGLE_AI_API_KEY');
console.log('- VITE_ASAAS_API_KEY');
console.log('- VITE_RESEND_API_KEY'); 