-- Script para crear un roadmap de ejemplo en una propuesta aprobada
-- Ejecutar DESPUÉS de test-data-corrected.sql

DO $$
DECLARE
    approved_proposal_id UUID;
    in_dev_proposal_id UUID;
BEGIN
    -- Buscar propuesta aprobada
    SELECT id INTO approved_proposal_id
    FROM public.proposals 
    WHERE status = 'approved' 
    AND user_id IN (SELECT id FROM public.profiles WHERE email = 'test@digitalpro.agency')
    LIMIT 1;

    -- Buscar propuesta en desarrollo
    SELECT id INTO in_dev_proposal_id
    FROM public.proposals 
    WHERE status = 'in_development' 
    AND user_id IN (SELECT id FROM public.profiles WHERE email = 'test@digitalpro.agency')
    LIMIT 1;

    -- Crear roadmap para propuesta aprobada
    IF approved_proposal_id IS NOT NULL THEN
        -- Eliminar roadmap existente si lo hay
        DELETE FROM public.proposal_roadmap WHERE proposal_id = approved_proposal_id;
        
        -- Crear roadmap nuevo
        INSERT INTO public.proposal_roadmap (proposal_id, step_order, title, description, estimated_days, status, started_at) VALUES
        (approved_proposal_id, 1, 'Análisis de Requisitos', 'Revisión detallada de la propuesta y definición de alcance', 3, 'completed', NOW() - INTERVAL '10 days'),
        (approved_proposal_id, 2, 'Diseño y Arquitectura', 'Creación de wireframes, diseño UI/UX y arquitectura del sistema', 5, 'in_progress', NOW() - INTERVAL '3 days'),
        (approved_proposal_id, 3, 'Configuración del Entorno', 'Setup de repositorios, CI/CD, base de datos y entornos', 2, 'not_started', NULL),
        (approved_proposal_id, 4, 'Desarrollo Backend/Python', 'Implementación de APIs, lógica de negocio y scripts Python', 10, 'not_started', NULL),
        (approved_proposal_id, 5, 'Desarrollo Frontend', 'Implementación de la interfaz de usuario', 8, 'not_started', NULL),
        (approved_proposal_id, 6, 'Testing y QA', 'Pruebas unitarias, integración y testing de usuario', 4, 'not_started', NULL),
        (approved_proposal_id, 7, 'Despliegue y Entrega', 'Despliegue en producción y entrega final', 2, 'not_started', NULL);

        -- Marcar el primer paso como completado
        UPDATE public.proposal_roadmap 
        SET completed_at = NOW() - INTERVAL '7 days', actual_days = 2
        WHERE proposal_id = approved_proposal_id AND step_order = 1;

        RAISE NOTICE 'Roadmap creado para propuesta aprobada: %', approved_proposal_id;
    END IF;

    -- Crear roadmap para propuesta en desarrollo
    IF in_dev_proposal_id IS NOT NULL THEN
        -- Eliminar roadmap existente si lo hay
        DELETE FROM public.proposal_roadmap WHERE proposal_id = in_dev_proposal_id;
        
        -- Crear roadmap más avanzado
        INSERT INTO public.proposal_roadmap (proposal_id, step_order, title, description, estimated_days, status, started_at, completed_at, actual_days) VALUES
        (in_dev_proposal_id, 1, 'Análisis de Requisitos', 'Revisión detallada de la propuesta y definición de alcance', 3, 'completed', NOW() - INTERVAL '20 days', NOW() - INTERVAL '17 days', 3),
        (in_dev_proposal_id, 2, 'Diseño y Arquitectura', 'Creación de wireframes, diseño UI/UX y arquitectura del sistema', 5, 'completed', NOW() - INTERVAL '17 days', NOW() - INTERVAL '12 days', 5),
        (in_dev_proposal_id, 3, 'Configuración del Entorno', 'Setup de repositorios, CI/CD, base de datos y entornos', 2, 'completed', NOW() - INTERVAL '12 days', NOW() - INTERVAL '10 days', 2),
        (in_dev_proposal_id, 4, 'Desarrollo Backend/Python', 'Implementación de APIs, lógica de negocio y scripts Python', 10, 'in_progress', NOW() - INTERVAL '10 days', NULL, NULL),
        (in_dev_proposal_id, 5, 'Desarrollo Frontend', 'Implementación de la interfaz de usuario', 8, 'not_started', NULL, NULL, NULL),
        (in_dev_proposal_id, 6, 'Testing y QA', 'Pruebas unitarias, integración y testing de usuario', 4, 'not_started', NULL, NULL, NULL),
        (in_dev_proposal_id, 7, 'Despliegue y Entrega', 'Despliegue en producción y entrega final', 2, 'not_started', NULL, NULL, NULL);

        RAISE NOTICE 'Roadmap creado para propuesta en desarrollo: %', in_dev_proposal_id;
    END IF;

    -- Si no encontramos propuestas, mostrar mensaje
    IF approved_proposal_id IS NULL AND in_dev_proposal_id IS NULL THEN
        RAISE NOTICE 'No se encontraron propuestas aprobadas o en desarrollo para crear roadmaps';
    END IF;

END $$;
