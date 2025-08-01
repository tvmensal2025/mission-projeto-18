#!/bin/bash

echo "🚀 DEPLOY RÁPIDO AUTOMÁTICO"
echo "=============================="

# Configurar Git para uploads grandes
git config --global http.postBuffer 524288000
git config --global http.maxRequestBuffer 100M

# Git pull
echo "📥 Fazendo git pull..."
git pull origin main

# Adicionar mudanças
echo "📝 Adicionando mudanças..."
git add .

# Commit automático
echo "💾 Criando commit..."
git commit -m "🔄 Deploy automático $(date '+%Y-%m-%d %H:%M:%S')"

# Push para GitHub
echo "📤 Fazendo push para GitHub..."
git push origin main

# Build
echo "🔨 Fazendo build..."
npm run build

# Criar ZIP
echo "📦 Criando ZIP para Lovable..."
cd dist
zip -r ../lovable-deploy-rapido.zip .
cd ..

echo ""
echo "✅ DEPLOY RÁPIDO CONCLUÍDO!"
echo "📁 Arquivo: lovable-deploy-rapido.zip"
echo "🚀 Pronto para upload na Lovable!" 