#!/bin/bash

# Script para configurar Supabase local com Docker

echo "🚀 Configurando Supabase local..."

# Verificar se o Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando. Por favor, inicie o Docker primeiro."
    exit 1
fi

# Verificar se o Supabase CLI está instalado
if ! command -v supabase &> /dev/null; then
    echo "📦 Instalando Supabase CLI..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install supabase/tap/supabase
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        curl -fsSL https://supabase.com/install.sh | sh
    else
        echo "❌ Sistema operacional não suportado. Instale o Supabase CLI manualmente."
        exit 1
    fi
fi

# Inicializar Supabase (se não estiver inicializado)
if [ ! -f "supabase/config.toml" ]; then
    echo "📁 Inicializando Supabase..."
    supabase init
fi

# Iniciar Supabase local
echo "🔄 Iniciando Supabase local..."
supabase start

# Aguardar um pouco para o banco inicializar
echo "⏳ Aguardando inicialização do banco de dados..."
sleep 10

# Aplicar migrações
echo "📊 Aplicando migrações..."
supabase db reset

# Verificar status
echo "✅ Verificando status do Supabase..."
supabase status

echo "🎉 Supabase local configurado com sucesso!"
echo ""
echo "📋 URLs importantes:"
echo "   - Supabase Studio: http://localhost:54323"
echo "   - API: http://localhost:54321"
echo "   - Database: postgresql://postgres:your-super-secret-and-long-postgres-password@localhost:54322/postgres"
echo "   - Inbucket (emails): http://localhost:54324"
echo ""
echo "🔑 Chaves de API:"
supabase status --output json | jq -r '.api_keys.anon' 