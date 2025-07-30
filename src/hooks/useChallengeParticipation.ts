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

      // Buscar dados do desafio
      const { data: challenge, error: challengeError } = await supabase
        .from('challenges')
        .select('target_value')
        .eq('id', challengeId)
        .maybeSingle();

      if (challengeError) throw challengeError;
      if (!challenge) throw new Error('Desafio não encontrado');

      // UPSERT: Insert ou ignore se já existe
      const { data, error } = await supabase
        .from('challenge_participations')
        .upsert({
          user_id: user.id,
          challenge_id: challengeId,
          target_value: challenge.target_value || 1,
          progress: 0,
          current_streak: 0,
          best_streak: 0,
          is_completed: false,
          started_at: new Date().toISOString()
        }, {
          onConflict: 'user_id,challenge_id',
          ignoreDuplicates: false
        })
        .select()
        .single();

      if (error) {
        // Se ainda assim der erro, verificar se é porque já existe
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
      queryClient.setQueryData(['challenge-participations'], (oldData: any) => {
        if (!oldData) return [data];
        return [...oldData, data];
      });
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

      const { data, error } = await supabase
        .from('challenge_participations')
        .update({ 
          progress,
          is_completed: progress >= 100,
          completed_at: progress >= 100 ? new Date().toISOString() : null
        })
        .eq('user_id', user.id)
        .eq('challenge_id', challengeId)
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: (data) => {
      const isCompleted = data.is_completed;
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
      progress: participation.progress || 0,
      isCompleted: participation.is_completed || false,
      currentStreak: participation.current_streak || 0,
      bestStreak: participation.best_streak || 0
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