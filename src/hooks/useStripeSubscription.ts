import { useState, useEffect, useCallback } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { useToast } from '@/hooks/use-toast';
import { safeInvokeEdgeFunction } from '@/utils/edgeFunctions';

export interface SubscriptionStatus {
  subscribed: boolean;
  subscription_tier?: string;
  subscription_end?: string;
  isLoading: boolean;
  error?: string;
}

export function useStripeSubscription() {
  const { user } = useAuth();
  const [status, setStatus] = useState<SubscriptionStatus>({
    subscribed: false,
    isLoading: true,
  });
  const { toast } = useToast();

  // Check subscription status with error handling
  const checkSubscription = useCallback(async () => {
    try {
      setStatus(prev => ({ ...prev, isLoading: true, error: undefined }));
      
      const response = await safeInvokeEdgeFunction('check-subscription');
      
      if (!response.success) {
        console.error('Subscription check failed:', response.error);
        setStatus({
          subscribed: false,
          isLoading: false,
          error: response.error
        });
        return;
      }

      const data = response.data;
      setStatus({
        subscribed: data.subscribed || false,
        subscription_tier: data.subscription_tier,
        subscription_end: data.subscription_end,
        isLoading: false,
      });
    } catch (error) {
      console.error('Error checking subscription:', error);
      setStatus({
        subscribed: false,
        isLoading: false,
        error: error instanceof Error ? error.message : 'Failed to check subscription',
      });
    }
  }, []);

  // Create checkout session with error handling
  const createCheckout = useCallback(async (planId: string) => {
    try {
      setStatus(prev => ({ ...prev, isLoading: true }));
      
      const response = await safeInvokeEdgeFunction('create-checkout', {
        body: { planId },
      });
      
      if (!response.success) {
        throw new Error(response.error || 'Failed to create checkout');
      }
      
      if (response.data?.url) {
        window.open(response.data.url, '_blank');
      }
    } catch (error) {
      console.error('Error creating checkout:', error);
      toast({
        title: "Erro",
        description: error instanceof Error ? error.message : "Erro ao processar pagamento",
        variant: "destructive",
      });
    } finally {
      setStatus(prev => ({ ...prev, isLoading: false }));
    }
  }, [toast]);

  // Manage subscription (customer portal) with error handling
  const manageSubscription = useCallback(async () => {
    try {
      const response = await safeInvokeEdgeFunction('customer-portal');
      
      if (!response.success) {
        throw new Error(response.error || 'Failed to open portal');
      }
      
      if (response.data?.url) {
        window.open(response.data.url, '_blank');
      }
    } catch (error) {
      console.error('Error opening customer portal:', error);
      toast({
        title: "Erro",
        description: error instanceof Error ? error.message : "Erro ao abrir portal",
        variant: "destructive",
      });
    }
  }, [toast]);

  useEffect(() => {
    if (user) {
      checkSubscription();
    } else {
      setStatus({
        subscribed: false,
        isLoading: false,
      });
    }
  }, [user, checkSubscription]);

  return {
    status,
    checkSubscription,
    createCheckout,
    manageSubscription,
  };
}