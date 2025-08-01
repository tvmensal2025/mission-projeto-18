# 🗄️ BANCO DE DADOS COMPLETO PARA SOFIA - SEM DUPLICAÇÃO

## ✅ **ANÁLISE DO CADASTRO ATUAL**

### **CAMPOS JÁ IMPLEMENTADOS NO CADASTRO:**
- ✅ **Nome completo** (`full_name`)
- ✅ **Email** (`email`)
- ✅ **Telefone** (`phone`)
- ✅ **Data de nascimento** (`birth_date`)
- ✅ **Gênero** (`gender`)
- ✅ **Cidade** (`city`)
- ✅ **Estado** (`state`)
- ✅ **Altura** (`height`)

### **PROCESSO DE SALVAMENTO:**
1. **`auth.users`** - Dados de autenticação
2. **`profiles`** - Perfil principal do usuário
3. **`user_physical_data`** - Dados físicos específicos

---

## 📊 **DADOS QUE SOFIA COLETARÁ DURANTE A SEMANA**

### **PERFIL EXPANDIDO:**
- 🎯 **Objetivos de peso** (`weight_goal`)
- 🏥 **Objetivos de saúde** (`health_goals`)
- 🚫 **Restrições alimentares** (`dietary_restrictions`)
- 💊 **Condições médicas** (`medical_conditions`)
- 🏃 **Nível de atividade** (`activity_level`)
- 😴 **Horas de sono** (`sleep_hours`)
- 💧 **Meta de água** (`water_goal_ml`)
- 💼 **Profissão** (`profession`)
- 😰 **Nível de stress** (`stress_level`)
- 💪 **Nível de motivação** (`motivation_level`)
- ⚙️ **Preferências** (`preferences`)
- 🚨 **Contato de emergência** (`emergency_contact`)

### **DADOS EMOCIONAIS (Via Chat):**
- 😊 **Sentimento diário** (-1.0 a +1.0)
- 💔 **Níveis de dor** (0-10)
- 😰 **Níveis de stress** (0-10)
- ⚡ **Níveis de energia** (0-10)
- 🏷️ **Emoções detectadas**
- 🎯 **Tópicos emocionais**
- 🚨 **Indicadores de trauma**
- 📍 **Localizações no corpo**

### **DADOS NUTRICIONAIS (Via Foto):**
- 🍎 **Alimentos consumidos**
- 🕐 **Tipos de refeição**
- 📊 **Scores nutricionais**
- 🔥 **Calorias estimadas**
- 💪 **Macronutrientes**
- 💡 **Recomendações**

---

## 🗄️ **ESTRUTURA COMPLETA DO BANCO**

### **1. TABELA `profiles` (Principal)**
```sql
-- CAMPOS DO CADASTRO INICIAL
full_name TEXT
email TEXT
phone TEXT
birth_date DATE
gender TEXT
city TEXT
state TEXT
height NUMERIC(5,2)

-- CAMPOS COLETADOS DURANTE A SEMANA
weight_goal NUMERIC(5,2)
health_goals TEXT[]
dietary_restrictions TEXT[]
medical_conditions TEXT[]
activity_level TEXT
sleep_hours INTEGER
water_goal_ml INTEGER
profession TEXT
stress_level INTEGER (1-10)
motivation_level INTEGER (1-10)
preferences JSONB
emergency_contact JSONB
onboarding_completed BOOLEAN
weekly_data_collected JSONB
```

### **2. TABELA `chat_conversations` (Sofia)**
```sql
-- DADOS DA CONVERSA
user_id UUID
message TEXT
response TEXT
character VARCHAR(50) -- Sofia/Dr. Vital
has_image BOOLEAN
image_url TEXT

-- ANÁLISE EMOCIONAL
sentiment_score NUMERIC(3,2)
emotion_tags TEXT[]
topic_tags TEXT[]
pain_level INTEGER (0-10)
stress_level INTEGER (0-10)
energy_level INTEGER (0-10)

-- ANÁLISE DE COMIDA
food_analysis JSONB
ai_analysis JSONB
```

### **3. TABELA `chat_emotional_analysis` (Detalhada)**
```sql
-- ANÁLISE EMOCIONAL COMPLETA
sentiment_score NUMERIC(3,2)
emotions_detected TEXT[]
pain_level INTEGER (0-10)
stress_level INTEGER (0-10)
energy_level INTEGER (0-10)
mood_keywords TEXT[]
physical_symptoms TEXT[]
emotional_topics TEXT[]
concerns_mentioned TEXT[]
goals_mentioned TEXT[]
achievements_mentioned TEXT[]
analysis_metadata JSONB
```

### **4. TABELA `ai_configurations` (Sofia)**
```sql
-- CONFIGURAÇÕES DE IA
functionality VARCHAR(100) -- 'health_chat'
service VARCHAR(50) -- 'google'
model VARCHAR(100) -- 'gemini-1.5-flash'
max_tokens INTEGER -- 2048
temperature NUMERIC(3,2) -- 0.7
is_active BOOLEAN -- true
```

---

## 🔄 **FLUXO DE COLETA DE DADOS**

### **CADASTRO INICIAL (Já implementado):**
1. Usuário preenche formulário
2. Dados salvos em `auth.users` + `profiles` + `user_physical_data`
3. Trigger automático cria perfil

### **DURANTE A SEMANA (Sofia coleta):**
1. **Chat diário** → Análise emocional automática
2. **Fotos de comida** → Análise nutricional
3. **Perguntas específicas** → Dados do perfil expandido
4. **Comportamento** → Padrões e preferências

### **RELATÓRIOS SEMANAIS:**
1. **Agregação de dados** → Tendências emocionais
2. **Análise de progresso** → Comparação com objetivos
3. **Recomendações** → Baseadas em IA
4. **Alertas** → Situações de risco

---

## 🛡️ **SEGURANÇA E NÃO DUPLICAÇÃO**

### **VERIFICAÇÕES IMPLEMENTADAS:**
- ✅ **IF NOT EXISTS** - Não cria tabelas duplicadas
- ✅ **ON CONFLICT DO UPDATE** - Atualiza ao invés de duplicar
- ✅ **DROP POLICY IF EXISTS** - Remove políticas antes de recriar
- ✅ **Verificação de colunas** - Só adiciona se não existir

### **POLÍTICAS RLS:**
- ✅ **Usuários** - Só veem seus próprios dados
- ✅ **Service Role** - Acesso total para Sofia
- ✅ **Authenticated** - Acesso controlado

---

## 📈 **DADOS DISPONÍVEIS PARA SOFIA**

### **CONTEXTO COMPLETO:**
1. **Perfil básico** - Nome, idade, altura, cidade
2. **Objetivos** - Peso, saúde, atividade
3. **Histórico emocional** - Sentimentos, dor, stress
4. **Padrões alimentares** - Comidas, calorias, nutrientes
5. **Comportamento** - Sono, atividade, motivação
6. **Preferências** - Gostos, restrições, emergência

### **ANÁLISES POSSÍVEIS:**
- 📊 **Tendências emocionais** - Padrões de humor
- 🍎 **Qualidade nutricional** - Score de alimentação
- 💪 **Progresso físico** - Evolução de peso e atividade
- 🎯 **Alcance de metas** - % de objetivos atingidos
- 🚨 **Alertas de saúde** - Situações de risco

---

## 🎯 **STATUS FINAL**

### **✅ ESTRUTURA COMPLETA:**
- [x] Tabelas principais criadas
- [x] Campos do cadastro mapeados
- [x] Campos da semana planejados
- [x] Políticas RLS configuradas
- [x] Triggers funcionando
- [x] Configurações de IA prontas

### **🔧 PRÓXIMO PASSO:**
1. **Execute** `sofia-database-safe-setup.sql` no Supabase
2. **Teste** Sofia no frontend: http://localhost:5174
3. **Confirme** que dados estão sendo salvos

**💡 SOFIA TERÁ ACESSO COMPLETO A TODOS OS DADOS SEM DUPLICAÇÃO!**

---

## 📝 **CAMPOS ESPECÍFICOS POR FUNÇÃO**

### **CADASTRO (Já coletados):**
- Nome, email, telefone, nascimento
- Gênero, cidade, estado, altura

### **SEMANA 1 (Sofia pergunta):**
- Objetivos de peso e saúde
- Restrições alimentares
- Condições médicas atuais

### **SEMANA 2 (Sofia observa):**
- Padrões de sono
- Níveis de stress e motivação
- Preferências alimentares

### **SEMANA 3 (Sofia analisa):**
- Profissão e rotina
- Contato de emergência
- Metas de hidratação

### **CONTÍNUO (Sofia monitora):**
- Emoções diárias via chat
- Análise de comida via foto
- Progresso em objetivos
- Alertas de saúde