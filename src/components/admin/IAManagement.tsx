import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Slider } from "@/components/ui/slider";
import { Switch } from "@/components/ui/switch";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Separator } from "@/components/ui/separator";
import { 
  Bot, 
  Brain, 
  Upload, 
  TestTube, 
  MessageSquare, 
  FileText, 
  Settings,
  Heart,
  Zap,
  Target,
  Users,
  Clock,
  Globe,
  Save,
  RotateCcw,
  Play,
  Pause,
  Download,
  Trash2,
  CheckCircle2,
  AlertTriangle,
  Sparkles
} from 'lucide-react';
import { useToast } from "@/hooks/use-toast";
import { supabase } from "@/integrations/supabase/client";
import { IAMigrationInstructions } from './IAMigrationInstructions';

interface PersonalityConfig {
  id: string;
  user_id: string;
  agent_name: 'sofia' | 'dr_vital';
  tone: string;
  communication_style: string;
  emotional_intelligence: number;
  energy_level: string;
  role_preference: string;
  response_length: string;
  use_emojis: boolean;
  formality_level: number;
  focus_areas: string[];
  expertise_level: string;
  humor_level: number;
  proactivity_level: number;
  preferred_language: string;
  cultural_context: string;
  is_active: boolean;
}

interface KnowledgeItem {
  id: string;
  title: string;
  content: string;
  category: string;
  agent_name: string;
  priority: number;
  created_at: string;
  effectiveness_score: number;
}

export function IAManagement() {
  const [activeTab, setActiveTab] = useState("setup");
  const [sofiaConfig, setSofiaConfig] = useState<PersonalityConfig | null>(null);
  const [drVitalConfig, setDrVitalConfig] = useState<PersonalityConfig | null>(null);
  const [knowledgeItems, setKnowledgeItems] = useState<KnowledgeItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [testMessage, setTestMessage] = useState("");
  const [testResponse, setTestResponse] = useState("");
  const [isTesting, setIsTesting] = useState(false);
  const { toast } = useToast();

  useEffect(() => {
    loadPersonalities();
    loadKnowledgeBase();
  }, []);

  const loadPersonalities = async () => {
    try {
      const { data, error } = await supabase
        .from('ai_personalities')
        .select('*')
        .in('agent_name', ['sofia', 'dr_vital'])
        .eq('is_active', true);

      if (error) {
        console.warn('Tabela ai_personalities não encontrada, usando configurações padrão:', error);
        // Usar configurações padrão se a tabela não existir
        setSofiaConfig(createDefaultPersonality('sofia'));
        setDrVitalConfig(createDefaultPersonality('dr_vital'));
        return;
      }

      const sofia = data?.find(p => p.agent_name === 'sofia');
      const drVital = data?.find(p => p.agent_name === 'dr_vital');

      setSofiaConfig(sofia || createDefaultPersonality('sofia'));
      setDrVitalConfig(drVital || createDefaultPersonality('dr_vital'));
      
      // Se carregou personalidades reais, mudar para a aba Sofia
      if (sofia?.id || drVital?.id) {
        setActiveTab("sofia-config");
      }
    } catch (error) {
      console.warn('Erro ao carregar personalidades, usando padrões:', error);
      setSofiaConfig(createDefaultPersonality('sofia'));
      setDrVitalConfig(createDefaultPersonality('dr_vital'));
      
      toast({
        title: "⚠️ Aviso",
        description: "Usando configurações padrão. Para persistir mudanças, aplique as migrações do IA Management.",
        variant: "default"
      });
    }
  };

  const loadKnowledgeBase = async () => {
    try {
      const { data, error } = await supabase
        .from('knowledge_base')
        .select('*')
        .order('priority_level', { ascending: false });

      if (error) {
        console.warn('Tabela knowledge_base não encontrada:', error);
        setKnowledgeItems([]);
        return;
      }
      
      setKnowledgeItems(data || []);
    } catch (error) {
      console.warn('Erro ao carregar base de conhecimento:', error);
      setKnowledgeItems([]);
    } finally {
      setIsLoading(false);
    }
  };

  const createDefaultPersonality = (agentName: 'sofia' | 'dr_vital'): PersonalityConfig => {
    const baseConfig = {
      id: '',
      user_id: '',
      agent_name: agentName,
      tone: agentName === 'sofia' ? 'friendly' : 'professional',
      communication_style: agentName === 'sofia' ? 'supportive' : 'analytical',
      emotional_intelligence: agentName === 'sofia' ? 0.9 : 0.7,
      energy_level: agentName === 'sofia' ? 'high' : 'balanced',
      role_preference: agentName === 'sofia' ? 'friend' : 'advisor',
      response_length: 'medium',
      use_emojis: agentName === 'sofia',
      formality_level: agentName === 'sofia' ? 0.3 : 0.7,
      focus_areas: agentName === 'sofia' 
        ? ['motivation', 'daily_habits', 'emotional_support']
        : ['medical_analysis', 'health_insights', 'data_interpretation'],
      expertise_level: agentName === 'sofia' ? 'general' : 'expert',
      humor_level: agentName === 'sofia' ? 0.8 : 0.4,
      proactivity_level: agentName === 'sofia' ? 0.8 : 0.6,
      preferred_language: 'pt-BR',
      cultural_context: 'brazilian',
      is_active: true
    };
    return baseConfig;
  };

  const savePersonality = async (config: PersonalityConfig) => {
    try {
      setIsSaving(true);
      
      if (config.id) {
        // Atualizar existente
        const { error } = await supabase
          .from('ai_personalities')
          .update(config)
          .eq('id', config.id);
        
        if (error) throw error;
      } else {
        // Criar novo
        const { error } = await supabase
          .from('ai_personalities')
          .insert([config]);
        
        if (error) throw error;
      }

      toast({
        title: "✅ Sucesso",
        description: `Personalidade da ${config.agent_name === 'sofia' ? 'Sofia' : 'Dr. Vital'} salva com sucesso!`,
      });
      
      await loadPersonalities();
    } catch (error) {
      console.error('Erro ao salvar personalidade:', error);
      
      if (error.message?.includes('relation "public.ai_personalities" does not exist')) {
        toast({
          title: "⚠️ Tabela não existe",
          description: "Execute o script 'apply-ia-management-migrations.sql' no Supabase para criar as tabelas necessárias.",
          variant: "destructive"
        });
      } else {
        toast({
          title: "❌ Erro",
          description: "Falha ao salvar configurações: " + error.message,
          variant: "destructive"
        });
      }
    } finally {
      setIsSaving(false);
    }
  };

  const testPersonality = async (agentName: 'sofia' | 'dr_vital') => {
    if (!testMessage.trim()) {
      toast({
        title: "⚠️ Atenção",
        description: "Digite uma mensagem para testar",
        variant: "destructive"
      });
      return;
    }

    try {
      setIsTesting(true);
      
      const { data, error } = await supabase.functions.invoke('personality-manager', {
        body: {
          action: 'adapt',
          userId: 'test-user',
          agentName,
          context: {
            message: testMessage,
            testMode: true
          }
        }
      });

      if (error) throw error;
      
      setTestResponse(data?.contextualPrompts?.personalityInstructions || 'Resposta de teste gerada com sucesso!');
      
      toast({
        title: "✅ Teste Concluído",
        description: `${agentName === 'sofia' ? 'Sofia' : 'Dr. Vital'} respondeu com sucesso!`,
      });
    } catch (error) {
      console.error('Erro no teste:', error);
      toast({
        title: "❌ Erro no Teste",
        description: "Falha ao testar personalidade",
        variant: "destructive"
      });
    } finally {
      setIsTesting(false);
    }
  };

  const uploadKnowledge = async (file: File, category: string, agentName: string) => {
    try {
      const formData = new FormData();
      formData.append('file', file);
      formData.append('category', category);
      formData.append('agent_name', agentName);

      const { data, error } = await supabase.functions.invoke('knowledge-retrieval', {
        body: {
          action: 'upload',
          file: await file.text(),
          metadata: {
            title: file.name,
            category,
            agentName,
            priority: 5
          }
        }
      });

      if (error) throw error;

      toast({
        title: "✅ Upload Concluído",
        description: `Conhecimento adicionado para ${agentName === 'sofia' ? 'Sofia' : 'Dr. Vital'}`,
      });

      await loadKnowledgeBase();
    } catch (error) {
      console.error('Erro no upload:', error);
      toast({
        title: "❌ Erro no Upload",
        description: "Falha ao adicionar conhecimento",
        variant: "destructive"
      });
    }
  };

  const PersonalityConfigForm = ({ config, onChange, agentName }: {
    config: PersonalityConfig;
    onChange: (config: PersonalityConfig) => void;
    agentName: 'sofia' | 'dr_vital';
  }) => (
    <div className="space-y-6">
      {/* Configurações Básicas */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Settings className="h-5 w-5" />
            Configurações Básicas
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label htmlFor="tone">Tom de Comunicação</Label>
              <Select value={config.tone} onValueChange={(value) => onChange({...config, tone: value})}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="friendly">Amigável</SelectItem>
                  <SelectItem value="professional">Profissional</SelectItem>
                  <SelectItem value="casual">Casual</SelectItem>
                  <SelectItem value="energetic">Energético</SelectItem>
                  <SelectItem value="warm">Caloroso</SelectItem>
                  <SelectItem value="analytical">Analítico</SelectItem>
                </SelectContent>
              </Select>
            </div>
            
            <div>
              <Label htmlFor="communication_style">Estilo de Comunicação</Label>
              <Select value={config.communication_style} onValueChange={(value) => onChange({...config, communication_style: value})}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="supportive">Apoiador</SelectItem>
                  <SelectItem value="direct">Direto</SelectItem>
                  <SelectItem value="motivational">Motivacional</SelectItem>
                  <SelectItem value="empathetic">Empático</SelectItem>
                  <SelectItem value="coaching">Coach</SelectItem>
                  <SelectItem value="analytical">Analítico</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <div>
            <Label>Inteligência Emocional: {Math.round(config.emotional_intelligence * 100)}%</Label>
            <Slider
              value={[config.emotional_intelligence]}
              onValueChange={([value]) => onChange({...config, emotional_intelligence: value})}
              max={1}
              min={0}
              step={0.1}
              className="mt-2"
            />
          </div>

          <div>
            <Label>Nível de Humor: {Math.round(config.humor_level * 100)}%</Label>
            <Slider
              value={[config.humor_level]}
              onValueChange={([value]) => onChange({...config, humor_level: value})}
              max={1}
              min={0}
              step={0.1}
              className="mt-2"
            />
          </div>

          <div>
            <Label>Formalidade: {Math.round(config.formality_level * 100)}%</Label>
            <Slider
              value={[config.formality_level]}
              onValueChange={([value]) => onChange({...config, formality_level: value})}
              max={1}
              min={0}
              step={0.1}
              className="mt-2"
            />
          </div>

          <div className="flex items-center space-x-2">
            <Switch
              id="use_emojis"
              checked={config.use_emojis}
              onCheckedChange={(checked) => onChange({...config, use_emojis: checked})}
            />
            <Label htmlFor="use_emojis">Usar Emojis</Label>
          </div>
        </CardContent>
      </Card>

      {/* Configurações Avançadas */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Brain className="h-5 w-5" />
            Configurações Avançadas
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label htmlFor="role_preference">Papel Preferido</Label>
              <Select value={config.role_preference} onValueChange={(value) => onChange({...config, role_preference: value})}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="coach">Coach</SelectItem>
                  <SelectItem value="friend">Amigo</SelectItem>
                  <SelectItem value="therapist">Terapeuta</SelectItem>
                  <SelectItem value="guide">Guia</SelectItem>
                  <SelectItem value="mentor">Mentor</SelectItem>
                  <SelectItem value="advisor">Conselheiro</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div>
              <Label htmlFor="response_length">Tamanho da Resposta</Label>
              <Select value={config.response_length} onValueChange={(value) => onChange({...config, response_length: value})}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="short">Curta</SelectItem>
                  <SelectItem value="medium">Média</SelectItem>
                  <SelectItem value="long">Longa</SelectItem>
                  <SelectItem value="adaptive">Adaptativa</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <div>
            <Label>Proatividade: {Math.round(config.proactivity_level * 100)}%</Label>
            <Slider
              value={[config.proactivity_level]}
              onValueChange={([value]) => onChange({...config, proactivity_level: value})}
              max={1}
              min={0}
              step={0.1}
              className="mt-2"
            />
          </div>
        </CardContent>
      </Card>

      <Button 
        onClick={() => savePersonality(config)} 
        disabled={isSaving}
        className="w-full"
      >
        {isSaving ? (
          <>
            <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
            Salvando...
          </>
        ) : (
          <>
            <Save className="h-4 w-4 mr-2" />
            Salvar Configurações
          </>
        )}
      </Button>
    </div>
  );

  if (isLoading) {
    return (
      <div className="space-y-4">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-4"></div>
          <div className="space-y-2">
            <div className="h-4 bg-gray-200 rounded"></div>
            <div className="h-4 bg-gray-200 rounded w-3/4"></div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold flex items-center gap-3">
            <Bot className="w-8 h-8 text-primary" />
            Gerenciamento de IA
          </h1>
          <p className="text-muted-foreground text-lg">
            Configure e gerencie as personalidades Sofia e Dr. Vital
          </p>
        </div>
        <Badge variant="outline" className="flex items-center gap-2">
          <Sparkles className="w-4 h-4" />
          Sistema Multi-Agente Ativo
        </Badge>
      </div>

      {/* Alerta de Migrações */}
      {(!sofiaConfig?.id || !drVitalConfig?.id) && (
        <Alert className="border-orange-200 bg-orange-50 dark:bg-orange-900/20">
          <AlertTriangle className="h-4 w-4 text-orange-600" />
          <AlertDescription className="text-orange-800 dark:text-orange-200">
            <strong>⚠️ Configuração Inicial Necessária:</strong> As tabelas do sistema IA ainda não foram criadas. 
            Execute o script <code className="bg-orange-100 dark:bg-orange-800 px-1 rounded">apply-ia-management-migrations.sql</code> no 
            Supabase para persistir as configurações. Atualmente usando configurações padrão temporárias.
          </AlertDescription>
        </Alert>
      )}

      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
        <TabsList className={`grid w-full ${(!sofiaConfig?.id || !drVitalConfig?.id) ? 'grid-cols-5' : 'grid-cols-4'}`}>
          {(!sofiaConfig?.id || !drVitalConfig?.id) && (
            <TabsTrigger value="setup" className="flex items-center gap-2">
              <Settings className="h-4 w-4" />
              Configuração
            </TabsTrigger>
          )}
          <TabsTrigger value="sofia-config" className="flex items-center gap-2">
            <Heart className="h-4 w-4" />
            Sofia
          </TabsTrigger>
          <TabsTrigger value="drvital-config" className="flex items-center gap-2">
            <Brain className="h-4 w-4" />
            Dr. Vital
          </TabsTrigger>
          <TabsTrigger value="knowledge" className="flex items-center gap-2">
            <FileText className="h-4 w-4" />
            Base de Conhecimento
          </TabsTrigger>
          <TabsTrigger value="testing" className="flex items-center gap-2">
            <TestTube className="h-4 w-4" />
            Testes
          </TabsTrigger>
        </TabsList>

        {/* Sofia Configuration */}
        <TabsContent value="sofia-config" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Heart className="h-5 w-5 text-pink-500" />
                Configurações da Sofia
              </CardTitle>
              <p className="text-muted-foreground">
                Configure a personalidade e comportamento da sua assistente virtual Sofia
              </p>
            </CardHeader>
            <CardContent>
              {sofiaConfig && (
                <PersonalityConfigForm
                  config={sofiaConfig}
                  onChange={setSofiaConfig}
                  agentName="sofia"
                />
              )}
            </CardContent>
          </Card>
        </TabsContent>

        {/* Dr. Vital Configuration */}
        <TabsContent value="drvital-config" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Brain className="h-5 w-5 text-blue-500" />
                Configurações do Dr. Vital
              </CardTitle>
              <p className="text-muted-foreground">
                Configure a personalidade e especialização do Dr. Vital para análises médicas
              </p>
            </CardHeader>
            <CardContent>
              {drVitalConfig && (
                <PersonalityConfigForm
                  config={drVitalConfig}
                  onChange={setDrVitalConfig}
                  agentName="dr_vital"
                />
              )}
            </CardContent>
          </Card>
        </TabsContent>

        {/* Knowledge Base */}
        <TabsContent value="knowledge" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <FileText className="h-5 w-5" />
                Base de Conhecimento
              </CardTitle>
              <p className="text-muted-foreground">
                Gerencie documentos, protocolos e materiais especializados das IA
              </p>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <Alert>
                  <Upload className="h-4 w-4" />
                  <AlertDescription>
                    Upload de PDFs, documentos médicos e protocolos será processado automaticamente 
                    e convertido em embeddings para busca semântica pelas IA.
                  </AlertDescription>
                </Alert>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <Card>
                    <CardHeader>
                      <CardTitle className="text-sm">Conhecimento da Sofia</CardTitle>
                    </CardHeader>
                    <CardContent>
                      <div className="text-center text-muted-foreground">
                        <Upload className="h-8 w-8 mx-auto mb-2" />
                        <p>Arraste documentos aqui</p>
                        <p className="text-xs">Motivação, hábitos, suporte emocional</p>
                      </div>
                    </CardContent>
                  </Card>
                  
                  <Card>
                    <CardHeader>
                      <CardTitle className="text-sm">Conhecimento do Dr. Vital</CardTitle>
                    </CardHeader>
                    <CardContent>
                      <div className="text-center text-muted-foreground">
                        <Upload className="h-8 w-8 mx-auto mb-2" />
                        <p>Arraste documentos aqui</p>
                        <p className="text-xs">Protocolos médicos, análises, relatórios</p>
                      </div>
                    </CardContent>
                  </Card>
                </div>

                {knowledgeItems.length > 0 && (
                  <div className="space-y-2">
                    <h4 className="font-medium">Documentos Carregados</h4>
                    {knowledgeItems.map((item) => (
                      <div key={item.id} className="flex items-center justify-between p-2 border rounded">
                        <div className="flex items-center gap-2">
                          <FileText className="h-4 w-4" />
                          <span className="text-sm">{item.title}</span>
                          <Badge variant="outline" className="text-xs">
                            {item.category}
                          </Badge>
                        </div>
                        <div className="flex items-center gap-2">
                          <span className="text-xs text-muted-foreground">
                            Score: {Math.round(item.effectiveness_score * 100)}%
                          </span>
                          <Button variant="ghost" size="sm">
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Testing Panel */}
        <TabsContent value="testing" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <TestTube className="h-5 w-5" />
                Painel de Testes
              </CardTitle>
              <p className="text-muted-foreground">
                Teste as configurações de personalidade antes de aplicar aos usuários
              </p>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label htmlFor="test-message">Mensagem de Teste</Label>
                <Textarea
                  id="test-message"
                  placeholder="Digite uma mensagem para testar as IA..."
                  value={testMessage}
                  onChange={(e) => setTestMessage(e.target.value)}
                  className="mt-2"
                />
              </div>

              <div className="flex gap-2">
                <Button 
                  onClick={() => testPersonality('sofia')}
                  disabled={isTesting}
                  className="flex items-center gap-2"
                >
                  <Heart className="h-4 w-4" />
                  Testar Sofia
                </Button>
                <Button 
                  onClick={() => testPersonality('dr_vital')}
                  disabled={isTesting}
                  variant="outline"
                  className="flex items-center gap-2"
                >
                  <Brain className="h-4 w-4" />
                  Testar Dr. Vital
                </Button>
              </div>

              {testResponse && (
                <Card>
                  <CardHeader>
                    <CardTitle className="text-sm">Resposta de Teste</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="p-3 bg-muted rounded text-sm">
                      {testResponse}
                    </div>
                  </CardContent>
                </Card>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        {/* Setup Configuration Tab */}
        {(!sofiaConfig?.id || !drVitalConfig?.id) && (
          <TabsContent value="setup" className="space-y-6">
            <IAMigrationInstructions />
          </TabsContent>
        )}
      </Tabs>
    </div>
  );
}