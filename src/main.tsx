
import React, { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App.tsx'
import './index.css'

// Configurar ambiente no body para CSS condicional
document.body.setAttribute('data-env', import.meta.env.DEV ? 'development' : 'production');

// Carregar scripts de desenvolvimento apenas em desenvolvimento
if (import.meta.env.DEV) {
  import('./utils/disable-lovable.js').catch(() => {
    // Script opcional - não quebrar se não existir
  });
}

const rootElement = document.getElementById("root");
if (!rootElement) {
  throw new Error("Root element not found");
}

const root = createRoot(rootElement);
root.render(
  <StrictMode>
    <App />
  </StrictMode>
);
