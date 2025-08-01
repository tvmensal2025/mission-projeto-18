-- ===============================================
-- 🚨 CORREÇÃO URGENTE - Instituto dos Sonhos
-- ===============================================
-- Resolve os problemas mais críticos identificados

-- ===============================================
-- 1. VERIFICAR E CORRIGIR TABELA CHALLENGES
-- ===============================================

-- Verificar se a coluna 'type' existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'challenges' 
        AND column_name = 'type'
    ) THEN
        ALTER TABLE challenges ADD COLUMN type VARCHAR(50) DEFAULT 'individual';
        RAISE NOTICE 'Coluna "type" adicionada à tabela challenges';
    ELSE
        RAISE NOTICE 'Coluna "type" já existe na tabela challenges';
    END IF;
END $$;

-- ===============================================
-- 2. VERIFICAR E CORRIGIR CHALLENGE_PARTICIPATIONS
-- ===============================================

-- Verificar se a tabela existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'challenge_participations') THEN
        CREATE TABLE challenge_participations (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
            challenge_id UUID REFERENCES challenges(id) ON DELETE CASCADE,
            joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            current_streak INTEGER DEFAULT 0,
            best_streak INTEGER DEFAULT 0,
            total_points INTEGER DEFAULT 0,
            is_active BOOLEAN DEFAULT true,
            daily_logs JSONB DEFAULT '{}',
            achievements_unlocked JSONB DEFAULT '{}',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            UNIQUE(user_id, challenge_id)
        );
        RAISE NOTICE 'Tabela challenge_participations criada';
    ELSE
        -- Verificar se a coluna best_streak existe
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'challenge_participations' 
            AND column_name = 'best_streak'
        ) THEN
            ALTER TABLE challenge_participations ADD COLUMN best_streak INTEGER DEFAULT 0;
            RAISE NOTICE 'Coluna "best_streak" adicionada à tabela challenge_participations';
        END IF;
        
        -- Verificar se a coluna daily_logs existe
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'challenge_participations' 
            AND column_name = 'daily_logs'
        ) THEN
            ALTER TABLE challenge_participations ADD COLUMN daily_logs JSONB DEFAULT '{}';
            RAISE NOTICE 'Coluna "daily_logs" adicionada à tabela challenge_participations';
        END IF;
        
        -- Verificar se a coluna achievements_unlocked existe
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'challenge_participations' 
            AND column_name = 'achievements_unlocked'
        ) THEN
            ALTER TABLE challenge_participations ADD COLUMN achievements_unlocked JSONB DEFAULT '{}';
            RAISE NOTICE 'Coluna "achievements_unlocked" adicionada à tabela challenge_participations';
        END IF;
    END IF;
END $$;

-- ===============================================
-- 3. VERIFICAR E CORRIGIR USER_GOALS
-- ===============================================

-- Verificar se a tabela existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_goals') THEN
        CREATE TABLE user_goals (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
            title TEXT NOT NULL,
            description TEXT,
            category VARCHAR(100) DEFAULT 'geral',
            priority INTEGER DEFAULT 1,
            tags TEXT[] DEFAULT '{}',
            target_value DECIMAL(10,2),
            current_value DECIMAL(10,2) DEFAULT 0,
            unit TEXT,
            deadline DATE,
            status VARCHAR(20) DEFAULT 'pendente',
            evidence_required BOOLEAN DEFAULT false,
            evidence_text TEXT,
            points INTEGER DEFAULT 0,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        RAISE NOTICE 'Tabela user_goals criada';
    ELSE
        -- Verificar se a coluna category existe
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'user_goals' 
            AND column_name = 'category'
        ) THEN
            ALTER TABLE user_goals ADD COLUMN category VARCHAR(100) DEFAULT 'geral';
            RAISE NOTICE 'Coluna "category" adicionada à tabela user_goals';
        END IF;
        
        -- Verificar se a coluna priority existe
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'user_goals' 
            AND column_name = 'priority'
        ) THEN
            ALTER TABLE user_goals ADD COLUMN priority INTEGER DEFAULT 1;
            RAISE NOTICE 'Coluna "priority" adicionada à tabela user_goals';
        END IF;
        
        -- Verificar se a coluna tags existe
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'user_goals' 
            AND column_name = 'tags'
        ) THEN
            ALTER TABLE user_goals ADD COLUMN tags TEXT[] DEFAULT '{}';
            RAISE NOTICE 'Coluna "tags" adicionada à tabela user_goals';
        END IF;
    END IF;
END $$;

-- ===============================================
-- 4. VERIFICAR E CORRIGIR PROFILES
-- ===============================================

-- Verificar se a tabela existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles') THEN
        CREATE TABLE profiles (
            id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
            full_name TEXT,
            avatar_url TEXT,
            email TEXT,
            phone TEXT,
            birth_date DATE,
            gender TEXT,
            height DECIMAL(5,2),
            city TEXT,
            state TEXT,
            activity_level TEXT,
            preferences JSONB DEFAULT '{}',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
            is_active BOOLEAN DEFAULT true
        );
        RAISE NOTICE 'Tabela profiles criada';
    ELSE
        -- Verificar se a coluna email existe
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'profiles' 
            AND column_name = 'email'
        ) THEN
            ALTER TABLE profiles ADD COLUMN email TEXT;
            RAISE NOTICE 'Coluna "email" adicionada à tabela profiles';
        END IF;
        
        -- Verificar se a coluna avatar_url existe
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'profiles' 
            AND column_name = 'avatar_url'
        ) THEN
            ALTER TABLE profiles ADD COLUMN avatar_url TEXT;
            RAISE NOTICE 'Coluna "avatar_url" adicionada à tabela profiles';
        END IF;
        
        -- Verificar se a coluna preferences existe
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'profiles' 
            AND column_name = 'preferences'
        ) THEN
            ALTER TABLE profiles ADD COLUMN preferences JSONB DEFAULT '{}';
            RAISE NOTICE 'Coluna "preferences" adicionada à tabela profiles';
        END IF;
    END IF;
END $$;

-- ===============================================
-- 5. CRIAR TABELA PREVENTIVE_HEALTH_ANALYSES
-- ===============================================

CREATE TABLE IF NOT EXISTS preventive_health_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    analysis_type VARCHAR(50) NOT NULL,
    results JSONB DEFAULT '{}',
    recommendations TEXT[] DEFAULT '{}',
    risk_level VARCHAR(20) DEFAULT 'low',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===============================================
-- 6. CRIAR TABELA COMPANY_CONFIGURATIONS
-- ===============================================

CREATE TABLE IF NOT EXISTS company_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name TEXT NOT NULL DEFAULT 'Instituto dos Sonhos',
    logo_url TEXT,
    primary_color TEXT DEFAULT '#3B82F6',
    secondary_color TEXT DEFAULT '#1E40AF',
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inserir configuração padrão se não existir
INSERT INTO company_configurations (company_name, logo_url, primary_color, secondary_color, settings)
VALUES (
    'Instituto dos Sonhos',
    '/images/dr-vital.png',
    '#3B82F6',
    '#1E40AF',
    '{"theme": "light", "features": {"challenges": true, "goals": true, "ai": true}}'
)
ON CONFLICT DO NOTHING;

-- ===============================================
-- 7. HABILITAR RLS E CRIAR POLÍTICAS
-- ===============================================

-- Habilitar RLS em todas as tabelas
ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_participations ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE preventive_health_analyses ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_configurations ENABLE ROW LEVEL SECURITY;

-- Criar políticas RLS básicas
DO $$
BEGIN
    -- Políticas para challenges
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'challenges' AND policyname = 'challenges_select') THEN
        CREATE POLICY "challenges_select" ON challenges FOR SELECT USING (true);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'challenges' AND policyname = 'challenges_modify') THEN
        CREATE POLICY "challenges_modify" ON challenges FOR ALL USING (auth.uid() IN (
            SELECT id FROM profiles WHERE role = 'admin'
        ));
    END IF;
    
    -- Políticas para challenge_participations
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'challenge_participations' AND policyname = 'challenge_participations_all') THEN
        CREATE POLICY "challenge_participations_all" ON challenge_participations FOR ALL USING (
            user_id = auth.uid() OR auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin')
        );
    END IF;
    
    -- Políticas para user_goals
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'user_goals' AND policyname = 'user_goals_all') THEN
        CREATE POLICY "user_goals_all" ON user_goals FOR ALL USING (
            user_id = auth.uid() OR auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin')
        );
    END IF;
    
    -- Políticas para profiles
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'profiles_all') THEN
        CREATE POLICY "profiles_all" ON profiles FOR ALL USING (
            id = auth.uid() OR auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin')
        );
    END IF;
    
    -- Políticas para preventive_health_analyses
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'preventive_health_analyses' AND policyname = 'preventive_health_analyses_all') THEN
        CREATE POLICY "preventive_health_analyses_all" ON preventive_health_analyses FOR ALL USING (
            user_id = auth.uid() OR auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin')
        );
    END IF;
    
    -- Políticas para company_configurations
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'company_configurations' AND policyname = 'company_configurations_select') THEN
        CREATE POLICY "company_configurations_select" ON company_configurations FOR SELECT USING (true);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'company_configurations' AND policyname = 'company_configurations_modify') THEN
        CREATE POLICY "company_configurations_modify" ON company_configurations FOR ALL USING (
            auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin')
        );
    END IF;
END $$;

-- ===============================================
-- 8. CRIAR ÍNDICES PARA PERFORMANCE
-- ===============================================

CREATE INDEX IF NOT EXISTS idx_challenges_active ON challenges(is_active);
CREATE INDEX IF NOT EXISTS idx_challenge_participations_user ON challenge_participations(user_id);
CREATE INDEX IF NOT EXISTS idx_user_goals_user_status ON user_goals(user_id, status);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE INDEX IF NOT EXISTS idx_preventive_health_analyses_user ON preventive_health_analyses(user_id);

-- ===============================================
-- 9. CRIAR FUNÇÃO PARA ATUALIZAR UPDATED_AT
-- ===============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger em todas as tabelas
DO $$
DECLARE
    table_name TEXT;
BEGIN
    FOR table_name IN 
        SELECT tablename FROM pg_tables 
        WHERE schemaname = 'public' 
        AND tablename IN ('challenges', 'challenge_participations', 'user_goals', 'profiles', 'preventive_health_analyses', 'company_configurations')
    LOOP
        EXECUTE format('
            DROP TRIGGER IF EXISTS update_updated_at_trigger ON %I;
            CREATE TRIGGER update_updated_at_trigger
                BEFORE UPDATE ON %I
                FOR EACH ROW
                EXECUTE FUNCTION update_updated_at_column();
        ', table_name, table_name);
    END LOOP;
END $$;

-- ===============================================
-- 10. VERIFICAÇÃO FINAL
-- ===============================================

-- Verificar se todas as tabelas foram criadas
SELECT 
    'Tabelas criadas:' as status,
    COUNT(*) as total
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('challenges', 'challenge_participations', 'user_goals', 'profiles', 'preventive_health_analyses', 'company_configurations');

-- Verificar se todas as colunas necessárias existem
SELECT 
    'Colunas verificadas:' as status,
    COUNT(*) as total
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND (
    (table_name = 'challenges' AND column_name = 'type') OR
    (table_name = 'challenge_participations' AND column_name IN ('best_streak', 'daily_logs', 'achievements_unlocked')) OR
    (table_name = 'user_goals' AND column_name IN ('category', 'priority', 'tags')) OR
    (table_name = 'profiles' AND column_name IN ('email', 'avatar_url', 'preferences'))
);

-- ===============================================
-- ✅ CORREÇÃO CONCLUÍDA
-- ===============================================

RAISE NOTICE '🎉 Correção urgente concluída com sucesso!';
RAISE NOTICE '📊 Todas as tabelas e colunas foram verificadas e corrigidas';
RAISE NOTICE '🔒 Políticas RLS foram aplicadas';
RAISE NOTICE '⚡ Índices de performance foram criados';
RAISE NOTICE '🔄 Triggers de updated_at foram configurados'; 