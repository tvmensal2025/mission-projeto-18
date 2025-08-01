// Cliente Supabase para desenvolvimento local
import { createClient } from '@supabase/supabase-js';
import type { Database } from './types';

// Configurações para desenvolvimento local
const SUPABASE_URL = process.env.REACT_APP_SUPABASE_URL || "http://localhost:54321";
const SUPABASE_ANON_KEY = process.env.REACT_APP_SUPABASE_ANON_KEY || "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhscmtveXl3anBja2RvdGltdGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMxNTMwNDcsImV4cCI6MjA2ODcyOTA0N30.kYEtg1hYG2pmcyIeXRs-vgNIVOD76Yu7KPlyFN0vdUI";

export const supabaseDev = createClient<Database>(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    storage: localStorage,
    persistSession: true,
    autoRefreshToken: true,
  },
  db: {
    schema: 'public'
  },
  global: {
    headers: {
      'X-Client-Info': 'supabase-js/2.38.0'
    }
  }
});

// Função para alternar entre ambiente local e remoto
export const getSupabaseClient = () => {
  const isDevelopment = process.env.NODE_ENV === 'development';
  return isDevelopment ? supabaseDev : require('./client').supabase;
}; 