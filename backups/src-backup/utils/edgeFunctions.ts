import { supabase } from '@/integrations/supabase/client';

export interface EdgeFunctionResponse<T = any> {
  data: T | null;
  error: string | null;
  success: boolean;
}

export const safeInvokeEdgeFunction = async <T = any>(
  functionName: string,
  options?: { body?: any; headers?: Record<string, string> }
): Promise<EdgeFunctionResponse<T>> => {
  try {
    console.log(`[Edge Function] Invoking: ${functionName}`, options?.body);
    
    const { data, error } = await supabase.functions.invoke(functionName, options);
    
    if (error) {
      console.error(`[Edge Function Error] ${functionName}:`, error);
      return {
        data: null,
        error: error.message || 'Edge function failed',
        success: false
      };
    }
    
    console.log(`[Edge Function Success] ${functionName}:`, data);
    return {
      data,
      error: null,
      success: true
    };
  } catch (err: any) {
    console.error(`[Edge Function Exception] ${functionName}:`, err);
    return {
      data: null,
      error: err.message || 'Network error occurred',
      success: false
    };
  }
};