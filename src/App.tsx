
import { Routes, Route, Navigate } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import Index from "./pages/Index";
import AuthPage from "./pages/AuthPage";
import HomePage from "./pages/HomePage";
import InstitutoHomePage from "./pages/InstitutoHomePage";
import NewHomePage from "./pages/NewHomePage";
import LandingPage from "./pages/LandingPage";
import GoalsPage from "./pages/GoalsPage";
import ProgressPage from "./pages/ProgressPage";
import { UserProfile } from "./components/UserProfile";
import RankingPage from "./components/RankingPage";
import DashboardPage from "./pages/DashboardPage";
import CompleteDashboardPage from "./pages/CompleteDashboardPage";
import EnhancedDashboardPage from "./pages/EnhancedDashboardPage";
import AdminPage from "./pages/AdminPage";
import { CoursePlatform } from "./components/CoursePlatform";
import MissionSystem from "./components/MissionSystem";
import OnboardingFlow from "./components/OnboardingFlow";
import SystemicAnamnesis from "./components/SystemicAnamnesis";
import DailyMissions from "./components/dashboard/DailyMissions";
import { DailyMissionsFinal } from "./components/daily-missions/DailyMissionsFinal";
import CompleteWeighingSystem from "./components/weighing/CompleteWeighingSystem";
import PersonagemCorporal3D from "./components/PersonagemCorporal3D";
import HealthFeedPage from "./pages/HealthFeedPage";
import AutoLoginPage from "./pages/AutoLoginPage";
import NotFound from "./pages/NotFound";
import TermsPage from "./pages/TermsPage";
import WhatsAppChatPage from "./pages/WhatsAppChatPage";
import GoogleFitTestPage from "./pages/GoogleFitTestPage";
import GoogleFitOAuthPage from "./pages/GoogleFitOAuthPage";
import ScaleTestPage from "./pages/ScaleTestPage";
import { HealthChatBot } from "./components/HealthChatBot";

// Simple fallback component for missing pages
const SimplePage = ({ title }: { title: string }) => (
  <div className="min-h-screen bg-background flex items-center justify-center">
    <div className="text-center">
      <h1 className="text-2xl font-bold mb-4">{title}</h1>
      <p className="text-muted-foreground">Esta página está sendo carregada...</p>
    </div>
  </div>
);

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000,
      refetchOnWindowFocus: false,
    },
  },
});

function App() {
  console.log('🚀 App component started');
  
  return (
    <QueryClientProvider client={queryClient}>
      <TooltipProvider>
        <div className="min-h-screen bg-background text-foreground">
          <Routes>
            <Route path="/" element={<Index />} />
            <Route path="/instituto" element={<InstitutoHomePage />} />
            <Route path="/instituto-home" element={<InstitutoHomePage />} />
            <Route path="/home" element={<HomePage />} />
            <Route path="/new-home" element={<NewHomePage />} />
            <Route path="/landing" element={<LandingPage />} />
            <Route path="/auth" element={<AuthPage />} />
            <Route path="/auto-login" element={<AutoLoginPage />} />
            <Route path="/terms" element={<TermsPage />} />
            <Route path="/goals" element={<GoalsPage />} />
            <Route path="/progress" element={<ProgressPage />} />
            <Route path="/ranking" element={<SimplePage title="Ranking" />} />
            <Route path="/profile" element={<SimplePage title="Perfil" />} />
            <Route path="/courses" element={<CoursePlatform viewMode="courses" />} />
            <Route path="/missions" element={<MissionSystem />} />
            <Route path="/onboarding" element={<OnboardingFlow onComplete={() => {}} />} />
            <Route path="/anamnesis" element={<SystemicAnamnesis />} />
            <Route path="/daily-missions" element={<SimplePage title="Missões Diárias" />} />
            <Route path="/daily-missions-final" element={<SimplePage title="Missões Finais" />} />
            <Route path="/weighing" element={<CompleteWeighingSystem />} />
            <Route path="/3d-body" element={<PersonagemCorporal3D genero="feminino" />} />
            <Route path="/health-feed" element={<HealthFeedPage />} />
            <Route path="/netflix" element={<SimplePage title="Netflix" />} />
            <Route path="/abundance-wheel" element={<SimplePage title="Roda da Abundância" />} />
            <Route path="/competency-wheel" element={<SimplePage title="Roda de Competências" />} />
            <Route path="/body-charts" element={<SimplePage title="Gráficos Corporais" />} />
            <Route path="/food-analysis" element={<SimplePage title="Análise de Alimentos" />} />
            <Route path="/galileu-charts" element={<SimplePage title="Gráficos Galileu" />} />
            <Route path="/challenge/:challengeId" element={<SimplePage title="Desafio" />} />
            <Route path="/sessions" element={<SimplePage title="Sessões" />} />
            <Route path="/chat" element={<WhatsAppChatPage />} />
            <Route path="/google-fit-test" element={<GoogleFitTestPage />} />
            <Route path="/google-fit/callback" element={<SimplePage title="Google Fit Callback" />} />
            <Route path="/google-fit-oauth" element={<GoogleFitOAuthPage />} />
            <Route path="/scale-test" element={<ScaleTestPage />} />
            <Route path="/user-sessions" element={<SimplePage title="Sessões do Usuário" />} />
            <Route path="/health-chat" element={<HealthChatBot />} />
            
            {/* Dashboard - standalone without layout */}
            <Route path="/dashboard" element={<CompleteDashboardPage />} />
            <Route path="/enhanced-dashboard" element={<EnhancedDashboardPage />} />
            <Route path="/dashboard/progress" element={<SimplePage title="Progresso" />} />
            
            {/* Admin - standalone without layout */}
            <Route path="/admin" element={<AdminPage />} />
            <Route path="/admin/*" element={<AdminPage />} />
            
            {/* 404 - Must be last */}
            <Route path="*" element={<NotFound />} />
          </Routes>
        </div>
        <Toaster />
        <Sonner />
      </TooltipProvider>
    </QueryClientProvider>
  );
}

export default App;
