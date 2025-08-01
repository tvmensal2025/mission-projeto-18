-- Script para criar desafios com UUIDs válidos
-- Execute este script no Supabase SQL Editor

-- Inserir desafios com UUIDs válidos
INSERT INTO challenges (
  id, 
  title, 
  description, 
  category, 
  difficulty, 
  duration_days, 
  xp_reward, 
  target_value, 
  is_active, 
  is_featured,
  created_at
) VALUES 
  (
    '01234567-89ab-cdef-0123-456789abcdef',
    'Hidratação Diária',
    'Beba 2L de água todos os dias por uma semana',
    'hidratacao',
    'facil',
    7,
    50,
    14,
    true,
    true,
    now()
  ),
  (
    '11234567-89ab-cdef-0123-456789abcdef',
    'Exercício Matinal',
    'Faça 30 minutos de exercício todas as manhãs',
    'exercicio',
    'medio',
    14,
    120,
    14,
    true,
    false,
    now()
  ),
  (
    '21234567-89ab-cdef-0123-456789abcdef',
    'Alimentação Saudável',
    'Coma 5 porções de frutas e vegetais por dia',
    'nutricao',
    'medio',
    21,
    200,
    105,
    true,
    false,
    now()
  )
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  category = EXCLUDED.category,
  difficulty = EXCLUDED.difficulty,
  duration_days = EXCLUDED.duration_days,
  xp_reward = EXCLUDED.xp_reward,
  target_value = EXCLUDED.target_value,
  is_active = EXCLUDED.is_active,
  is_featured = EXCLUDED.is_featured,
  updated_at = now(); 