// Script para desabilitar Lovable e suas conexões WebSocket
(function() {
  'use strict';
  
  // Só executar em desenvolvimento - verificação dupla
  if (process.env.NODE_ENV !== 'development' && !import.meta.env.DEV) {
    console.log('🚀 Ambiente de produção - Lovable habilitado');
    return;
  }
  
  console.log('🔒 Desabilitando Lovable e conexões WebSocket...');
  
  // Configuração
  const LOVABLE_CONFIG = {
    disabled: process.env.NODE_ENV === 'development', // Desabilitar apenas em desenvolvimento
    blockedUrls: ['lovable.dev', 'lovableproject.com', 'app.lovable.dev'],
    blockedSelectors: [
      '[data-lovable]', '[class*="lovable"]', '[id*="lovable"]',
      'iframe[src*="lovable"]', 'script[src*="lovable"]', 'link[href*="lovable"]',
      'a[href*="lovable"]', 'div[style*="lovable"]', '.lovable-badge',
      '[data-testid*="lovable"]'
    ]
  };
  
  // Função para verificar se uma URL deve ser bloqueada
  function shouldBlockUrl(url) {
    if (!url || typeof url !== 'string') return false;
    return LOVABLE_CONFIG.blockedUrls.some(blockedUrl => 
      url.toLowerCase().includes(blockedUrl.toLowerCase())
    );
  }
  
  // Interceptar e bloquear WebSocket connections
  const originalWebSocket = window.WebSocket;
  window.WebSocket = function(url, protocols) {
    if (shouldBlockUrl(url)) {
      console.log('🚫 Bloqueando conexão WebSocket para:', url);
      // Retornar um WebSocket falso que não faz nada
      return {
        readyState: 3, // CLOSED
        send: function() {},
        close: function() {},
        addEventListener: function() {},
        removeEventListener: function() {},
        dispatchEvent: function() { return false; }
      };
    }
    return new originalWebSocket(url, protocols);
  };
  
  // Interceptar fetch requests para Lovable
  const originalFetch = window.fetch;
  window.fetch = function(url, options) {
    if (shouldBlockUrl(url)) {
      console.log('🚫 Bloqueando fetch para:', url);
      return Promise.resolve(new Response('', { status: 404 }));
    }
    return originalFetch(url, options);
  };
  
  // Interceptar XMLHttpRequest para Lovable
  const originalXHROpen = XMLHttpRequest.prototype.open;
  XMLHttpRequest.prototype.open = function(method, url, async, user, password) {
    if (shouldBlockUrl(url)) {
      console.log('🚫 Bloqueando XMLHttpRequest para:', url);
      // Não fazer nada
      return;
    }
    return originalXHROpen.call(this, method, url, async, user, password);
  };
  
  // Remover elementos Lovable do DOM
  function removeLovableElements() {
    LOVABLE_CONFIG.blockedSelectors.forEach(selector => {
      const elements = document.querySelectorAll(selector);
      elements.forEach(el => {
        console.log('🗑️ Removendo elemento Lovable:', el);
        el.remove();
      });
    });
  }
  
  // Executar imediatamente
  removeLovableElements();
  
  // Observar mudanças no DOM para remover novos elementos Lovable
  const observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
      if (mutation.type === 'childList') {
        mutation.addedNodes.forEach(function(node) {
          if (node.nodeType === 1) { // Element node
            if (node.matches && LOVABLE_CONFIG.blockedSelectors.some(selector => 
              node.matches(selector)
            )) {
              console.log('🗑️ Removendo novo elemento Lovable:', node);
              node.remove();
            }
          }
        });
      }
    });
  });
  
  // Iniciar observação
  observer.observe(document.body, {
    childList: true,
    subtree: true
  });
  
  console.log('✅ Lovable desabilitado com sucesso!');
})(); 