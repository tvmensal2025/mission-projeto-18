
import React from 'react'
import { createRoot } from 'react-dom/client'
import App from './App.tsx'
// import './index.css' // Temporariamente desabilitado

console.log('🚀 main.tsx iniciado');

const rootElement = document.getElementById("root");
if (!rootElement) {
  console.error('❌ Root element não encontrado');
  throw new Error("Root element not found");
}

console.log('✅ Root element encontrado');

const root = createRoot(rootElement);
console.log('✅ Root criado');

root.render(<App />);
console.log('✅ App renderizado');
