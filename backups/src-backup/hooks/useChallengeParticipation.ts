import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { useToast } from '@/hooks/use-toast';

export const useChallengeParticipation = () => {
  const { toast } = useToast();
  const queryClient = useQueryClient();

  // Buscar participações do usuário
  const { data: participations, isLoading } = useQuery({
    queryKey: ['challenge-participations'],
    queryFn: async () => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return [];

      const { data, error } = await supabase
        .from('challenge_participations')
        .select(`
          *,
          challenges (*)
        `)
        .eq('user_id', user.id);

      if (error) throw error;
      return data || [];
    }
  });

  // Participar de um desafio
  const participateMutation = useMutation({
    mutationFn: async (challengeId: string) => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Usuário não autenticado');

      // Verificar se já está participando
      const existingParticipation = participations?.find(p => p.challenge_id === challengeId);
      if (existingParticipation) {
        throw new Error('Você já está participando deste desafio');
      }

      // Buscar dados do desafio para definir target_value
      const { data: challenge, error: challengeError } = await supabase
        .from('challenges')
        .select('*')
        .eq('id', challengeId)
        .maybeSingle();

      if (challengeError) throw challengeError;
      if (!challenge) throw new Error('Desafio não encontrado');

      // Definir target_value baseado no tipo de desafio
      let targetValue = 100; // valor padrão
      if (challenge.title?.toLowerCase().includes('água') || challenge.title?.toLowerCase().includes('hidratacao')) {
        targetValue = 2000; // 2L de água
      } else if (challenge.title?.toLowerCase().includes('exercício') || challenge.title?.toLowerCase().includes('exercicio')) {
        targetValue = 30; // 30 minutos
      } else if (challenge.title?.toLowerCase().includes('meditação') || challenge.title?.toLowerCase().includes('meditacao')) {
        targetValue = 10; // 10 minutos
      } else if (challenge.title?.toLowerCase().includes('frutas') || challenge.title?.toLowerCase().includes('vegetais')) {
        targetValue = 5; // 5 porções
      }

      // Inserir nova participação com as colunas corretas
      const { data, error } = await supabase
        .from('challenge_participations')
        .insert({
          user_id: user.id,
          challenge_id: challengeId,
          target_value: targetValue,
          current_value: 0,
          progress_percentage: 0,
          status: 'active',
          start_date: new Date().toISOString()
        })
        .select()
        .single();

      if (error) {
        // Se der erro de constraint única, significa que já está participando
        if (error.code === '23505') {
          throw new Error('Você já está participando deste desafio');
        }
        throw error;
      }
      return data;
    },
    onSuccess: (data) => {
      toast({
        title: "🎯 Desafio Iniciado!",
        description: "Você agora está participando do desafio!",
      });
      // Invalidar queries para atualizar a UI imediatamente
      queryClient.invalidateQueries({ queryKey: ['challenge-participations'] });
    },
    onError: (error: Error) => {
      toast({
        title: "Erro",
        description: error.message,
        variant: "destructive"
      });
    }
  });

  // Atualizar progresso
  const updateProgressMutation = useMutation({
    mutationFn: async ({ challengeId, progress }: { challengeId: string; progress: number }) => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Usuário não autenticado');

      // Buscar participação atual
      const { data: participation, error: fetchError } = await supabase
        .from('challenge_participations')
        .select('*')
        .eq('user_id', user.id)
        .eq('challenge_id', challengeId)
        .single();

      if (fetchError) throw fetchError;
      if (!participation) throw new Error('Participação não encontrada');

      // Calcular novo progresso
      const newCurrentValue = Math.min(progress, participation.target_value);
      const newProgressPercentage = (newCurrentValue / participation.target_value) * 100;
      const isCompleted = newProgressPercentage >= 100;

      // Atualizar participação
      const { data, error } = await supabase
        .from('challenge_participations')
        .update({ 
          current_value: newCurrentValue,
          progress_percentage: newProgressPercentage,
          status: isCompleted ? 'completed' : 'active',
          completed_at: isCompleted ? new Date().toISOString() : null
        })
        .eq('user_id', user.id)
        .eq('challenge_id', challengeId)
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: (data) => {
      const isCompleted = data.status === 'completed';
      toast({
        title: isCompleted ? "🎉 Desafio Concluído!" : "💪 Progresso Atualizado!",
        description: isCompleted ? "Parabéns! Você concluiu o desafio!" : "Seu progresso foi atualizado!",
      });
      queryClient.invalidateQueries({ queryKey: ['challenge-participations'] });
    },
    onError: (error: Error) => {
      toast({
        title: "Erro",
        description: error.message,
        variant: "destructive"
      });
    }
  });

  // Verificar se está participando de um desafio
  const isParticipating = (challengeId: string) => {
    return participations?.some(p => p.challenge_id === challengeId) || false;
  };

  // Obter progresso de um desafio
  const getProgress = (challengeId: string) => {
    const participation = participations?.find(p => p.challenge_id === challengeId);
    return participation ? {
      progress: participation.progress_percentage || 0,
      isCompleted: participation.status === 'completed',
      currentValue: participation.current_value || 0,
      targetValue: participation.target_value || 100
    } : null;
  };

  return {
    participations,
    isLoading,
    participate: participateMutation.mutate,
    isParticipatingInChallenge: participateMutation.isPending,
    updateProgress: updateProgressMutation.mutate,
    isUpdatingProgress: updateProgressMutation.isPending,
    isParticipating,
    getProgress
  };
};