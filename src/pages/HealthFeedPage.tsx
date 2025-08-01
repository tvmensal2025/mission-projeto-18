import React, { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Badge } from '@/components/ui/badge';
import { useToast } from '@/hooks/use-toast';
import { RankingSidebar } from '@/components/health-feed/RankingSidebar';
import { FeedPostCard } from '@/components/health-feed/FeedPostCard';
import { CreatePost } from '@/components/health-feed/CreatePost';
import { 
  Sparkles, 
  TrendingUp, 
  Users, 
  Clock,
  RefreshCw,
  Filter,
  Search
} from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { defaultPosts } from '@/data/health-feed-data';
import { getUserAvatar } from '@/lib/avatar-utils';

export function HealthFeedPage() {
  const [feedFilter, setFeedFilter] = useState<'todos' | 'seguindo' | 'populares'>('todos');
  const [postTypeFilter, setPostTypeFilter] = useState<string>('todos');
  const [searchQuery, setSearchQuery] = useState('');
  const { toast } = useToast();
  const queryClient = useQueryClient();

  // Dados do usuário atual
  const { data: currentUser } = useQuery({
    queryKey: ['current-user-profile'],
    queryFn: async () => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Não autenticado');

      // Buscar dados do perfil
      const { data: userProfile } = await supabase
        .from('profiles')
        .select('full_name, avatar_url')
        .eq('id', user.id)
        .single();

      if (userProfile) {
        return {
          id: user.id,
          name: userProfile.full_name || 'Usuário',
          avatar: userProfile.avatar_url || '',
          level: 'Iniciante',
          points: 0,
          badges: []
        };
      } else {
        return {
          id: user.id,
          name: 'Usuário',
          avatar: '',
          level: 'Iniciante',
          points: 0,
          badges: []
        };
      }
    }
  });

  // Buscar posts do feed
  const { data: feedPosts, isLoading: loadingPosts, refetch: refetchPosts } = useQuery({
    queryKey: ['health-feed-posts', feedFilter, postTypeFilter, searchQuery],
    queryFn: async () => {
      const { data: posts, error } = await supabase
        .from('health_feed_posts')
        .select(`
          *,
          profiles(full_name, avatar_url)
        `)
        .eq('is_public', true)
        .order('created_at', { ascending: false })
        .limit(20);

      if (error) throw error;
      return posts || [];


    },
    enabled: !!currentUser
  });

  // Criar novo post
  const createPostMutation = useMutation({
    mutationFn: async (postData: any) => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Não autenticado');

      const { error } = await supabase.from('health_feed_posts').insert({
        user_id: user.id,
        content: postData.content,
        post_type: postData.postType,
        media_urls: postData.mediaUrls,
        achievements_data: postData.achievementsData,
        progress_data: postData.progressData,
        visibility: postData.visibility,
        location: postData.location,
        tags: postData.tags,
        is_story: postData.isStory
      });

      if (error) throw error;
    },
    onSuccess: () => {
      toast({
        title: "Post publicado!",
        description: "Seu post foi compartilhado com sucesso."
      });
      queryClient.invalidateQueries({ queryKey: ['health-feed-posts'] });
    },
    onError: (error: any) => {
      toast({
        title: "Erro ao publicar",
        description: error.message,
        variant: "destructive"
      });
    }
  });

  // Reagir a post
  const reactionMutation = useMutation({
    mutationFn: async ({ postId, reactionType }: { postId: string, reactionType: string }) => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Não autenticado');

      // Implementar reações quando as tabelas forem criadas
      // Por enquanto, apenas simular
      console.log('Reação:', { postId, reactionType, userId: user.id });
      
      return { success: true };
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['health-feed-posts'] });
    }
  });

  // Comentar em post
  const commentMutation = useMutation({
    mutationFn: async ({ postId, content }: { postId, content: string }) => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Não autenticado');

      // Implementar comentários quando as tabelas forem criadas
      console.log('Comentário:', { postId, content, userId: user.id });
      
      return { success: true };
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['health-feed-posts'] });
    }
  });

  const handleReaction = (postId: string, reactionType: string) => {
    reactionMutation.mutate({ postId, reactionType });
  };

  const handleComment = (postId: string, content: string) => {
    commentMutation.mutate({ postId, content });
  };

  const handleShare = (postId: string) => {
    // Implementar compartilhamento
    toast({
      title: "Em breve!",
      description: "Funcionalidade de compartilhamento será implementada em breve."
    });
  };

  const handleCreatePost = (postData: any) => {
    createPostMutation.mutate(postData);
  };

  if (!currentUser) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <Card className="p-8 max-w-md mx-auto">
          <CardContent className="text-center space-y-4">
            <Users className="w-16 h-16 mx-auto text-muted-foreground" />
            <h3 className="text-xl font-semibold">Login necessário</h3>
            <p className="text-muted-foreground">
              Faça login para acessar a comunidade de saúde e compartilhar sua jornada.
            </p>
            <Button onClick={() => window.location.href = '/auth'}>
              Fazer Login
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <div className="container mx-auto px-3 md:px-4 py-4 md:py-6">
        {/* Banner da Comunidade - Compacto no mobile */}
        <div className="relative mb-4 md:mb-6 rounded-lg md:rounded-xl overflow-hidden bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 p-4 md:p-6 text-white">
          <div className="absolute inset-0 bg-black/20"></div>
          <div className="relative flex items-center justify-between">
            <div className="space-y-2 md:space-y-3">
              <div className="flex items-center gap-2 md:gap-3">
                <div className="p-1.5 md:p-2 bg-white/20 rounded-lg backdrop-blur-sm">
                  <Users className="w-4 h-4 md:w-6 md:h-6" />
                </div>
                <div>
                  <h1 className="text-xl md:text-2xl font-bold">Comunidade dos Sonhos</h1>
                  <p className="text-blue-100 text-xs md:text-sm">Compartilhe sua jornada e realize seus sonhos</p>
                </div>
              </div>
            </div>
            
            {/* Perfil do Usuário - Otimizado para mobile */}
            <div className="flex items-center gap-2 md:gap-3">
              <div className="text-center hidden md:block">
                <p className="font-semibold text-sm">{currentUser?.name}</p>
                <div className="flex items-center gap-1 text-xs text-blue-100">
                  <span>{currentUser?.level}</span>
                  <span>•</span>
                  <span>{currentUser?.points} pts</span>
                </div>
              </div>
              <div className="relative">
                <div className="w-10 h-10 md:w-12 md:h-12 rounded-full overflow-hidden border-2 border-white/30 bg-white/10 backdrop-blur-sm flex items-center justify-center">
                  {(() => {
                    const avatar = getUserAvatar(currentUser?.avatar || null, currentUser?.name || 'User');
                    
                    if (avatar.type === 'photo') {
                      return (
                        <img 
                          src={avatar.value} 
                          alt={currentUser.name}
                          className="w-full h-full object-cover"
                        />
                      );
                    } else if (avatar.type === 'emoji') {
                      return (
                        <div className="text-sm md:text-lg">
                          {avatar.value}
                        </div>
                      );
                    } else {
                      return (
                        <img 
                          src={avatar.value} 
                          alt={currentUser.name}
                          className="w-full h-full object-cover"
                        />
                      );
                    }
                  })()}
                </div>
                <div className="absolute -bottom-1 -right-1 w-3 h-3 md:w-4 md:h-4 bg-success rounded-full border-2 border-white flex items-center justify-center">
                  <div className="w-1 h-1 md:w-1.5 md:h-1.5 bg-white rounded-full"></div>
                </div>
              </div>
            </div>
          </div>
          
          {/* Info do usuário no mobile */}
          <div className="md:hidden mt-3 pt-3 border-t border-white/20">
            <div className="flex items-center justify-between text-xs">
              <span className="text-blue-100">Nível: {currentUser?.level}</span>
              <span className="text-blue-100">{currentUser?.points} pontos</span>
            </div>
          </div>
        </div>

        {/* Layout Principal - Melhor organização */}
        <div className="grid grid-cols-1 xl:grid-cols-4 gap-4 md:gap-6">
          {/* Feed Principal */}
          <div className="xl:col-span-3 space-y-4 md:space-y-6">
            {/* Header do Feed - Compacto */}
            <Card>
              <CardHeader className="pb-3 md:pb-4">
                <div className="flex items-center justify-between">
                  <div>
                    <CardTitle className="flex items-center gap-2 text-lg md:text-xl">
                      <Sparkles className="w-5 h-5 md:w-6 md:h-6 text-primary" />
                      HealthFeed
                    </CardTitle>
                    <p className="text-muted-foreground text-sm md:text-base">
                      Compartilhe sua jornada de saúde
                    </p>
                  </div>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => refetchPosts()}
                    disabled={loadingPosts}
                  >
                    <RefreshCw className={`w-4 h-4 ${loadingPosts ? 'animate-spin' : ''}`} />
                  </Button>
                </div>
              </CardHeader>
            </Card>

            {/* Filtros - Layout melhorado */}
            <Card>
              <CardContent className="p-4 md:p-6">
                <div className="space-y-3 md:space-y-4">
                  {/* Busca */}
                  <div className="flex gap-2 md:gap-3">
                    <div className="flex-1">
                      <Input
                        placeholder="Buscar posts..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="w-full"
                      />
                    </div>
                    <Button variant="outline" size="icon" className="shrink-0">
                      <Search className="w-4 h-4" />
                    </Button>
                  </div>

                  {/* Filtros - Responsivo */}
                  <div className="flex flex-col md:flex-row gap-2 md:gap-3">
                    <Select value={feedFilter} onValueChange={(value: any) => setFeedFilter(value)}>
                      <SelectTrigger className="w-full md:w-40">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="todos">
                          <div className="flex items-center gap-2">
                            <TrendingUp className="w-4 h-4" />
                            Todos
                          </div>
                        </SelectItem>
                        <SelectItem value="seguindo">
                          <div className="flex items-center gap-2">
                            <Users className="w-4 h-4" />
                            Seguindo
                          </div>
                        </SelectItem>
                        <SelectItem value="populares">
                          <div className="flex items-center gap-2">
                            <Sparkles className="w-4 h-4" />
                            Populares
                          </div>
                        </SelectItem>
                      </SelectContent>
                    </Select>

                    <Select value={postTypeFilter} onValueChange={setPostTypeFilter}>
                      <SelectTrigger className="w-full md:w-48">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="todos">Todos os tipos</SelectItem>
                        <SelectItem value="conquista">Conquistas</SelectItem>
                        <SelectItem value="progresso">Progresso</SelectItem>
                        <SelectItem value="meta">Metas</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Criar Post */}
            <CreatePost
              onPost={handleCreatePost}
              currentUser={currentUser}
            />

            {/* Banner de demonstração */}
            {(!feedPosts || feedPosts.length === 0) && defaultPosts.length > 0 && (
              <Card className="border-amber-200 bg-amber-50 dark:bg-amber-950/20 dark:border-amber-800">
                <CardContent className="py-4">
                  <div className="flex items-center gap-2 text-amber-700 dark:text-amber-300">
                    <Sparkles className="w-5 h-5" />
                    <p className="text-sm font-medium">
                      Mostrando posts de demonstração. Crie seu primeiro post para começar!
                    </p>
                  </div>
                </CardContent>
              </Card>
            )}

            {/* Lista de Posts */}
            <div className="space-y-4 md:space-y-6">
              {loadingPosts ? (
                <div className="space-y-4 md:space-y-6">
                  {[1, 2, 3].map(i => (
                    <Card key={i}>
                      <CardContent className="p-4 md:p-6">
                        <div className="animate-pulse space-y-4">
                          <div className="flex items-center gap-3">
                            <div className="w-8 h-8 md:w-10 md:h-10 bg-muted rounded-full"></div>
                            <div className="space-y-2">
                              <div className="w-24 md:w-32 h-3 md:h-4 bg-muted rounded"></div>
                              <div className="w-20 md:w-24 h-2 md:h-3 bg-muted rounded"></div>
                            </div>
                          </div>
                          <div className="w-full h-16 md:h-20 bg-muted rounded"></div>
                          <div className="w-full h-32 md:h-40 bg-muted rounded"></div>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              ) : (feedPosts && feedPosts.length > 0) || defaultPosts.length > 0 ? (
                (feedPosts && feedPosts.length > 0 ? feedPosts : defaultPosts).map((post) => (
                  <FeedPostCard
                    key={post.id}
                    post={post}
                    onReaction={handleReaction}
                    onComment={handleComment}
                    onShare={handleShare}
                  />
                ))
              ) : (
                <Card>
                  <CardContent className="py-8 md:py-12 text-center">
                    <Sparkles className="w-10 h-10 md:w-12 md:h-12 text-muted-foreground mx-auto mb-4" />
                    <h3 className="text-lg font-semibold mb-2">Nenhum post encontrado</h3>
                    <p className="text-muted-foreground mb-4">
                      Seja o primeiro a compartilhar sua jornada de saúde!
                    </p>
                    <Button onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}>
                      Criar primeiro post
                    </Button>
                  </CardContent>
                </Card>
              )}
            </div>
          </div>

          {/* Sidebar de Ranking - Desktop */}
          <div className="hidden xl:block xl:col-span-1">
            <div className="sticky top-4">
              <RankingSidebar currentUserId={currentUser.id} />
            </div>
          </div>
        </div>

        {/* Ranking Mobile - Melhor apresentação */}
        <div className="xl:hidden mt-6 md:mt-8">
          <div className="bg-gradient-to-r from-primary/10 to-secondary/10 rounded-lg p-4 md:p-6">
            <div className="flex items-center gap-2 mb-4">
              <div className="p-2 bg-primary/20 rounded-lg">
                <Users className="w-5 h-5 text-primary" />
              </div>
              <h2 className="text-xl font-bold">Comunidade</h2>
            </div>
            <RankingSidebar currentUserId={currentUser.id} />
          </div>
        </div>
      </div>
    </div>
  );
}

export default HealthFeedPage;
