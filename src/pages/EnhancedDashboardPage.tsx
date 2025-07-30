
import React, { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { User } from "@supabase/supabase-js";
import { useNavigate } from "react-router-dom";
import { useToast } from "@/hooks/use-toast";

// Importar componentes de forma dinâmica para capturar erros
const EnhancedDashboardPage = () => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();
  const { toast } = useToast();

  console.log('🚀 EnhancedDashboardPage: Componente iniciado');

  useEffect(() => {
    console.log('🔄 EnhancedDashboardPage: useEffect executado');
    
    // Get initial session
    supabase.auth.getSession().then(({ data: { session }, error }) => {
      console.log('🔐 Session obtida:', { session, error });
      
      if (error) {
        console.error('❌ Erro na sessão:', error);
        setError(`Erro de autenticação: ${error.message}`);
        setLoading(false);
        return;
      }

      setUser(session?.user ?? null);
      setLoading(false);
      
      if (!session) {
        console.log('❌ Sem sessão, redirecionando para auth');
        navigate("/auth");
      } else {
        console.log('✅ Usuário autenticado:', session.user.email);
      }
    }).catch((err) => {
      console.error('❌ Erro crítico na autenticação:', err);
      setError(`Erro crítico: ${err.message}`);
      setLoading(false);
    });

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (event, session) => {
        console.log('🔄 Auth state changed:', { event, session });
        setUser(session?.user ?? null);
        if (!session && event !== 'SIGNED_OUT') {
          navigate("/auth");
        }
      }
    );

    return () => subscription.unsubscribe();
  }, [navigate]);

  // Loading state
  if (loading) {
    console.log('⏳ Mostrando loading...');
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-muted-foreground">Carregando dashboard...</p>
        </div>
      </div>
    );
  }

  // Error state
  if (error) {
    console.log('❌ Mostrando erro:', error);
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center max-w-md mx-auto p-6">
          <div className="text-red-500 mb-4">❌</div>
          <h2 className="text-lg font-semibold mb-2">Erro no Dashboard</h2>
          <p className="text-muted-foreground mb-4">{error}</p>
          <button 
            onClick={() => window.location.reload()} 
            className="bg-primary text-primary-foreground px-4 py-2 rounded-md hover:bg-primary/90"
          >
            Tentar Novamente
          </button>
        </div>
      </div>
    );
  }

  // Not authenticated
  if (!user) {
    console.log('❌ Usuário não autenticado, redirecionando...');
    return null; // Will redirect
  }

  console.log('✅ Renderizando dashboard para usuário:', user.email);

  try {
    console.log('🔄 Tentando renderizar dashboard simples primeiro...');
    
    // Versão temporária sem lazy loading para debug
    return (
      <div className="min-h-screen bg-background">
        <div className="container mx-auto px-4 py-8">
          <div className="bg-card p-6 rounded-lg border">
            <h1 className="text-2xl font-bold mb-4">Dashboard Gamificado</h1>
            <p className="text-muted-foreground mb-4">
              Olá {user.email}! Dashboard está carregando...
            </p>
            <div className="bg-blue-50 border border-blue-200 rounded-md p-4">
              <p className="text-blue-800 text-sm">
                🚀 Dashboard simplificado funcionando. Pronto para adicionar componentes.
              </p>
            </div>
          </div>
        </div>
      </div>
    );
  } catch (componentError) {
    console.error('❌ Erro ao carregar componente:', componentError);
    
    // Fallback para versão simplificada
    return (
      <div className="min-h-screen bg-background">
        <div className="container mx-auto px-4 py-8">
          <div className="bg-card p-6 rounded-lg border">
            <h1 className="text-2xl font-bold mb-4">Dashboard Simplificado</h1>
            <p className="text-muted-foreground mb-4">
              Olá {user.email}! Houve um problema ao carregar o dashboard completo.
            </p>
            <div className="bg-yellow-50 border border-yellow-200 rounded-md p-4">
              <p className="text-yellow-800 text-sm">
                ⚠️ Erro ao carregar componentes avançados. 
                Usando versão simplificada temporariamente.
              </p>
            </div>
          </div>
        </div>
      </div>
    );
  }
};

export default EnhancedDashboardPage;
