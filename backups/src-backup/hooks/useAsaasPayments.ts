import { useState, useCallback } from 'react';
import { asaasClient, CreateCustomerRequest, CreatePaymentRequest, CreateSubscriptionRequest, AsaasCustomer, AsaasPayment, AsaasSubscription } from '@/lib/asaas-client';
import { config } from '@/lib/config';

export interface PaymentStatus {
  isLoading: boolean;
  error: string | null;
  success: boolean;
}

export interface CustomerData {
  name: string;
  email: string;
  phone?: string;
  cpfCnpj?: string;
}

export interface PaymentData {
  value: number;
  description: string;
  billingType: 'BOLETO' | 'CREDIT_CARD' | 'PIX' | 'DEBIT_CARD';
  dueDate: string;
}

export interface SubscriptionData {
  value: number;
  description: string;
  billingType: 'BOLETO' | 'CREDIT_CARD' | 'PIX' | 'DEBIT_CARD';
  cycle: 'WEEKLY' | 'BIWEEKLY' | 'MONTHLY' | 'QUARTERLY' | 'SEMIANNUALLY' | 'YEARLY';
  nextDueDate: string;
}

export function useAsaasPayments() {
  const [status, setStatus] = useState<PaymentStatus>({
    isLoading: false,
    error: null,
    success: false,
  });

  const [currentCustomer, setCurrentCustomer] = useState<AsaasCustomer | null>(null);
  const [currentPayment, setCurrentPayment] = useState<AsaasPayment | null>(null);
  const [currentSubscription, setCurrentSubscription] = useState<AsaasSubscription | null>(null);

  // Criar cliente
  const createCustomer = useCallback(async (customerData: CustomerData): Promise<AsaasCustomer | null> => {
    if (!config.features.enableAsaasPayments) {
      throw new Error('Pagamentos Asaas não estão habilitados');
    }

    setStatus({ isLoading: true, error: null, success: false });

    try {
      const customerRequest: CreateCustomerRequest = {
        name: customerData.name,
        email: customerData.email,
        phone: customerData.phone,
        cpfCnpj: customerData.cpfCnpj,
      };

      const customer = await asaasClient.createCustomer(customerRequest);
      setCurrentCustomer(customer);
      setStatus({ isLoading: false, error: null, success: true });
      return customer;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Erro ao criar cliente';
      setStatus({ isLoading: false, error: errorMessage, success: false });
      return null;
    }
  }, []);

  // Criar pagamento único
  const createPayment = useCallback(async (paymentData: PaymentData): Promise<AsaasPayment | null> => {
    if (!config.features.enableAsaasPayments) {
      throw new Error('Pagamentos Asaas não estão habilitados');
    }

    if (!currentCustomer) {
      throw new Error('Cliente não encontrado. Crie um cliente primeiro.');
    }

    setStatus({ isLoading: true, error: null, success: false });

    try {
      const paymentRequest: CreatePaymentRequest = {
        customer: currentCustomer.id,
        value: paymentData.value,
        billingType: paymentData.billingType,
        dueDate: paymentData.dueDate,
        description: paymentData.description,
      };

      const payment = await asaasClient.createPayment(paymentRequest);
      setCurrentPayment(payment);
      setStatus({ isLoading: false, error: null, success: true });
      return payment;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Erro ao criar pagamento';
      setStatus({ isLoading: false, error: errorMessage, success: false });
      return null;
    }
  }, [currentCustomer]);

  // Criar assinatura
  const createSubscription = useCallback(async (subscriptionData: SubscriptionData): Promise<AsaasSubscription | null> => {
    if (!config.features.enableAsaasPayments) {
      throw new Error('Pagamentos Asaas não estão habilitados');
    }

    if (!currentCustomer) {
      throw new Error('Cliente não encontrado. Crie um cliente primeiro.');
    }

    setStatus({ isLoading: true, error: null, success: false });

    try {
      const subscriptionRequest: CreateSubscriptionRequest = {
        customer: currentCustomer.id,
        value: subscriptionData.value,
        billingType: subscriptionData.billingType,
        cycle: subscriptionData.cycle,
        nextDueDate: subscriptionData.nextDueDate,
        description: subscriptionData.description,
      };

      const subscription = await asaasClient.createSubscription(subscriptionRequest);
      setCurrentSubscription(subscription);
      setStatus({ isLoading: false, error: null, success: true });
      return subscription;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Erro ao criar assinatura';
      setStatus({ isLoading: false, error: errorMessage, success: false });
      return null;
    }
  }, [currentCustomer]);

  // Buscar cliente
  const getCustomer = useCallback(async (customerId: string): Promise<AsaasCustomer | null> => {
    if (!config.features.enableAsaasPayments) {
      throw new Error('Pagamentos Asaas não estão habilitados');
    }

    setStatus({ isLoading: true, error: null, success: false });

    try {
      const customer = await asaasClient.getCustomer(customerId);
      setCurrentCustomer(customer);
      setStatus({ isLoading: false, error: null, success: true });
      return customer;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Erro ao buscar cliente';
      setStatus({ isLoading: false, error: errorMessage, success: false });
      return null;
    }
  }, []);

  // Buscar pagamento
  const getPayment = useCallback(async (paymentId: string): Promise<AsaasPayment | null> => {
    if (!config.features.enableAsaasPayments) {
      throw new Error('Pagamentos Asaas não estão habilitados');
    }

    setStatus({ isLoading: true, error: null, success: false });

    try {
      const payment = await asaasClient.getPayment(paymentId);
      setCurrentPayment(payment);
      setStatus({ isLoading: false, error: null, success: true });
      return payment;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Erro ao buscar pagamento';
      setStatus({ isLoading: false, error: errorMessage, success: false });
      return null;
    }
  }, []);

  // Buscar assinatura
  const getSubscription = useCallback(async (subscriptionId: string): Promise<AsaasSubscription | null> => {
    if (!config.features.enableAsaasPayments) {
      throw new Error('Pagamentos Asaas não estão habilitados');
    }

    setStatus({ isLoading: true, error: null, success: false });

    try {
      const subscription = await asaasClient.getSubscription(subscriptionId);
      setCurrentSubscription(subscription);
      setStatus({ isLoading: false, error: null, success: true });
      return subscription;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Erro ao buscar assinatura';
      setStatus({ isLoading: false, error: errorMessage, success: false });
      return null;
    }
  }, []);

  // Cancelar assinatura
  const cancelSubscription = useCallback(async (subscriptionId: string): Promise<AsaasSubscription | null> => {
    if (!config.features.enableAsaasPayments) {
      throw new Error('Pagamentos Asaas não estão habilitados');
    }

    setStatus({ isLoading: true, error: null, success: false });

    try {
      const subscription = await asaasClient.cancelSubscription(subscriptionId);
      setCurrentSubscription(subscription);
      setStatus({ isLoading: false, error: null, success: true });
      return subscription;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Erro ao cancelar assinatura';
      setStatus({ isLoading: false, error: errorMessage, success: false });
      return null;
    }
  }, []);

  // Limpar status
  const clearStatus = useCallback(() => {
    setStatus({ isLoading: false, error: null, success: false });
  }, []);

  // Limpar dados
  const clearData = useCallback(() => {
    setCurrentCustomer(null);
    setCurrentPayment(null);
    setCurrentSubscription(null);
    clearStatus();
  }, [clearStatus]);

  return {
    // Estado
    status,
    currentCustomer,
    currentPayment,
    currentSubscription,
    
    // Ações
    createCustomer,
    createPayment,
    createSubscription,
    getCustomer,
    getPayment,
    getSubscription,
    cancelSubscription,
    clearStatus,
    clearData,
    
    // Utilitários
    isEnabled: config.features.enableAsaasPayments,
  };
} 