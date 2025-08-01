import { useState, useEffect } from 'react';
import { User, Session } from '@supabase/supabase-js';
import { supabase } from '@/integrations/supabase/client';

interface AuthState {
  user: User | null;
  session: Session | null;
  loading: boolean;
}

let authListeners: Array<(state: AuthState) => void> = [];
let currentAuthState: AuthState = {
  user: null,
  session: null,
  loading: true
};

// Singleton para gerenciar auth state
let authInitialized = false;

const initializeAuth = () => {
  if (authInitialized) return;
  authInitialized = true;

  // Get initial session
  supabase.auth.getSession().then(({ data: { session } }) => {
    currentAuthState = {
      user: session?.user ?? null,
      session,
      loading: false
    };
    authListeners.forEach(listener => listener(currentAuthState));
  });

  // Listen for auth changes - ONLY ONE LISTENER
  supabase.auth.onAuthStateChange((event, session) => {
    currentAuthState = {
      user: session?.user ?? null,
      session,
      loading: false
    };
    authListeners.forEach(listener => listener(currentAuthState));
  });
};

export const useAuth = () => {
  const [authState, setAuthState] = useState<AuthState>(currentAuthState);

  useEffect(() => {
    initializeAuth();

    // Add this component's listener
    authListeners.push(setAuthState);

    // Cleanup
    return () => {
      authListeners = authListeners.filter(listener => listener !== setAuthState);
    };
  }, []);

  return authState;
};