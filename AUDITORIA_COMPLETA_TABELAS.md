# 🔍 AUDITORIA COMPLETA - TODAS AS TABELAS E COLUNAS NECESSÁRIAS

## 📊 TABELAS IDENTIFICADAS NO FRONTEND

### 1. **TABELAS PRINCIPAIS**
- `profiles` ✅
- `weight_measurements` ✅
- `user_physical_data` ✅
- `user_goals` ✅
- `sessions` ⚠️ (problemas identificados)
- `user_sessions` ❌
- `courses` ✅
- `course_modules` ✅
- `lessons` / `course_lessons` ✅
- `ai_configurations` ✅

### 2. **TABELAS DE MISSÕES E GAMIFICAÇÃO**
- `daily_mission_sessions` ❌
- `daily_responses` ❌
- `user_scores` ❌
- `challenges` ⚠️ (falta target_value)
- `challenge_participations` ❌
- `goal_categories` ❌
- `goal_updates` ❌

### 3. **TABELAS DE TRACKING**
- `water_tracking` ❌
- `sleep_tracking` ❌
- `mood_tracking` ❌
- `weekly_analyses` ❌
- `life_wheel` ❌
- `activity_categories` ❌
- `activity_sessions` ❌

### 4. **TABELAS DE SAÚDE E ANÁLISES**
- `preventive_health_analyses` ❌
- `health_diary` ❌
- `chat_conversations` ❌
- `chat_emotional_analysis` ❌
- `custom_saboteurs` ❌

### 5. **TABELAS DE CONTEÚDO E MÍDIA**
- `avatars` ❌
- `chat-images` ❌
- `community-uploads` ❌

## 🚨 PROBLEMAS CRÍTICOS IDENTIFICADOS

### **SESSIONS TABLE** - Colunas faltantes:
- `follow_up_questions` (TEXT[])
- `target_saboteurs` (TEXT[])
- `type` (TEXT)
- `is_active` (BOOLEAN)
- `tools_data` (JSONB)

### **USER_SESSIONS TABLE** - Tabela inexistente:
```sql
CREATE TABLE user_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID REFERENCES sessions(id),
  user_id UUID REFERENCES auth.users(id),
  status TEXT DEFAULT 'pending',
  assigned_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  started_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  due_date TIMESTAMP WITH TIME ZONE,
  progress INTEGER DEFAULT 0,
  feedback TEXT,
  notes TEXT,
  auto_save_data JSONB DEFAULT '{}',
  tools_data JSONB DEFAULT '{}',
  last_activity TIMESTAMP WITH TIME ZONE DEFAULT now(),
  cycle_number INTEGER DEFAULT 1,
  next_available_date TIMESTAMP WITH TIME ZONE,
  is_locked BOOLEAN DEFAULT false,
  review_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
```

### **DAILY_MISSION_SESSIONS** - Tabela crítica inexistente:
```sql
CREATE TABLE daily_mission_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  date DATE DEFAULT CURRENT_DATE,
  is_completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
```

### **DAILY_RESPONSES** - Tabela crítica inexistente:
```sql
CREATE TABLE daily_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  session_id UUID,
  question_id TEXT,
  response_value INTEGER,
  response_text TEXT,
  date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
```

## 🎯 PRIORIDADES DE CORREÇÃO

### **PRIORIDADE 1 - CRÍTICA** (Sistema não funciona sem):
1. Corrigir tabela `sessions` - adicionar colunas faltantes
2. Criar tabela `user_sessions` 
3. Criar tabela `daily_mission_sessions`
4. Criar tabela `daily_responses`

### **PRIORIDADE 2 - ALTA** (Funcionalidades importantes):
1. Criar tabelas de tracking (`water_tracking`, `sleep_tracking`, `mood_tracking`)
2. Criar `challenge_participations`
3. Criar `goal_categories` e `goal_updates`
4. Adicionar `target_value` em `challenges`

### **PRIORIDADE 3 - MÉDIA** (Funcionalidades complementares):
1. Criar tabelas de análise (`weekly_analyses`, `preventive_health_analyses`)
2. Criar tabelas de chat (`chat_conversations`, `chat_emotional_analysis`)
3. Criar tabelas de conteúdo (`avatars`, `community-uploads`)

## 📋 COLUNAS ESPECÍFICAS FALTANTES

### **SESSIONS TABLE**:
- `follow_up_questions` TEXT[]
- `target_saboteurs` TEXT[]
- `type` TEXT
- `is_active` BOOLEAN
- `tools_data` JSONB

### **CHALLENGES TABLE**:
- `target_value` DECIMAL(10,2)

### **PROFILES TABLE** (verificar se existem):
- `height_cm` DECIMAL
- `role` TEXT

## 🔧 SCRIPT DE CORREÇÃO NECESSÁRIO

Preciso criar um script que:
1. Adicione colunas faltantes em `sessions`
2. Crie todas as tabelas inexistentes
3. Configure RLS adequadamente
4. Insira dados de exemplo onde necessário

## ✅ CONCLUSÃO

O sistema tem **43 tabelas esperadas pelo frontend**, mas apenas **~15 existem**. 
A maioria dos erros vem de **tabelas completamente inexistentes**, não apenas colunas faltantes.

**Próximo passo**: Criar script de correção completa baseado nesta auditoria.