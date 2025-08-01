# 🔍 DIAGNÓSTICO DA SOFIA - PROBLEMAS DE CONEXÃO

## 🚨 PROBLEMAS IDENTIFICADOS

### 1. **Erro 401 - Unauthorized**
- A função `health-chat-bot` está retornando erro de autenticação
- Isso indica que a Sofia não consegue se conectar com a IA

### 2. **Possíveis Causas:**

#### A) **Chave de API Inválida**
- A chave do Supabase pode estar incorreta
- A chave do Google AI pode estar expirada

#### B) **Configurações de RLS (Row Level Security)**
- As políticas de segurança podem estar bloqueando o acesso
- A função pode não ter permissões adequadas

#### C) **Configurações da Edge Function**
- A função pode ter sido alterada e perdeu configurações
- Variáveis de ambiente podem estar faltando

## 🛠️ SOLUÇÕES PARA MANTER SOFIA CONECTADA

### **SOLUÇÃO 1: Verificar no Frontend**
```
1. Abra http://localhost:5173
2. Faça login na plataforma
3. Vá para o chat da Sofia
4. Teste uma mensagem: "Oi Sofia"
```

### **SOLUÇÃO 2: Verificar Logs da Edge Function**
```bash
# Ver logs em tempo real
npx supabase functions logs health-chat-bot --follow
```

### **SOLUÇÃO 3: Redeployar a Função**
```bash
# Redeploy da função Sofia
npx supabase functions deploy health-chat-bot
```

### **SOLUÇÃO 4: Verificar Variáveis de Ambiente**
No Supabase Dashboard:
- `GOOGLE_AI_API_KEY` - Deve estar configurada
- `SUPABASE_URL` - Deve estar configurada  
- `SUPABASE_SERVICE_ROLE_KEY` - Deve estar configurada

## 🎯 PRÓXIMOS PASSOS

1. **TESTE NO FRONTEND PRIMEIRO** - É a forma mais confiável
2. Se não funcionar no frontend, o problema é real
3. Se funcionar no frontend, é só problema de autenticação nos testes

## 📱 COMO ACESSAR O CHAT DA SOFIA

1. Abra o navegador em `http://localhost:5173`
2. Faça login com suas credenciais
3. Procure por "Chat" ou "Sofia" no menu
4. Teste uma conversa simples

## ✅ SOFIA FUNCIONANDO = PLATAFORMA FUNCIONAL

Se a Sofia responder no frontend, significa que:
- ✅ IA está conectada
- ✅ Configurações estão corretas
- ✅ Usuários podem conversar normalmente
- ✅ Análise de comida funciona
- ✅ Relatórios são gerados