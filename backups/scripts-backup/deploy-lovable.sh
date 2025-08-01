#!/bin/bash

# Script para deploy no Lovable

echo "🚀 Iniciando deploy para Lovable..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: package.json não encontrado. Execute este script na raiz do projeto."
    exit 1
fi

# Verificar se o Lovable CLI está instalado
if ! command -v lovable &> /dev/null; then
    echo "📦 Instalando Lovable CLI..."
    npm install -g @lovable/cli
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
NODE_ENV=production npm run build

# Verificar se o build foi bem-sucedido
if [ ! -d "dist" ]; then
    echo "❌ Erro: Build falhou. Verifique os erros acima."
    exit 1
fi

echo "✅ Build concluído com sucesso!"

# Fazer deploy para Lovable
echo "🚀 Fazendo deploy para Lovable..."
lovable deploy

# Verificar status do deploy
if [ $? -eq 0 ]; then
    echo "🎉 Deploy concluído com sucesso!"
    echo "📱 URL da aplicação: https://94a97375-ac4d-47f4-bf1d-a6ea0bef1040.lovableproject.com"
else
    echo "❌ Erro no deploy. Verifique os logs acima."
    exit 1
fi

echo "✅ Deploy para Lovable finalizado!" 