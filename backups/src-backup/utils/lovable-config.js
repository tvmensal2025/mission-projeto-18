// Configuração para desabilitar Lovable em desenvolvimento
export const LOVABLE_CONFIG = {
  // Desabilitar Lovable apenas em desenvolvimento local
  disabled: import.meta.env.DEV || process.env.NODE_ENV === 'development',
  
  // URLs do Lovable para bloquear
  blockedUrls: [
    'lovable.dev',
    'lovableproject.com',
    'app.lovable.dev'
  ],
  
  // Elementos do Lovable para remover
  blockedSelectors: [
    '[data-lovable]',
    '[class*="lovable"]',
    '[id*="lovable"]',
    'iframe[src*="lovable"]',
    'script[src*="lovable"]',
    'link[href*="lovable"]',
    'a[href*="lovable"]',
    'div[style*="lovable"]',
    '.lovable-badge',
    '[data-testid*="lovable"]'
  ],
  
  // Configurações de WebSocket
  websocket: {
    blocked: true,
    fakeResponse: {
      readyState: 3, // CLOSED
      send: function() {},
      close: function() {},
      addEventListener: function() {},
      removeEventListener: function() {},
      dispatchEvent: function() { return false; }
    }
  }
};

// Função para verificar se uma URL deve ser bloqueada
export function shouldBlockUrl(url) {
  if (!url || typeof url !== 'string') return false;
  return LOVABLE_CONFIG.blockedUrls.some(blockedUrl => 
    url.toLowerCase().includes(blockedUrl.toLowerCase())
  );
}

// Função para verificar se um elemento deve ser removido
export function shouldRemoveElement(element) {
  if (!element || !element.matches) return false;
  return LOVABLE_CONFIG.blockedSelectors.some(selector => 
    element.matches(selector)
  );
}

export default LOVABLE_CONFIG; 