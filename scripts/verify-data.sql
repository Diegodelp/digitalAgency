-- Script para verificar que los datos de prueba se crearon correctamente

-- 1. Verificar usuario de prueba
SELECT 
    'Usuario de prueba' as "Tipo",
    p.email,
    p.full_name,
    p.role,
    p.company,
    p.created_at
FROM public.profiles p
WHERE p.email = 'test@digitalpro.agency';

-- 2. Verificar propuestas
SELECT 
    'Propuestas' as "Tipo",
    p.title,
    p.project_type,
    p.status,
    p.priority,
    p.budget_range,
    array_length(p.features, 1) as "Num_Features"
FROM public.proposals p
JOIN public.profiles pr ON p.user_id = pr.id
WHERE pr.email = 'test@digitalpro.agency'
ORDER BY p.created_at;

-- 3. Verificar roadmaps
SELECT 
    'Roadmaps' as "Tipo",
    prop.title as "Propuesta",
    r.step_order as "Paso",
    r.title as "Etapa",
    r.status as "Estado",
    r.estimated_days as "Días_Estimados",
    r.actual_days as "Días_Reales",
    CASE 
        WHEN r.started_at IS NOT NULL THEN 'Sí'
        ELSE 'No'
    END as "Iniciado",
    CASE 
        WHEN r.completed_at IS NOT NULL THEN 'Sí'
        ELSE 'No'
    END as "Completado"
FROM public.proposal_roadmap r
JOIN public.proposals prop ON r.proposal_id = prop.id
JOIN public.profiles pr ON prop.user_id = pr.id
WHERE pr.email = 'test@digitalpro.agency'
ORDER BY prop.title, r.step_order;

-- 4. Estadísticas generales
SELECT 
    'Estadísticas' as "Tipo",
    'Total usuarios' as "Métrica",
    COUNT(*)::text as "Valor"
FROM public.profiles
UNION ALL
SELECT 
    'Estadísticas' as "Tipo",
    'Total propuestas' as "Métrica",
    COUNT(*)::text as "Valor"
FROM public.proposals
UNION ALL
SELECT 
    'Estadísticas' as "Tipo",
    'Propuestas con roadmap' as "Métrica",
    COUNT(DISTINCT proposal_id)::text as "Valor"
FROM public.proposal_roadmap
UNION ALL
SELECT 
    'Estadísticas' as "Tipo",
    'Etapas completadas' as "Métrica",
    COUNT(*)::text as "Valor"
FROM public.proposal_roadmap
WHERE status = 'completed';

-- 5. Verificar que los triggers funcionan
SELECT 
    'Triggers' as "Tipo",
    trigger_name as "Nombre",
    event_object_table as "Tabla",
    action_timing || ' ' || event_manipulation as "Evento"
FROM information_schema.triggers 
WHERE trigger_schema = 'public'
AND trigger_name IN ('on_auth_user_created', 'create_roadmap_on_approval')
ORDER BY event_object_table;
