#!/bin/bash

# Script completo para deploy no Lovable

echo "🚀 DEPLOY COMPLETO PARA LOVABLE"
echo "=================================="

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: package.json não encontrado. Execute este script na raiz do projeto."
    exit 1
fi

# Parar servidores em execução
echo "🛑 Parando servidores em execução..."
pkill -f vite 2>/dev/null || true
pkill -f supabase 2>/dev/null || true

# Limpar builds anteriores
echo "🧹 Limpando builds anteriores..."
rm -rf dist
rm -rf .lovable
rm -f lovable-deploy.zip

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

# Criar ZIP para upload
echo "📦 Criando arquivo ZIP para upload..."
cd dist && zip -r ../lovable-deploy.zip . && cd ..

# Verificar se o ZIP foi criado
if [ ! -f "lovable-deploy.zip" ]; then
    echo "❌ Erro: Falha ao criar arquivo ZIP."
    exit 1
fi

echo "✅ Arquivo ZIP criado: lovable-deploy.zip"

# Informações finais
echo ""
echo "🎉 DEPLOY PRONTO!"
echo "=================="
echo ""
echo "📱 URL do projeto: https://94a97375-ac4d-47f4-bf1d-a6ea0bef1040.lovableproject.com"
echo "📦 Arquivo ZIP: lovable-deploy.zip"
echo "📁 Pasta dist: ./dist/"
echo ""
echo "📋 PRÓXIMOS PASSOS:"
echo "1. Acesse: https://app.lovable.dev"
echo "2. Faça login na sua conta"
echo "3. Selecione o projeto: Mission Health Nexus 99"
echo "4. Vá em 'Deploy' ou 'Settings'"
echo "5. Faça upload do arquivo: lovable-deploy.zip"
echo ""
echo "📊 ARQUIVOS DISPONÍVEIS:"
echo "- lovable-deploy.zip (arquivo compactado para upload)"
echo "- ./dist/ (pasta com todos os arquivos)"
echo ""
echo "📈 ESTATÍSTICAS DO BUILD:"
ls -lh dist/assets/ | head -10
echo ""
echo "✅ Deploy completo finalizado!"
echo "🌐 Acesse https://app.lovable.dev para fazer o upload" 