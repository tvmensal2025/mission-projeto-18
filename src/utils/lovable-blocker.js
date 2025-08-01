// Bloqueador agressivo de reconexões Lovable
(function() {
  'use strict';
  
  // Silenciar TODOS os logs
  const originalConsole = {
    log: console.log,
    error: console.error,
    warn: console.warn,
    info: console.info,
    debug: console.debug
  };
  
  ['log', 'error', 'warn', 'info', 'debug'].forEach(method => {
    console[method] = function(...args) {
      const message = args.join(' ').toLowerCase();
      if (message.includes('lovable') || 
          message.includes('websocket') || 
          message.includes('reconnect') || 
          message.includes('connection') ||
          message.includes('ws://') ||
          message.includes('wss://')) {
        return;
      }
      originalConsole[method].apply(console, args);
    };
  });

  // Bloquear WebSocket COMPLETAMENTE
  const fakeWebSocket = function(url, protocols) {
    return {
      readyState: 3, // CLOSED
      url: url || '',
      protocol: '',
      bufferedAmount: 0,
      extensions: '',
      binaryType: 'blob',
      send: () => {},
      close: () => {},
      addEventListener: () => {},
      removeEventListener: () => {},
      dispatchEvent: () => false,
      onopen: null,
      onclose: null,
      onmessage: null,
      onerror: null
    };
  };
  
  fakeWebSocket.CONNECTING = 0;
  fakeWebSocket.OPEN = 1;
  fakeWebSocket.CLOSING = 2;
  fakeWebSocket.CLOSED = 3;
  
  window.WebSocket = fakeWebSocket;

  // Bloquear todos os timers
  const originalSetTimeout = window.setTimeout;
  const originalSetInterval = window.setInterval;
  const originalRAF = window.requestAnimationFrame;
  
  window.setTimeout = function(callback, delay, ...args) {
    try {
      const callbackStr = callback.toString();
      if (callbackStr.includes('lovable') || 
          callbackStr.includes('reconnect') || 
          callbackStr.includes('WebSocket') ||
          callbackStr.includes('connect')) {
        return 0;
      }
    } catch (e) {}
    return originalSetTimeout(callback, delay, ...args);
  };
  
  window.setInterval = function(callback, delay, ...args) {
    try {
      const callbackStr = callback.toString();
      if (callbackStr.includes('lovable') || 
          callbackStr.includes('reconnect') || 
          callbackStr.includes('WebSocket') ||
          callbackStr.includes('connect')) {
        return 0;
      }
    } catch (e) {}
    return originalSetInterval(callback, delay, ...args);
  };
  
  window.requestAnimationFrame = function(callback) {
    try {
      const callbackStr = callback.toString();
      if (callbackStr.includes('lovable') || callbackStr.includes('reconnect')) {
        return 0;
      }
    } catch (e) {}
    return originalRAF(callback);
  };

  // Bloquear fetch e XMLHttpRequest
  const originalFetch = window.fetch;
  window.fetch = function(url, options) {
    if (typeof url === 'string' && (
        url.includes('lovable') || 
        url.includes('facebook.net') || 
        url.includes('pixel') || 
        url.includes('analytics'))) {
      return Promise.resolve(new Response('', { status: 404 }));
    }
    return originalFetch(url, options);
  };
  
  const originalXHROpen = XMLHttpRequest.prototype.open;
  XMLHttpRequest.prototype.open = function(method, url, async, user, password) {
    if (typeof url === 'string' && (
        url.includes('lovable') || 
        url.includes('facebook.net') || 
        url.includes('pixel') || 
        url.includes('analytics'))) {
      return;
    }
    return originalXHROpen.call(this, method, url, async, user, password);
  };

  // Bloquear scripts
  const originalCreateElement = document.createElement;
  document.createElement = function(tagName) {
    const element = originalCreateElement.call(document, tagName);
    if (tagName.toLowerCase() === 'script') {
      const originalSrcDescriptor = Object.getOwnPropertyDescriptor(HTMLScriptElement.prototype, 'src');
      if (originalSrcDescriptor) {
        Object.defineProperty(element, 'src', {
          set: function(value) {
            if (typeof value === 'string' && (
                value.includes('lovable') || 
                value.includes('facebook.net') || 
                value.includes('pixel'))) {
              return;
            }
            originalSrcDescriptor.set.call(this, value);
          },
          get: originalSrcDescriptor.get
        });
      }
    }
    return element;
  };

  // Remover elementos DOM
  const blockedSelectors = [
    '[data-lovable]', '[class*="lovable"]', '[id*="lovable"]',
    'iframe[src*="lovable"]', 'script[src*="lovable"]', 
    'link[href*="lovable"]', 'a[href*="lovable"]',
    '.lovable-badge', '[data-testid*="lovable"]'
  ];
  
  function removeElements() {
    blockedSelectors.forEach(selector => {
      try {
        const elements = document.querySelectorAll(selector);
        elements.forEach(el => el.remove());
      } catch (e) {}
    });
  }
  
  removeElements();
  
  // Observer para elementos novos
  if (document.body) {
    const observer = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutation) {
        if (mutation.type === 'childList') {
          mutation.addedNodes.forEach(function(node) {
            if (node.nodeType === 1 && node.matches) {
              try {
                if (blockedSelectors.some(selector => node.matches(selector))) {
                  node.remove();
                }
              } catch (e) {}
            }
          });
        }
      });
    });
    
    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }

  // Desabilitar qualquer evento de conexão
  window.addEventListener = (function(original) {
    return function(type, listener, options) {
      if (typeof listener === 'function') {
        try {
          const listenerStr = listener.toString();
          if (listenerStr.includes('lovable') || 
              listenerStr.includes('reconnect') || 
              listenerStr.includes('WebSocket')) {
            return;
          }
        } catch (e) {}
      }
      return original.call(this, type, listener, options);
    };
  })(window.addEventListener);

  // Bloquear document.addEventListener também
  document.addEventListener = (function(original) {
    return function(type, listener, options) {
      if (typeof listener === 'function') {
        try {
          const listenerStr = listener.toString();
          if (listenerStr.includes('lovable') || 
              listenerStr.includes('reconnect') || 
              listenerStr.includes('WebSocket')) {
            return;
          }
        } catch (e) {}
      }
      return original.call(this, type, listener, options);
    };
  })(document.addEventListener);

})();