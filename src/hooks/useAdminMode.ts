import { useState, useEffect } from 'react';
import { User } from '@supabase/supabase-js';
import { supabase } from '@/integrations/supabase/client';

export type UserRole = 'test' | 'user' | 'admin';

export const useAdminMode = (user: User | null) => {
  const [userRole, setUserRole] = useState<UserRole>('user');
  const [isAdmin, setIsAdmin] = useState(false);
  const [isTestUser, setIsTestUser] = useState(false);
  const [adminModeEnabled, setAdminModeEnabled] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchUserRole = async () => {
      if (!user) {
        setUserRole('user');
        setIsAdmin(false);
        setIsTestUser(false);
        setAdminModeEnabled(false);
        setLoading(false);
        return;
      }

      try {
        // Verificar role na tabela user_roles (sistema robusto)
        const { data: roleData } = await supabase
          .from('user_roles')
          .select('role')
          .eq('user_id', user.id)
          .eq('is_active', true)
          .order('assigned_at', { ascending: false })
          .limit(1)
          .single();

        let role: UserRole = 'user';
        
        if (roleData?.role) {
          role = roleData.role as UserRole;
        } else {
          // Fallback: verificar na tabela profiles
          const { data: profileData } = await supabase
            .from('profiles')
            .select('role')
            .eq('user_id', user.id)
            .single();
          
          if (profileData?.role && ['test', 'user', 'admin'].includes(profileData.role)) {
            role = profileData.role as UserRole;
          } else {
            // Fallback: verificar por email (compatibilidade)
            const adminEmails = [
              'admin@institutodossonhos.com.br',
              'teste@institutodossonhos.com',
              'contato@rafael-dias.com'
            ];
            
            if (adminEmails.includes(user.email || '') || 
                user.email?.includes('admin') ||
                user.user_metadata?.role === 'admin') {
              role = 'admin';
            }
          }
        }

        setUserRole(role);
        setIsAdmin(role === 'admin');
        setIsTestUser(role === 'test');
        setAdminModeEnabled(role === 'admin');
        
      } catch (error) {
        console.error('Erro ao buscar role do usuário:', error);
        // Em caso de erro, assumir usuário padrão
        setUserRole('user');
        setIsAdmin(false);
        setIsTestUser(false);
        setAdminModeEnabled(false);
      } finally {
        setLoading(false);
      }
    };

    fetchUserRole();
  }, [user]);

  const toggleAdminMode = () => {
    // Apenas admins podem alternar modo admin
    if (isAdmin) {
      setAdminModeEnabled(!adminModeEnabled);
    }
  };

  const switchRole = async (newRole: UserRole) => {
    if (!user || !isAdmin) {
      console.warn('Apenas admins podem alterar roles');
      return false;
    }

    try {
      // Atualizar role na tabela user_roles
      const { error } = await supabase
        .from('user_roles')
        .upsert({
          user_id: user.id,
          role: newRole,
          assigned_at: new Date().toISOString(),
          assigned_by: user.id,
          is_active: true
        });

      if (error) throw error;

      // Atualizar também na tabela profiles para compatibilidade
      await supabase
        .from('profiles')
        .update({ role: newRole })
        .eq('user_id', user.id);

      // Atualizar estado local
      setUserRole(newRole);
      setIsAdmin(newRole === 'admin');
      setIsTestUser(newRole === 'test');
      setAdminModeEnabled(newRole === 'admin');

      return true;
    } catch (error) {
      console.error('Erro ao alterar role:', error);
      return false;
    }
  };

  return {
    userRole,
    isAdmin,
    isTestUser,
    adminModeEnabled,
    loading,
    toggleAdminMode,
    switchRole
  };
};