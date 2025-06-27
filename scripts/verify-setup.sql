-- Script para verificar que todo esté configurado correctamente

-- 1. Verificar tipos creados
SELECT 
    typname as "Tipo",
    CASE 
        WHEN typname = 'user_role' THEN 'Roles de usuario'
        WHEN typname = 'proposal_status' THEN 'Estados de propuesta'
        WHEN typname = 'project_status' THEN 'Estados de proyecto'
        WHEN typname = 'priority_level' THEN 'Niveles de prioridad'
        WHEN typname = 'roadmap_step_status' THEN 'Estados de roadmap'
    END as "Descripción"
FROM pg_type 
WHERE typname IN ('user_role', 'proposal_status', 'project_status', 'priority_level', 'roadmap_step_status')
ORDER BY typname;

-- 2. Verificar tablas creadas
SELECT 
    tablename as "Tabla",
    CASE 
        WHEN tablename = 'profiles' THEN 'Perfiles de usuario'
        WHEN tablename = 'proposals' THEN 'Propuestas de proyecto'
        WHEN tablename = 'proposal_roadmap' THEN 'Roadmap de propuestas'
        WHEN tablename = 'projects' THEN 'Proyectos'
        WHEN tablename = 'project_milestones' THEN 'Hitos de proyecto'
        WHEN tablename = 'project_technologies' THEN 'Tecnologías de proyecto'
    END as "Descripción"
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('profiles', 'proposals', 'proposal_roadmap', 'projects', 'project_milestones', 'project_technologies')
ORDER BY tablename;

-- 3. Verificar políticas RLS
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd as "Comando"
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- 4. Verificar funciones
SELECT 
    proname as "Función",
    CASE 
        WHEN proname = 'handle_updated_at' THEN 'Actualizar timestamp'
        WHEN proname = 'handle_new_user' THEN 'Crear perfil automático'
        WHEN proname = 'create_proposal_roadmap' THEN 'Crear roadmap automático'
    END as "Descripción"
FROM pg_proc 
WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
AND proname IN ('handle_updated_at', 'handle_new_user', 'create_proposal_roadmap')
ORDER BY proname;

-- 5. Verificar triggers
SELECT 
    trigger_name as "Trigger",
    event_object_table as "Tabla",
    action_timing as "Momento",
    event_manipulation as "Evento"
FROM information_schema.triggers 
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- 6. Estadísticas de datos
SELECT 
    'Usuarios totales' as "Métrica",
    COUNT(*) as "Valor"
FROM public.profiles
UNION ALL
SELECT 
    'Usuarios admin' as "Métrica",
    COUNT(*) as "Valor"
FROM public.profiles
WHERE role = 'admin'
UNION ALL
SELECT 
    'Propuestas totales' as "Métrica",
    COUNT(*) as "Valor"
FROM public.proposals
UNION ALL
SELECT 
    'Roadmaps creados' as "Métrica",
    COUNT(DISTINCT proposal_id) as "Valor"
FROM public.proposal_roadmap;
