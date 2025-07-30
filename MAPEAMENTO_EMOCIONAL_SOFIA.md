# 🧠 Mapeamento Emocional Automático da Sofia

## 📊 Resumo do Sistema

A Sofia agora faz **mapeamento automático** de todas as conversas, incluindo dor, trauma, stress e outros indicadores emocionais.

## 🎯 O que está sendo mapeado automaticamente:

### 1. **📈 Análise de Sentimento**
- **sentiment_score**: -1.0 a 1.0 (negativo a positivo)
- **emotions_detected**: Array de emoções detectadas
- **mood_keywords**: Palavras-chave do humor

### 2. **💊 Níveis de Dor e Stress**
- **pain_level**: 0-10 (se mencionado)
- **stress_level**: 0-10 (se mencionado)
- **energy_level**: 0-10 (se mencionado)
- **intensity_level**: 0-10 (intensidade geral)

### 3. **🏥 Sintomas Físicos**
- **physical_symptoms**: Sintomas físicos mencionados
- **body_locations**: Localizações no corpo onde sente emoções
- **trauma_indicators**: Indicadores de trauma

### 4. **🎯 Tópicos Emocionais**
- **emotional_topics**: Tópicos emocionais discutidos
- **concerns_mentioned**: Preocupações mencionadas
- **goals_mentioned**: Objetivos mencionados
- **achievements_mentioned**: Conquistas mencionadas

### 5. **🍽️ Impacto na Alimentação**
- **eating_impact**: Como afeta a alimentação
- **triggers_mentioned**: Gatilhos emocionais

## 📋 Exemplos de Mapeamento

### Exemplo 1: Usuário com Dor
```
Mensagem: "Estou com dor de cabeça há 3 dias e muito stress no trabalho"

Mapeamento:
- sentiment_score: -0.7
- emotions_detected: ["stress", "ansiedade", "frustração"]
- pain_level: 7
- stress_level: 8
- energy_level: 3
- physical_symptoms: ["dor de cabeça", "tensão"]
- body_locations: ["cabeça", "pescoço"]
- emotional_topics: ["trabalho", "stress"]
- concerns_mentioned: ["saúde", "produtividade"]
```

### Exemplo 2: Trauma Mencionado
```
Mensagem: "Quando era criança, tive um trauma com comida e agora tenho dificuldade para comer"

Mapeamento:
- sentiment_score: -0.5
- emotions_detected: ["medo", "ansiedade", "trauma"]
- trauma_indicators: ["trauma infantil", "dificuldade alimentar"]
- eating_impact: "Trauma infantil afetando alimentação atual"
- body_locations: ["estômago", "garganta"]
- intensity_level: 6
- triggers_mentioned: ["lembranças de infância", "situações sociais"]
```

### Exemplo 3: Conquista Positiva
```
Mensagem: "Consegui fazer exercício hoje e me sinto muito bem!"

Mapeamento:
- sentiment_score: 0.8
- emotions_detected: ["alegria", "orgulho", "motivação"]
- energy_level: 8
- achievements_mentioned: ["exercício realizado"]
- goals_mentioned: ["manter rotina"]
- mood_keywords: ["bem", "consegui", "motivação"]
```

## 🗄️ Tabelas do Banco de Dados

### 1. **chat_conversations**
```sql
- sentiment_score: numeric
- emotion_tags: text[]
- topic_tags: text[]
- pain_level: integer
- stress_level: integer
- energy_level: integer
- ai_analysis: jsonb (análise completa)
```

### 2. **chat_emotional_analysis**
```sql
- sentiment_score: numeric(3,2)
- emotions_detected: text[]
- pain_level: integer
- stress_level: integer
- energy_level: integer
- mood_keywords: text[]
- physical_symptoms: text[]
- emotional_topics: text[]
- concerns_mentioned: text[]
- goals_mentioned: text[]
- achievements_mentioned: text[]
- analysis_metadata: jsonb (trauma, body_locations, etc.)
```

## 🔄 Processo Automático

### 1. **Análise em Tempo Real**
- ✅ Cada mensagem é analisada automaticamente
- ✅ Usa Gemini Flash para precisão
- ✅ Extrai dados estruturados em JSON

### 2. **Salvamento Duplo**
- ✅ **chat_conversations**: Dados básicos da conversa
- ✅ **chat_emotional_analysis**: Análise emocional detalhada

### 3. **Relatórios Semanais**
- ✅ Análise agregada das conversas
- ✅ Tendências emocionais
- ✅ Alertas para profissionais de saúde

## 📈 Benefícios

### 1. **Para o Usuário**
- 🎯 **Acompanhamento**: Histórico emocional completo
- 📊 **Insights**: Tendências e padrões
- 🚨 **Alertas**: Identificação de crises

### 2. **Para Profissionais**
- 📋 **Dados**: Informações estruturadas
- 🎯 **Foco**: Áreas que precisam de atenção
- 📈 **Progresso**: Evolução do paciente

### 3. **Para a Plataforma**
- 🤖 **IA Inteligente**: Respostas personalizadas
- 📊 **Analytics**: Dados para melhorias
- 🔄 **Automação**: Processo sem intervenção manual

## 🚨 Alertas Automáticos

### Níveis de Risco:
- **🟢 Baixo**: sentiment_score > 0.3, pain_level < 4
- **🟡 Moderado**: sentiment_score -0.3 a 0.3, pain_level 4-6
- **🟠 Alto**: sentiment_score < -0.3, pain_level 7-8
- **🔴 Crítico**: sentiment_score < -0.7, pain_level > 8

### Gatilhos de Alerta:
- Trauma mencionado
- Dor intensa (pain_level > 7)
- Stress alto (stress_level > 8)
- Ideações negativas
- Impacto severo na alimentação

## 📊 Relatórios Disponíveis

### 1. **Relatório Semanal**
- Tendências emocionais
- Padrões de dor
- Conquistas e objetivos
- Recomendações personalizadas

### 2. **Relatório Mensal**
- Análise profunda
- Comparação com períodos anteriores
- Sugestões de intervenção

### 3. **Relatório de Trauma**
- Indicadores de trauma
- Gatilhos identificados
- Impacto na alimentação
- Recomendações terapêuticas

## 🎯 Próximos Passos

### 1. **Melhorias Planejadas**
- 🤖 IA mais precisa para análise emocional
- 📱 Notificações inteligentes
- 🎯 Recomendações personalizadas
- 📊 Dashboards visuais

### 2. **Integrações**
- 🏥 Conectividade com profissionais de saúde
- 📋 Relatórios para terapeutas
- 🚨 Sistema de alertas emergenciais
- 📈 Analytics avançados

---

**Status:** ✅ Implementado e Funcionando  
**Última atualização:** Janeiro 2025  
**Responsável:** Equipe de IA 