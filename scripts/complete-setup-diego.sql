-- Script completo para configurar todo para Diego

-- 1. Primero verificar el estado actual
SELECT 
    'Estado Inicial' as "Paso",
    'auth.users' as "Tabla",
    COUNT(*) as "Registros",
    string_agg(email, ', ') as "Emails"
FROM auth.users
WHERE email = 'diegodelp22@gmail.com'
UNION ALL
SELECT 
    'Estado Inicial' as "Paso",
    'public.profiles' as "Tabla",
    COUNT(*) as "Registros",
    string_agg(email, ', ') as "Emails"
FROM public.profiles
WHERE email = 'diegodelp22@gmail.com';

-- 2. Crear Diego si no existe
DO $$
DECLARE
    diego_email TEXT := 'diegodelp22@gmail.com';
    diego_id UUID;
    auth_exists BOOLEAN := FALSE;
    profile_exists BOOLEAN := FALSE;
BEGIN
    -- Verificar existencia en auth.users
    SELECT EXISTS(SELECT 1 FROM auth.users WHERE email = diego_email) INTO auth_exists;
    SELECT EXISTS(SELECT 1 FROM public.profiles WHERE email = diego_email) INTO profile_exists;
    
    RAISE NOTICE 'Estado: Auth=%, Profile=%', auth_exists, profile_exists;
    
    -- Si no existe en auth.users, crearlo
    IF NOT auth_exists THEN
        diego_id := gen_random_uuid();
        
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
            diego_id,
            diego_email,
            crypt('admin123', gen_salt('bf')),
            NOW(),
            NOW(),
            NOW(),
            '{"full_name": "Diego Admin"}',
            'authenticated',
            'authenticated'
        );
        
        RAISE NOTICE 'Diego creado en auth.users con contraseña: admin123';
    ELSE
        SELECT id INTO diego_id FROM auth.users WHERE email = diego_email;
        RAISE NOTICE 'Diego ya existe en auth.users';
    END IF;
    
    -- Crear/actualizar perfil
    INSERT INTO public.profiles (id, email, full_name, role, company, created_at)
    VALUES (
        diego_id,
        diego_email,
        'Diego - Administrador Principal',
        'admin',
        'DigitalPro Agency',
        NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
        role = 'admin',
        full_name = 'Diego - Administrador Principal',
        company = 'DigitalPro Agency';
    
    RAISE NOTICE 'Perfil de administrador configurado para Diego';
    
END $$;

-- 3. Crear datos de prueba adicionales
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
    gen_random_uuid(),
    'test@digitalpro.agency',
    crypt('test123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '{"full_name": "Usuario de Prueba"}',
    'authenticated',
    'authenticated'
) ON CONFLICT (email) DO NOTHING;

-- Crear perfil para usuario de prueba
INSERT INTO public.profiles (id, email, full_name, role, company, created_at)
SELECT 
    au.id,
    au.email,
    'Usuario de Prueba',
    'user',
    'Empresa Test',
    NOW()
FROM auth.users au
WHERE au.email = 'test@digitalpro.agency'
ON CONFLICT (id) DO UPDATE SET
    full_name = 'Usuario de Prueba',
    company = 'Empresa Test';

-- 4. Crear propuestas de ejemplo
DO $$
DECLARE
    test_user_id UUID;
BEGIN
    SELECT id INTO test_user_id FROM auth.users WHERE email = 'test@digitalpro.agency';
    
    IF test_user_id IS NOT NULL THEN
        INSERT INTO public.proposals (
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
            test_user_id,
            'Sistema de Análisis de Datos con Python',
            'Sistema completo de análisis de datos usando Python, pandas, y machine learning para generar reportes automáticos.',
            'python-app',
            '5000-10000',
            '1-2months',
            'pending',
            'high',
            ARRAY['Machine Learning', 'Análisis de datos', 'Automatización de procesos', 'Panel de administración'],
            NOW() - INTERVAL '2 days'
        ),
        (
            test_user_id,
            'API REST para E-commerce',
            'API completa para tienda online con autenticación JWT, carrito de compras, pasarela de pagos y gestión de inventario.',
            'api',
            '3000-5000',
            '3-4weeks',
            'approved',
            'medium',
            ARRAY['API REST', 'Autenticación de usuarios', 'Integración de pagos', 'Base de datos'],
            NOW() - INTERVAL '1 day'
        ),
        (
            test_user_id,
            'Dashboard Analytics con IA',
            'Panel de control inteligente con predicciones usando machine learning y visualizaciones interactivas.',
            'ai-ml',
            '10000-20000',
            '3-6months',
            'in_development',
            'high',
            ARRAY['Machine Learning', 'Panel de administración', 'Análisis de datos', 'Diseño responsive'],
            NOW() - INTERVAL '3 hours'
        )
        ON CONFLICT DO NOTHING;
        
        RAISE NOTICE 'Propuestas de ejemplo creadas';
    END IF;
END $$;

-- 5. Verificación final
SELECT 
    'RESUMEN FINAL' as "=== ESTADO ===",
    '' as "Detalle";

SELECT 
    'Usuarios Totales' as "Métrica",
    COUNT(*)::text as "Valor"
FROM auth.users
UNION ALL
SELECT 
    'Perfiles Totales' as "Métrica",
    COUNT(*)::text as "Valor"
FROM public.profiles
UNION ALL
SELECT 
    'Administradores' as "Métrica",
    COUNT(*)::text as "Valor"
FROM public.profiles
WHERE role = 'admin'
UNION ALL
SELECT 
    'Propuestas Totales' as "Métrica",
    COUNT(*)::text as "Valor"
FROM public.proposals;

-- Mostrar detalles de Diego
SELECT 
    '=== DIEGO ADMIN ===' as "Info",
    p.email,
    p.full_name,
    p.role,
    p.company,
    p.created_at
FROM public.profiles p
WHERE p.email = 'diegodelp22@gmail.com';

-- Mostrar propuestas de ejemplo
SELECT 
    '=== PROPUESTAS ===' as "Info",
    p.title,
    p.status,
    p.priority,
    pr.email as "Usuario"
FROM public.proposals p
JOIN public.profiles pr ON p.user_id = pr.id
ORDER BY p.created_at DESC;
