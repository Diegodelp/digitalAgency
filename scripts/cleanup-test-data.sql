-- Script para limpiar datos de prueba (opcional)
-- Solo ejecutar si quieres eliminar los datos de prueba

DO $$
DECLARE
    test_user_id UUID;
BEGIN
    -- Obtener ID del usuario de prueba
    SELECT id INTO test_user_id 
    FROM public.profiles 
    WHERE email = 'test@digitalpro.agency';

    IF test_user_id IS NOT NULL THEN
        -- Eliminar roadmaps
        DELETE FROM public.proposal_roadmap 
        WHERE proposal_id IN (
            SELECT id FROM public.proposals WHERE user_id = test_user_id
        );

        -- Eliminar propuestas
        DELETE FROM public.proposals WHERE user_id = test_user_id;

        -- Eliminar perfil
        DELETE FROM public.profiles WHERE id = test_user_id;

        -- Eliminar usuario de auth
        DELETE FROM auth.users WHERE id = test_user_id;

        RAISE NOTICE 'Datos de prueba eliminados para usuario: %', test_user_id;
    ELSE
        RAISE NOTICE 'No se encontró usuario de prueba para eliminar';
    END IF;
END $$;
