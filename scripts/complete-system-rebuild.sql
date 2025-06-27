-- Reconstrucción completa del sistema desde cero

-- 1. Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. Eliminar políticas RLS existentes
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can view own proposals" ON public.proposals;
DROP POLICY IF EXISTS "Users can create proposals" ON public.proposals;
DROP POLICY IF EXISTS "Users can update own proposals" ON public.proposals;
DROP POLICY IF EXISTS "Admins can view all proposals" ON public.proposals;
DROP POLICY IF EXISTS "Admins can update all proposals" ON public.proposals;

-- 3. Eliminar tablas existentes si existen
DROP TABLE IF EXISTS public.proposals CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- 4. Eliminar funciones existentes
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

-- 5. Crear tabla profiles
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    role TEXT DEFAULT 'user' CHECK (role IN ('admin', 'user')),
    company TEXT,
    phone TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Crear tabla proposals
CREATE TABLE public.proposals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    project_type TEXT NOT NULL CHECK (project_type IN ('web-app', 'mobile-app', 'api', 'ai-ml', 'python-app', 'other')),
    budget_range TEXT NOT NULL CHECK (budget_range IN ('1000-3000', '3000-5000', '5000-10000', '10000-20000', '20000+')),
    timeline TEXT NOT NULL CHECK (timeline IN ('1-2weeks', '3-4weeks', '1-2months', '3-6months', '6months+')),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'in_development', 'completed')),
    priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    features TEXT[],
    additional_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Crear índices
CREATE INDEX profiles_email_idx ON public.profiles(email);
CREATE INDEX profiles_role_idx ON public.profiles(role);
CREATE INDEX proposals_user_id_idx ON public.proposals(user_id);
CREATE INDEX proposals_status_idx ON public.proposals(status);
CREATE INDEX proposals_created_at_idx ON public.proposals(created_at);

-- 8. Función para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 9. Triggers para updated_at
CREATE TRIGGER update_profiles_updated_at 
    BEFORE UPDATE ON public.profiles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_proposals_updated_at 
    BEFORE UPDATE ON public.proposals 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 10. Deshabilitar RLS temporalmente para evitar recursión
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.proposals DISABLE ROW LEVEL SECURITY;

-- Mensaje de confirmación
SELECT 'Sistema reconstruido completamente - RLS deshabilitado temporalmente' as resultado;
