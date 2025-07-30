
import React from "react";

// Versão ultra-simplificada para debug
function App() {
  console.log('🚀 App ultra-simplificado iniciado');
  
  try {
    return (
      <div className="min-h-screen bg-white">
        <div className="p-8 text-center">
          <h1 className="text-2xl font-bold text-black">Sistema Funcionando</h1>
          <p className="text-gray-600 mt-4">App carregado sem erros</p>
          <div className="mt-6 p-4 bg-green-100 border border-green-300 rounded">
            <p className="text-green-800">✅ Versão debug - sem providers ou routers</p>
          </div>
        </div>
      </div>
    );
  } catch (error) {
    console.error('❌ Erro crítico no App:', error);
    return (
      <div className="min-h-screen bg-red-50 flex items-center justify-center">
        <div className="text-center p-8">
          <h1 className="text-xl font-bold text-red-600">Erro Fatal</h1>
          <p className="text-red-500">Falha na aplicação</p>
        </div>
      </div>
    );
  }
}

export default App;
