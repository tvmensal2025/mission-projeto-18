# 🚀 Guia de Deploy na Lovable

## 📋 Pré-requisitos

### ✅ Verificações Concluídas
- ✅ Build funcionando corretamente
- ✅ Arquivos críticos presentes
- ✅ Dependências verificadas
- ✅ Configuração otimizada
- ✅ Pasta dist gerada

## 🔧 Configuração para Lovable

### 1. **Variáveis de Ambiente Necessárias**

Configure estas variáveis na Lovable:

```bash
# Supabase Configuration
VITE_SUPABASE_URL=https://hlrkoyywjpckdotimtik.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhscmtveXl3anBja2RvdGltdGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMxNTMwNDcsImV4cCI6MjA2ODcyOTA0N30.kYEtg1hYG2pmcyIeXRs-vgNIVOD76Yu7KPlyFN0vdUI

# Google AI (Gemini) Configuration
VITE_GOOGLE_AI_API_KEY=your_google_ai_api_key_here

# Asaas Payment Configuration
VITE_ASAAS_API_KEY=your_asaas_api_key_here
VITE_ASAAS_SANDBOX_API_KEY=your_asaas_sandbox_api_key_here
VITE_ASAAS_BASE_URL=https://sandbox.asaas.com/api/v3
VITE_ASAAS_SANDBOX=true

# Resend Email Configuration
VITE_RESEND_API_KEY=your_resend_api_key_here

# App Configuration
VITE_APP_NAME=Mission Health Nexus
VITE_APP_VERSION=1.0.0
VITE_APP_ENVIRONMENT=production

# GitHub Configuration
VITE_GITHUB_REPO_URL=https://github.com/tvmensal2025/mission-projeto-18
VITE_GITHUB_REPO_NAME=mission-projeto-18

# API Configuration
VITE_API_BASE_URL=https://your-app.lovable.dev
```

### 2. **Configuração do Build**

O projeto está configurado com:
- **Build Command**: `npm run build:prod`
- **Output Directory**: `dist`
- **Node Version**: 18
- **Install Command**: `npm ci`

### 3. **Arquivos Ignorados**

Os seguintes arquivos/pastas são ignorados no deploy:
- `node_modules`
- `.git`
- `dist`
- `build`
- `*.log`
- `.env.local`
- `.env.production`
- `coverage`
- `*.md`
- `docs/`
- `supabase/functions/`
- `supabase/migrations/`
- `update-*.js`
- `fix-*.js`
- `create-*.js`

## 🚀 Passos para Deploy

### 1. **Acesse a Lovable**
- Vá para https://lovable.dev
- Faça login com sua conta GitHub

### 2. **Conecte o Repositório**
- Clique em "New Project"
- Selecione o repositório `tvmensal2025/mission-projeto-18`
- Escolha a branch `main`

### 3. **Configure as Variáveis de Ambiente**
- Vá em "Settings" > "Environment Variables"
- Adicione todas as variáveis listadas acima
- Certifique-se de usar os valores corretos para produção

### 4. **Configure o Build**
- **Framework**: Vite
- **Build Command**: `npm run build:prod`
- **Output Directory**: `dist`
- **Install Command**: `npm ci`

### 5. **Faça o Deploy**
- Clique em "Deploy"
- Aguarde o build completar
- Verifique se não há erros

## 🔍 Solução de Problemas

### Erro: "Build failed"
**Solução:**
1. Verifique se todas as dependências estão no `package.json`
2. Confirme se o Node.js 18 está sendo usado
3. Verifique se as variáveis de ambiente estão configuradas

### Erro: "Module not found"
**Solução:**
1. Execute `npm install` localmente
2. Verifique se o `package-lock.json` está no repositório
3. Use `npm ci` em vez de `npm install`

### Erro: "Environment variables not found"
**Solução:**
1. Configure todas as variáveis necessárias na Lovable
2. Verifique se os nomes das variáveis estão corretos
3. Reinicie o deploy após configurar as variáveis

### Erro: "Chunk size too large"
**Solução:**
- O projeto já está configurado com code splitting
- Os chunks estão otimizados para melhor performance

## 📊 Monitoramento

### 1. **Logs de Build**
- Verifique os logs na seção "Deployments"
- Procure por erros específicos
- Confirme se o build está usando as variáveis corretas

### 2. **Performance**
- O projeto está otimizado com:
  - Code splitting automático
  - Minificação com Terser
  - Chunks otimizados
  - Dependências pré-carregadas

### 3. **Variáveis de Ambiente**
- Todas as variáveis começam com `VITE_`
- São acessíveis no frontend
- Configuradas para produção

## 🎯 URLs Importantes

### Desenvolvimento
- **Local**: http://localhost:5173
- **GitHub**: https://github.com/tvmensal2025/mission-projeto-18

### Produção
- **Lovable**: https://your-app.lovable.dev
- **Supabase**: https://hlrkoyywjpckdotimtik.supabase.co

## 📞 Suporte

Se encontrar problemas:
1. Verifique os logs de build
2. Confirme as variáveis de ambiente
3. Teste o build localmente primeiro
4. Entre em contato com o suporte da Lovable

---

**Status:** ✅ Pronto para Deploy  
**Última verificação:** Janeiro 2025  
**Responsável:** Equipe de Desenvolvimento 