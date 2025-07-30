# 🔑 Configuração das Chaves do Asaas

## Como obter sua chave da API do Asaas

### 1. Acesse o Portal do Asaas
Acesse: [Portal de API do Asaas](https://www.asaas.com/customerApiAccessToken/index?mshs=5827f28427311df056dc17d8b74230c6)

### 2. Faça login em sua conta
- Use seu email e senha do Asaas
- Se não tem conta, clique em "Criar uma conta"

### 3. Obtenha sua chave de API
Após fazer login, você encontrará sua chave de API no painel.

## 🛠️ Configuração no Projeto

### Crie o arquivo `.env` na raiz do projeto:

```env
# Configurações do Supabase
VITE_SUPABASE_URL=https://hlrkoyywjpckdotimtik.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhscmtveXl3anBja2RvdGltdGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMxNTMwNDcsImV4cCI6MjA2ODcyOTA0N30.kYEtg1hYG2pmcyIeXRs-vgNIVOD76Yu7KPlyFN0vdUI

# Configurações do Asaas - AMBIENTE DE PRODUÇÃO 🚀
VITE_ASAAS_SANDBOX=false
VITE_ASAAS_API_KEY=SUA_CHAVE_PRODUCAO_AQUI
VITE_ASAAS_BASE_URL=https://api.asaas.com/v3

# Para testes (sandbox), use estas configurações:
# VITE_ASAAS_SANDBOX=true
# VITE_ASAAS_SANDBOX_API_KEY=SUA_CHAVE_SANDBOX_AQUI
# VITE_ASAAS_BASE_URL=https://sandbox.asaas.com/api/v3

# Configurações da aplicação
VITE_APP_NAME=Plataforma dos Sonhos
VITE_APP_VERSION=1.0.0
VITE_APP_ENVIRONMENT=development

# Feature Flags
VITE_ENABLE_ASAAS_PAYMENTS=true
VITE_DEBUG_MODE=true
```

## 🔄 Passos para Configurar:

1. **Crie o arquivo `.env`** na raiz do projeto (mesmo nível do `package.json`)

2. **Copie o conteúdo acima** e cole no arquivo `.env`

3. **Substitua `SUA_CHAVE_PRODUCAO_AQUI`** pela chave que você obteve no portal do Asaas

4. **Reinicie o servidor de desenvolvimento**:
   ```bash
   npm run dev
   # ou
   yarn dev
   ```

## 🧪 Ambientes

### Sandbox (Testes)
- Use para desenvolvimento e testes
- As transações são simuladas
- URL: `https://sandbox.asaas.com/api/v3`

### Produção
- Use apenas quando a aplicação estiver pronta
- Transações reais
- URL: `https://api.asaas.com/v3`

## ✅ Verificação

Após configurar, a integração com pagamentos estará ativa e você poderá:
- Criar clientes
- Gerar cobranças
- Processar pagamentos
- Receber webhooks

## 🔐 Segurança

⚠️ **IMPORTANTE**: 
- Nunca commite o arquivo `.env` no git
- Mantenha suas chaves seguras
- Use o ambiente sandbox para testes 