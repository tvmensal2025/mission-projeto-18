import { useState, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';

interface TrackingData {
  waterIntake: {
    today: number;
    goal: number;
    streak: number;
    weeklyData: { date: string; amount: number }[];
    todayTotal: number;
    weeklyAverage: number;
  };
  water: {
    today: { id: string; recorded_at: string; amount_ml: number }[];
    todayTotal: number;
    goal: number;
    weeklyAverage: number;
  };
  sleep: {
    lastNight: {
      hours: number;
      quality: number;
    };
    goal: number;
    quality: number;
    weeklyAverage: number;
    weeklyData: { date: string; hours: number; quality: number }[];
  };
  mood: {
    today: {
      day_rating: number;
      energy_level: number;
      stress_level: number;
    };
    average: number;
    weeklyData: { date: string; mood: number; energy: number; stress: number }[];
  };
  exercise: {
    todayMinutes: number;
    weeklyGoal: number;
    streak: number;
    weeklyData: { date: string; minutes: number; type: string }[];
  };
}

export const useTrackingData = () => {
  const [trackingData, setTrackingData] = useState<TrackingData | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    loadTrackingData();
  }, []);

  const loadTrackingData = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        setTrackingData(null);
        setIsLoading(false);
        return;
      }

      // Temporário - usar dados mock até tabelas serem criadas
      const mockData: TrackingData = {
        waterIntake: {
          today: 4,
          goal: 8,
          streak: 3,
          weeklyData: [],
          todayTotal: 4,
          weeklyAverage: 6
        },
        water: {
          today: [],
          todayTotal: 4,
          goal: 8,
          weeklyAverage: 6
        },
        sleep: {
          lastNight: {
            hours: 7.5,
            quality: 4
          },
          goal: 8,
          quality: 85,
          weeklyAverage: 7.2,
          weeklyData: []
        },
        mood: {
          today: {
            day_rating: 8,
            energy_level: 4,
            stress_level: 2
          },
          average: 7.5,
          weeklyData: []
        },
        exercise: {
          todayMinutes: 30,
          weeklyGoal: 150,
          streak: 2,
          weeklyData: []
        }
      };

      setTrackingData(mockData);
    } catch (error) {
      console.error('Erro ao carregar dados de tracking:', error);
      setTrackingData(null);
    } finally {
      setIsLoading(false);
    }
  };

  const addWaterIntake = async (amount: number) => {
    console.log('Adding water intake:', amount);
    if (trackingData) {
      setTrackingData({
        ...trackingData,
        waterIntake: {
          ...trackingData.waterIntake,
          today: trackingData.waterIntake.today + amount
        }
      });
    }
  };

  const addSleepData = async (sleepForm: { hours: number; quality: number; notes: string }) => {
    console.log('Adding sleep data:', sleepForm.hours, sleepForm.quality);
    if (trackingData) {
      setTrackingData({
        ...trackingData,
        sleep: {
          ...trackingData.sleep,
          lastNight: {
            hours: sleepForm.hours,
            quality: sleepForm.quality
          }
        }
      });
    }
  };

  const addMoodData = async (moodForm: { energy: number; stress: number; rating: number; gratitude: string }) => {
    console.log('Adding mood data:', moodForm.rating, moodForm.energy, moodForm.stress);
    if (trackingData) {
      setTrackingData({
        ...trackingData,
        mood: {
          ...trackingData.mood,
          today: {
            day_rating: moodForm.rating,
            energy_level: moodForm.energy,
            stress_level: moodForm.stress
          }
        }
      });
    }
  };

  const addExerciseData = async (minutes: number, type: string) => {
    console.log('Adding exercise data:', minutes, type);
    if (trackingData) {
      setTrackingData({
        ...trackingData,
        exercise: {
          ...trackingData.exercise,
          todayMinutes: trackingData.exercise.todayMinutes + minutes
        }
      });
    }
  };

  return {
    trackingData,
    isLoading,
    addWaterIntake,
    addSleepData,
    addMoodData,
    addExerciseData,
    refreshData: loadTrackingData,
    // Aliases para compatibilidade
    addWater: addWaterIntake,
    addSleep: addSleepData,
    addMood: addMoodData,
    isAddingWater: false,
    isAddingSleep: false,
    isAddingMood: false,
    water: trackingData?.waterIntake
  };
};