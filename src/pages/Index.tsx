import React from 'react';
// import Dashboard from '../components/Dashboard';

const Index = () => {
  console.log('🚀 Index component started');
  
  try {
    // Versão temporária sem Dashboard para debug
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-3xl font-bold mb-4">Instituto Mental Health</h1>
          <p className="text-muted-foreground mb-8">Sistema carregado com sucesso!</p>
          <div className="bg-green-50 border border-green-200 rounded-md p-4 max-w-md">
            <p className="text-green-800 text-sm">
              ✅ Aplicação funcionando. Dashboard temporariamente desabilitado para debug.
            </p>
          </div>
        </div>
      </div>
    );
  } catch (error) {
    console.error('❌ Erro no Index:', error);
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-2xl font-bold mb-4 text-red-600">Erro no Sistema</h1>
          <p className="text-red-500">Houve um problema ao carregar a aplicação.</p>
        </div>
      </div>
    );
  }
};

export default Index;
