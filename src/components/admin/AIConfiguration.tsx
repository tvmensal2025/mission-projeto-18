
import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Separator } from '@/components/ui/separator';
import { useToast } from '@/hooks/use-toast';
import { supabase } from '@/integrations/supabase/client';
import { 
  Bot, 
  MessageSquare, 
  Mail, 
  BarChart3, 
  FileText, 
  Settings, 
  Save,
  Eye,
  EyeOff,
  Zap,
  Brain,
  TestTube
} from 'lucide-react';
import GPTTestPanel from './GPTTestPanel';

interface AIConfig {
  service: string;
  model: string;
  temperature: number;
  maxTokens: number;
  isEnabled: boolean;
}

interface AIConfigurations {
  dailyChat: AIConfig;
  emailReports: AIConfig;
  weeklyAnalysis: AIConfig;
  medicalAnalysis: AIConfig;
  generalAssistant: AIConfig;
}

const AIConfiguration: React.FC = () => {
  const { toast } = useToast();
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [showApiKeys, setShowApiKeys] = useState(false);
  const [apiKeys, setApiKeys] = useState({
    openai: '',
    gemini: ''
  });
  
  const [configurations, setConfigurations] = useState<AIConfigurations>({
    dailyChat: {
      service: 'openai',
      model: 'gpt-4o',
      temperature: 0.8,
      maxTokens: 1000,
      isEnabled: true
    },
    emailReports: {
      service: 'openai',
      model: 'gpt-4o',
      temperature: 0.7,
      maxTokens: 2000,
      isEnabled: true
    },
    weeklyAnalysis: {
      service: 'openai',
      model: 'gpt-4o',
      temperature: 0.6,
      maxTokens: 2500,
      isEnabled: true
    },
    medicalAnalysis: {
      service: 'openai',
      model: 'o3-2025-04-16',
      temperature: 0.3,
      maxTokens: 3000,
      isEnabled: true
    },
    generalAssistant: {
      service: 'openai',
      model: 'gpt-4o',
      temperature: 0.8,
      maxTokens: 2000,
      isEnabled: true
    }
  });

  const aiServices = [
    { value: 'openai', label: 'OpenAI GPT', icon: <Brain className="h-4 w-4" /> },
    { value: 'gemini', label: 'Google Gemini', icon: <Zap className="h-4 w-4" /> }
  ];

  const openaiModels = [
    { value: 'gpt-4.1-2025-04-14', label: 'GPT-4.1 (Mais Recente e Poderoso)' },
    { value: 'o3-2025-04-16', label: 'O3 (Raciocínio Avançado)' },
    { value: 'o4-mini-2025-04-16', label: 'O4 Mini (Raciocínio Rápido)' },
    { value: 'gpt-4o', label: 'GPT-4o (Visão e Texto)' },
    { value: 'gpt-4o-mini', label: 'GPT-4o Mini (Rápido)' },
    { value: 'gpt-4-turbo', label: 'GPT-4 Turbo (Balanceado)' },
    { value: 'gpt-3.5-turbo', label: 'GPT-3.5 Turbo (Econômico)' }
  ];

  const geminiModels = [
    { value: 'gemini-1.5-flash', label: 'Gemini 1.5 Flash (Rápido)' },
    { value: 'gemini-1.5-pro', label: 'Gemini 1.5 Pro (Poderoso)' }
  ];

  const configurationItems = [
    {
      key: 'dailyChat' as keyof AIConfigurations,
      title: 'Chat Diário',
      description: 'Conversas diárias com Sof.ia e Dr. Vita',
      icon: <MessageSquare className="h-5 w-5" />
    },
    {
      key: 'emailReports' as keyof AIConfigurations,
      title: 'Relatórios por Email',
      description: 'Geração de relatórios semanais por email',
      icon: <Mail className="h-5 w-5" />
    },
    {
      key: 'weeklyAnalysis' as keyof AIConfigurations,
      title: 'Análise Semanal',
      description: 'Insights semanais do chat emocional',
      icon: <BarChart3 className="h-5 w-5" />
    },
    {
      key: 'medicalAnalysis' as keyof AIConfigurations,
      title: 'Análise Médica',
      description: 'Análise de exames e dados de saúde',
      icon: <FileText className="h-5 w-5" />
    },
    {
      key: 'generalAssistant' as keyof AIConfigurations,
      title: 'Assistente Geral',
      description: 'Outras funcionalidades de IA',
      icon: <Bot className="h-5 w-5" />
    }
  ];

  useEffect(() => {
    loadConfigurations();
  }, []);

  const loadConfigurations = async () => {
    try {
      setLoading(true);
      
      // Buscar configurações existentes
      const { data: configs } = await supabase
        .from('ai_configurations' as any)
        .select('*');

      if (configs && configs.length > 0) {
        const configMap: any = {};
        configs.forEach((config: any) => {
          configMap[config.functionality] = {
            service: config.service,
            model: config.model,
            temperature: config.temperature,
            maxTokens: config.max_tokens,
            isEnabled: config.is_enabled
          };
        });
        setConfigurations(prev => ({ ...prev, ...configMap }));
      }
    } catch (error) {
      console.error('Erro ao carregar configurações:', error);
    } finally {
      setLoading(false);
    }
  };

  const saveConfigurations = async () => {
    try {
      setSaving(true);

      // Salvar cada configuração
      for (const [functionality, config] of Object.entries(configurations)) {
        await supabase
          .from('ai_configurations' as any)
          .upsert({
            functionality,
            service: config.service,
            model: config.model,
            temperature: config.temperature,
            max_tokens: config.maxTokens,
            is_enabled: config.isEnabled
          }, { onConflict: 'functionality' });
      }

      toast({
        title: "Configurações Salvas",
        description: "As configurações de IA foram atualizadas com sucesso!"
      });
    } catch (error) {
      console.error('Erro ao salvar configurações:', error);
      toast({
        title: "Erro",
        description: "Erro ao salvar as configurações.",
        variant: "destructive"
      });
    } finally {
      setSaving(false);
    }
  };

  const updateConfiguration = (key: keyof AIConfigurations, field: keyof AIConfig, value: any) => {
    setConfigurations(prev => ({
      ...prev,
      [key]: {
        ...prev[key],
        [field]: value
      }
    }));
  };

  const getAvailableModels = (service: string) => {
    return service === 'openai' ? openaiModels : geminiModels;
  };

  const getServiceBadge = (service: string) => {
    const serviceConfig = aiServices.find(s => s.value === service);
    return (
      <Badge variant="outline" className="flex items-center gap-1">
        {serviceConfig?.icon}
        {serviceConfig?.label}
      </Badge>
    );
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold">Configurações de IA</h2>
          <p className="text-muted-foreground">
            Configure qual serviço de IA usar para cada funcionalidade
          </p>
        </div>
        <Button 
          onClick={saveConfigurations}
          disabled={saving}
          className="flex items-center gap-2"
        >
          <Save className="h-4 w-4" />
          {saving ? 'Salvando...' : 'Salvar Configurações'}
        </Button>
      </div>

      {/* Painel de Teste */}
      <GPTTestPanel />

      {/* API Keys Section */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Settings className="h-5 w-5" />
            Chaves de API
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center justify-between">
            <Label>Visualizar chaves de API</Label>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setShowApiKeys(!showApiKeys)}
            >
              {showApiKeys ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
            </Button>
          </div>
          
          {showApiKeys && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="openai-key">OpenAI API Key</Label>
                <Input
                  id="openai-key"
                  type="password"
                  placeholder="sk-..."
                  value={apiKeys.openai}
                  onChange={(e) => setApiKeys(prev => ({ ...prev, openai: e.target.value }))}
                />
              </div>
              <div>
                <Label htmlFor="gemini-key">Google Gemini API Key</Label>
                <Input
                  id="gemini-key"
                  type="password"
                  placeholder="AI..."
                  value={apiKeys.gemini}
                  onChange={(e) => setApiKeys(prev => ({ ...prev, gemini: e.target.value }))}
                />
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Configurations */}
      <div className="grid gap-6">
        {configurationItems.map((item) => {
          const config = configurations[item.key];
          return (
            <Card key={item.key}>
              <CardHeader>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    {item.icon}
                    <div>
                      <CardTitle className="text-lg">{item.title}</CardTitle>
                      <p className="text-sm text-muted-foreground">{item.description}</p>
                    </div>
                  </div>
                  {getServiceBadge(config.service)}
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <Label>Serviço de IA</Label>
                    <Select 
                      value={config.service} 
                      onValueChange={(value) => updateConfiguration(item.key, 'service', value)}
                    >
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        {aiServices.map(service => (
                          <SelectItem key={service.value} value={service.value}>
                            <div className="flex items-center gap-2">
                              {service.icon}
                              {service.label}
                            </div>
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>

                  <div>
                    <Label>Modelo</Label>
                    <Select 
                      value={config.model} 
                      onValueChange={(value) => updateConfiguration(item.key, 'model', value)}
                    >
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        {getAvailableModels(config.service).map(model => (
                          <SelectItem key={model.value} value={model.value}>
                            {model.label}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <Label>Temperatura: {config.temperature}</Label>
                    <Input
                      type="range"
                      min="0"
                      max="1"
                      step="0.1"
                      value={config.temperature}
                      onChange={(e) => updateConfiguration(item.key, 'temperature', parseFloat(e.target.value))}
                      className="mt-2"
                    />
                    <p className="text-xs text-muted-foreground mt-1">
                      Menor = mais conservador, Maior = mais criativo
                    </p>
                  </div>

                  <div>
                    <Label>Max Tokens</Label>
                    <Input
                      type="number"
                      min="50"
                      max="4000"
                      value={config.maxTokens}
                      onChange={(e) => updateConfiguration(item.key, 'maxTokens', parseInt(e.target.value))}
                      className="mt-2"
                    />
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    id={`enabled-${item.key}`}
                    checked={config.isEnabled}
                    onChange={(e) => updateConfiguration(item.key, 'isEnabled', e.target.checked)}
                  />
                  <Label htmlFor={`enabled-${item.key}`}>Funcionalidade ativada</Label>
                </div>
              </CardContent>
            </Card>
          );
        })}
      </div>
    </div>
  );
};

export default AIConfiguration;
