import React from 'react';
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { 
  Database, 
  Terminal, 
  Copy, 
  CheckCircle,
  ExternalLink,
  ArrowRight,
  Code
} from 'lucide-react';
import { useToast } from "@/hooks/use-toast";

export function IAMigrationInstructions() {
  const { toast } = useToast();
  
  const copyToClipboard = (text: string, description: string) => {
    navigator.clipboard.writeText(text);
    toast({
      title: "✅ Copiado",
      description: `${description} copiado para área de transferência`,
    });
  };

  const sqlScript = `-- Execute este script no SQL Editor do Supabase
-- Aplicar migrações para IA Management

-- 1. Criar tabela de personalidades IA
CREATE TABLE IF NOT EXISTS public.ai_personalities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  agent_name VARCHAR(50) NOT NULL,
  tone VARCHAR(20) DEFAULT 'friendly',
  communication_style VARCHAR(20) DEFAULT 'supportive',
  emotional_intelligence NUMERIC(3,2) DEFAULT 0.8 CHECK (emotional_intelligence >= 0.0 AND emotional_intelligence <= 1.0),
  energy_level VARCHAR(20) DEFAULT 'balanced',
  role_preference VARCHAR(30) DEFAULT 'coach',
  response_length VARCHAR(20) DEFAULT 'medium',
  use_emojis BOOLEAN DEFAULT true,
  formality_level NUMERIC(3,2) DEFAULT 0.5 CHECK (formality_level >= 0.0 AND formality_level <= 1.0),
  focus_areas TEXT[] DEFAULT ARRAY['nutrition', 'fitness', 'mental_health', 'habits']::TEXT[],
  expertise_level VARCHAR(20) DEFAULT 'general',
  humor_level NUMERIC(3,2) DEFAULT 0.6 CHECK (humor_level >= 0.0 AND humor_level <= 1.0),
  proactivity_level NUMERIC(3,2) DEFAULT 0.7 CHECK (proactivity_level >= 0.0 AND proactivity_level <= 1.0),
  preferred_language VARCHAR(10) DEFAULT 'pt-BR',
  cultural_context VARCHAR(20) DEFAULT 'brazilian',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, agent_name),
  CHECK (agent_name IN ('sofia', 'dr_vital'))
);

-- 2. Criar tabela de base de conhecimento
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS public.knowledge_base (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(200) NOT NULL,
  category VARCHAR(50) DEFAULT 'general',
  priority_level INTEGER DEFAULT 5 CHECK (priority_level >= 1 AND priority_level <= 10),
  source_type VARCHAR(30) DEFAULT 'manual_upload',
  content TEXT NOT NULL,
  content_summary TEXT,
  tags TEXT[] DEFAULT ARRAY[]::TEXT[],
  keywords TEXT[] DEFAULT ARRAY[]::TEXT[],
  language VARCHAR(10) DEFAULT 'pt-BR',
  applicable_agents TEXT[] DEFAULT ARRAY['sofia', 'dr_vital']::TEXT[],
  usage_frequency INTEGER DEFAULT 0,
  effectiveness_score NUMERIC(3,2) DEFAULT 0.5,
  last_used_at TIMESTAMPTZ,
  version INTEGER DEFAULT 1,
  visibility VARCHAR(20) DEFAULT 'private',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Configurar RLS (Row Level Security)
ALTER TABLE public.ai_personalities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.knowledge_base ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para ai_personalities
CREATE POLICY "ai_personalities_select_policy" ON public.ai_personalities
    FOR SELECT USING (true);

CREATE POLICY "ai_personalities_insert_policy" ON public.ai_personalities
    FOR INSERT WITH CHECK (true);

CREATE POLICY "ai_personalities_update_policy" ON public.ai_personalities
    FOR UPDATE USING (true);

CREATE POLICY "ai_personalities_delete_policy" ON public.ai_personalities
    FOR DELETE USING (true);

-- Políticas RLS para knowledge_base
CREATE POLICY "knowledge_base_select_policy" ON public.knowledge_base
    FOR SELECT USING (true);

CREATE POLICY "knowledge_base_insert_policy" ON public.knowledge_base
    FOR INSERT WITH CHECK (true);

CREATE POLICY "knowledge_base_update_policy" ON public.knowledge_base
    FOR UPDATE USING (true);

CREATE POLICY "knowledge_base_delete_policy" ON public.knowledge_base
    FOR DELETE USING (true);

-- 4. Inserir personalidades padrão
INSERT INTO public.ai_personalities (
  user_id, agent_name, tone, communication_style, emotional_intelligence,
  energy_level, role_preference, use_emojis, formality_level, focus_areas,
  expertise_level, humor_level, proactivity_level, is_active
) VALUES 
-- Sofia - Personalidade padrão
(
  NULL, 'sofia', 'friendly', 'supportive', 0.9, 'high', 'friend', 
  true, 0.3, ARRAY['motivation', 'daily_habits', 'emotional_support'],
  'general', 0.8, 0.8, true
),
-- Dr. Vital - Personalidade padrão
(
  NULL, 'dr_vital', 'professional', 'analytical', 0.7, 'balanced', 'advisor',
  false, 0.7, ARRAY['medical_analysis', 'health_insights', 'data_interpretation'],
  'expert', 0.4, 0.6, true
)
ON CONFLICT (user_id, agent_name) DO NOTHING;

-- 5. Verificar se tudo foi criado corretamente
SELECT 'ai_personalities' as tabela, COUNT(*) as registros
FROM public.ai_personalities
UNION ALL
SELECT 'knowledge_base' as tabela, COUNT(*) as registros  
FROM public.knowledge_base;`;

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Database className="h-5 w-5 text-blue-500" />
            Configuração do Banco de Dados - IA Management
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Passo a Passo */}
          <div className="space-y-4">
            <h3 className="font-semibold text-lg">📋 Passo a Passo:</h3>
            
            <div className="grid gap-4">
              <div className="flex items-start gap-3 p-3 border rounded-lg">
                <div className="bg-blue-500 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold">
                  1
                </div>
                <div>
                  <p className="font-medium">Acesse o Supabase Dashboard</p>
                  <p className="text-sm text-muted-foreground">
                    Vá para seu projeto no Supabase e acesse o SQL Editor
                  </p>
                </div>
              </div>

              <div className="flex items-start gap-3 p-3 border rounded-lg">
                <div className="bg-blue-500 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold">
                  2
                </div>
                <div className="flex-1">
                  <p className="font-medium">Execute o Script SQL</p>
                  <p className="text-sm text-muted-foreground mb-2">
                    Copie e cole o script abaixo no SQL Editor do Supabase
                  </p>
                  <Button
                    onClick={() => copyToClipboard(sqlScript, "Script SQL")}
                    variant="outline"
                    size="sm"
                    className="flex items-center gap-2"
                  >
                    <Copy className="h-4 w-4" />
                    Copiar Script Completo
                  </Button>
                </div>
              </div>

              <div className="flex items-start gap-3 p-3 border rounded-lg">
                <div className="bg-blue-500 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold">
                  3
                </div>
                <div>
                  <p className="font-medium">Verificar Resultado</p>
                  <p className="text-sm text-muted-foreground">
                    O script criará as tabelas e inserirá configurações padrão para Sofia e Dr. Vital
                  </p>
                </div>
              </div>

              <div className="flex items-start gap-3 p-3 border rounded-lg">
                <div className="bg-green-500 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm font-bold">
                  4
                </div>
                <div>
                  <p className="font-medium">Recarregar a Página</p>
                  <p className="text-sm text-muted-foreground">
                    Após executar o script, recarregue esta página para ver as configurações
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Alerta de Informação */}
          <Alert className="border-blue-200 bg-blue-50 dark:bg-blue-900/20">
            <CheckCircle className="h-4 w-4 text-blue-600" />
            <AlertDescription className="text-blue-800 dark:text-blue-200">
              <strong>ℹ️ O que será criado:</strong> O script criará as tabelas necessárias, 
              configurará as políticas de segurança (RLS) e inserirá personalidades padrão 
              para Sofia (assistente motivacional) e Dr. Vital (analista médico).
            </AlertDescription>
          </Alert>

          {/* Script SQL em caixa */}
          <div>
            <div className="flex items-center justify-between mb-2">
              <h4 className="font-medium flex items-center gap-2">
                <Code className="h-4 w-4" />
                Script SQL Completo:
              </h4>
              <Button
                onClick={() => copyToClipboard(sqlScript, "Script SQL")}
                variant="outline"
                size="sm"
              >
                <Copy className="h-4 w-4 mr-2" />
                Copiar
              </Button>
            </div>
            <div className="bg-gray-900 rounded-lg p-4 max-h-96 overflow-y-auto">
              <pre className="text-sm text-gray-100 whitespace-pre-wrap font-mono">
                {sqlScript}
              </pre>
            </div>
          </div>

          {/* Links Úteis */}
          <div className="border-t pt-4">
            <h4 className="font-medium mb-2">🔗 Links Úteis:</h4>
            <div className="flex flex-wrap gap-2">
              <Button variant="outline" size="sm" asChild>
                <a 
                  href="https://supabase.com/dashboard" 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="flex items-center gap-2"
                >
                  <ExternalLink className="h-4 w-4" />
                  Supabase Dashboard
                </a>
              </Button>
              <Button variant="outline" size="sm" asChild>
                <a 
                  href="https://supabase.com/docs/guides/database/sql-editor" 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="flex items-center gap-2"
                >
                  <Terminal className="h-4 w-4" />
                  SQL Editor Docs
                </a>
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}