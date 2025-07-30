import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { useToast } from "@/hooks/use-toast";

export const useGoals = () => {
  const { toast } = useToast();
  const queryClient = useQueryClient();

  // Buscar metas do usuário
  const {
    data: goals,
    isLoading,
    error,
  } = useQuery({
    queryKey: ["user-goals"],
    queryFn: async () => {
      // Buscar apenas metas do usuário logado
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error("Usuário não autenticado");

      const { data, error } = await supabase
        .from("user_goals")
        .select("*")
        .eq("user_id", user.id)
        .order("created_at", { ascending: false });

      if (error) throw error;
      return data;
    },
  });

  // Buscar categorias de metas
  const { data: categories } = useQuery({
    queryKey: ["goal-categories"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("goal_categories")
        .select("*")
        .eq("is_active", true)
        .order("name");

      if (error) throw error;
      return data;
    },
  });

  // Criar nova meta
  const createGoalMutation = useMutation({
    mutationFn: async (goalData: any) => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error("Usuário não autenticado");

      const { error } = await supabase.from("user_goals").insert({
        ...goalData,
        user_id: user.id,
        status: "pendente",
        current_value: 0,
      });

      if (error) throw error;
    },
    onSuccess: () => {
      toast({
        title: "Meta criada com sucesso!",
        description: "Sua meta foi enviada para aprovação administrativa.",
      });
      queryClient.invalidateQueries({ queryKey: ["user-goals"] });
    },
    onError: (error: any) => {
      toast({
        title: "Erro ao criar meta",
        description: error.message,
        variant: "destructive",
      });
    },
  });

  // Atualizar progresso da meta
  const updateProgressMutation = useMutation({
    mutationFn: async ({ goalId, newValue, notes }: { 
      goalId: string; 
      newValue: number; 
      notes?: string; 
    }) => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error("Usuário não autenticado");

      // Buscar meta atual para obter valor anterior
      const { data: currentGoal, error: fetchError } = await supabase
        .from("user_goals")
        .select("current_value")
        .eq("id", goalId)
        .single();

      if (fetchError) throw fetchError;

      // Atualizar meta
      const { error: updateError } = await supabase
        .from("user_goals")
        .update({ 
          current_value: newValue,
          status: "em_progresso" 
        })
        .eq("id", goalId);

      if (updateError) throw updateError;

      // Registrar atualização no histórico
      const { error: logError } = await supabase
        .from("goal_updates")
        .insert({
          goal_id: goalId,
          user_id: user.id,
          previous_value: currentGoal.current_value,
          new_value: newValue,
          notes,
        });

      if (logError) throw logError;
    },
    onSuccess: () => {
      toast({
        title: "Progresso atualizado!",
        description: "O progresso da sua meta foi registrado com sucesso.",
      });
      queryClient.invalidateQueries({ queryKey: ["user-goals"] });
    },
    onError: (error: any) => {
      toast({
        title: "Erro ao atualizar progresso",
        description: error.message,
        variant: "destructive",
      });
    },
  });

  // Buscar estatísticas
  const { data: stats } = useQuery({
    queryKey: ["goal-stats"],
    queryFn: async () => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return null;

      const { data, error } = await supabase
        .from("user_goals")
        .select("status, estimated_points")
        .eq("user_id", user.id);

      if (error) throw error;

      const total = data.length;
      const pending = data.filter(g => g.status === 'pendente').length;
      const approved = data.filter(g => g.status === 'aprovada' || g.status === 'em_progresso').length;
      const completed = data.filter(g => g.status === 'concluida').length;
      const totalPoints = data
        .filter(g => g.estimated_points)
        .reduce((sum, g) => sum + (g.estimated_points || 0), 0);

      return { total, pending, approved, completed, totalPoints };
    },
  });

  return {
    goals,
    categories,
    stats,
    isLoading,
    error,
    createGoal: createGoalMutation.mutate,
    isCreating: createGoalMutation.isPending,
    updateProgress: updateProgressMutation.mutate,
    isUpdating: updateProgressMutation.isPending,
  };
};