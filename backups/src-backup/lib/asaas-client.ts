import { config } from './config';

// Tipos para a API da Asaas
export interface AsaasCustomer {
  id: string;
  name: string;
  email: string;
  phone?: string;
  mobilePhone?: string;
  address?: string;
  addressNumber?: string;
  complement?: string;
  province?: string;
  postalCode?: string;
  cpfCnpj?: string;
  personType?: 'FISICA' | 'JURIDICA';
  deleted?: boolean;
  additionalEmails?: string;
  externalReference?: string;
  notificationDisabled?: boolean;
  observations?: string;
}

export interface AsaasPayment {
  id: string;
  customer: string;
  subscription?: string;
  installment?: string;
  installmentNumber?: number;
  installmentDescription?: string;
  paymentLink?: string;
  dueDate: string;
  value: number;
  netValue: number;
  originalValue?: number;
  interestValue?: number;
  description?: string;
  billingType: 'BOLETO' | 'CREDIT_CARD' | 'PIX' | 'DEBIT_CARD' | 'TRANSFER' | 'DEPOSIT' | 'WITHDRAWAL';
  status: 'PENDING' | 'CONFIRMED' | 'OVERDUE' | 'REFUNDED' | 'RECEIVED' | 'RECEIVED_IN_CASH' | 'CHARGEBACK_REQUESTED' | 'CHARGEBACK_DISPUTE' | 'AWAITING_CHARGEBACK_REVERSAL' | 'DUNNING_REQUESTED' | 'DUNNING_RECEIVED' | 'AWAITING_RISK_ANALYSIS';
  pixTransaction?: string;
  confirmedDate?: string;
  paymentDate?: string;
  clientPaymentDate?: string;
  invoiceUrl?: string;
  bankSlipUrl?: string;
  transactionReceiptUrl?: string;
  discount?: {
    value: number;
    dueDateLimitDays: number;
    type: 'FIXED' | 'PERCENTAGE';
  };
  interest?: {
    value: number;
  };
  fine?: {
    value: number;
  };
  postalService?: boolean;
  split?: Array<{
    walletId: string;
    fixedValue?: number;
    percentualValue?: number;
    totalFixedValue?: number;
    totalPercentualValue?: number;
  }>;
}

export interface AsaasSubscription {
  id: string;
  customer: string;
  value: number;
  nextDueDate: string;
  cycle: 'WEEKLY' | 'BIWEEKLY' | 'MONTHLY' | 'QUARTERLY' | 'SEMIANNUALLY' | 'YEARLY';
  description?: string;
  status: 'ACTIVE' | 'INACTIVE' | 'OVERDUE' | 'CANCELLED';
  billingType: 'BOLETO' | 'CREDIT_CARD' | 'PIX' | 'DEBIT_CARD';
  endDate?: string;
  maxPayments?: number;
  fine?: {
    value: number;
  };
  interest?: {
    value: number;
  };
  discount?: {
    value: number;
    dueDateLimitDays: number;
    type: 'FIXED' | 'PERCENTAGE';
  };
}

export interface CreateCustomerRequest {
  name: string;
  email: string;
  phone?: string;
  mobilePhone?: string;
  cpfCnpj?: string;
  postalCode?: string;
  address?: string;
  addressNumber?: string;
  complement?: string;
  province?: string;
  externalReference?: string;
  notificationDisabled?: boolean;
  observations?: string;
}

export interface CreatePaymentRequest {
  customer: string;
  billingType: 'BOLETO' | 'CREDIT_CARD' | 'PIX' | 'DEBIT_CARD' | 'TRANSFER' | 'DEPOSIT' | 'WITHDRAWAL';
  value: number;
  dueDate: string;
  description?: string;
  externalReference?: string;
  installmentCount?: number;
  installmentValue?: number;
  discount?: {
    value: number;
    dueDateLimitDays: number;
    type: 'FIXED' | 'PERCENTAGE';
  };
  interest?: {
    value: number;
  };
  fine?: {
    value: number;
  };
  postalService?: boolean;
  split?: Array<{
    walletId: string;
    fixedValue?: number;
    percentualValue?: number;
  }>;
}

export interface CreateSubscriptionRequest {
  customer: string;
  billingType: 'BOLETO' | 'CREDIT_CARD' | 'PIX' | 'DEBIT_CARD';
  value: number;
  nextDueDate: string;
  cycle: 'WEEKLY' | 'BIWEEKLY' | 'MONTHLY' | 'QUARTERLY' | 'SEMIANNUALLY' | 'YEARLY';
  description?: string;
  endDate?: string;
  maxPayments?: number;
  fine?: {
    value: number;
  };
  interest?: {
    value: number;
  };
  discount?: {
    value: number;
    dueDateLimitDays: number;
    type: 'FIXED' | 'PERCENTAGE';
  };
}

// Cliente da Asaas
export class AsaasClient {
  private apiKey: string;
  private baseUrl: string;

  constructor() {
    this.apiKey = config.asaas.apiKey;
    this.baseUrl = config.asaas.baseUrl;
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const url = `${this.baseUrl}${endpoint}`;
    
    const response = await fetch(url, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        'access_token': this.apiKey,
        ...options.headers,
      },
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(`Asaas API Error: ${response.status} - ${errorData.message || response.statusText}`);
    }

    return response.json();
  }

  // Criar cliente
  async createCustomer(data: CreateCustomerRequest): Promise<AsaasCustomer> {
    return this.request<AsaasCustomer>('/customers', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  // Buscar cliente por ID
  async getCustomer(id: string): Promise<AsaasCustomer> {
    return this.request<AsaasCustomer>(`/customers/${id}`);
  }

  // Criar pagamento
  async createPayment(data: CreatePaymentRequest): Promise<AsaasPayment> {
    return this.request<AsaasPayment>('/payments', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  // Buscar pagamento por ID
  async getPayment(id: string): Promise<AsaasPayment> {
    return this.request<AsaasPayment>(`/payments/${id}`);
  }

  // Criar assinatura
  async createSubscription(data: CreateSubscriptionRequest): Promise<AsaasSubscription> {
    return this.request<AsaasSubscription>('/subscriptions', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  // Buscar assinatura por ID
  async getSubscription(id: string): Promise<AsaasSubscription> {
    return this.request<AsaasSubscription>(`/subscriptions/${id}`);
  }

  // Cancelar assinatura
  async cancelSubscription(id: string): Promise<AsaasSubscription> {
    return this.request<AsaasSubscription>(`/subscriptions/${id}/cancel`, {
      method: 'POST',
    });
  }

  // Listar pagamentos de um cliente
  async getCustomerPayments(customerId: string, params?: {
    limit?: number;
    offset?: number;
    status?: string;
  }): Promise<{ data: AsaasPayment[]; totalCount: number; limit: number; offset: number }> {
    const queryParams = new URLSearchParams();
    if (params?.limit) queryParams.append('limit', params.limit.toString());
    if (params?.offset) queryParams.append('offset', params.offset.toString());
    if (params?.status) queryParams.append('status', params.status);

    return this.request<{ data: AsaasPayment[]; totalCount: number; limit: number; offset: number }>(
      `/customers/${customerId}/payments?${queryParams.toString()}`
    );
  }

  // Listar assinaturas de um cliente
  async getCustomerSubscriptions(customerId: string, params?: {
    limit?: number;
    offset?: number;
    status?: string;
  }): Promise<{ data: AsaasSubscription[]; totalCount: number; limit: number; offset: number }> {
    const queryParams = new URLSearchParams();
    if (params?.limit) queryParams.append('limit', params.limit.toString());
    if (params?.offset) queryParams.append('offset', params.offset.toString());
    if (params?.status) queryParams.append('status', params.status);

    return this.request<{ data: AsaasSubscription[]; totalCount: number; limit: number; offset: number }>(
      `/customers/${customerId}/subscriptions?${queryParams.toString()}`
    );
  }
}

// Instância singleton do cliente
export const asaasClient = new AsaasClient(); 