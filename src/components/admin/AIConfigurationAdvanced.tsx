import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Progress } from "@/components/ui/progress";
import { 
  Settings, 
  Zap, 
  DollarSign, 
  TrendingUp, 
  Save, 
  RotateCcw,
  Bot,
  Brain,
  AlertTriangle,
  CheckCircle2,
  Activity
} from 'lucide-react';
import { useToast } from "@/hooks/use-toast";
import { supabase } from "@/integrations/supabase/client";
import { AIFunctionalityCard } from './AIFunctionalityCard';
import { AIConfigTemplate } from './AIConfigTemplate';
import { useAITemplates } from '@/hooks/useAITemplates';

interface AIConfig {
  id: string;
  functionality: string;
  service: string;
  model: string;
  max_tokens: number;
  temperature: number;
  is_active: boolean;
  system_prompt: string;
  created_at: string;
  updated_at: string;
}

export function AIConfigurationAdvanced() {
  const [configs, setConfigs] = useState<AIConfig[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [totalCost, setTotalCost] = useState(0);
  const [globalSettings, setGlobalSettings] = useState({
    auto_optimize: false,
    cost_limit: 100,
    performance_mode: 'balanced'
  });
  const { toast } = useToast();
  const {
    templates,
    saveTemplate,
    deleteTemplate,
    toggleFavorite,
    incrementUsage
  } = useAITemplates();

  useEffect(() => {
    loadConfigurations();
  }, []);

  useEffect(() => {
    calculateTotalCost();
  }, [configs]);

  const loadConfigurations = async () => {
    try {
      setIsLoading(true);
      const { data, error } = await supabase
        .from('ai_configurations')
        .select('*')
        .order('functionality', { ascending: true });

      if (error) throw error;

      setConfigs(data || []);
      console.log('✅ Configurações carregadas:', data?.length || 0);
    } catch (error) {
      console.error('❌ Erro ao carregar configurações:', error);
      toast({
        title: "❌ Erro",
        description: "Falha ao carregar configurações de IA",
        variant: "destructive"
      });
    } finally {
      setIsLoading(false);
    }
  };

  const updateConfiguration = async (functionality: string, updates: Partial<AIConfig>) => {
    try {
      console.log(`🔄 Atualizando configuração: ${functionality}`, updates);

      const { error } = await supabase
        .from('ai_configurations')
        .update(updates)
        .eq('functionality', functionality);

      if (error) throw error;

      // Update local state
      setConfigs(prev => prev.map(config => 
        config.functionality === functionality 
          ? { ...config, ...updates }
          : config
      ));

      console.log('✅ Configuração atualizada no banco');
    } catch (error) {
      console.error('❌ Erro ao atualizar configuração:', error);
      throw error;
    }
  };

  const resetConfiguration = async (functionality: string) => {
    const defaultConfig = {
      service: 'openai',
      model: 'gpt-4.1-2025-04-14',
      max_tokens: 1024,
      temperature: 0.7,
      preset_level: 'medio',
      is_enabled: true
    };

    await updateConfiguration(functionality, defaultConfig);
    
    toast({
      title: "✅ Configuração Resetada",
      description: `${functionality} foi resetado para os padrões`,
    });
  };

  const calculateTotalCost = () => {
    let total = 0;
      configs.forEach(config => {
        if (config.is_active) {
          // Simplified cost calculation
          total += (config.max_tokens / 1000) * 0.03; // Base cost estimate
        }
      });
    setTotalCost(total);
  };

  const applyGlobalPreset = async (preset: 'minimo' | 'medio' | 'maximo') => {
    const presetConfigs = {
      minimo: { max_tokens: 1024, temperature: 0.5 },
      medio: { max_tokens: 4096, temperature: 0.7 },
      maximo: { max_tokens: 8192, temperature: 0.8 }
    };

    const config = presetConfigs[preset];
    
    try {
      setIsSaving(true);
      
      // Update all configurations
      for (const item of configs) {
        await updateConfiguration(item.functionality, {
          ...config,
          preset_level: preset
        });
      }

      toast({
        title: "✅ Preset Aplicado",
        description: `Todas as configurações foram atualizadas para ${preset.toUpperCase()}`,
      });
    } catch (error) {
      toast({
        title: "❌ Erro",
        description: "Falha ao aplicar preset global",
        variant: "destructive"
      });
    } finally {
      setIsSaving(false);
    }
  };

  const handleApplyTemplate = async (template: any) => {
    try {
      setIsSaving(true);
      
      // Apply template configurations to all functionalities
      for (const config of configs) {
        await updateConfiguration(config.functionality, {
          service: template.configurations.default_service || 'openai',
          model: template.configurations.default_model || 'gpt-4.1-2025-04-14',
          max_tokens: template.configurations.default_tokens || 4096,
          temperature: template.configurations.default_temperature || 0.7,
          preset_level: 'personalizado'
        });
      }

      incrementUsage(template.id);
      await loadConfigurations();
    } finally {
      setIsSaving(false);
    }
  };

  const getSystemHealthScore = () => {
    const enabledConfigs = configs.filter(c => c.is_active);
    const optimalConfigs = enabledConfigs.filter(c => 
      c.max_tokens >= 2048 && c.max_tokens <= 4096 && 
      c.temperature >= 0.6 && c.temperature <= 0.8
    );
    
    if (enabledConfigs.length === 0) return 0;
    return Math.round((optimalConfigs.length / enabledConfigs.length) * 100);
  };

  const getPerformanceIndicator = () => {
    const avgTokens = configs.reduce((sum, c) => sum + (c.is_active ? c.max_tokens : 0), 0) / configs.filter(c => c.is_active).length;
    
    if (avgTokens <= 2048) return { level: 'Rápido', color: 'text-green-600', icon: Zap };
    if (avgTokens <= 4096) return { level: 'Equilibrado', color: 'text-yellow-600', icon: Activity };
    return { level: 'Potente', color: 'text-red-600', icon: Brain };
  };

  const healthScore = getSystemHealthScore();
  const performance = getPerformanceIndicator();
  const PerformanceIcon = performance.icon;

  if (isLoading) {
    return (
      <Card>
        <CardContent className="flex items-center justify-center py-8">
          <div className="text-center">
            <Settings className="w-8 h-8 animate-spin mx-auto mb-2" />
            <p>Carregando configurações...</p>
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-6">
      {/* System Overview */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Bot className="w-5 h-5" />
            Central de Configuração de IA
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-4">
            <div className="bg-gradient-to-r from-blue-50 to-blue-100 p-4 rounded-lg">
              <div className="flex items-center gap-2">
                <CheckCircle2 className="w-4 h-4 text-blue-600" />
                <span className="text-sm font-medium">Saúde do Sistema</span>
              </div>
              <div className="mt-2">
                <div className="text-2xl font-bold text-blue-600">{healthScore}%</div>
                <Progress value={healthScore} className="mt-1" />
              </div>
            </div>

            <div className="bg-gradient-to-r from-green-50 to-green-100 p-4 rounded-lg">
              <div className="flex items-center gap-2">
                <PerformanceIcon className="w-4 h-4 text-green-600" />
                <span className="text-sm font-medium">Performance</span>
              </div>
              <div className="mt-2">
                <div className={`text-lg font-bold ${performance.color}`}>
                  {performance.level}
                </div>
              </div>
            </div>

            <div className="bg-gradient-to-r from-yellow-50 to-yellow-100 p-4 rounded-lg">
              <div className="flex items-center gap-2">
                <DollarSign className="w-4 h-4 text-yellow-600" />
                <span className="text-sm font-medium">Custo Estimado</span>
              </div>
              <div className="mt-2">
                <div className="text-lg font-bold text-yellow-600">
                  ${totalCost.toFixed(4)}/uso
                </div>
              </div>
            </div>

            <div className="bg-gradient-to-r from-purple-50 to-purple-100 p-4 rounded-lg">
              <div className="flex items-center gap-2">
                <Settings className="w-4 h-4 text-purple-600" />
                <span className="text-sm font-medium">Configurações</span>
              </div>
              <div className="mt-2">
                <div className="text-lg font-bold text-purple-600">
                  {configs.filter(c => c.is_active).length}/{configs.length}
                </div>
              </div>
            </div>
          </div>

          {/* Quick Actions */}
          <div className="flex flex-wrap gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => applyGlobalPreset('minimo')}
              disabled={isSaving}
            >
              Aplicar MÍNIMO Global
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => applyGlobalPreset('medio')}
              disabled={isSaving}
            >
              Aplicar MEIO Global
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => applyGlobalPreset('maximo')}
              disabled={isSaving}
            >
              Aplicar MÁXIMO Global
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={loadConfigurations}
              disabled={isSaving}
            >
              <RotateCcw className="w-4 h-4 mr-1" />
              Recarregar
            </Button>
          </div>
        </CardContent>
      </Card>

      <Tabs defaultValue="configurations" className="w-full">
        <TabsList className="grid w-full grid-cols-2">
          <TabsTrigger value="configurations">⚙️ Configurações Individuais</TabsTrigger>
          <TabsTrigger value="templates">📚 Templates</TabsTrigger>
        </TabsList>

        <TabsContent value="configurations" className="space-y-4">
          {/* Health Alerts */}
          {healthScore < 60 && (
            <Alert>
              <AlertTriangle className="h-4 w-4" />
              <AlertDescription>
                Algumas configurações podem estar subotimizadas. 
                Considere revisar as configurações marcadas em vermelho.
              </AlertDescription>
            </Alert>
          )}

          {/* Individual Configuration Cards */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
            {configs.map((config) => (
              <AIFunctionalityCard
                key={config.functionality}
                config={config}
                onUpdate={(updates) => updateConfiguration(config.functionality, updates)}
                onReset={() => resetConfiguration(config.functionality)}
                estimatedCost={totalCost}
              />
            ))}
          </div>
        </TabsContent>

        <TabsContent value="templates" className="space-y-4">
          <AIConfigTemplate
            currentConfigs={configs.reduce((acc, config) => ({
              ...acc,
              [config.functionality]: config
            }), {})}
            onApplyTemplate={handleApplyTemplate}
            templates={templates}
            onSaveTemplate={saveTemplate}
            onDeleteTemplate={deleteTemplate}
            onToggleFavorite={toggleFavorite}
          />
        </TabsContent>
      </Tabs>
    </div>
  );
}