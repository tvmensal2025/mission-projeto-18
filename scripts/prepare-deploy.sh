#!/bin/bash

# Script de preparação final para deploy no Lovable

echo "🚀 Preparando projeto para deploy no Lovable..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: package.json não encontrado. Execute este script na raiz do projeto."
    exit 1
fi

# Limpar builds anteriores
echo "🧹 Limpando builds anteriores..."
rm -rf dist
rm -rf .lovable

# Limpar arquivos temporários
echo "🧹 Limpando arquivos temporários..."
find . -name "*.log" -delete
find . -name ".DS_Store" -delete
find . -name "Thumbs.db" -delete

# Instalar dependências
echo "📦 Instalando dependências..."
npm install

# Fazer build para produção
echo "🔨 Fazendo build para produção..."
NODE_ENV=production npm run build:prod

# Verificar se o build foi bem-sucedido
if [ ! -d "dist" ]; then
    echo "❌ Erro: Build falhou. Verifique os erros acima."
    exit 1
fi

# Remover arquivos desnecessários do build
echo "🧹 Removendo arquivos desnecessários do build..."
rm -f dist/test-*.js
rm -f dist/*.test.js
rm -f dist/*.spec.js
rm -f dist/debug-*.js

# Verificar tamanho do build
echo "📊 Tamanho do build:"
du -sh dist/

echo ""
echo "✅ PREPARAÇÃO CONCLUÍDA!"
echo ""
echo "🎯 INFORMAÇÕES DO DEPLOY:"
echo "📱 URL do projeto: https://94a97375-ac4d-47f4-bf1d-a6ea0bef1040.lovableproject.com"
echo "🔧 Build gerado em: ./dist/"
echo ""
echo "📋 PRÓXIMOS PASSOS:"
echo "1. Acesse: https://app.lovable.dev"
echo "2. Faça login na sua conta"
echo "3. Selecione o projeto: Mission Health Nexus 99"
echo "4. Vá em 'Deploy' ou 'Settings'"
echo "5. Faça upload dos arquivos da pasta ./dist/"
echo ""
echo "📁 ARQUIVOS PARA UPLOAD:"
ls -la dist/

echo ""
echo "🎉 Projeto pronto para deploy no Lovable!" 