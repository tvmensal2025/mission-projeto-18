# Integração com Asaas

Este documento explica como configurar e usar a integração com a plataforma de pagamentos Asaas no projeto.

## Configuração

### 1. Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto com as seguintes variáveis:

```env
# Asaas Configuration
VITE_ASAAS_API_KEY=your_production_api_key_here
VITE_ASAAS_BASE_URL=https://api.asaas.com/v3
VITE_ASAAS_WEBHOOK_URL=https://your-domain.com/api/asaas-webhook
VITE_ENABLE_ASAAS_PAYMENTS=true
```

### 2. Obter Chaves da API

1. Acesse o [painel da Asaas](https://www.asaas.com/)
2. Crie uma conta ou faça login
3. Vá para **Configurações > API**
4. Copie a chave de API de produção

### 3. Configurar Webhook (Opcional)

Para receber notificações de pagamentos:

1. No painel da Asaas, vá para **Configurações > Webhook**
2. Adicione a URL do seu webhook
3. Configure os eventos que deseja receber (pagamento confirmado, assinatura criada, etc.)

## Funcionalidades

### Cliente Asaas (`src/lib/asaas-client.ts`)

- **Criar Cliente**: `createCustomer(data)`
- **Buscar Cliente**: `getCustomer(id)`
- **Criar Pagamento**: `createPayment(data)`
- **Buscar Pagamento**: `getPayment(id)`
- **Criar Assinatura**: `createSubscription(data)`
- **Buscar Assinatura**: `getSubscription(id)`
- **Cancelar Assinatura**: `cancelSubscription(id)`

### Hook de Pagamentos (`src/hooks/useAsaasPayments.ts`)

O hook `useAsaasPayments` fornece:

- **Estado**: `status`, `currentCustomer`, `currentPayment`, `currentSubscription`
- **Ações**: `createCustomer`, `createPayment`, `createSubscription`, etc.
- **Utilitários**: `isEnabled`, `clearData`

### Componente de Gestão (`src/components/payments/PaymentManager.tsx`)

Interface completa para:

- Criar e gerenciar clientes
- Criar pagamentos únicos
- Criar e cancelar assinaturas
- Consultar dados existentes
- Visualizar status das operações

## Uso

### 1. No Painel Administrativo

Acesse `/admin` e clique na seção "Pagamentos" para usar a interface de gestão.

### 2. Programaticamente

```typescript
import { useAsaasPayments } from '@/hooks/useAsaasPayments';

function MyComponent() {
  const {
    createCustomer,
    createPayment,
    status,
    currentCustomer
  } = useAsaasPayments();

  const handleCreateCustomer = async () => {
    const customer = await createCustomer({
      name: 'João Silva',
      email: 'joao@exemplo.com',
      phone: '(11) 99999-9999',
      cpfCnpj: '123.456.789-00'
    });
    
    if (customer) {
      console.log('Cliente criado:', customer.id);
    }
  };

  const handleCreatePayment = async () => {
    const payment = await createPayment({
      value: 99.90,
      description: 'Curso de Saúde',
      billingType: 'PIX',
      dueDate: '2024-01-15'
    });
    
    if (payment) {
      console.log('Pagamento criado:', payment.id);
    }
  };

  return (
    <div>
      <button onClick={handleCreateCustomer}>Criar Cliente</button>
      <button onClick={handleCreatePayment}>Criar Pagamento</button>
      {status.isLoading && <p>Carregando...</p>}
      {status.error && <p>Erro: {status.error}</p>}
    </div>
  );
}
```

## Tipos de Pagamento Suportados

- **PIX**: Pagamento instantâneo
- **BOLETO**: Boleto bancário
- **CREDIT_CARD**: Cartão de crédito
- **DEBIT_CARD**: Cartão de débito

## Ciclos de Assinatura

- **WEEKLY**: Semanal
- **BIWEEKLY**: Quinzenal
- **MONTHLY**: Mensal
- **QUARTERLY**: Trimestral
- **SEMIANNUALLY**: Semestral
- **YEARLY**: Anual

## Status de Pagamentos

- **PENDING**: Pendente
- **CONFIRMED**: Confirmado
- **OVERDUE**: Vencido
- **REFUNDED**: Reembolsado
- **RECEIVED**: Recebido
- **RECEIVED_IN_CASH**: Recebido em dinheiro

## Status de Assinaturas

- **ACTIVE**: Ativa
- **INACTIVE**: Inativa
- **OVERDUE**: Vencida
- **CANCELLED**: Cancelada

## Ambiente de Produção

A integração está configurada para usar apenas o ambiente de produção da Asaas.

## Segurança

- Nunca commite as chaves de API no repositório
- Use variáveis de ambiente para todas as configurações sensíveis
- Valide sempre os dados de entrada
- Implemente rate limiting se necessário

## Troubleshooting

### Erro: "Pagamentos Asaas não estão habilitados"

Verifique se `VITE_ENABLE_ASAAS_PAYMENTS=true` está configurado.

### Erro: "API Key inválida"

Verifique se as chaves de API estão corretas e se está usando o ambiente correto (sandbox vs produção).

### Erro: "Cliente não encontrado"

Crie um cliente antes de tentar criar pagamentos ou assinaturas.

## Próximos Passos

1. Implementar webhook para notificações
2. Adicionar validação de dados
3. Implementar retry automático
4. Adicionar logs detalhados
5. Criar testes automatizados 