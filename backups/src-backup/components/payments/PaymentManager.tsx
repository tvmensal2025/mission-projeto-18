import React, { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Loader2, CreditCard, Receipt, Calendar, User, CheckCircle, XCircle } from 'lucide-react';
import { useAsaasPayments, CustomerData, PaymentData, SubscriptionData } from '@/hooks/useAsaasPayments';

export function PaymentManager() {
  const {
    status,
    currentCustomer,
    currentPayment,
    currentSubscription,
    createCustomer,
    createPayment,
    createSubscription,
    getCustomer,
    getPayment,
    getSubscription,
    cancelSubscription,
    clearStatus,
    clearData,
    isEnabled,
  } = useAsaasPayments();

  const [customerData, setCustomerData] = useState<CustomerData>({
    name: '',
    email: '',
    phone: '',
    cpfCnpj: '',
  });

  const [paymentData, setPaymentData] = useState<PaymentData>({
    value: 0,
    description: '',
    billingType: 'PIX',
    dueDate: new Date().toISOString().split('T')[0],
  });

  const [subscriptionData, setSubscriptionData] = useState<SubscriptionData>({
    value: 0,
    description: '',
    billingType: 'PIX',
    cycle: 'MONTHLY',
    nextDueDate: new Date().toISOString().split('T')[0],
  });

  const [customerId, setCustomerId] = useState('');
  const [paymentId, setPaymentId] = useState('');
  const [subscriptionId, setSubscriptionId] = useState('');

  const handleCreateCustomer = async () => {
    if (!customerData.name || !customerData.email) {
      alert('Nome e email são obrigatórios');
      return;
    }

    const customer = await createCustomer(customerData);
    if (customer) {
      alert(`Cliente criado com sucesso! ID: ${customer.id}`);
    }
  };

  const handleCreatePayment = async () => {
    if (!currentCustomer) {
      alert('Crie um cliente primeiro');
      return;
    }

    if (!paymentData.value || !paymentData.description) {
      alert('Valor e descrição são obrigatórios');
      return;
    }

    const payment = await createPayment(paymentData);
    if (payment) {
      alert(`Pagamento criado com sucesso! ID: ${payment.id}`);
    }
  };

  const handleCreateSubscription = async () => {
    if (!currentCustomer) {
      alert('Crie um cliente primeiro');
      return;
    }

    if (!subscriptionData.value || !subscriptionData.description) {
      alert('Valor e descrição são obrigatórios');
      return;
    }

    const subscription = await createSubscription(subscriptionData);
    if (subscription) {
      alert(`Assinatura criada com sucesso! ID: ${subscription.id}`);
    }
  };

  const handleGetCustomer = async () => {
    if (!customerId) {
      alert('Digite o ID do cliente');
      return;
    }

    await getCustomer(customerId);
  };

  const handleGetPayment = async () => {
    if (!paymentId) {
      alert('Digite o ID do pagamento');
      return;
    }

    await getPayment(paymentId);
  };

  const handleGetSubscription = async () => {
    if (!subscriptionId) {
      alert('Digite o ID da assinatura');
      return;
    }

    await getSubscription(subscriptionId);
  };

  const handleCancelSubscription = async () => {
    if (!subscriptionId) {
      alert('Digite o ID da assinatura');
      return;
    }

    const subscription = await cancelSubscription(subscriptionId);
    if (subscription) {
      alert('Assinatura cancelada com sucesso!');
    }
  };

  if (!isEnabled) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Pagamentos Asaas</CardTitle>
          <CardDescription>Integração com pagamentos não está habilitada</CardDescription>
        </CardHeader>
        <CardContent>
          <Alert>
            <XCircle className="h-4 w-4" />
            <AlertDescription>
              Para habilitar os pagamentos, configure a variável de ambiente VITE_ENABLE_ASAAS_PAYMENTS=true
            </AlertDescription>
          </Alert>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-6">
      {/* Status */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <CreditCard className="h-5 w-5" />
            Status da Integração
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center gap-2">
            <Badge variant="default">
              Produção
            </Badge>
            <Badge variant={status.isLoading ? "secondary" : status.success ? "default" : "destructive"}>
              {status.isLoading ? "Carregando..." : status.success ? "Sucesso" : "Erro"}
            </Badge>
          </div>
          
          {status.error && (
            <Alert variant="destructive">
              <XCircle className="h-4 w-4" />
              <AlertDescription>{status.error}</AlertDescription>
            </Alert>
          )}
          
          {status.success && (
            <Alert>
              <CheckCircle className="h-4 w-4" />
              <AlertDescription>Operação realizada com sucesso!</AlertDescription>
            </Alert>
          )}
        </CardContent>
      </Card>

      {/* Criar Cliente */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <User className="h-5 w-5" />
            Criar Cliente
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label htmlFor="name">Nome</Label>
              <Input
                id="name"
                value={customerData.name}
                onChange={(e) => setCustomerData({ ...customerData, name: e.target.value })}
                placeholder="Nome completo"
              />
            </div>
            <div>
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                value={customerData.email}
                onChange={(e) => setCustomerData({ ...customerData, email: e.target.value })}
                placeholder="email@exemplo.com"
              />
            </div>
            <div>
              <Label htmlFor="phone">Telefone</Label>
              <Input
                id="phone"
                value={customerData.phone}
                onChange={(e) => setCustomerData({ ...customerData, phone: e.target.value })}
                placeholder="(11) 99999-9999"
              />
            </div>
            <div>
              <Label htmlFor="cpfCnpj">CPF/CNPJ</Label>
              <Input
                id="cpfCnpj"
                value={customerData.cpfCnpj}
                onChange={(e) => setCustomerData({ ...customerData, cpfCnpj: e.target.value })}
                placeholder="123.456.789-00"
              />
            </div>
          </div>
          
          <Button onClick={handleCreateCustomer} disabled={status.isLoading}>
            {status.isLoading ? <Loader2 className="h-4 w-4 animate-spin" /> : "Criar Cliente"}
          </Button>
        </CardContent>
      </Card>

      {/* Criar Pagamento */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Receipt className="h-5 w-5" />
            Criar Pagamento
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label htmlFor="paymentValue">Valor (R$)</Label>
              <Input
                id="paymentValue"
                type="number"
                step="0.01"
                value={paymentData.value}
                onChange={(e) => setPaymentData({ ...paymentData, value: parseFloat(e.target.value) || 0 })}
                placeholder="0.00"
              />
            </div>
            <div>
              <Label htmlFor="paymentBillingType">Forma de Pagamento</Label>
              <Select
                value={paymentData.billingType}
                onValueChange={(value: any) => setPaymentData({ ...paymentData, billingType: value })}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="PIX">PIX</SelectItem>
                  <SelectItem value="BOLETO">Boleto</SelectItem>
                  <SelectItem value="CREDIT_CARD">Cartão de Crédito</SelectItem>
                  <SelectItem value="DEBIT_CARD">Cartão de Débito</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div>
              <Label htmlFor="paymentDescription">Descrição</Label>
              <Input
                id="paymentDescription"
                value={paymentData.description}
                onChange={(e) => setPaymentData({ ...paymentData, description: e.target.value })}
                placeholder="Descrição do pagamento"
              />
            </div>
            <div>
              <Label htmlFor="paymentDueDate">Data de Vencimento</Label>
              <Input
                id="paymentDueDate"
                type="date"
                value={paymentData.dueDate}
                onChange={(e) => setPaymentData({ ...paymentData, dueDate: e.target.value })}
              />
            </div>
          </div>
          
          <Button onClick={handleCreatePayment} disabled={status.isLoading || !currentCustomer}>
            {status.isLoading ? <Loader2 className="h-4 w-4 animate-spin" /> : "Criar Pagamento"}
          </Button>
        </CardContent>
      </Card>

      {/* Criar Assinatura */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Calendar className="h-5 w-5" />
            Criar Assinatura
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label htmlFor="subscriptionValue">Valor (R$)</Label>
              <Input
                id="subscriptionValue"
                type="number"
                step="0.01"
                value={subscriptionData.value}
                onChange={(e) => setSubscriptionData({ ...subscriptionData, value: parseFloat(e.target.value) || 0 })}
                placeholder="0.00"
              />
            </div>
            <div>
              <Label htmlFor="subscriptionBillingType">Forma de Pagamento</Label>
              <Select
                value={subscriptionData.billingType}
                onValueChange={(value: any) => setSubscriptionData({ ...subscriptionData, billingType: value })}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="PIX">PIX</SelectItem>
                  <SelectItem value="BOLETO">Boleto</SelectItem>
                  <SelectItem value="CREDIT_CARD">Cartão de Crédito</SelectItem>
                  <SelectItem value="DEBIT_CARD">Cartão de Débito</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div>
              <Label htmlFor="subscriptionCycle">Ciclo</Label>
              <Select
                value={subscriptionData.cycle}
                onValueChange={(value: any) => setSubscriptionData({ ...subscriptionData, cycle: value })}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="WEEKLY">Semanal</SelectItem>
                  <SelectItem value="BIWEEKLY">Quinzenal</SelectItem>
                  <SelectItem value="MONTHLY">Mensal</SelectItem>
                  <SelectItem value="QUARTERLY">Trimestral</SelectItem>
                  <SelectItem value="SEMIANNUALLY">Semestral</SelectItem>
                  <SelectItem value="YEARLY">Anual</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div>
              <Label htmlFor="subscriptionDescription">Descrição</Label>
              <Input
                id="subscriptionDescription"
                value={subscriptionData.description}
                onChange={(e) => setSubscriptionData({ ...subscriptionData, description: e.target.value })}
                placeholder="Descrição da assinatura"
              />
            </div>
            <div>
              <Label htmlFor="subscriptionNextDueDate">Próximo Vencimento</Label>
              <Input
                id="subscriptionNextDueDate"
                type="date"
                value={subscriptionData.nextDueDate}
                onChange={(e) => setSubscriptionData({ ...subscriptionData, nextDueDate: e.target.value })}
              />
            </div>
          </div>
          
          <Button onClick={handleCreateSubscription} disabled={status.isLoading || !currentCustomer}>
            {status.isLoading ? <Loader2 className="h-4 w-4 animate-spin" /> : "Criar Assinatura"}
          </Button>
        </CardContent>
      </Card>

      {/* Consultas */}
      <Card>
        <CardHeader>
          <CardTitle>Consultas</CardTitle>
          <CardDescription>Buscar clientes, pagamentos e assinaturas</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-3 gap-4">
            <div>
              <Label htmlFor="customerId">ID do Cliente</Label>
              <Input
                id="customerId"
                value={customerId}
                onChange={(e) => setCustomerId(e.target.value)}
                placeholder="cus_000000000001"
              />
              <Button onClick={handleGetCustomer} disabled={status.isLoading} className="mt-2 w-full">
                Buscar Cliente
              </Button>
            </div>
            <div>
              <Label htmlFor="paymentId">ID do Pagamento</Label>
              <Input
                id="paymentId"
                value={paymentId}
                onChange={(e) => setPaymentId(e.target.value)}
                placeholder="pay_000000000001"
              />
              <Button onClick={handleGetPayment} disabled={status.isLoading} className="mt-2 w-full">
                Buscar Pagamento
              </Button>
            </div>
            <div>
              <Label htmlFor="subscriptionId">ID da Assinatura</Label>
              <Input
                id="subscriptionId"
                value={subscriptionId}
                onChange={(e) => setSubscriptionId(e.target.value)}
                placeholder="sub_000000000001"
              />
              <Button onClick={handleGetSubscription} disabled={status.isLoading} className="mt-2 w-full">
                Buscar Assinatura
              </Button>
            </div>
          </div>
          
          <Button onClick={handleCancelSubscription} disabled={status.isLoading} variant="destructive">
            Cancelar Assinatura
          </Button>
        </CardContent>
      </Card>

      {/* Dados Atuais */}
      {(currentCustomer || currentPayment || currentSubscription) && (
        <Card>
          <CardHeader>
            <CardTitle>Dados Atuais</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {currentCustomer && (
              <div className="p-4 border rounded-lg">
                <h4 className="font-semibold mb-2">Cliente Atual</h4>
                <p><strong>ID:</strong> {currentCustomer.id}</p>
                <p><strong>Nome:</strong> {currentCustomer.name}</p>
                <p><strong>Email:</strong> {currentCustomer.email}</p>
                {currentCustomer.phone && <p><strong>Telefone:</strong> {currentCustomer.phone}</p>}
                {currentCustomer.cpfCnpj && <p><strong>CPF/CNPJ:</strong> {currentCustomer.cpfCnpj}</p>}
              </div>
            )}
            
            {currentPayment && (
              <div className="p-4 border rounded-lg">
                <h4 className="font-semibold mb-2">Pagamento Atual</h4>
                <p><strong>ID:</strong> {currentPayment.id}</p>
                <p><strong>Valor:</strong> R$ {currentPayment.value.toFixed(2)}</p>
                <p><strong>Status:</strong> {currentPayment.status}</p>
                <p><strong>Forma:</strong> {currentPayment.billingType}</p>
                {currentPayment.description && <p><strong>Descrição:</strong> {currentPayment.description}</p>}
              </div>
            )}
            
            {currentSubscription && (
              <div className="p-4 border rounded-lg">
                <h4 className="font-semibold mb-2">Assinatura Atual</h4>
                <p><strong>ID:</strong> {currentSubscription.id}</p>
                <p><strong>Valor:</strong> R$ {currentSubscription.value.toFixed(2)}</p>
                <p><strong>Status:</strong> {currentSubscription.status}</p>
                <p><strong>Ciclo:</strong> {currentSubscription.cycle}</p>
                {currentSubscription.description && <p><strong>Descrição:</strong> {currentSubscription.description}</p>}
              </div>
            )}
            
            <Button onClick={clearData} variant="outline">
              Limpar Dados
            </Button>
          </CardContent>
        </Card>
      )}
    </div>
  );
} 