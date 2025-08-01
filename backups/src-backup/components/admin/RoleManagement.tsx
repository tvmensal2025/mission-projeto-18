import React, { useState } from 'react';
import { User } from '@supabase/supabase-js';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { useToast } from '@/hooks/use-toast';
import { useAdminMode, UserRole } from '@/hooks/useAdminMode';
import { 
  Shield, 
  User as UserIcon, 
  TestTube, 
  RotateCcw,
  CheckCircle,
  AlertCircle,
  Info
} from 'lucide-react';
import { Alert, AlertDescription } from '@/components/ui/alert';

interface RoleManagementProps {
  user: User;
}

const RoleManagement: React.FC<RoleManagementProps> = ({ user }) => {
  const { userRole, isAdmin, isTestUser, switchRole, loading } = useAdminMode(user);
  const [switching, setSwitching] = useState(false);
  const { toast } = useToast();

  const handleRoleSwitch = async (newRole: UserRole) => {
    if (newRole === userRole) return;
    
    setSwitching(true);
    try {
      const success = await switchRole(newRole);
      
      if (success) {
        toast({
          title: "Role alterado com sucesso!",
          description: `Agora você está como: ${getRoleLabel(newRole)}`,
          variant: "default"
        });
      } else {
        toast({
          title: "Erro ao alterar role",
          description: "Não foi possível alterar o role. Verifique suas permissões.",
          variant: "destructive"
        });
      }
    } catch (error) {
      console.error('Erro ao alterar role:', error);
      toast({
        title: "Erro inesperado",
        description: "Ocorreu um erro inesperado ao alterar o role.",
        variant: "destructive"
      });
    } finally {
      setSwitching(false);
    }
  };

  const getRoleLabel = (role: UserRole): string => {
    switch (role) {
      case 'admin': return 'Administrador';
      case 'user': return 'Usuário Padrão';
      case 'test': return 'Usuário de Teste';
      default: return 'Desconhecido';
    }
  };

  const getRoleIcon = (role: UserRole) => {
    switch (role) {
      case 'admin': return Shield;
      case 'user': return UserIcon;
      case 'test': return TestTube;
      default: return UserIcon;
    }
  };

  const getRoleColor = (role: UserRole): string => {
    switch (role) {
      case 'admin': return 'bg-red-100 text-red-700 border-red-200';
      case 'user': return 'bg-blue-100 text-blue-700 border-blue-200';
      case 'test': return 'bg-yellow-100 text-yellow-700 border-yellow-200';
      default: return 'bg-gray-100 text-gray-700 border-gray-200';
    }
  };

  const getRoleDescription = (role: UserRole): string => {
    switch (role) {
      case 'admin': 
        return 'Acesso completo ao sistema. Pode criar, editar e deletar cursos, gerenciar usuários, acessar relatórios avançados e configurações do sistema.';
      case 'user': 
        return 'Acesso padrão ao sistema. Pode visualizar cursos publicados, acompanhar progresso, criar metas e participar de desafios.';
      case 'test': 
        return 'Acesso limitado para testes. Pode navegar pelo sistema com restrições, ideal para demonstrações e validações.';
      default: 
        return 'Role não reconhecido.';
    }
  };

  if (loading) {
    return (
      <Card>
        <CardContent className="pt-6">
          <div className="flex items-center justify-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
            <span className="ml-2">Carregando informações do usuário...</span>
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-6">
      {/* Status Atual */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Shield className="h-5 w-5" />
            Gerenciamento de Roles
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {/* Role Atual */}
          <div className="flex items-center justify-between p-4 border rounded-lg">
            <div className="flex items-center gap-3">
              {React.createElement(getRoleIcon(userRole), { 
                className: "h-6 w-6 text-muted-foreground" 
              })}
              <div>
                <h3 className="font-semibold">Role Atual</h3>
                <p className="text-sm text-muted-foreground">{user.email}</p>
              </div>
            </div>
            <Badge className={getRoleColor(userRole)}>
              {getRoleLabel(userRole)}
            </Badge>
          </div>

          {/* Descrição do Role Atual */}
          <Alert>
            <Info className="h-4 w-4" />
            <AlertDescription>
              {getRoleDescription(userRole)}
            </AlertDescription>
          </Alert>

          {/* Transições de Role (apenas para admins) */}
          {isAdmin && (
            <div className="space-y-4">
              <h4 className="font-semibold text-sm text-muted-foreground uppercase tracking-wide">
                Alternar Role (Apenas Admins)
              </h4>
              
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                {(['test', 'user', 'admin'] as UserRole[]).map((role) => {
                  const Icon = getRoleIcon(role);
                  const isCurrentRole = role === userRole;
                  
                  return (
                    <Card 
                      key={role}
                      className={`cursor-pointer transition-all ${
                        isCurrentRole 
                          ? 'ring-2 ring-primary bg-primary/5' 
                          : 'hover:shadow-md'
                      }`}
                      onClick={() => !isCurrentRole && !switching && handleRoleSwitch(role)}
                    >
                      <CardContent className="pt-4">
                        <div className="text-center space-y-3">
                          <Icon className={`h-8 w-8 mx-auto ${
                            isCurrentRole ? 'text-primary' : 'text-muted-foreground'
                          }`} />
                          <div>
                            <h3 className="font-medium">{getRoleLabel(role)}</h3>
                            <p className="text-xs text-muted-foreground mt-1">
                              {getRoleDescription(role).substring(0, 60)}...
                            </p>
                          </div>
                          
                          {isCurrentRole ? (
                            <Badge variant="default" className="w-full justify-center">
                              <CheckCircle className="h-3 w-3 mr-1" />
                              Ativo
                            </Badge>
                          ) : (
                            <Button 
                              variant="outline" 
                              size="sm" 
                              className="w-full"
                              disabled={switching}
                              onClick={(e) => {
                                e.stopPropagation();
                                handleRoleSwitch(role);
                              }}
                            >
                              {switching ? (
                                <>
                                  <RotateCcw className="h-3 w-3 mr-1 animate-spin" />
                                  Alterando...
                                </>
                              ) : (
                                <>
                                  <RotateCcw className="h-3 w-3 mr-1" />
                                  Alternar
                                </>
                              )}
                            </Button>
                          )}
                        </div>
                      </CardContent>
                    </Card>
                  );
                })}
              </div>
            </div>
          )}

          {/* Aviso para usuários não-admin */}
          {!isAdmin && (
            <Alert>
              <AlertCircle className="h-4 w-4" />
              <AlertDescription>
                Apenas administradores podem alterar roles. Entre em contato com um admin se precisar de permissões diferentes.
              </AlertDescription>
            </Alert>
          )}
        </CardContent>
      </Card>

      {/* Informações de Segurança */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Shield className="h-5 w-5" />
            Informações de Segurança
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
            <div>
              <h4 className="font-medium">Permissões por Role:</h4>
              <ul className="mt-2 space-y-1 text-muted-foreground">
                <li>• <strong>Test:</strong> Navegação limitada, sem edição</li>
                <li>• <strong>User:</strong> Acesso completo à área do usuário</li>
                <li>• <strong>Admin:</strong> Acesso total ao sistema</li>
              </ul>
            </div>
            
            <div>
              <h4 className="font-medium">Transições Seguras:</h4>
              <ul className="mt-2 space-y-1 text-muted-foreground">
                <li>• Apenas admins podem alterar roles</li>
                <li>• Mudanças são registradas no banco</li>
                <li>• Compatibilidade com sistema antigo</li>
                <li>• Rollback automático em caso de erro</li>
              </ul>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default RoleManagement;