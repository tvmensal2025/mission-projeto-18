// Script para desabilitar completamente Lovable e todas suas reconexões
(function() {
  'use strict';
  
  // Silenciar todos os logs relacionados
  const originalConsoleLog = console.log;
  const originalConsoleError = console.error;
  const originalConsoleWarn = console.warn;
  
  console.log = function(...args) {
    const message = args.join(' ');
    if (message.includes('lovable') || message.includes('WebSocket') || message.includes('reconnect')) {
      return;
    }
    originalConsoleLog.apply(console, args);
  };
  
  console.error = function(...args) {
    const message = args.join(' ');
    if (message.includes('lovable') || message.includes('WebSocket') || message.includes('reconnect')) {
      return;
    }
    originalConsoleError.apply(console, args);
  };
  
  console.warn = function(...args) {
    const message = args.join(' ');
    if (message.includes('lovable') || message.includes('WebSocket') || message.includes('reconnect')) {
      return;
    }
    originalConsoleWarn.apply(console, args);
  };
  
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
  
  // Desabilitar completamente WebSocket
  const originalWebSocket = window.WebSocket;
  window.WebSocket = function(url, protocols) {
    if (shouldBlockUrl(url) || url.includes('lovable') || url.includes('ws://') || url.includes('wss://')) {
      // Retornar WebSocket falso que nunca conecta
      return {
        readyState: 3, // CLOSED
        url: url,
        protocol: '',
        send: function() {},
        close: function() {},
        addEventListener: function() {},
        removeEventListener: function() {},
        dispatchEvent: function() { return false; },
        onopen: null,
        onclose: null,
        onmessage: null,
        onerror: null
      };
    }
    return new originalWebSocket(url, protocols);
  };

  // Bloquear setInterval e setTimeout para reconexões
  const originalSetInterval = window.setInterval;
  const originalSetTimeout = window.setTimeout;
  
  window.setInterval = function(callback, delay, ...args) {
    const callbackStr = callback.toString();
    if (callbackStr.includes('lovable') || callbackStr.includes('reconnect') || callbackStr.includes('WebSocket')) {
      return 0; // Timer inválido
    }
    return originalSetInterval(callback, delay, ...args);
  };
  
  window.setTimeout = function(callback, delay, ...args) {
    const callbackStr = callback.toString();
    if (callbackStr.includes('lovable') || callbackStr.includes('reconnect') || callbackStr.includes('WebSocket')) {
      return 0; // Timer inválido
    }
    return originalSetTimeout(callback, delay, ...args);
  };
  
  // Interceptar fetch requests para Lovable e scripts externos
  const originalFetch = window.fetch;
  window.fetch = function(url, options) {
    if (shouldBlockUrl(url) || url.includes('facebook.net') || url.includes('pixel') || url.includes('analytics')) {
      return Promise.resolve(new Response('', { status: 404 }));
    }
    return originalFetch(url, options);
  };
  
  // Interceptar XMLHttpRequest para Lovable e scripts externos
  const originalXHROpen = XMLHttpRequest.prototype.open;
  XMLHttpRequest.prototype.open = function(method, url, async, user, password) {
    if (shouldBlockUrl(url) || url.includes('facebook.net') || url.includes('pixel') || url.includes('analytics')) {
      return;
    }
    return originalXHROpen.call(this, method, url, async, user, password);
  };

  // Bloquear criação de novos scripts
  const originalCreateElement = document.createElement;
  document.createElement = function(tagName) {
    const element = originalCreateElement.call(document, tagName);
    if (tagName.toLowerCase() === 'script') {
      const originalSrc = Object.getOwnPropertyDescriptor(HTMLScriptElement.prototype, 'src');
      Object.defineProperty(element, 'src', {
        set: function(value) {
          if (shouldBlockUrl(value) || value.includes('facebook.net') || value.includes('pixel') || value.includes('lovable.js')) {
            return;
          }
          originalSrc.set.call(this, value);
        },
        get: originalSrc.get
      });
    }
    return element;
  };

  // Desabilitar requestAnimationFrame para loops de reconexão
  const originalRAF = window.requestAnimationFrame;
  window.requestAnimationFrame = function(callback) {
    const callbackStr = callback.toString();
    if (callbackStr.includes('lovable') || callbackStr.includes('reconnect')) {
      return 0;
    }
    return originalRAF(callback);
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