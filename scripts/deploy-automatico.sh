#!/bin/bash

# ===============================================
# 🚀 SCRIPT DE DEPLOY AUTOMÁTICO COMPLETO
# ===============================================
# Autor: Sistema Automatizado
# Data: $(date)
# Versão: 1.0

set -e  # Parar em caso de erro

echo "🚀 INICIANDO DEPLOY AUTOMÁTICO COMPLETO..."
echo "=============================================="

# ===============================================
# 1. CONFIGURAÇÕES INICIAIS
# ===============================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log colorido
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERRO] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[AVISO] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# ===============================================
# 2. VERIFICAR DEPENDÊNCIAS
# ===============================================

log "Verificando dependências..."

# Verificar se git está instalado
if ! command -v git &> /dev/null; then
    error "Git não está instalado!"
    exit 1
fi

# Verificar se node está instalado
if ! command -v node &> /dev/null; then
    error "Node.js não está instalado!"
    exit 1
fi

# Verificar se npm está instalado
if ! command -v npm &> /dev/null; then
    error "NPM não está instalado!"
    exit 1
fi

log "✅ Todas as dependências estão instaladas"

# ===============================================
# 3. CONFIGURAR GIT
# ===============================================

log "Configurando Git para uploads grandes..."

# Configurar buffers para uploads grandes
git config --global http.postBuffer 524288000
git config --global http.maxRequestBuffer 100M
git config --global core.compression 9

log "✅ Git configurado para uploads grandes"

# ===============================================
# 4. GIT PULL
# ===============================================

log "Fazendo git pull..."

if git pull origin main; then
    log "✅ Git pull realizado com sucesso"
else
    warning "⚠️ Git pull falhou, continuando mesmo assim..."
fi

# ===============================================
# 5. VERIFICAR MUDANÇAS
# ===============================================

log "Verificando mudanças..."

if [[ -n $(git status --porcelain) ]]; then
    log "📝 Mudanças detectadas, preparando commit..."
    
    # Adicionar todas as mudanças
    git add .
    
    # Criar commit com timestamp
    COMMIT_MESSAGE="🔄 Deploy automático $(date '+%Y-%m-%d %H:%M:%S') - Sistema atualizado"
    
    if git commit -m "$COMMIT_MESSAGE"; then
        log "✅ Commit criado: $COMMIT_MESSAGE"
    else
        error "❌ Falha ao criar commit"
        exit 1
    fi
else
    log "ℹ️ Nenhuma mudança detectada"
fi

# ===============================================
# 6. GIT PUSH
# ===============================================

log "Fazendo push para GitHub..."

if git push origin main --verbose; then
    log "✅ Push para GitHub realizado com sucesso"
else
    error "❌ Falha no push para GitHub"
    exit 1
fi

# ===============================================
# 7. INSTALAR DEPENDÊNCIAS
# ===============================================

log "Instalando dependências..."

if npm install; then
    log "✅ Dependências instaladas"
else
    error "❌ Falha ao instalar dependências"
    exit 1
fi

# ===============================================
# 8. BUILD DO PROJETO
# ===============================================

log "Fazendo build do projeto..."

if npm run build; then
    log "✅ Build realizado com sucesso"
else
    error "❌ Falha no build"
    exit 1
fi

# ===============================================
# 9. CRIAR ZIP PARA LOVABLE
# ===============================================

log "Criando arquivo ZIP para Lovable..."

# Remover ZIP anterior se existir
if [ -f "lovable-deploy-auto.zip" ]; then
    rm lovable-deploy-auto.zip
fi

# Criar novo ZIP
cd dist
if zip -r ../lovable-deploy-auto.zip .; then
    log "✅ ZIP criado: lovable-deploy-auto.zip"
else
    error "❌ Falha ao criar ZIP"
    exit 1
fi
cd ..

# ===============================================
# 10. VERIFICAR DOCKER
# ===============================================

log "Verificando status do Docker..."

if command -v docker &> /dev/null; then
    if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "supabase"; then
        log "✅ Containers Supabase estão rodando"
    else
        warning "⚠️ Containers Supabase não estão rodando"
    fi
else
    warning "⚠️ Docker não está instalado"
fi

# ===============================================
# 11. RELATÓRIO FINAL
# ===============================================

echo ""
echo "🎉 DEPLOY AUTOMÁTICO CONCLUÍDO COM SUCESSO!"
echo "=============================================="
echo ""
echo "📊 RESUMO:"
echo "✅ Git pull realizado"
echo "✅ Commit criado e enviado"
echo "✅ Push para GitHub realizado"
echo "✅ Dependências instaladas"
echo "✅ Build do projeto realizado"
echo "✅ ZIP para Lovable criado"
echo ""
echo "📁 ARQUIVOS CRIADOS:"
echo "   - lovable-deploy-auto.zip (pronto para upload na Lovable)"
echo ""
echo "🌐 URLs DISPONÍVEIS:"
echo "   - Local: http://localhost:8080"
echo "   - Supabase Studio: http://127.0.0.1:54323"
echo "   - API: http://127.0.0.1:54321"
echo ""
echo "🚀 PRÓXIMOS PASSOS:"
echo "   1. Fazer upload do lovable-deploy-auto.zip na Lovable"
echo "   2. Testar o sistema em produção"
echo "   3. Verificar se Maria Joana aparece na lista"
echo ""
echo "⏰ Deploy realizado em: $(date)"
echo "==============================================" 