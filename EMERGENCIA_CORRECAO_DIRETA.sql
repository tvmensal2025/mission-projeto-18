-- 🚨 CORREÇÃO DE EMERGÊNCIA - ADICIONAR COLUNAS FALTANTES DIRETAMENTE
-- Execute este script para resolver os erros imediatos

-- =====================================================
-- PARTE 1: ADICIONAR COLUNAS CRÍTICAS FALTANTES
-- =====================================================

-- 1.1 Adicionar is_completed em challenge_participations (ERRO ATUAL)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_participations' AND column_name = 'is_completed' AND table_schema = 'public') THEN
        ALTER TABLE challenge_participations ADD COLUMN is_completed BOOLEAN DEFAULT false;
        RAISE NOTICE '✅ Coluna is_completed adicionada em challenge_participations';
    ELSE
        RAISE NOTICE '⚠️ Coluna is_completed já existe em challenge_participations';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro ao adicionar is_completed: %', SQLERRM;
END $$;

-- 1.2 Adicionar best_streak se não existir
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_participations' AND column_name = 'best_streak' AND table_schema = 'public') THEN
        ALTER TABLE challenge_participations ADD COLUMN best_streak INTEGER DEFAULT 0;
        RAISE NOTICE '✅ Coluna best_streak adicionada em challenge_participations';
    ELSE
        RAISE NOTICE '⚠️ Coluna best_streak já existe em challenge_participations';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro ao adicionar best_streak: %', SQLERRM;
END $$;

-- 1.3 Adicionar category em user_goals
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'category' AND table_schema = 'public') THEN
        ALTER TABLE user_goals ADD COLUMN category VARCHAR(100) DEFAULT 'geral';
        RAISE NOTICE '✅ Coluna category adicionada em user_goals';
    ELSE
        RAISE NOTICE '⚠️ Coluna category já existe em user_goals';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro ao adicionar category: %', SQLERRM;
END $$;

-- 1.4 Adicionar email em profiles
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'email' AND table_schema = 'public') THEN
        ALTER TABLE profiles ADD COLUMN email TEXT;
        RAISE NOTICE '✅ Coluna email adicionada em profiles';
    ELSE
        RAISE NOTICE '⚠️ Coluna email já existe em profiles';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro ao adicionar email: %', SQLERRM;
END $$;

-- 1.5 Adicionar is_active em modules
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'modules' AND column_name = 'is_active' AND table_schema = 'public') THEN
        ALTER TABLE modules ADD COLUMN is_active BOOLEAN DEFAULT true;
        RAISE NOTICE '✅ Coluna is_active adicionada em modules';
    ELSE
        RAISE NOTICE '⚠️ Coluna is_active já existe em modules';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro ao adicionar is_active: %', SQLERRM;
END $$;

-- =====================================================
-- PARTE 2: CRIAR TABELAS FALTANTES ESSENCIAIS
-- =====================================================

-- 2.1 Criar preventive_health_analyses se não existir
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'preventive_health_analyses' AND table_schema = 'public') THEN
        CREATE TABLE preventive_health_analyses (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
            analysis_type VARCHAR(50) NOT NULL,
            results JSONB NOT NULL DEFAULT '{}',
            recommendations TEXT[] DEFAULT '{}',
            risk_level VARCHAR(20) DEFAULT 'baixo',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
        );
        RAISE NOTICE '✅ Tabela preventive_health_analyses criada';
    ELSE
        RAISE NOTICE '⚠️ Tabela preventive_health_analyses já existe';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro ao criar preventive_health_analyses: %', SQLERRM;
END $$;

-- 2.2 Criar company_configurations se não existir
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'company_configurations' AND table_schema = 'public') THEN
        CREATE TABLE company_configurations (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            company_name TEXT NOT NULL DEFAULT 'Instituto dos Sonhos',
            logo_url TEXT DEFAULT '/placeholder.svg',
            primary_color TEXT DEFAULT '#ff6b35',
            contact_email TEXT DEFAULT 'contato@institutodossonhos.com',
            mission TEXT DEFAULT 'Guiar pessoas na transformação integral da saúde',
            vision TEXT DEFAULT 'Ser reconhecido como referência em saúde integral',
            settings JSONB DEFAULT '{}',
            is_active BOOLEAN DEFAULT true,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
        );
        RAISE NOTICE '✅ Tabela company_configurations criada';
    ELSE
        RAISE NOTICE '⚠️ Tabela company_configurations já existe';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro ao criar company_configurations: %', SQLERRM;
END $$;

-- =====================================================
-- PARTE 3: INSERIR DADOS ESSENCIAIS
-- =====================================================

-- 3.1 Inserir configuração da empresa se não existir
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM company_configurations WHERE company_name = 'Instituto dos Sonhos') THEN
        INSERT INTO company_configurations (
            company_name, 
            logo_url, 
            primary_color, 
            contact_email,
            mission,
            vision
        ) VALUES (
            'Instituto dos Sonhos',
            '/placeholder.svg',
            '#ff6b35',
            'contato@institutodossonhos.com',
            'Guiar pessoas na transformação integral da saúde',
            'Ser reconhecido como referência em saúde integral'
        );
        RAISE NOTICE '✅ Configuração da empresa inserida';
    ELSE
        RAISE NOTICE '⚠️ Configuração da empresa já existe';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro ao inserir configuração da empresa: %', SQLERRM;
END $$;

-- =====================================================
-- PARTE 4: HABILITAR RLS BÁSICO
-- =====================================================

-- 4.1 Habilitar RLS nas tabelas se existirem
DO $$
BEGIN
    -- RLS para preventive_health_analyses
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'preventive_health_analyses' AND table_schema = 'public') THEN
        ALTER TABLE preventive_health_analyses ENABLE ROW LEVEL SECURITY;
        
        -- Política básica
        DROP POLICY IF EXISTS "Users can view own analyses" ON preventive_health_analyses;
        CREATE POLICY "Users can view own analyses" ON preventive_health_analyses 
        FOR SELECT USING (user_id = auth.uid());
        
        RAISE NOTICE '✅ RLS configurado para preventive_health_analyses';
    END IF;
    
    -- RLS para company_configurations
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'company_configurations' AND table_schema = 'public') THEN
        ALTER TABLE company_configurations ENABLE ROW LEVEL SECURITY;
        
        -- Política básica
        DROP POLICY IF EXISTS "Anyone can view company config" ON company_configurations;
        CREATE POLICY "Anyone can view company config" ON company_configurations 
        FOR SELECT USING (is_active = true);
        
        RAISE NOTICE '✅ RLS configurado para company_configurations';
    END IF;
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro ao configurar RLS: %', SQLERRM;
END $$;

-- =====================================================
-- PARTE 5: FUNÇÃO PARA PARTICIPAR DO DESAFIO
-- =====================================================

-- 5.1 Criar função para participar do desafio (resolve o erro atual)
CREATE OR REPLACE FUNCTION participate_in_challenge(
    p_user_id UUID,
    p_challenge_id UUID
)
RETURNS UUID AS $$
DECLARE
    v_participation_id UUID;
BEGIN
    -- Verificar se já está participando
    IF EXISTS (
        SELECT 1 FROM challenge_participations 
        WHERE user_id = p_user_id AND challenge_id = p_challenge_id
    ) THEN
        -- Se já existe, retornar o ID existente
        SELECT id INTO v_participation_id 
        FROM challenge_participations 
        WHERE user_id = p_user_id AND challenge_id = p_challenge_id;
        
        RETURN v_participation_id;
    END IF;
    
    -- Criar nova participação com todas as colunas necessárias
    INSERT INTO challenge_participations (
        challenge_id,
        user_id,
        status,
        current_progress,
        best_streak,
        is_completed
    ) VALUES (
        p_challenge_id,
        p_user_id,
        'active',
        0,
        0,
        false
    ) RETURNING id INTO v_participation_id;
    
    RETURN v_participation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- PARTE 6: ATUALIZAR PARTICIPAÇÕES EXISTENTES
-- =====================================================

-- 6.1 Atualizar participações existentes para ter is_completed
DO $$
BEGIN
    -- Se a coluna is_completed existe, garantir que tem valor
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_participations' AND column_name = 'is_completed') THEN
        UPDATE challenge_participations 
        SET is_completed = CASE 
            WHEN status = 'completed' THEN true 
            ELSE false 
        END
        WHERE is_completed IS NULL;
        
        RAISE NOTICE '✅ Participações existentes atualizadas com is_completed';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro ao atualizar participações: %', SQLERRM;
END $$;

-- =====================================================
-- PARTE 7: VERIFICAÇÃO FINAL
-- =====================================================

-- 7.1 Verificar se todas as colunas críticas existem
SELECT 
    '🚨 VERIFICAÇÃO DE EMERGÊNCIA' as titulo,
    jsonb_build_object(
        'challenge_participations_is_completed', EXISTS(
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'challenge_participations' AND column_name = 'is_completed'
        ),
        'challenge_participations_best_streak', EXISTS(
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'challenge_participations' AND column_name = 'best_streak'
        ),
        'user_goals_category', EXISTS(
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'user_goals' AND column_name = 'category'
        ),
        'profiles_email', EXISTS(
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'profiles' AND column_name = 'email'
        ),
        'modules_is_active', EXISTS(
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'modules' AND column_name = 'is_active'
        ),
        'preventive_health_analyses_exists', EXISTS(
            SELECT 1 FROM information_schema.tables 
            WHERE table_name = 'preventive_health_analyses'
        ),
        'company_configurations_exists', EXISTS(
            SELECT 1 FROM information_schema.tables 
            WHERE table_name = 'company_configurations'
        ),
        'funcao_participate_criada', EXISTS(
            SELECT 1 FROM information_schema.routines 
            WHERE routine_name = 'participate_in_challenge'
        )
    ) as verificacao_emergencia;

-- 7.2 Contagem de dados
SELECT 
    '📊 CONTAGEM DE DADOS' as titulo,
    jsonb_build_object(
        'challenge_participations', (SELECT COUNT(*) FROM challenge_participations),
        'challenges', (SELECT COUNT(*) FROM challenges),
        'user_goals', (SELECT COUNT(*) FROM user_goals),
        'company_configurations', (SELECT COUNT(*) FROM company_configurations WHERE company_configurations.id IS NOT NULL)
    ) as contagem_dados;

-- 🚨 CORREÇÃO DE EMERGÊNCIA CONCLUÍDA!
-- ✅ Coluna is_completed adicionada (resolve erro atual)
-- ✅ Outras colunas críticas verificadas
-- ✅ Tabelas essenciais criadas
-- ✅ Função participate_in_challenge criada
-- ✅ RLS básico configurado
-- 🔄 RECARREGUE A APLICAÇÃO AGORA!