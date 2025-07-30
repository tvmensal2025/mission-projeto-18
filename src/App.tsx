
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
import UserProfile from "./components/UserProfile";
import RankingPage from "./components/RankingPage";
import DashboardPage from "./pages/DashboardPage";
import CompleteDashboardPage from "./pages/CompleteDashboardPage";
import EnhancedDashboardPage from "./pages/EnhancedDashboardPage";
import AdminPage from "./pages/AdminPage";
import { CoursePlatform } from "./components/CoursePlatform";
import MissionSystem from "./components/MissionSystem";
import OnboardingFlow from "./components/OnboardingFlow";
import SystemicAnamnesis from "./components/SystemicAnamnesis";
import { DailyMissions } from "./components/dashboard/DailyMissions";
import { DailyMissionsFinal } from "./components/daily-missions/DailyMissionsFinal";
import CompleteWeighingSystem from "./components/weighing/CompleteWeighingSystem";
import { PersonagemCorporal3D } from "./components/PersonagemCorporal3D";
import HealthFeedPage from "./pages/HealthFeedPage";
import CoursePlatformPage from "./pages/CoursePlatformPage";
import AbundanceWheelPage from "./pages/AbundanceWheelPage";
import CompetencyWheelPage from "./pages/CompetencyWheelPage";
import BodyChartsPage from "./pages/BodyChartsPage";
import FoodAnalysisPage from "./pages/FoodAnalysisPage";
import GalileuChartsPage from "./pages/GalileuChartsPage";
import ChallengeDetailPage from "./pages/ChallengeDetailPage";
import AutoLoginPage from "./pages/AutoLoginPage";
import NotFound from "./pages/NotFound";
import TermsPage from "./pages/TermsPage";
import SessionsPage from "./components/SessionsPage";
import WhatsAppChatPage from "./pages/WhatsAppChatPage";
import GoogleFitTestPage from "./pages/GoogleFitTestPage";
import GoogleFitCallback from "./pages/GoogleFitCallback";
import GoogleFitOAuthPage from "./pages/GoogleFitOAuthPage";
import ScaleTestPage from "./pages/ScaleTestPage";
import UserSessions from "./components/UserSessions";
import { HealthChatBot } from "./components/HealthChatBot";

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000,
      refetchOnWindowFocus: false,
    },
  },
});

function App() {
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
            <Route path="/ranking" element={<RankingPage />} />
            <Route path="/profile" element={<UserProfile />} />
            <Route path="/courses" element={<CoursePlatform />} />
            <Route path="/missions" element={<MissionSystem />} />
            <Route path="/onboarding" element={<OnboardingFlow />} />
            <Route path="/anamnesis" element={<SystemicAnamnesis />} />
            <Route path="/daily-missions" element={<DailyMissions />} />
            <Route path="/daily-missions-final" element={<DailyMissionsFinal />} />
            <Route path="/weighing" element={<CompleteWeighingSystem />} />
            <Route path="/3d-body" element={<PersonagemCorporal3D />} />
            <Route path="/health-feed" element={<HealthFeedPage />} />
            <Route path="/netflix" element={<CoursePlatformPage />} />
            <Route path="/abundance-wheel" element={<AbundanceWheelPage />} />
            <Route path="/competency-wheel" element={<CompetencyWheelPage />} />
            <Route path="/body-charts" element={<BodyChartsPage />} />
            <Route path="/food-analysis" element={<FoodAnalysisPage />} />
            <Route path="/galileu-charts" element={<GalileuChartsPage />} />
            <Route path="/challenge/:challengeId" element={<ChallengeDetailPage />} />
            <Route path="/sessions" element={<SessionsPage />} />
            <Route path="/chat" element={<WhatsAppChatPage />} />
            <Route path="/google-fit-test" element={<GoogleFitTestPage />} />
            <Route path="/google-fit/callback" element={<GoogleFitCallback />} />
            <Route path="/google-fit-oauth" element={<GoogleFitOAuthPage />} />
            <Route path="/scale-test" element={<ScaleTestPage />} />
            <Route path="/user-sessions" element={<UserSessions />} />
            <Route path="/health-chat" element={<HealthChatBot />} />
            
            {/* Dashboard - standalone without layout */}
            <Route path="/dashboard" element={<CompleteDashboardPage />} />
            <Route path="/enhanced-dashboard" element={<EnhancedDashboardPage />} />
            <Route path="/dashboard/progress" element={<MyProgress />} />
            
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
