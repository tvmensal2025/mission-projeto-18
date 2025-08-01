# 🚀 Configuração Supabase + Docker + GitHub

Este guia mostra como configurar o Supabase local com Docker e integrar com GitHub Actions.

## 📋 Pré-requisitos

- Docker Desktop instalado
- Node.js 18+ instalado
- Supabase CLI instalado
- Conta no GitHub

## 🔧 Configuração Local

### 1. Instalar Supabase CLI

```bash
# macOS
brew install supabase/tap/supabase

# Linux
curl -fsSL https://supabase.com/install.sh | sh

# Windows (com Chocolatey)
choco install supabase
```

### 2. Inicializar Supabase Local

```bash
# Tornar o script executável
chmod +x scripts/supabase-setup.sh

# Executar o script de configuração
./scripts/supabase-setup.sh
```

### 3. Alternativa Manual

Se preferir configurar manualmente:

```bash
# Inicializar Supabase
supabase init

# Iniciar Supabase local
supabase start

# Aplicar migrações
supabase db reset
```

## 🐳 Docker Compose

### Desenvolvimento Local

```bash
# Usar o arquivo de desenvolvimento
docker-compose -f docker-compose.dev.yml up -d

# Ver logs
docker-compose -f docker-compose.dev.yml logs -f
```

### Produção

```bash
# Usar o arquivo de produção
docker-compose up -d
```

## 🔑 Variáveis de Ambiente

Crie um arquivo `.env.local` na raiz do projeto:

```env
# Desenvolvimento Local
REACT_APP_SUPABASE_URL=http://localhost:54321
REACT_APP_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhscmtveXl3anBja2RvdGltdGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMxNTMwNDcsImV4cCI6MjA2ODcyOTA0N30.kYEtg1hYG2pmcyIeXRs-vgNIVOD76Yu7KPlyFN0vdUI

# Produção
# REACT_APP_SUPABASE_URL=https://hlrkoyywjpckdotimtik.supabase.co
# REACT_APP_SUPABASE_ANON_KEY=sua_chave_de_producao
```

## 📊 URLs Importantes

Após iniciar o Supabase local:

- **Supabase Studio**: http://localhost:54323
- **API**: http://localhost:54321
- **Database**: postgresql://postgres:your-super-secret-and-long-postgres-password@localhost:54322/postgres
- **Inbucket (emails)**: http://localhost:54324

## 🔄 Comandos Úteis

```bash
# Status do Supabase
supabase status

# Parar Supabase
supabase stop

# Reiniciar Supabase
supabase restart

# Ver logs
supabase logs

# Aplicar migrações
supabase db reset

# Gerar tipos TypeScript
supabase gen types typescript --local > src/integrations/supabase/types.ts
```

## 🚀 GitHub Actions

### 1. Configurar Secrets

No seu repositório GitHub, vá em Settings > Secrets and variables > Actions e adicione:

- `SUPABASE_URL`: URL do seu projeto Supabase
- `SUPABASE_ANON_KEY`: Chave anônima do Supabase
- `SUPABASE_SERVICE_ROLE_KEY`: Chave de serviço do Supabase

### 2. Workflow CI/CD

O arquivo `.github/workflows/ci-cd.yml` já está configurado para:

- Executar testes em cada PR
- Fazer build da aplicação
- Deploy automático na branch main

## 🔧 Desenvolvimento

### Usar Cliente Local

```typescript
// Importar cliente de desenvolvimento
import { supabaseDev } from '@/integrations/supabase/client-dev';

// Ou usar função que alterna automaticamente
import { getSupabaseClient } from '@/integrations/supabase/client-dev';
const supabase = getSupabaseClient();
```

### Migrações

```bash
# Criar nova migração
supabase migration new nome_da_migracao

# Aplicar migrações
supabase db reset

# Fazer diff com produção
supabase db diff
```

## 🐛 Troubleshooting

### Docker não inicia

```bash
# Verificar se Docker está rodando
docker info

# Limpar containers
docker system prune -a

# Reiniciar Docker Desktop
```

### Supabase não conecta

```bash
# Verificar status
supabase status

# Reiniciar Supabase
supabase stop
supabase start

# Verificar logs
supabase logs
```

### Problemas de Porta

Se as portas estiverem ocupadas:

```bash
# Verificar portas em uso
lsof -i :54321
lsof -i :54322
lsof -i :54323

# Matar processo se necessário
kill -9 <PID>
```

## 📚 Recursos Adicionais

- [Documentação Supabase](https://supabase.com/docs)
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- [Docker Compose](https://docs.docker.com/compose/)
- [GitHub Actions](https://docs.github.com/en/actions)

## 🎯 Próximos Passos

1. Configure as variáveis de ambiente
2. Execute o script de setup
3. Teste a conexão local
4. Configure os secrets no GitHub
5. Faça push para testar o CI/CD

---

**✅ Configuração completa!** Seu ambiente Supabase + Docker + GitHub está pronto para desenvolvimento. 