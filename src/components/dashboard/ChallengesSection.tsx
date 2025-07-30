import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';
import { 
  Trophy, Users, Calendar, Target, Dumbbell, 
  Droplets, Brain, Apple, Moon, Scale, Timer, ArrowLeft, 
  Star, Zap, CheckCircle, Plus, Flame
} from 'lucide-react';
import { supabase } from '@/integrations/supabase/client';
import { useToast } from '@/hooks/use-toast';
import { motion } from 'framer-motion';
import { UpdateChallengeProgressModal } from '@/components/gamification/UpdateChallengeProgressModal';
import { User } from '@supabase/supabase-js';
import { VisualEffectsManager } from '@/components/gamification/VisualEffectsManager';
import { useCelebrationEffects } from '@/hooks/useCelebrationEffects';
import { useChallengeParticipation } from '@/hooks/useChallengeParticipation';

interface Challenge {
  id: string;
  title: string;
  description: string;
  category: string;
  difficulty: string;
  duration_days: number;
  points_reward: number;
  badge_icon: string;
  badge_name: string;
  instructions: string;
  tips: string[];
  is_active: boolean;
  is_featured: boolean;
  is_group_challenge: boolean;
  target_value?: number;
  user_participation?: {
    id: string;
    progress: number;
    is_completed: boolean;
    started_at: string;
  };
}

interface ChallengesSectionProps {
  user: User | null;
}

const ChallengesSection: React.FC<ChallengesSectionProps> = ({ user }) => {
  const [challenges, setChallenges] = useState<Challenge[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedChallenge, setSelectedChallenge] = useState<Challenge | null>(null);
  const [showUpdateModal, setShowUpdateModal] = useState(false);
  const [updateModalOpen, setUpdateModalOpen] = useState(false);
  const [currentChallengeForUpdate, setCurrentChallengeForUpdate] = useState<Challenge | null>(null);
  const { toast } = useToast();
  const { celebrateChallengeCompletion, activeCelebration } = useCelebrationEffects();
  
  // Usar o hook de participação em desafios
  const { 
    participations, 
    isLoading: participationsLoading, 
    participate, 
    isParticipatingInChallenge,
    isParticipating,
    getProgress,
    updateProgress
  } = useChallengeParticipation();

  useEffect(() => {
    fetchChallenges();
  }, []);

  const fetchChallenges = async () => {
    try {
      setLoading(true);
      
      // Buscar desafios do banco de dados
      const { data: dbChallenges, error } = await supabase
        .from('challenges')
        .select('*')
        .eq('is_active', true)
        .order('created_at', { ascending: false });

      if (error) {
        console.error('Erro ao buscar desafios:', error);
        // Se não conseguir buscar do banco, usar dados mock como fallback
        const mockChallenges: Challenge[] = [
          {
            id: '01234567-89ab-cdef-0123-456789abcdef',
            title: 'Hidratação Diária',
            description: 'Beba 2L de água todos os dias por uma semana',
            category: 'hidratacao',
            difficulty: 'facil',
            duration_days: 7,
            points_reward: 50,
            badge_icon: '💧',
            badge_name: 'Hidratado',
            instructions: 'Beba 2 litros de água por dia',
            tips: ['Carregue uma garrafa de água', 'Defina lembretes'],
            is_active: true,
            is_featured: true,
            is_group_challenge: false,
            target_value: 14
          },
          {
            id: '11234567-89ab-cdef-0123-456789abcdef',
            title: 'Exercício Matinal',
            description: 'Faça 30 minutos de exercício todas as manhãs',
            category: 'exercicio',
            difficulty: 'medio',
            duration_days: 14,
            points_reward: 120,
            badge_icon: '🏃‍♂️',
            badge_name: 'Atleta Matinal',
            instructions: 'Exercite-se por 30 minutos todas as manhãs',
            tips: ['Comece devagar', 'Prepare a roupa na noite anterior'],
            is_active: true,
            is_featured: false,
            is_group_challenge: true,
            target_value: 14
          },
          {
            id: '21234567-89ab-cdef-0123-456789abcdef',
            title: 'Alimentação Saudável',
            description: 'Coma 5 porções de frutas e vegetais por dia',
            category: 'nutricao',
            difficulty: 'medio',
            duration_days: 21,
            points_reward: 200,
            badge_icon: '🥗',
            badge_name: 'Nutricionista',
            instructions: 'Inclua 5 porções de frutas e vegetais em suas refeições diárias',
            tips: ['Planeje as refeições', 'Varie as cores dos alimentos'],
            is_active: true,
            is_featured: false,
            is_group_challenge: false,
            target_value: 105
          }
        ];
        
        setChallenges(mockChallenges);
        return;
      }

      // Converter dados do banco para o formato esperado
      const formattedChallenges: Challenge[] = dbChallenges?.map(challenge => ({
        id: challenge.id,
        title: challenge.title,
        description: challenge.description || '',
        category: challenge.category || 'geral',
        difficulty: challenge.difficulty || 'medio',
        duration_days: challenge.duration_days || 7,
        points_reward: challenge.xp_reward || 100,
        badge_icon: '🎯', // Valor padrão
        badge_name: 'Conquista', // Valor padrão
        instructions: '', // Valor padrão
        tips: [], // Valor padrão
        is_active: challenge.is_active || true,
        is_featured: false, // Valor padrão
        is_group_challenge: false, // Valor padrão
        target_value: challenge.target_value || 100
      })) || [];

      setChallenges(formattedChallenges);
    } catch (error) {
      console.error('Erro ao carregar desafios:', error);
      toast({
        title: "Erro",
        description: "Não foi possível carregar os desafios",
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };

  const getCategoryIcon = (category: string) => {
    switch (category) {
      case 'jejum': return <Timer className="h-5 w-5" />;
      case 'exercicio': return <Dumbbell className="h-5 w-5" />;
      case 'hidratacao': return <Droplets className="h-5 w-5" />;
      case 'mindfulness': return <Brain className="h-5 w-5" />;
      case 'nutricao': return <Apple className="h-5 w-5" />;
      case 'sono': return <Moon className="h-5 w-5" />;
      case 'medicao': return <Scale className="h-5 w-5" />;
      default: return <Target className="h-5 w-5" />;
    }
  };

  const getDifficultyGradient = (difficulty: string) => {
    switch (difficulty) {
      case 'facil': return 'from-green-500 to-green-600';
      case 'medio': return 'from-yellow-500 to-orange-500';
      case 'dificil': return 'from-orange-500 to-red-500';
      case 'extremo': return 'from-red-500 to-pink-500';
      default: return 'from-gray-500 to-gray-600';
    }
  };

  const getDifficultyIcon = (difficulty: string) => {
    switch (difficulty) {
      case 'facil': return Star;
      case 'medio': return Target;
      case 'dificil': return Trophy;
      case 'extremo': return Trophy;
      default: return Target;
    }
  };

  const getDifficultyText = (difficulty: string) => {
    switch (difficulty) {
      case 'facil': return 'Fácil';
      case 'medio': return 'Médio';
      case 'dificil': return 'Difícil';
      case 'extremo': return 'Extremo';
      default: return difficulty;
    }
  };

  const handleChallengeClick = (challenge: Challenge) => {
    setSelectedChallenge(challenge);
  };

  const handleJoinChallenge = async (challengeId: string, e: React.MouseEvent) => {
    e.stopPropagation();
    
    if (!user) {
      toast({
        title: "Login necessário",
        description: "Faça login para participar dos desafios",
        variant: "destructive"
      });
      return;
    }

    // Verificar se já está participando
    if (isParticipating(challengeId)) {
      toast({
        title: "Já participando",
        description: "Você já está participando deste desafio!",
      });
      return;
    }

    try {
      // Usar o hook para participar do desafio
      participate(challengeId);
      
      // Trigger celebration effect for joining challenge
      celebrateChallengeCompletion();
    } catch (error: any) {
      toast({
        title: "Erro ao participar do desafio",
        description: error.message,
        variant: "destructive"
      });
    }
  };

  const handleUpdateProgress = (challenge: Challenge) => {
    setCurrentChallengeForUpdate(challenge);
    setUpdateModalOpen(true);
  };

  const handleProgressUpdate = (newProgress: number) => {
    if (currentChallengeForUpdate) {
      // Atualizar progresso usando o hook
      updateProgress({
        challengeId: currentChallengeForUpdate.id,
        progress: newProgress
      });
      
      // Atualizar o estado local
      setChallenges(prev => prev.map(challenge => 
        challenge.id === currentChallengeForUpdate.id 
          ? {
              ...challenge,
              user_participation: challenge.user_participation ? {
                ...challenge.user_participation,
                progress: newProgress,
                is_completed: newProgress >= 100
              } : challenge.user_participation
            }
          : challenge
      ));
    }
    setUpdateModalOpen(false);
  };

  const renderChallengesList = () => {
    if (loading || participationsLoading) {
      return (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {[1, 2, 3].map((i) => (
            <Card key={i} className="animate-pulse">
              <CardHeader>
                <div className="h-4 bg-muted rounded w-3/4 mb-2"></div>
                <div className="h-3 bg-muted rounded w-1/2"></div>
              </CardHeader>
              <CardContent>
                <div className="h-3 bg-muted rounded w-full mb-2"></div>
                <div className="h-3 bg-muted rounded w-2/3"></div>
              </CardContent>
            </Card>
          ))}
        </div>
      );
    }

    return (
      <div className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {challenges.map((challenge, index) => {
            const DifficultyIcon = getDifficultyIcon(challenge.difficulty);
            const userProgress = getProgress(challenge.id);
            const isUserParticipating = isParticipating(challenge.id);

            return (
              <motion.div
                key={challenge.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1 }}
                className="relative"
              >
                <Card className="h-full relative overflow-hidden hover:shadow-lg transition-shadow">
                  <CardHeader className="pb-4">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <motion.div
                          className={`p-3 bg-gradient-to-br ${getDifficultyGradient(challenge.difficulty)} rounded-full`}
                          whileHover={{ rotate: 10 }}
                          transition={{ duration: 0.2 }}
                        >
                          <DifficultyIcon className="w-6 h-6 text-white" />
                        </motion.div>
                        
                        <div className="flex-1">
                          <CardTitle className="text-lg mb-2">{challenge.title}</CardTitle>
                          <div className="flex items-center gap-2">
                            <Badge className={`bg-gradient-to-r ${getDifficultyGradient(challenge.difficulty)} text-white border-0`}>
                              {getDifficultyText(challenge.difficulty)}
                            </Badge>
                            {getCategoryIcon(challenge.category)}
                          </div>
                        </div>
                      </div>

                      <div className="text-3xl ml-3">{challenge.badge_icon}</div>
                    </div>
                  </CardHeader>

                  <CardContent className="space-y-4 relative z-10">
                    <CardDescription className="text-sm leading-relaxed">
                      {challenge.description}
                    </CardDescription>

                    {/* Stats Section */}
                    <div className="grid grid-cols-2 gap-4">
                      <div className="flex items-center gap-2 p-3 bg-muted/50 rounded-lg">
                        <Calendar className="w-4 h-4 text-primary" />
                        <div>
                          <div className="text-sm font-medium">{challenge.duration_days}</div>
                          <div className="text-xs text-muted-foreground">dias</div>
                        </div>
                      </div>
                      
                      <div className="flex items-center gap-2 p-3 bg-muted/50 rounded-lg">
                        <Trophy className="w-4 h-4 text-yellow-500" />
                        <div>
                          <div className="text-sm font-medium">{challenge.points_reward}</div>
                          <div className="text-xs text-muted-foreground">pontos</div>
                        </div>
                      </div>
                    </div>

                    {/* Group Challenge Indicator */}
                    {challenge.is_group_challenge && (
                      <div className="flex items-center gap-2 p-2 bg-blue-50 rounded-lg">
                        <Users className="w-4 h-4 text-blue-500" />
                        <span className="text-sm text-blue-700 font-medium">Desafio em Grupo</span>
                      </div>
                    )}

                    {/* Progress Section - Mostrar se está participando */}
                    {isUserParticipating && userProgress && (
                      <div className="space-y-2">
                        <div className="flex justify-between text-sm">
                          <span>Progresso</span>
                          <span>{Math.round(userProgress.progress)}%</span>
                        </div>
                        <Progress value={userProgress.progress} className="h-2" />
                      </div>
                    )}

                    {/* Action Button */}
                    <motion.div
                      whileHover={{ scale: 1.02 }}
                      whileTap={{ scale: 0.98 }}
                      className="pt-2"
                    >
                      {isUserParticipating ? (
                        <Button 
                          className="w-full bg-gradient-to-r from-green-500 to-green-600 hover:from-green-600 hover:to-green-700 text-white font-medium" 
                          onClick={() => handleUpdateProgress(challenge)}
                        >
                          <CheckCircle className="w-4 h-4 mr-2" />
                          Atualizar Progresso ({Math.round(userProgress?.progress || 0)}%)
                        </Button>
                      ) : (
                        <Button 
                          className="w-full bg-gradient-to-r from-primary to-primary/80 hover:from-primary/90 hover:to-primary/70 text-white font-medium" 
                          onClick={(e) => handleJoinChallenge(challenge.id, e)}
                          disabled={isParticipatingInChallenge}
                        >
                          <Target className="w-4 h-4 mr-2" />
                          {isParticipatingInChallenge ? 'Participando...' : 'Participar do Desafio'}
                        </Button>
                      )}
                    </motion.div>
                  </CardContent>

                  {/* Hover Glow Effect */}
                  <motion.div
                    className={`absolute inset-0 border-2 border-transparent bg-gradient-to-br ${getDifficultyGradient(challenge.difficulty)} opacity-0 rounded-lg`}
                    whileHover={{ opacity: 0.1 }}
                    transition={{ duration: 0.3 }}
                  />
                </Card>
              </motion.div>
            );
          })}
        </div>
        
        {/* Visual Effects */}
        {activeCelebration && (
          <VisualEffectsManager
            trigger={activeCelebration.trigger}
            effectType={activeCelebration.type}
            duration={3000}
          />
        )}

        {/* Modal de Atualização de Progresso */}
        {currentChallengeForUpdate && (
          <UpdateChallengeProgressModal
            isOpen={updateModalOpen}
            onClose={() => setUpdateModalOpen(false)}
            challengeId={currentChallengeForUpdate.id}
            challengeTitle={currentChallengeForUpdate.title}
            currentProgress={getProgress(currentChallengeForUpdate.id)?.progress || 0}
            onProgressUpdate={handleProgressUpdate}
          />
        )}
      </div>
    );
  };

  return renderChallengesList();
};

export default ChallengesSection;