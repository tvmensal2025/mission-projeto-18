import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { supabase } from "@/integrations/supabase/client";
import { toast } from "sonner";
import { 
  Activity, 
  AlertTriangle, 
  TrendingUp, 
  TrendingDown, 
  Brain, 
  Heart, 
  Target,
  Calendar,
  BarChart3,
  LineChart,
  CheckCircle,
  XCircle,
  AlertCircle
} from 'lucide-react';
import {
  LineChart as RechartsLineChart,
  BarChart as RechartsBarChart,
  Line,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell
} from 'recharts';

interface PreventiveAnalysis {
  id: string;
  analysis_type: 'quinzenal' | 'mensal';
  analysis_date: string;
  risk_level: 'baixo' | 'medio' | 'alto' | 'critico';
  health_score: number;
  analysis_data: any;
  recommendations: string[];
  risk_factors: string[];
  improvement_areas: string[];
  next_analysis_date: string;
  is_completed: boolean;
}

const PreventiveAnalyticsDashboard: React.FC = () => {
  const [analyses, setAnalyses] = useState<PreventiveAnalysis[]>([]);
  const [loading, setLoading] = useState(true);
  const [generating, setGenerating] = useState(false);
  const [selectedPeriod, setSelectedPeriod] = useState<'quinzenal' | 'mensal' | 'todos'>('todos');

  useEffect(() => {
    loadAnalyses();
  }, []);

  const loadAnalyses = async () => {
    try {
      const { data: user } = await supabase.auth.getUser();
      if (!user.user) return;

      const { data, error } = await supabase
        .from('preventive_health_analyses')
        .select('*')
        .eq('user_id', user.user.id)
        .order('analysis_date', { ascending: false });

      if (error) {
        console.error('Erro ao carregar análises:', error);
        toast.error('Erro ao carregar análises');
        return;
      }
      
      setAnalyses(data || []);
    } catch (error) {
      console.error('Erro ao carregar análises:', error);
      toast.error('Erro ao carregar análises');
    } finally {
      setLoading(false);
    }
  };

  const generateAnalysis = async (type: 'quinzenal' | 'mensal') => {
    try {
      setGenerating(true);
      const { data: user } = await supabase.auth.getUser();
      if (!user.user) return;

      // Simular geração de análise
      const mockAnalysis = {
        user_id: user.user.id,
        analysis_type: type,
        risk_level: 'medio' as const,
        health_score: 7.5,
        analysis_data: {
          weight_trend: 'stable',
          exercise_frequency: 'moderate',
          sleep_quality: 'good',
          stress_level: 'medium'
        },
        recommendations: [
          'Aumentar frequência de exercícios',
          'Melhorar qualidade do sono',
          'Reduzir níveis de estresse'
        ],
        risk_factors: [
          'Sedentarismo moderado',
          'Estresse elevado'
        ],
        improvement_areas: [
          'Atividade física',
          'Gestão do estresse'
        ],
        next_analysis_date: new Date(Date.now() + (type === 'quinzenal' ? 14 : 30) * 24 * 60 * 60 * 1000).toISOString()
      };

      const { data, error } = await supabase
        .from('preventive_health_analyses')
        .insert([mockAnalysis])
        .select()
        .single();

      if (error) throw error;

      toast.success(`Análise ${type} gerada com sucesso!`);
      loadAnalyses();
    } catch (error) {
      console.error('Erro ao gerar análise:', error);
      toast.error('Erro ao gerar análise');
    } finally {
      setGenerating(false);
    }
  };

  const getRiskColor = (level: string) => {
    switch (level) {
      case 'baixo': return 'bg-green-100 text-green-800';
      case 'medio': return 'bg-yellow-100 text-yellow-800';
      case 'alto': return 'bg-orange-100 text-orange-800';
      case 'critico': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getRiskIcon = (level: string) => {
    switch (level) {
      case 'baixo': return <CheckCircle className="h-4 w-4" />;
      case 'medio': return <AlertCircle className="h-4 w-4" />;
      case 'alto': return <AlertTriangle className="h-4 w-4" />;
      case 'critico': return <XCircle className="h-4 w-4" />;
      default: return <Activity className="h-4 w-4" />;
    }
  };

  const filteredAnalyses = selectedPeriod === 'todos' 
    ? analyses 
    : analyses.filter(a => a.analysis_type === selectedPeriod);

  const latestAnalysis = analyses[0];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Análises Preventivas - Dr. Vital</h1>
          <p className="text-muted-foreground">
            Análises automáticas quinzenais e mensais da sua saúde
          </p>
        </div>
        <div className="flex gap-2">
          <Button
            onClick={() => generateAnalysis('quinzenal')}
            disabled={generating}
            className="bg-orange-500 hover:bg-orange-600"
          >
            {generating ? 'Gerando...' : 'Gerar Quinzenal'}
          </Button>
          <Button
            onClick={() => generateAnalysis('mensal')}
            disabled={generating}
            className="bg-orange-500 hover:bg-orange-600"
          >
            {generating ? 'Gerando...' : 'Gerar Mensal'}
          </Button>
        </div>
      </div>

      <Tabs value={selectedPeriod} onValueChange={(value) => setSelectedPeriod(value as any)}>
        <TabsList>
          <TabsTrigger value="todos">Todos</TabsTrigger>
          <TabsTrigger value="quinzenal">Quinzenal</TabsTrigger>
          <TabsTrigger value="mensal">Mensal</TabsTrigger>
        </TabsList>

        <TabsContent value={selectedPeriod} className="space-y-6">
          {loading ? (
            <div className="flex items-center justify-center h-64">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-orange-500"></div>
            </div>
          ) : filteredAnalyses.length === 0 ? (
            <Alert>
              <AlertCircle className="h-4 w-4" />
              <AlertDescription>
                Nenhuma análise encontrada. Clique em "Gerar Quinzenal" ou "Gerar Mensal" para criar sua primeira análise.
              </AlertDescription>
            </Alert>
          ) : (
            <>
              {/* Análise Mais Recente */}
              {latestAnalysis && (
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <Brain className="h-5 w-5" />
                      Análise Mais Recente
                    </CardTitle>
                    <CardDescription>
                      Última análise realizada em {new Date(latestAnalysis.analysis_date).toLocaleDateString('pt-BR')}
                    </CardDescription>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="flex items-center gap-4">
                      <Badge className={getRiskColor(latestAnalysis.risk_level)}>
                        {getRiskIcon(latestAnalysis.risk_level)}
                        {latestAnalysis.risk_level.toUpperCase()}
                      </Badge>
                      <div className="flex items-center gap-2">
                        <Heart className="h-4 w-4 text-red-500" />
                        <span>Score de Saúde: {latestAnalysis.health_score}/10</span>
                      </div>
                    </div>
                    
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div>
                        <h4 className="font-semibold mb-2">Recomendações</h4>
                        <ul className="space-y-1">
                          {latestAnalysis.recommendations?.map((rec, index) => (
                            <li key={index} className="flex items-center gap-2 text-sm">
                              <CheckCircle className="h-3 w-3 text-green-500" />
                              {rec}
                            </li>
                          ))}
                        </ul>
                      </div>
                      
                      <div>
                        <h4 className="font-semibold mb-2">Fatores de Risco</h4>
                        <ul className="space-y-1">
                          {latestAnalysis.risk_factors?.map((risk, index) => (
                            <li key={index} className="flex items-center gap-2 text-sm">
                              <AlertTriangle className="h-3 w-3 text-orange-500" />
                              {risk}
                            </li>
                          ))}
                        </ul>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              )}

              {/* Gráficos e Métricas */}
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <TrendingUp className="h-5 w-5" />
                      Tendência de Risco ao Longo do Tempo
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="h-64 flex items-center justify-center text-muted-foreground">
                      Gráfico de tendência será exibido aqui
                    </div>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <BarChart3 className="h-5 w-5" />
                      Métricas de Saúde
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="h-64 flex items-center justify-center text-muted-foreground">
                      Métricas serão exibidas aqui
                    </div>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <PieChart className="h-5 w-5" />
                      Distribuição de Níveis de Risco
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="h-64 flex items-center justify-center text-muted-foreground">
                      Distribuição será exibida aqui
                    </div>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <Calendar className="h-5 w-5" />
                      Histórico de Análises
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2">
                      {filteredAnalyses.slice(0, 5).map((analysis) => (
                        <div key={analysis.id} className="flex items-center justify-between p-2 border rounded">
                          <div>
                            <p className="font-medium">{analysis.analysis_type}</p>
                            <p className="text-sm text-muted-foreground">
                              {new Date(analysis.analysis_date).toLocaleDateString('pt-BR')}
                            </p>
                          </div>
                          <Badge className={getRiskColor(analysis.risk_level)}>
                            {analysis.risk_level}
                          </Badge>
                        </div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </div>
            </>
          )}
        </TabsContent>
      </Tabs>
    </div>
  );
};

export default PreventiveAnalyticsDashboard; 