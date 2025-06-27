-- Script para crear un roadmap de ejemplo en una propuesta aprobada
-- Ejecutar DESPUÉS de test-data-fixed.sql

DO $$
DECLARE
    approved_proposal_id UUID;
BEGIN
    -- Buscar una propuesta aprobada
    SELECT id INTO approved_proposal_id
    FROM public.proposals 
    WHERE status = 'approved' 
    LIMIT 1;

    -- Si encontramos una propuesta aprobada, verificar que tenga roadmap
    IF approved_proposal_id IS NOT NULL THEN
        -- Verificar si ya tiene roadmap
        IF NOT EXISTS (SELECT 1 FROM public.proposal_roadmap WHERE proposal_id = approved_proposal_id) THEN
            -- Crear roadmap manualmente
            INSERT INTO public.proposal_roadmap (proposal_id, step_order, title, description, estimated_days, status, started_at) VALUES
            (approved_proposal_id, 1, 'Análisis de Requisitos', 'Revisión detallada de la propuesta y definición de alcance', 3, 'completed', NOW() - INTERVAL '10 days'),
            (approved_proposal_id, 2, 'Diseño y Arquitectura', 'Creación de wireframes, diseño UI/UX y arquitectura del sistema', 5, 'completed', NOW() - INTERVAL '7 days'),
            (approved_proposal_id, 3, 'Configuración del Entorno', 'Setup de repositorios, CI/CD, base de datos y entornos', 2, 'in_progress', NOW() - INTERVAL '2 days'),
            (approved_proposal_id, 4, 'Desarrollo Backend/Python', 'Implementación de APIs, lógica de negocio y scripts Python', 10, 'not_started', NULL),
            (approved_proposal_id, 5, 'Desarrollo Frontend', 'Implementación de la interfaz de usuario', 8, 'not_started', NULL),
            (approved_proposal_id, 6, 'Testing y QA', 'Pruebas unitarias, integración y testing de usuario', 4, 'not_started', NULL),
            (approved_proposal_id, 7, 'Despliegue y Entrega', 'Despliegue en producción y entrega final', 2, 'not_started', NULL);

            -- Marcar los pasos completados
            UPDATE public.proposal_roadmap 
            SET completed_at = NOW() - INTERVAL '7 days', actual_days = 2
            WHERE proposal_id = approved_proposal_id AND step_order = 1;

            UPDATE public.proposal_roadmap 
            SET completed_at = NOW() - INTERVAL '2 days', actual_days = 5
            WHERE proposal_id = approved_proposal_id AND step_order = 2;

            RAISE NOTICE 'Roadmap creado para propuesta: %', approved_proposal_id;
        ELSE
            RAISE NOTICE 'La propuesta ya tiene roadmap: %', approved_proposal_id;
        END IF;
    ELSE
        RAISE NOTICE 'No se encontró ninguna propuesta aprobada';
    END IF;
END $$;

-- Verificar el roadmap creado
SELECT 
    p.title as propuesta,
    r.step_order,
    r.title as etapa,
    r.status,
    r.estimated_days,
    r.actual_days,
    r.started_at,
    r.completed_at
FROM public.proposal_roadmap r
JOIN public.proposals p ON r.proposal_id = p.id
ORDER BY r.proposal_id, r.step_order;
