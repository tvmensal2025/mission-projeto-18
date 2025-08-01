export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instanciate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "12.2.3 (519615d)"
  }
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          operationName?: string
          query?: string
          variables?: Json
          extensions?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      assessments: {
        Row: {
          challenges_faced: string | null
          created_at: string
          goal_achievement_rating: number | null
          id: string
          improvements_noted: string | null
          next_week_goals: string | null
          satisfaction_rating: number | null
          user_id: string
          week_start_date: string
          weight_change: number | null
        }
        Insert: {
          challenges_faced?: string | null
          created_at?: string
          goal_achievement_rating?: number | null
          id?: string
          improvements_noted?: string | null
          next_week_goals?: string | null
          satisfaction_rating?: number | null
          user_id: string
          week_start_date: string
          weight_change?: number | null
        }
        Update: {
          challenges_faced?: string | null
          created_at?: string
          goal_achievement_rating?: number | null
          id?: string
          improvements_noted?: string | null
          next_week_goals?: string | null
          satisfaction_rating?: number | null
          user_id?: string
          week_start_date?: string
          weight_change?: number | null
        }
        Relationships: []
      }
      content_access: {
        Row: {
          access_granted: boolean | null
          content_id: string
          content_type: string
          created_at: string
          expires_at: string | null
          granted_at: string | null
          id: string
          user_id: string | null
        }
        Insert: {
          access_granted?: boolean | null
          content_id: string
          content_type: string
          created_at?: string
          expires_at?: string | null
          granted_at?: string | null
          id?: string
          user_id?: string | null
        }
        Update: {
          access_granted?: boolean | null
          content_id?: string
          content_type?: string
          created_at?: string
          expires_at?: string | null
          granted_at?: string | null
          id?: string
          user_id?: string | null
        }
        Relationships: []
      }
      course_modules: {
        Row: {
          course_id: string
          created_at: string
          description: string | null
          id: string
          order_index: number
          title: string
        }
        Insert: {
          course_id: string
          created_at?: string
          description?: string | null
          id?: string
          order_index: number
          title: string
        }
        Update: {
          course_id?: string
          created_at?: string
          description?: string | null
          id?: string
          order_index?: number
          title?: string
        }
        Relationships: [
          {
            foreignKeyName: "course_modules_course_id_fkey"
            columns: ["course_id"]
            isOneToOne: false
            referencedRelation: "courses"
            referencedColumns: ["id"]
          },
        ]
      }
      courses: {
        Row: {
          category: string | null
          created_at: string
          description: string | null
          difficulty_level: string | null
          duration_minutes: number | null
          id: string
          instructor_name: string | null
          is_premium: boolean | null
          is_published: boolean | null
          price: number | null
          thumbnail_url: string | null
          title: string
          updated_at: string
        }
        Insert: {
          category?: string | null
          created_at?: string
          description?: string | null
          difficulty_level?: string | null
          duration_minutes?: number | null
          id?: string
          instructor_name?: string | null
          is_premium?: boolean | null
          is_published?: boolean | null
          price?: number | null
          thumbnail_url?: string | null
          title: string
          updated_at?: string
        }
        Update: {
          category?: string | null
          created_at?: string
          description?: string | null
          difficulty_level?: string | null
          duration_minutes?: number | null
          id?: string
          instructor_name?: string | null
          is_premium?: boolean | null
          is_published?: boolean | null
          price?: number | null
          thumbnail_url?: string | null
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      daily_mission_sessions: {
        Row: {
          completed_sections: string[] | null
          created_at: string | null
          date: string
          id: string
          is_completed: boolean | null
          streak_days: number | null
          total_points: number | null
          updated_at: string | null
          user_id: string | null
        }
        Insert: {
          completed_sections?: string[] | null
          created_at?: string | null
          date?: string
          id?: string
          is_completed?: boolean | null
          streak_days?: number | null
          total_points?: number | null
          updated_at?: string | null
          user_id?: string | null
        }
        Update: {
          completed_sections?: string[] | null
          created_at?: string | null
          date?: string
          id?: string
          is_completed?: boolean | null
          streak_days?: number | null
          total_points?: number | null
          updated_at?: string | null
          user_id?: string | null
        }
        Relationships: []
      }
      daily_responses: {
        Row: {
          answer: string
          created_at: string | null
          date: string
          id: string
          points_earned: number | null
          question_id: string
          section: string
          text_response: string | null
          user_id: string | null
        }
        Insert: {
          answer: string
          created_at?: string | null
          date?: string
          id?: string
          points_earned?: number | null
          question_id: string
          section: string
          text_response?: string | null
          user_id?: string | null
        }
        Update: {
          answer?: string
          created_at?: string | null
          date?: string
          id?: string
          points_earned?: number | null
          question_id?: string
          section?: string
          text_response?: string | null
          user_id?: string | null
        }
        Relationships: []
      }
      device_sync_log: {
        Row: {
          device_type: string
          error_message: string | null
          id: string
          integration_name: string
          last_sync_date: string | null
          records_synced: number | null
          sync_status: string | null
          sync_type: string
          synced_at: string | null
          user_id: string | null
        }
        Insert: {
          device_type: string
          error_message?: string | null
          id?: string
          integration_name: string
          last_sync_date?: string | null
          records_synced?: number | null
          sync_status?: string | null
          sync_type: string
          synced_at?: string | null
          user_id?: string | null
        }
        Update: {
          device_type?: string
          error_message?: string | null
          id?: string
          integration_name?: string
          last_sync_date?: string | null
          records_synced?: number | null
          sync_status?: string | null
          sync_type?: string
          synced_at?: string | null
          user_id?: string | null
        }
        Relationships: []
      }
      exercise_sessions: {
        Row: {
          avg_heart_rate: number | null
          calories_burned: number | null
          created_at: string | null
          device_type: string | null
          distance_km: number | null
          duration_minutes: number
          ended_at: string | null
          exercise_type: string
          id: string
          max_heart_rate: number | null
          min_heart_rate: number | null
          notes: string | null
          started_at: string | null
          steps: number | null
          user_id: string | null
          zones: Json | null
        }
        Insert: {
          avg_heart_rate?: number | null
          calories_burned?: number | null
          created_at?: string | null
          device_type?: string | null
          distance_km?: number | null
          duration_minutes: number
          ended_at?: string | null
          exercise_type: string
          id?: string
          max_heart_rate?: number | null
          min_heart_rate?: number | null
          notes?: string | null
          started_at?: string | null
          steps?: number | null
          user_id?: string | null
          zones?: Json | null
        }
        Update: {
          avg_heart_rate?: number | null
          calories_burned?: number | null
          created_at?: string | null
          device_type?: string | null
          distance_km?: number | null
          duration_minutes?: number
          ended_at?: string | null
          exercise_type?: string
          id?: string
          max_heart_rate?: number | null
          min_heart_rate?: number | null
          notes?: string | null
          started_at?: string | null
          steps?: number | null
          user_id?: string | null
          zones?: Json | null
        }
        Relationships: []
      }
      food_analysis: {
        Row: {
          created_at: string
          food_items: Json
          id: string
          meal_type: string
          nutrition_analysis: Json
          sofia_analysis: Json
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          food_items: Json
          id?: string
          meal_type: string
          nutrition_analysis: Json
          sofia_analysis: Json
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          food_items?: Json
          id?: string
          meal_type?: string
          nutrition_analysis?: Json
          sofia_analysis?: Json
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      food_patterns: {
        Row: {
          confidence_score: number | null
          context_data: Json | null
          detected_at: string
          id: string
          is_active: boolean | null
          pattern_description: string
          pattern_type: string
          user_id: string
        }
        Insert: {
          confidence_score?: number | null
          context_data?: Json | null
          detected_at?: string
          id?: string
          is_active?: boolean | null
          pattern_description: string
          pattern_type: string
          user_id: string
        }
        Update: {
          confidence_score?: number | null
          context_data?: Json | null
          detected_at?: string
          id?: string
          is_active?: boolean | null
          pattern_description?: string
          pattern_type?: string
          user_id?: string
        }
        Relationships: []
      }
      health_diary: {
        Row: {
          created_at: string
          date: string
          energy_level: number | null
          exercise_minutes: number | null
          id: string
          mood_rating: number | null
          notes: string | null
          sleep_hours: number | null
          user_id: string
          water_intake: number | null
        }
        Insert: {
          created_at?: string
          date?: string
          energy_level?: number | null
          exercise_minutes?: number | null
          id?: string
          mood_rating?: number | null
          notes?: string | null
          sleep_hours?: number | null
          user_id: string
          water_intake?: number | null
        }
        Update: {
          created_at?: string
          date?: string
          energy_level?: number | null
          exercise_minutes?: number | null
          id?: string
          mood_rating?: number | null
          notes?: string | null
          sleep_hours?: number | null
          user_id?: string
          water_intake?: number | null
        }
        Relationships: []
      }
      health_integrations: {
        Row: {
          api_key: string | null
          client_id: string | null
          client_secret: string | null
          config: Json | null
          created_at: string | null
          display_name: string
          enabled: boolean | null
          id: string
          name: string
          updated_at: string | null
        }
        Insert: {
          api_key?: string | null
          client_id?: string | null
          client_secret?: string | null
          config?: Json | null
          created_at?: string | null
          display_name: string
          enabled?: boolean | null
          id?: string
          name: string
          updated_at?: string | null
        }
        Update: {
          api_key?: string | null
          client_id?: string | null
          client_secret?: string | null
          config?: Json | null
          created_at?: string | null
          display_name?: string
          enabled?: boolean | null
          id?: string
          name?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      heart_rate_data: {
        Row: {
          activity_type: string | null
          created_at: string | null
          device_model: string | null
          device_type: string | null
          heart_rate_bpm: number
          heart_rate_variability: number | null
          id: string
          recorded_at: string | null
          recovery_time: number | null
          stress_level: number | null
          user_id: string | null
        }
        Insert: {
          activity_type?: string | null
          created_at?: string | null
          device_model?: string | null
          device_type?: string | null
          heart_rate_bpm: number
          heart_rate_variability?: number | null
          id?: string
          recorded_at?: string | null
          recovery_time?: number | null
          stress_level?: number | null
          user_id?: string | null
        }
        Update: {
          activity_type?: string | null
          created_at?: string | null
          device_model?: string | null
          device_type?: string | null
          heart_rate_bpm?: number
          heart_rate_variability?: number | null
          id?: string
          recorded_at?: string | null
          recovery_time?: number | null
          stress_level?: number | null
          user_id?: string | null
        }
        Relationships: []
      }
      lessons: {
        Row: {
          created_at: string
          description: string | null
          duration_minutes: number | null
          id: string
          is_free: boolean | null
          module_id: string
          order_index: number
          title: string
          video_url: string | null
        }
        Insert: {
          created_at?: string
          description?: string | null
          duration_minutes?: number | null
          id?: string
          is_free?: boolean | null
          module_id: string
          order_index: number
          title: string
          video_url?: string | null
        }
        Update: {
          created_at?: string
          description?: string | null
          duration_minutes?: number | null
          id?: string
          is_free?: boolean | null
          module_id?: string
          order_index?: number
          title?: string
          video_url?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "lessons_module_id_fkey"
            columns: ["module_id"]
            isOneToOne: false
            referencedRelation: "course_modules"
            referencedColumns: ["id"]
          },
        ]
      }
      missions: {
        Row: {
          category: string | null
          created_at: string
          description: string | null
          difficulty: string | null
          id: string
          is_active: boolean | null
          points: number | null
          title: string
        }
        Insert: {
          category?: string | null
          created_at?: string
          description?: string | null
          difficulty?: string | null
          id?: string
          is_active?: boolean | null
          points?: number | null
          title: string
        }
        Update: {
          category?: string | null
          created_at?: string
          description?: string | null
          difficulty?: string | null
          id?: string
          is_active?: boolean | null
          points?: number | null
          title?: string
        }
        Relationships: []
      }
      profiles: {
        Row: {
          avatar_url: string | null
          birth_date: string | null
          city: string | null
          created_at: string
          full_name: string | null
          id: string
          phone: string | null
          updated_at: string
          user_id: string | null
        }
        Insert: {
          avatar_url?: string | null
          birth_date?: string | null
          city?: string | null
          created_at?: string
          full_name?: string | null
          id?: string
          phone?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Update: {
          avatar_url?: string | null
          birth_date?: string | null
          city?: string | null
          created_at?: string
          full_name?: string | null
          id?: string
          phone?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Relationships: []
      }
      sessions: {
        Row: {
          content: Json
          created_at: string | null
          created_by: string | null
          description: string | null
          difficulty: string | null
          estimated_time: number | null
          follow_up_questions: string[] | null
          id: string
          is_active: boolean | null
          materials_needed: string[] | null
          target_saboteurs: string[] | null
          title: string
          type: string
          updated_at: string | null
        }
        Insert: {
          content: Json
          created_at?: string | null
          created_by?: string | null
          description?: string | null
          difficulty?: string | null
          estimated_time?: number | null
          follow_up_questions?: string[] | null
          id?: string
          is_active?: boolean | null
          materials_needed?: string[] | null
          target_saboteurs?: string[] | null
          title: string
          type?: string
          updated_at?: string | null
        }
        Update: {
          content?: Json
          created_at?: string | null
          created_by?: string | null
          description?: string | null
          difficulty?: string | null
          estimated_time?: number | null
          follow_up_questions?: string[] | null
          id?: string
          is_active?: boolean | null
          materials_needed?: string[] | null
          target_saboteurs?: string[] | null
          title?: string
          type?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      subscription_invoices: {
        Row: {
          amount: number
          asaas_payment_id: string | null
          bank_slip_url: string | null
          created_at: string
          due_date: string
          id: string
          invoice_url: string | null
          paid_date: string | null
          payment_method: string | null
          pix_qr_code: string | null
          status: string | null
          subscription_id: string | null
          updated_at: string
        }
        Insert: {
          amount: number
          asaas_payment_id?: string | null
          bank_slip_url?: string | null
          created_at?: string
          due_date: string
          id?: string
          invoice_url?: string | null
          paid_date?: string | null
          payment_method?: string | null
          pix_qr_code?: string | null
          status?: string | null
          subscription_id?: string | null
          updated_at?: string
        }
        Update: {
          amount?: number
          asaas_payment_id?: string | null
          bank_slip_url?: string | null
          created_at?: string
          due_date?: string
          id?: string
          invoice_url?: string | null
          paid_date?: string | null
          payment_method?: string | null
          pix_qr_code?: string | null
          status?: string | null
          subscription_id?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "subscription_invoices_subscription_id_fkey"
            columns: ["subscription_id"]
            isOneToOne: false
            referencedRelation: "user_subscriptions"
            referencedColumns: ["id"]
          },
        ]
      }
      subscription_plans: {
        Row: {
          created_at: string
          description: string | null
          features: Json | null
          id: string
          interval_count: number | null
          interval_type: string | null
          is_active: boolean | null
          name: string
          price: number
          updated_at: string
        }
        Insert: {
          created_at?: string
          description?: string | null
          features?: Json | null
          id?: string
          interval_count?: number | null
          interval_type?: string | null
          is_active?: boolean | null
          name: string
          price: number
          updated_at?: string
        }
        Update: {
          created_at?: string
          description?: string | null
          features?: Json | null
          id?: string
          interval_count?: number | null
          interval_type?: string | null
          is_active?: boolean | null
          name?: string
          price?: number
          updated_at?: string
        }
        Relationships: []
      }
      user_achievements: {
        Row: {
          achievement_type: string
          created_at: string | null
          description: string | null
          icon: string | null
          id: string
          progress: number | null
          target: number | null
          title: string
          unlocked_at: string | null
          user_id: string | null
        }
        Insert: {
          achievement_type: string
          created_at?: string | null
          description?: string | null
          icon?: string | null
          id?: string
          progress?: number | null
          target?: number | null
          title: string
          unlocked_at?: string | null
          user_id?: string | null
        }
        Update: {
          achievement_type?: string
          created_at?: string | null
          description?: string | null
          icon?: string | null
          id?: string
          progress?: number | null
          target?: number | null
          title?: string
          unlocked_at?: string | null
          user_id?: string | null
        }
        Relationships: []
      }
      user_favorite_foods: {
        Row: {
          created_at: string
          food_category: string
          food_name: string
          id: string
          last_used: string | null
          nutrition_data: Json | null
          usage_count: number | null
          user_id: string
        }
        Insert: {
          created_at?: string
          food_category: string
          food_name: string
          id?: string
          last_used?: string | null
          nutrition_data?: Json | null
          usage_count?: number | null
          user_id: string
        }
        Update: {
          created_at?: string
          food_category?: string
          food_name?: string
          id?: string
          last_used?: string | null
          nutrition_data?: Json | null
          usage_count?: number | null
          user_id?: string
        }
        Relationships: []
      }
      user_goals: {
        Row: {
          created_at: string | null
          data_fim: string | null
          data_inicio: string | null
          gordura_corporal_meta_percent: number | null
          id: string
          imc_meta: number | null
          peso_meta_kg: number | null
          status: string | null
          user_id: string | null
        }
        Insert: {
          created_at?: string | null
          data_fim?: string | null
          data_inicio?: string | null
          gordura_corporal_meta_percent?: number | null
          id?: string
          imc_meta?: number | null
          peso_meta_kg?: number | null
          status?: string | null
          user_id?: string | null
        }
        Update: {
          created_at?: string | null
          data_fim?: string | null
          data_inicio?: string | null
          gordura_corporal_meta_percent?: number | null
          id?: string
          imc_meta?: number | null
          peso_meta_kg?: number | null
          status?: string | null
          user_id?: string | null
        }
        Relationships: []
      }
      user_missions: {
        Row: {
          completed_at: string | null
          date_assigned: string
          id: string
          is_completed: boolean | null
          mission_id: string
          user_id: string
        }
        Insert: {
          completed_at?: string | null
          date_assigned?: string
          id?: string
          is_completed?: boolean | null
          mission_id: string
          user_id: string
        }
        Update: {
          completed_at?: string | null
          date_assigned?: string
          id?: string
          is_completed?: boolean | null
          mission_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_missions_mission_id_fkey"
            columns: ["mission_id"]
            isOneToOne: false
            referencedRelation: "missions"
            referencedColumns: ["id"]
          },
        ]
      }
      user_physical_data: {
        Row: {
          altura_cm: number
          created_at: string | null
          id: string
          idade: number
          nivel_atividade: string | null
          sexo: string
          updated_at: string | null
          user_id: string | null
        }
        Insert: {
          altura_cm: number
          created_at?: string | null
          id?: string
          idade: number
          nivel_atividade?: string | null
          sexo: string
          updated_at?: string | null
          user_id?: string | null
        }
        Update: {
          altura_cm?: number
          created_at?: string | null
          id?: string
          idade?: number
          nivel_atividade?: string | null
          sexo?: string
          updated_at?: string | null
          user_id?: string | null
        }
        Relationships: []
      }
      user_progress: {
        Row: {
          completed_at: string | null
          id: string
          is_completed: boolean | null
          lesson_id: string
          user_id: string
          watch_time_seconds: number | null
        }
        Insert: {
          completed_at?: string | null
          id?: string
          is_completed?: boolean | null
          lesson_id: string
          user_id: string
          watch_time_seconds?: number | null
        }
        Update: {
          completed_at?: string | null
          id?: string
          is_completed?: boolean | null
          lesson_id?: string
          user_id?: string
          watch_time_seconds?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "user_progress_lesson_id_fkey"
            columns: ["lesson_id"]
            isOneToOne: false
            referencedRelation: "lessons"
            referencedColumns: ["id"]
          },
        ]
      }
      user_sessions: {
        Row: {
          assigned_at: string | null
          completed_at: string | null
          created_at: string | null
          due_date: string | null
          feedback: Json | null
          id: string
          notes: string | null
          progress: number | null
          session_id: string | null
          started_at: string | null
          status: string | null
          updated_at: string | null
          user_id: string | null
        }
        Insert: {
          assigned_at?: string | null
          completed_at?: string | null
          created_at?: string | null
          due_date?: string | null
          feedback?: Json | null
          id?: string
          notes?: string | null
          progress?: number | null
          session_id?: string | null
          started_at?: string | null
          status?: string | null
          updated_at?: string | null
          user_id?: string | null
        }
        Update: {
          assigned_at?: string | null
          completed_at?: string | null
          created_at?: string | null
          due_date?: string | null
          feedback?: Json | null
          id?: string
          notes?: string | null
          progress?: number | null
          session_id?: string | null
          started_at?: string | null
          status?: string | null
          updated_at?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "user_sessions_session_id_fkey"
            columns: ["session_id"]
            isOneToOne: false
            referencedRelation: "sessions"
            referencedColumns: ["id"]
          },
        ]
      }
      user_subscriptions: {
        Row: {
          asaas_customer_id: string | null
          canceled_at: string | null
          created_at: string
          current_period_end: string | null
          current_period_start: string | null
          id: string
          plan_id: string | null
          status: string | null
          trial_end: string | null
          trial_start: string | null
          updated_at: string
          user_id: string | null
        }
        Insert: {
          asaas_customer_id?: string | null
          canceled_at?: string | null
          created_at?: string
          current_period_end?: string | null
          current_period_start?: string | null
          id?: string
          plan_id?: string | null
          status?: string | null
          trial_end?: string | null
          trial_start?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Update: {
          asaas_customer_id?: string | null
          canceled_at?: string | null
          created_at?: string
          current_period_end?: string | null
          current_period_start?: string | null
          id?: string
          plan_id?: string | null
          status?: string | null
          trial_end?: string | null
          trial_start?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "user_subscriptions_plan_id_fkey"
            columns: ["plan_id"]
            isOneToOne: false
            referencedRelation: "subscription_plans"
            referencedColumns: ["id"]
          },
        ]
      }
      weekly_analyses: {
        Row: {
          created_at: string | null
          id: string
          media_imc: number | null
          observacoes: string | null
          peso_final: number | null
          peso_inicial: number | null
          semana_fim: string
          semana_inicio: string
          tendencia: string | null
          user_id: string | null
          variacao_gordura_corporal: number | null
          variacao_massa_muscular: number | null
          variacao_peso: number | null
        }
        Insert: {
          created_at?: string | null
          id?: string
          media_imc?: number | null
          observacoes?: string | null
          peso_final?: number | null
          peso_inicial?: number | null
          semana_fim: string
          semana_inicio: string
          tendencia?: string | null
          user_id?: string | null
          variacao_gordura_corporal?: number | null
          variacao_massa_muscular?: number | null
          variacao_peso?: number | null
        }
        Update: {
          created_at?: string | null
          id?: string
          media_imc?: number | null
          observacoes?: string | null
          peso_final?: number | null
          peso_inicial?: number | null
          semana_fim?: string
          semana_inicio?: string
          tendencia?: string | null
          user_id?: string | null
          variacao_gordura_corporal?: number | null
          variacao_massa_muscular?: number | null
          variacao_peso?: number | null
        }
        Relationships: []
      }
      weekly_insights: {
        Row: {
          average_energy: number | null
          average_mood: number | null
          average_stress: number | null
          created_at: string | null
          exercise_frequency: number | null
          id: string
          most_common_gratitude: string | null
          sleep_consistency: number | null
          streak_days: number | null
          total_points: number | null
          user_id: string | null
          water_consistency: number | null
          week_start_date: string
        }
        Insert: {
          average_energy?: number | null
          average_mood?: number | null
          average_stress?: number | null
          created_at?: string | null
          exercise_frequency?: number | null
          id?: string
          most_common_gratitude?: string | null
          sleep_consistency?: number | null
          streak_days?: number | null
          total_points?: number | null
          user_id?: string | null
          water_consistency?: number | null
          week_start_date: string
        }
        Update: {
          average_energy?: number | null
          average_mood?: number | null
          average_stress?: number | null
          created_at?: string | null
          exercise_frequency?: number | null
          id?: string
          most_common_gratitude?: string | null
          sleep_consistency?: number | null
          streak_days?: number | null
          total_points?: number | null
          user_id?: string | null
          water_consistency?: number | null
          week_start_date?: string
        }
        Relationships: []
      }
      weighings: {
        Row: {
          basal_metabolism: number | null
          bmi: number | null
          body_fat: number | null
          body_water: number | null
          bone_mass: number | null
          created_at: string
          device_type: string | null
          id: string
          metabolic_age: number | null
          muscle_mass: number | null
          user_id: string
          weight: number
        }
        Insert: {
          basal_metabolism?: number | null
          bmi?: number | null
          body_fat?: number | null
          body_water?: number | null
          bone_mass?: number | null
          created_at?: string
          device_type?: string | null
          id?: string
          metabolic_age?: number | null
          muscle_mass?: number | null
          user_id: string
          weight: number
        }
        Update: {
          basal_metabolism?: number | null
          bmi?: number | null
          body_fat?: number | null
          body_water?: number | null
          bone_mass?: number | null
          created_at?: string
          device_type?: string | null
          id?: string
          metabolic_age?: number | null
          muscle_mass?: number | null
          user_id?: string
          weight?: number
        }
        Relationships: []
      }
      weight_measurements: {
        Row: {
          agua_corporal_percent: number | null
          circunferencia_abdominal_cm: number | null
          circunferencia_braco_cm: number | null
          circunferencia_perna_cm: number | null
          created_at: string | null
          device_type: string | null
          gordura_corporal_percent: number | null
          gordura_visceral: number | null
          id: string
          idade_metabolica: number | null
          imc: number | null
          massa_muscular_kg: number | null
          measurement_date: string | null
          metabolismo_basal_kcal: number | null
          notes: string | null
          osso_kg: number | null
          peso_kg: number
          risco_metabolico: string | null
          user_id: string | null
        }
        Insert: {
          agua_corporal_percent?: number | null
          circunferencia_abdominal_cm?: number | null
          circunferencia_braco_cm?: number | null
          circunferencia_perna_cm?: number | null
          created_at?: string | null
          device_type?: string | null
          gordura_corporal_percent?: number | null
          gordura_visceral?: number | null
          id?: string
          idade_metabolica?: number | null
          imc?: number | null
          massa_muscular_kg?: number | null
          measurement_date?: string | null
          metabolismo_basal_kcal?: number | null
          notes?: string | null
          osso_kg?: number | null
          peso_kg: number
          risco_metabolico?: string | null
          user_id?: string | null
        }
        Update: {
          agua_corporal_percent?: number | null
          circunferencia_abdominal_cm?: number | null
          circunferencia_braco_cm?: number | null
          circunferencia_perna_cm?: number | null
          created_at?: string | null
          device_type?: string | null
          gordura_corporal_percent?: number | null
          gordura_visceral?: number | null
          id?: string
          idade_metabolica?: number | null
          imc?: number | null
          massa_muscular_kg?: number | null
          measurement_date?: string | null
          metabolismo_basal_kcal?: number | null
          notes?: string | null
          osso_kg?: number | null
          peso_kg?: number
          risco_metabolico?: string | null
          user_id?: string | null
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      calculate_heart_rate_zones: {
        Args: { age: number; resting_hr?: number }
        Returns: Json
      }
      sync_device_data: {
        Args: {
          p_user_id: string
          p_integration_name: string
          p_device_type: string
          p_data: Json
        }
        Returns: number
      }
      user_has_active_subscription: {
        Args: { user_uuid: string }
        Returns: boolean
      }
      user_has_content_access: {
        Args: {
          user_uuid: string
          content_type_param: string
          content_id_param: string
        }
        Returns: boolean
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  storage: {
    Tables: {
      buckets: {
        Row: {
          allowed_mime_types: string[] | null
          avif_autodetection: boolean | null
          created_at: string | null
          file_size_limit: number | null
          id: string
          name: string
          owner: string | null
          owner_id: string | null
          public: boolean | null
          updated_at: string | null
        }
        Insert: {
          allowed_mime_types?: string[] | null
          avif_autodetection?: boolean | null
          created_at?: string | null
          file_size_limit?: number | null
          id: string
          name: string
          owner?: string | null
          owner_id?: string | null
          public?: boolean | null
          updated_at?: string | null
        }
        Update: {
          allowed_mime_types?: string[] | null
          avif_autodetection?: boolean | null
          created_at?: string | null
          file_size_limit?: number | null
          id?: string
          name?: string
          owner?: string | null
          owner_id?: string | null
          public?: boolean | null
          updated_at?: string | null
        }
        Relationships: []
      }
      migrations: {
        Row: {
          executed_at: string | null
          hash: string
          id: number
          name: string
        }
        Insert: {
          executed_at?: string | null
          hash: string
          id: number
          name: string
        }
        Update: {
          executed_at?: string | null
          hash?: string
          id?: number
          name?: string
        }
        Relationships: []
      }
      objects: {
        Row: {
          bucket_id: string | null
          created_at: string | null
          id: string
          last_accessed_at: string | null
          metadata: Json | null
          name: string | null
          owner: string | null
          owner_id: string | null
          path_tokens: string[] | null
          updated_at: string | null
          user_metadata: Json | null
          version: string | null
        }
        Insert: {
          bucket_id?: string | null
          created_at?: string | null
          id?: string
          last_accessed_at?: string | null
          metadata?: Json | null
          name?: string | null
          owner?: string | null
          owner_id?: string | null
          path_tokens?: string[] | null
          updated_at?: string | null
          user_metadata?: Json | null
          version?: string | null
        }
        Update: {
          bucket_id?: string | null
          created_at?: string | null
          id?: string
          last_accessed_at?: string | null
          metadata?: Json | null
          name?: string | null
          owner?: string | null
          owner_id?: string | null
          path_tokens?: string[] | null
          updated_at?: string | null
          user_metadata?: Json | null
          version?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "objects_bucketId_fkey"
            columns: ["bucket_id"]
            isOneToOne: false
            referencedRelation: "buckets"
            referencedColumns: ["id"]
          },
        ]
      }
      s3_multipart_uploads: {
        Row: {
          bucket_id: string
          created_at: string
          id: string
          in_progress_size: number
          key: string
          owner_id: string | null
          upload_signature: string
          user_metadata: Json | null
          version: string
        }
        Insert: {
          bucket_id: string
          created_at?: string
          id: string
          in_progress_size?: number
          key: string
          owner_id?: string | null
          upload_signature: string
          user_metadata?: Json | null
          version: string
        }
        Update: {
          bucket_id?: string
          created_at?: string
          id?: string
          in_progress_size?: number
          key?: string
          owner_id?: string | null
          upload_signature?: string
          user_metadata?: Json | null
          version?: string
        }
        Relationships: [
          {
            foreignKeyName: "s3_multipart_uploads_bucket_id_fkey"
            columns: ["bucket_id"]
            isOneToOne: false
            referencedRelation: "buckets"
            referencedColumns: ["id"]
          },
        ]
      }
      s3_multipart_uploads_parts: {
        Row: {
          bucket_id: string
          created_at: string
          etag: string
          id: string
          key: string
          owner_id: string | null
          part_number: number
          size: number
          upload_id: string
          version: string
        }
        Insert: {
          bucket_id: string
          created_at?: string
          etag: string
          id?: string
          key: string
          owner_id?: string | null
          part_number: number
          size?: number
          upload_id: string
          version: string
        }
        Update: {
          bucket_id?: string
          created_at?: string
          etag?: string
          id?: string
          key?: string
          owner_id?: string | null
          part_number?: number
          size?: number
          upload_id?: string
          version?: string
        }
        Relationships: [
          {
            foreignKeyName: "s3_multipart_uploads_parts_bucket_id_fkey"
            columns: ["bucket_id"]
            isOneToOne: false
            referencedRelation: "buckets"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "s3_multipart_uploads_parts_upload_id_fkey"
            columns: ["upload_id"]
            isOneToOne: false
            referencedRelation: "s3_multipart_uploads"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      can_insert_object: {
        Args: { bucketid: string; name: string; owner: string; metadata: Json }
        Returns: undefined
      }
      extension: {
        Args: { name: string }
        Returns: string
      }
      filename: {
        Args: { name: string }
        Returns: string
      }
      foldername: {
        Args: { name: string }
        Returns: string[]
      }
      get_size_by_bucket: {
        Args: Record<PropertyKey, never>
        Returns: {
          size: number
          bucket_id: string
        }[]
      }
      list_multipart_uploads_with_delimiter: {
        Args: {
          bucket_id: string
          prefix_param: string
          delimiter_param: string
          max_keys?: number
          next_key_token?: string
          next_upload_token?: string
        }
        Returns: {
          key: string
          id: string
          created_at: string
        }[]
      }
      list_objects_with_delimiter: {
        Args: {
          bucket_id: string
          prefix_param: string
          delimiter_param: string
          max_keys?: number
          start_after?: string
          next_token?: string
        }
        Returns: {
          name: string
          id: string
          metadata: Json
          updated_at: string
        }[]
      }
      operation: {
        Args: Record<PropertyKey, never>
        Returns: string
      }
      search: {
        Args: {
          prefix: string
          bucketname: string
          limits?: number
          levels?: number
          offsets?: number
          search?: string
          sortcolumn?: string
          sortorder?: string
        }
        Returns: {
          name: string
          id: string
          updated_at: string
          created_at: string
          last_accessed_at: string
          metadata: Json
        }[]
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {},
  },
  storage: {
    Enums: {},
  },
} as const
