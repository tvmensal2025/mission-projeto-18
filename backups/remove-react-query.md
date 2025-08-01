# 🔧 Como Remover React Query (se necessário)

## 🎯 **Opção 1: Desabilitar WebSockets (Recomendado)**
✅ **Já aplicado** - Modificamos a configuração do QueryClient para desabilitar otimizações de rede

## 🎯 **Opção 2: Remover React Query Completamente**

### 📋 **Passos**:

1. **Desinstalar dependência**:
```bash
npm uninstall @tanstack/react-query
```

2. **Remover QueryClientProvider do App.tsx**:
```tsx
// Remover estas linhas:
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
const queryClient = new QueryClient({...});
<QueryClientProvider client={queryClient}>
```

3. **Substituir useQuery por useState + useEffect**:
```tsx
// Antes (React Query):
const { data: goals } = useQuery({
  queryKey: ['user-goals'],
  queryFn: fetchGoals
});

// Depois (useState + useEffect):
const [goals, setGoals] = useState([]);
useEffect(() => {
  fetchGoals().then(setGoals);
}, []);
```

4. **Substituir useMutation por funções normais**:
```tsx
// Antes (React Query):
const createGoalMutation = useMutation({
  mutationFn: createGoal,
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['user-goals'] });
  }
});

// Depois (função normal):
const handleCreateGoal = async (goalData) => {
  await createGoal(goalData);
  // Recarregar dados manualmente
  const updatedGoals = await fetchGoals();
  setGoals(updatedGoals);
};
```

## 🎯 **Arquivos Afetados**:
- `src/App.tsx`
- `src/pages/HealthFeedPage.tsx`
- `src/pages/GoalsPage.tsx`
- `src/components/admin/GoalManagement.tsx`
- `src/components/admin/CreateGoalModal.tsx`
- `src/components/goals/CreateGoalModal.tsx`
- `src/components/goals/CreateGoalDialog.tsx`

## ✅ **Status Atual**:
- ✅ WebSockets desabilitados na configuração
- ✅ Código `sharedWebSockets` não deve mais aparecer
- ✅ Performance mantida com cache local 