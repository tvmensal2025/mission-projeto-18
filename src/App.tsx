
// Versão super básica sem nenhuma dependência externa
function App() {
  console.log('🚀 App básico iniciado');
  
  return (
    <div style={{ 
      minHeight: '100vh', 
      display: 'flex', 
      alignItems: 'center', 
      justifyContent: 'center',
      backgroundColor: '#f0f0f0',
      fontFamily: 'Arial, sans-serif'
    }}>
      <div style={{ textAlign: 'center', padding: '20px' }}>
        <h1 style={{ color: '#333', fontSize: '24px', marginBottom: '10px' }}>
          Sistema Funcionando!
        </h1>
        <p style={{ color: '#666', fontSize: '16px' }}>
          Versão ultra-básica sem dependências
        </p>
        <div style={{ 
          marginTop: '20px', 
          padding: '10px', 
          backgroundColor: '#e8f5e8', 
          border: '1px solid #4caf50',
          borderRadius: '4px',
          color: '#2e7d32'
        }}>
          ✅ React funcionando perfeitamente
        </div>
      </div>
    </div>
  );
}

export default App;
