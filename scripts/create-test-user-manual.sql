-- Script para crear manualmente un usuario de prueba

DO $$
DECLARE
    test_user_id UUID := 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'; -- UUID fijo para pruebas
    existing_user_id UUID;
BEGIN
    -- Verificar si ya existe el usuario de prueba
    SELECT id INTO existing_user_id 
    FROM auth.users 
    WHERE email = 'test@digitalpro.agency';
    
    IF existing_user_id IS NOT NULL THEN
        RAISE NOTICE 'Usuario de prueba ya existe con ID: %', existing_user_id;
        test_user_id := existing_user_id;
    ELSE
        -- Crear usuario en auth.users
        INSERT INTO auth.users (
            id, 
            email, 
            encrypted_password,
            email_confirmed_at, 
            created_at, 
            updated_at,
            raw_user_meta_data,
            aud,
            role
        ) VALUES (
            test_user_id,
            'test@digitalpro.agency',
            crypt('test123', gen_salt('bf')), -- Contraseña: test123
            NOW(),
            NOW(),
            NOW(),
            '{"full_name": "Usuario de Prueba"}',
            'authenticated',
            'authenticated'
        );
        
        RAISE NOTICE 'Usuario de prueba creado en auth.users con ID: %', test_user_id;
    END IF;
    
    -- Crear o actualizar perfil
    INSERT INTO public.profiles (id, email, full_name, role, company, created_at)
    VALUES (
        test_user_id,
        'test@digitalpro.agency',
        'Usuario de Prueba',
        'user',
        'Empresa Test',
        NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
        full_name = 'Usuario de Prueba',
        company = 'Empresa Test',
        role = 'user';
    
    RAISE NOTICE 'Perfil de prueba creado/actualizado';
    
    -- Crear propuestas de ejemplo
    INSERT INTO public.proposals (
        id,
        user_id,
        title,
        description,
        project_type,
        budget_range,
        timeline,
        status,
        priority,
        features,
        created_at
    ) VALUES 
    (
        gen_random_uuid(),
        test_user_id,
        'Sistema de Análisis de Datos con Python',
        'Necesito un sistema que analice datos de ventas y genere reportes automáticos usando Python y machine learning.',
        'python-app',
        '5000-10000',
        '1-2months',
        'pending',
        'high',
        ARRAY['Machine Learning', 'Análisis de datos', 'Automatización de procesos', 'Panel de administración'],
        NOW() - INTERVAL '2 days'
    ),
    (
        gen_random_uuid(),
        test_user_id,
        'API REST para E-commerce',
        'API completa para tienda online con autenticación, carrito de compras y pasarela de pagos.',
        'api',
        '3000-5000',
        '3-4weeks',
        'approved',
        'medium',
        ARRAY['API REST', 'Autenticación de usuarios', 'Integración de pagos', 'Base de datos'],
        NOW() - INTERVAL '1 day'
    )
    ON CONFLICT DO NOTHING;
    
    RAISE NOTICE 'Propuestas de ejemplo creadas';
    
END $$;

-- Verificar que todo se creó correctamente
SELECT 
    'Verificación' as "Tipo",
    au.email as "Email",
    p.full_name as "Nombre",
    p.role as "Rol",
    p.company as "Empresa",
    (SELECT COUNT(*) FROM public.proposals WHERE user_id = au.id) as "Propuestas"
FROM auth.users au
JOIN public.profiles p ON au.id = p.id
WHERE au.email = 'test@digitalpro.agency';
