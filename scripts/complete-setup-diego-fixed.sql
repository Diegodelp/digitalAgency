-- Script completo corregido para configurar todo para Diego

-- 1. Primero verificar el estado actual
SELECT 
    'Estado Inicial' as "Paso",
    'auth.users' as "Tabla",
    COUNT(*) as "Registros",
    COALESCE(string_agg(email, ', '), 'Ninguno') as "Emails"
FROM auth.users
WHERE email = 'diegodelp22@gmail.com'
UNION ALL
SELECT 
    'Estado Inicial' as "Paso",
    'public.profiles' as "Tabla",
    COUNT(*) as "Registros",
    COALESCE(string_agg(email, ', '), 'Ninguno') as "Emails"
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
    
    -- Crear/actualizar perfil (sin ON CONFLICT, usando IF/ELSE)
    IF profile_exists THEN
        UPDATE public.profiles 
        SET 
            role = 'admin',
            full_name = 'Diego - Administrador Principal',
            company = 'DigitalPro Agency'
        WHERE id = diego_id;
        
        RAISE NOTICE 'Perfil de Diego actualizado a administrador';
    ELSE
        INSERT INTO public.profiles (id, email, full_name, role, company, created_at)
        VALUES (
            diego_id,
            diego_email,
            'Diego - Administrador Principal',
            'admin',
            'DigitalPro Agency',
            NOW()
        );
        
        RAISE NOTICE 'Perfil de administrador creado para Diego';
    END IF;
    
END $$;

-- 3. Crear usuario de prueba
DO $$
DECLARE
    test_email TEXT := 'test@digitalpro.agency';
    test_id UUID;
    test_auth_exists BOOLEAN := FALSE;
    test_profile_exists BOOLEAN := FALSE;
BEGIN
    -- Verificar si existe el usuario de prueba
    SELECT EXISTS(SELECT 1 FROM auth.users WHERE email = test_email) INTO test_auth_exists;
    SELECT EXISTS(SELECT 1 FROM public.profiles WHERE email = test_email) INTO test_profile_exists;
    
    -- Crear en auth.users si no existe
    IF NOT test_auth_exists THEN
        test_id := gen_random_uuid();
        
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
            test_id,
            test_email,
            crypt('test123', gen_salt('bf')),
            NOW(),
            NOW(),
            NOW(),
            '{"full_name": "Usuario de Prueba"}',
            'authenticated',
            'authenticated'
        );
        
        RAISE NOTICE 'Usuario de prueba creado en auth.users';
    ELSE
        SELECT id INTO test_id FROM auth.users WHERE email = test_email;
        RAISE NOTICE 'Usuario de prueba ya existe en auth.users';
    END IF;
    
    -- Crear perfil si no existe
    IF NOT test_profile_exists THEN
        INSERT INTO public.profiles (id, email, full_name, role, company, created_at)
        VALUES (
            test_id,
            test_email,
            'Usuario de Prueba',
            'user',
            'Empresa Test',
            NOW()
        );
        
        RAISE NOTICE 'Perfil de usuario de prueba creado';
    ELSE
        RAISE NOTICE 'Perfil de usuario de prueba ya existe';
    END IF;
    
END $$;

-- 4. Crear propuestas de ejemplo
DO $$
DECLARE
    test_user_id UUID;
    proposal_count INTEGER;
BEGIN
    SELECT id INTO test_user_id FROM auth.users WHERE email = 'test@digitalpro.agency';
    
    IF test_user_id IS NOT NULL THEN
        -- Verificar si ya existen propuestas
        SELECT COUNT(*) INTO proposal_count FROM public.proposals WHERE user_id = test_user_id;
        
        IF proposal_count = 0 THEN
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
            );
            
            RAISE NOTICE 'Propuestas de ejemplo creadas (3 propuestas)';
        ELSE
            RAISE NOTICE 'Ya existen % propuestas para el usuario de prueba', proposal_count;
        END IF;
    ELSE
        RAISE NOTICE 'No se pudo encontrar el usuario de prueba para crear propuestas';
    END IF;
END $$;

-- 5. Verificación final
SELECT 
    '=== RESUMEN FINAL ===' as "Estado",
    '' as "Detalle",
    '' as "Valor";

SELECT 
    'Usuarios Totales' as "Métrica",
    COUNT(*)::text as "Valor",
    string_agg(email, ', ') as "Emails"
FROM auth.users
UNION ALL
SELECT 
    'Perfiles Totales' as "Métrica",
    COUNT(*)::text as "Valor",
    string_agg(email, ', ') as "Emails"
FROM public.profiles
UNION ALL
SELECT 
    'Administradores' as "Métrica",
    COUNT(*)::text as "Valor",
    string_agg(email, ', ') as "Emails"
FROM public.profiles
WHERE role = 'admin'
UNION ALL
SELECT 
    'Propuestas Totales' as "Métrica",
    COUNT(*)::text as "Valor",
    string_agg(title, '; ') as "Títulos"
FROM public.proposals;

-- Mostrar detalles de Diego
SELECT 
    '=== DIEGO ADMIN ===' as "Tipo",
    p.email as "Email",
    p.full_name as "Nombre",
    p.role as "Rol",
    p.company as "Empresa",
    p.created_at::date as "Creado"
FROM public.profiles p
WHERE p.email = 'diegodelp22@gmail.com';

-- Mostrar propuestas de ejemplo
SELECT 
    '=== PROPUESTAS ===' as "Tipo",
    p.title as "Título",
    p.status as "Estado",
    p.priority as "Prioridad",
    pr.email as "Usuario",
    p.created_at::date as "Creado"
FROM public.proposals p
JOIN public.profiles pr ON p.user_id = pr.id
ORDER BY p.created_at DESC;

-- Mostrar credenciales para login
SELECT 
    '=== CREDENCIALES ===' as "Tipo",
    'diegodelp22@gmail.com' as "Email_Admin",
    'admin123' as "Password_Admin",
    'test@digitalpro.agency' as "Email_Test",
    'test123' as "Password_Test";
