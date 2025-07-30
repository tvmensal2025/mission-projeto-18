import { useState, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/hooks/useAuth';

export const useAnamnesisStatus = () => {
  const { user } = useAuth();
  const [hasCompletedAnamnesis, setHasCompletedAnamnesis] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  const checkAnamnesisStatus = async () => {
    if (!user) {
      setHasCompletedAnamnesis(false);
      setIsLoading(false);
      return;
    }

    try {
      // Temporário - simular até tipos serem atualizados
      console.log('Checking anamnesis status for user:', user.id);
      setHasCompletedAnamnesis(false);
    } catch (error) {
      console.error('Erro ao verificar anamnese:', error);
      setHasCompletedAnamnesis(false);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    checkAnamnesisStatus();
  }, [user]);

  return { hasCompletedAnamnesis, isLoading };
};