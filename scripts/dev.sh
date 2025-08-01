#!/bin/bash

# Script para desenvolvimento com Supabase e Docker

echo "🚀 Iniciando ambiente de desenvolvimento..."

# Verificar se Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando. Por favor, inicie o Docker primeiro."
    exit 1
fi

# Função para mostrar menu
show_menu() {
    echo ""
    echo "📋 Menu de Desenvolvimento:"
    echo "1) Iniciar Supabase local"
    echo "2) Parar Supabase local"
    echo "3) Reiniciar Supabase local"
    echo "4) Ver status do Supabase"
    echo "5) Ver logs do Supabase"
    echo "6) Aplicar migrações"
    echo "7) Iniciar aplicação React"
    echo "8) Iniciar tudo (Supabase + React)"
    echo "9) Parar tudo"
    echo "0) Sair"
    echo ""
    read -p "Escolha uma opção: " choice
}

# Função para iniciar Supabase
start_supabase() {
    echo "🔄 Iniciando Supabase local..."
    supabase start
    echo "✅ Supabase iniciado!"
    echo "📊 URLs:"
    echo "   - Studio: http://localhost:54323"
    echo "   - API: http://localhost:54321"
    echo "   - Database: localhost:54322"
}

# Função para parar Supabase
stop_supabase() {
    echo "🛑 Parando Supabase local..."
    supabase stop
    echo "✅ Supabase parado!"
}

# Função para reiniciar Supabase
restart_supabase() {
    echo "🔄 Reiniciando Supabase local..."
    supabase stop
    sleep 2
    supabase start
    echo "✅ Supabase reiniciado!"
}

# Função para ver status
show_status() {
    echo "📊 Status do Supabase:"
    supabase status
}

# Função para ver logs
show_logs() {
    echo "📋 Logs do Supabase:"
    supabase logs
}

# Função para aplicar migrações
apply_migrations() {
    echo "📊 Aplicando migrações..."
    supabase db reset
    echo "✅ Migrações aplicadas!"
}

# Função para iniciar React
start_react() {
    echo "⚛️ Iniciando aplicação React..."
    npm start
}

# Função para iniciar tudo
start_all() {
    echo "🚀 Iniciando ambiente completo..."
    start_supabase
    echo ""
    echo "⏳ Aguardando 10 segundos para o banco inicializar..."
    sleep 10
    apply_migrations
    echo ""
    echo "⚛️ Iniciando aplicação React..."
    npm start
}

# Função para parar tudo
stop_all() {
    echo "🛑 Parando tudo..."
    stop_supabase
    echo "✅ Ambiente parado!"
}

# Loop principal
while true; do
    show_menu
    
    case $choice in
        1)
            start_supabase
            ;;
        2)
            stop_supabase
            ;;
        3)
            restart_supabase
            ;;
        4)
            show_status
            ;;
        5)
            show_logs
            ;;
        6)
            apply_migrations
            ;;
        7)
            start_react
            ;;
        8)
            start_all
            ;;
        9)
            stop_all
            ;;
        0)
            echo "👋 Saindo..."
            exit 0
            ;;
        *)
            echo "❌ Opção inválida!"
            ;;
    esac
    
    echo ""
    read -p "Pressione Enter para continuar..."
done 