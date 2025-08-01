# ✅ Configuração Completa: Supabase + Docker + GitHub

## 🎯 O que foi configurado

### 1. **Supabase Local**
- ✅ Configuração completa do `supabase/config.toml`
- ✅ Cliente de desenvolvimento em `src/integrations/supabase/client-dev.ts`
- ✅ Script de setup automático em `scripts/supabase-setup.sh`

### 2. **Docker Compose**
- ✅ Arquivo de desenvolvimento: `docker-compose.dev.yml`
- ✅ Configuração para produção: `docker-compose.yml`
- ✅ Serviços: Supabase, Redis, Aplicação React

### 3. **GitHub Actions**
- ✅ Workflow CI/CD em `.github/workflows/ci-cd.yml`
- ✅ Testes automatizados com PostgreSQL
- ✅ Deploy automático na branch main

### 4. **Scripts de Desenvolvimento**
- ✅ Script interativo: `scripts/dev.sh`
- ✅ Script de setup: `scripts/supabase-setup.sh`
- ✅ Comandos npm adicionados ao `package.json`

## 🚀 Como usar

### Início Rápido

```bash
# 1. Configurar Supabase local
npm run setup

# 2. Iniciar ambiente completo
npm run dev:full

# 3. Ou usar comandos individuais
npm run supabase:start
npm run docker:dev
npm run dev
```

### Comandos Disponíveis

```bash
# Supabase
npm run supabase:start    # Iniciar Supabase local
npm run supabase:stop     # Parar Supabase local
npm run supabase:status   # Ver status
npm run supabase:reset    # Aplicar migrações
npm run supabase:logs     # Ver logs

# Docker
npm run docker:dev        # Iniciar containers de desenvolvimento
npm run docker:stop       # Parar containers
npm run docker:logs       # Ver logs dos containers

# Desenvolvimento
npm run dev:full          # Script interativo completo
npm run setup             # Setup inicial
```

## 📊 URLs Importantes

### Desenvolvimento Local
- **Supabase Studio**: http://localhost:54323
- **API**: http://localhost:54321
- **Database**: postgresql://postgres:your-super-secret-and-long-postgres-password@localhost:54322/postgres
- **Inbucket (emails)**: http://localhost:54324
- **Aplicação React**: http://localhost:3000

### Produção
- **Supabase**: https://hlrkoyywjpckdotimtik.supabase.co
- **Aplicação**: (configurar conforme deploy)

## 🔑 Variáveis de Ambiente

### Desenvolvimento (.env.local)
```env
REACT_APP_SUPABASE_URL=http://localhost:54321
REACT_APP_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhscmtveXl3anBja2RvdGltdGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMxNTMwNDcsImV4cCI6MjA2ODcyOTA0N30.kYEtg1hYG2pmcyIeXRs-vgNIVOD76Yu7KPlyFN0vdUI
```

### GitHub Secrets (Configurar no repositório)
- `SUPABASE_URL`: URL do projeto Supabase
- `SUPABASE_ANON_KEY`: Chave anônima do Supabase
- `SUPABASE_SERVICE_ROLE_KEY`: Chave de serviço do Supabase

## 📁 Estrutura de Arquivos

```
mission-projeto-18/
├── supabase/
│   ├── config.toml                    # Configuração Supabase
│   ├── migrations/                    # Migrações do banco
│   └── functions/                     # Edge Functions
├── src/integrations/supabase/
│   ├── client.ts                      # Cliente produção
│   ├── client-dev.ts                  # Cliente desenvolvimento
│   └── types.ts                       # Tipos TypeScript
├── scripts/
│   ├── supabase-setup.sh             # Setup automático
│   └── dev.sh                        # Script interativo
├── docker-compose.yml                 # Produção
├── docker-compose.dev.yml             # Desenvolvimento
├── .github/workflows/ci-cd.yml       # GitHub Actions
└── env.example                       # Exemplo de variáveis
```

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

### Problemas Comuns

1. **Docker não inicia**
   ```bash
   docker info
   docker system prune -a
   ```

2. **Supabase não conecta**
   ```bash
   supabase status
   supabase stop && supabase start
   ```

3. **Portas ocupadas**
   ```bash
   lsof -i :54321
   kill -9 <PID>
   ```

## 🎯 Próximos Passos

1. ✅ Configurar variáveis de ambiente
2. ✅ Executar `npm run setup`
3. ✅ Testar conexão local
4. ✅ Configurar secrets no GitHub
5. ✅ Fazer push para testar CI/CD

## 📚 Documentação

- [Guia Completo](SUPABASE_DOCKER_GITHUB_SETUP.md)
- [Supabase Docs](https://supabase.com/docs)
- [Docker Compose](https://docs.docker.com/compose/)
- [GitHub Actions](https://docs.github.com/en/actions)

---

**🎉 Configuração completa!** Seu ambiente está pronto para desenvolvimento com Supabase, Docker e GitHub Actions. 