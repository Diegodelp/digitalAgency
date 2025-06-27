-- Create custom types only if they don't exist
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('user', 'admin');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE proposal_status AS ENUM ('pending', 'in_review', 'approved', 'rejected', 'in_development', 'completed');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE project_status AS ENUM ('planning', 'in_progress', 'review', 'completed', 'on_hold');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE priority_level AS ENUM ('low', 'medium', 'high', 'urgent');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE roadmap_step_status AS ENUM ('not_started', 'in_progress', 'completed', 'blocked');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Create proposal_roadmap table (nueva tabla para el roadmap interno)
CREATE TABLE IF NOT EXISTS public.proposal_roadmap (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  proposal_id UUID REFERENCES public.proposals(id) ON DELETE CASCADE NOT NULL,
  step_order INTEGER NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  estimated_days INTEGER DEFAULT 1,
  actual_days INTEGER,
  status roadmap_step_status DEFAULT 'not_started',
  started_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(proposal_id, step_order)
);

-- Add new columns to proposals table if they don't exist
DO $$ BEGIN
    ALTER TABLE public.proposals ADD COLUMN estimated_completion_date DATE;
EXCEPTION
    WHEN duplicate_column THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE public.proposals ADD COLUMN actual_start_date DATE;
EXCEPTION
    WHEN duplicate_column THEN null;
END $$;

-- Remove ClickUp columns if they exist
DO $$ BEGIN
    ALTER TABLE public.proposals DROP COLUMN IF EXISTS clickup_task_id;
EXCEPTION
    WHEN others THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE public.projects DROP COLUMN IF EXISTS clickup_list_id;
EXCEPTION
    WHEN others THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE public.projects DROP COLUMN IF EXISTS clickup_folder_id;
EXCEPTION
    WHEN others THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE public.project_milestones DROP COLUMN IF EXISTS clickup_task_id;
EXCEPTION
    WHEN others THEN null;
END $$;

-- Enable Row Level Security for new table
ALTER TABLE public.proposal_roadmap ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for proposal_roadmap
DROP POLICY IF EXISTS "Users can view roadmap of own proposals" ON public.proposal_roadmap;
CREATE POLICY "Users can view roadmap of own proposals" ON public.proposal_roadmap
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.proposals 
      WHERE id = proposal_id AND user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admins can manage all roadmaps" ON public.proposal_roadmap;
CREATE POLICY "Admins can manage all roadmaps" ON public.proposal_roadmap
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Create trigger for updated_at on proposal_roadmap
DROP TRIGGER IF EXISTS handle_proposal_roadmap_updated_at ON public.proposal_roadmap;
CREATE TRIGGER handle_proposal_roadmap_updated_at
  BEFORE UPDATE ON public.proposal_roadmap
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Function to create default roadmap when proposal is approved
CREATE OR REPLACE FUNCTION public.create_proposal_roadmap()
RETURNS TRIGGER AS $$
BEGIN
  -- Only create roadmap when status changes to 'approved'
  IF NEW.status = 'approved' AND (OLD.status IS NULL OR OLD.status != 'approved') THEN
    -- Delete existing roadmap if any
    DELETE FROM public.proposal_roadmap WHERE proposal_id = NEW.id;
    
    -- Insert default roadmap steps
    INSERT INTO public.proposal_roadmap (proposal_id, step_order, title, description, estimated_days) VALUES
    (NEW.id, 1, 'Análisis de Requisitos', 'Revisión detallada de la propuesta y definición de alcance', 3),
    (NEW.id, 2, 'Diseño y Arquitectura', 'Creación de wireframes, diseño UI/UX y arquitectura del sistema', 5),
    (NEW.id, 3, 'Configuración del Entorno', 'Setup de repositorios, CI/CD, base de datos y entornos', 2),
    (NEW.id, 4, 'Desarrollo Backend/Python', 'Implementación de APIs, lógica de negocio y scripts Python', 10),
    (NEW.id, 5, 'Desarrollo Frontend', 'Implementación de la interfaz de usuario', 8),
    (NEW.id, 6, 'Testing y QA', 'Pruebas unitarias, integración y testing de usuario', 4),
    (NEW.id, 7, 'Despliegue y Entrega', 'Despliegue en producción y entrega final', 2);
    
    -- Start the first step
    UPDATE public.proposal_roadmap 
    SET status = 'in_progress', started_at = NOW()
    WHERE proposal_id = NEW.id AND step_order = 1;
    
    -- Set estimated completion date
    UPDATE public.proposals 
    SET estimated_completion_date = CURRENT_DATE + INTERVAL '34 days'
    WHERE id = NEW.id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop and recreate trigger for roadmap creation
DROP TRIGGER IF EXISTS create_roadmap_on_approval ON public.proposals;
CREATE TRIGGER create_roadmap_on_approval
  AFTER UPDATE ON public.proposals
  FOR EACH ROW EXECUTE FUNCTION public.create_proposal_roadmap();

-- Ensure the handle_new_user function exists and works correctly
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'),
    NEW.raw_user_meta_data->>'avatar_url'
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = COALESCE(EXCLUDED.full_name, public.profiles.full_name),
    avatar_url = COALESCE(EXCLUDED.avatar_url, public.profiles.avatar_url);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Ensure trigger exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Update RLS policy for profiles to allow INSERT
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);
