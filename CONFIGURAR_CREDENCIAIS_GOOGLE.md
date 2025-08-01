# 🔑 CONFIGURAR CREDENCIAIS DO GOOGLE

## ✅ **O QUE VOCÊ PRECISA CRIAR:**

### 1️⃣ **ID DO CLIENTE OAUTH 2.0** (Para Google Calendar)
- **Finalidade:** Sofia criar/gerenciar eventos no Google Calendar
- **Tipo:** Aplicativo da Web
- **URI de redirecionamento:** `https://hlrkoyywjpckdotimtik.supabase.co/functions/v1/calendar-oauth-callback`

### 2️⃣ **CHAVE DE API** (Para Google AI/Gemini)  
- **Finalidade:** Sofia e Dr. Vital usarem Google AI (Gemini)
- **Restrição recomendada:** Generative Language API

---

## 🚀 **DEPOIS DE CRIAR, EXECUTE:**

### 1. **Configurar no Supabase:**
```bash
# OAuth Client ID (para Calendar)
supabase secrets set GOOGLE_OAUTH_CLIENT_ID="seu_client_id_aqui"

# API Key (para AI/Gemini) - se não tiver ainda
supabase secrets set GOOGLE_AI_API_KEY="sua_api_key_aqui"
```

### 2. **Verificar se funcionou:**
```bash
supabase secrets list
```

### 3. **Testar o sistema:**
```javascript
// Testar Calendar Integration
fetch('https://hlrkoyywjpckdotimtik.supabase.co/functions/v1/calendar-manager', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    userId: 'test-user',
    action: 'setup_oauth'
  })
})

// Testar AI Integration (Sofia)
fetch('https://hlrkoyywjpckdotimtik.supabase.co/functions/v1/health-chat-bot', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    message: 'Olá Sofia!',
    userId: 'test-user'
  })
})
```

---

## 🎯 **RESULTADO ESPERADO:**

✅ **Google Calendar:** Sofia poderá criar eventos automaticamente
✅ **Google AI:** Sofia e Dr. Vital funcionando com Gemini
✅ **Sistema Completo:** Todos os 6 módulos multi-agente operacionais

---

## 🚨 **IMPORTANTE:**

- **OAuth Client ID** = Para Calendar (criar eventos)
- **API Key** = Para AI/Gemini (chat inteligente)
- Ambos são necessários para o sistema completo funcionar

**Crie os dois e depois configure no Supabase!** 🔥