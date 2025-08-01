#!/bin/bash

# Script para deploy manual no Lovable

echo "🚀 Iniciando deploy manual para Lovable..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: package.json não encontrado. Execute este script na raiz do projeto."
    exit 1
fi

# Limpar builds anteriores
echo "🧹 Limpando builds anteriores..."
rm -rf dist
rm -rf .lovable

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

echo "✅ Build concluído com sucesso!"

# Informações sobre o deploy
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
echo "✅ Build pronto para deploy manual!"
echo "🌐 Acesse https://app.lovable.dev para fazer o upload" 