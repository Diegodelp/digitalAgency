-- Script seguro para corregir problemas de login sin duplicados

-- 1. Primero diagnosticar el estado actual
SELECT 
    'ESTADO ACTUAL' as "Diagnóstico",
    'auth.users' as "Tabla",
    COUNT(*) as "Total",
    string_agg(email, ', ') as "Emails"
FROM auth.users
UNION ALL
SELECT 
    'ESTADO ACTUAL' as "Diagnóstico",
    'public.profiles' as "Tabla",
    COUNT(*) as "Total",
    string_agg(email, ', ') as "Emails"
FROM public.profiles;

-- 2. Función para actualizar contraseñas de usuarios existentes
DO $$
DECLARE
    diego_id UUID;
    test_id UUID;
    diego_exists BOOLEAN := FALSE;
    test_exists BOOLEAN := FALSE;
BEGIN
    -- Verificar si Diego existe en auth.users
    SELECT id INTO diego_id FROM auth.users WHERE email = 'diegodelp22@gmail.com';
    diego_exists := (diego_id IS NOT NULL);
    
    -- Verificar si test user existe en auth.users
    SELECT id INTO test_id FROM auth.users WHERE email = 'test@digitalpro.agency';
    test_exists := (test_id IS NOT NULL);
    
    RAISE NOTICE 'Diego existe: %, Test existe: %', diego_exists, test_exists;
    
    -- Actualizar contraseña de Diego si existe
    IF diego_exists THEN
        UPDATE auth.users 
        SET 
            encrypted_password = crypt('admin123', gen_salt('bf', 10)),
            email_confirmed_at = NOW(),
            updated_at = NOW()
        WHERE email = 'diegodelp22@gmail.com';
        
        -- Actualizar o crear perfil de Diego
        INSERT INTO public.profiles (id, email, full_name, role, company, created_at)
        VALUES (
            diego_id,
            'diegodelp22@gmail.com',
            'Diego - Administrador Principal',
            'admin',
            'DigitalPro Agency',
            NOW()
        )
        ON CONFLICT (id) DO UPDATE SET
            role = 'admin',
            full_name = 'Diego - Administrador Principal',
            company = 'DigitalPro Agency';
            
        RAISE NOTICE 'Diego actualizado como admin';
    ELSE
        -- Crear Diego desde cero
        diego_id := gen_random_uuid();
        
        INSERT INTO auth.users (
            instance_id,
            id,
            aud,
            role,
            email,
            encrypted_password,
            email_confirmed_at,
            created_at,
            updated_at,
            raw_app_meta_data,
            raw_user_meta_data
        ) VALUES (
            '00000000-0000-0000-0000-000000000000',
            diego_id,
            'authenticated',
            'authenticated',
            'diegodelp22@gmail.com',
            crypt('admin123', gen_salt('bf', 10)),
            NOW(),
            NOW(),
            NOW(),
            '{"provider": "email", "providers": ["email"]}',
            '{"full_name": "Diego Admin"}'
        );
        
        INSERT INTO public.profiles (id, email, full_name, role, company, created_at)
        VALUES (
            diego_id,
            'diegodelp22@gmail.com',
            'Diego - Administrador Principal',
            'admin',
            'DigitalPro Agency',
            NOW()
        );
        
        RAISE NOTICE 'Diego creado como admin';
    END IF;
    
    -- Actualizar contraseña del usuario test si existe
    IF test_exists THEN
        UPDATE auth.users 
        SET 
            encrypted_password = crypt('test123', gen_salt('bf', 10)),
            email_confirmed_at = NOW(),
            updated_at = NOW()
        WHERE email = 'test@digitalpro.agency';
        
        -- Actualizar o crear perfil de test
        INSERT INTO public.profiles (id, email, full_name, role, company, created_at)
        VALUES (
            test_id,
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
            
        RAISE NOTICE 'Usuario test actualizado';
    ELSE
        -- Crear usuario test desde cero
        test_id := gen_random_uuid();
        
        INSERT INTO auth.users (
            instance_id,
            id,
            aud,
            role,
            email,
            encrypted_password,
            email_confirmed_at,
            created_at,
            updated_at,
            raw_app_meta_data,
            raw_user_meta_data
        ) VALUES (
            '00000000-0000-0000-0000-000000000000',
            test_id,
            'authenticated',
            'authenticated',
            'test@digitalpro.agency',
            crypt('test123', gen_salt('bf', 10)),
            NOW(),
            NOW(),
            NOW(),
            '{"provider": "email", "providers": ["email"]}',
            '{"full_name": "Usuario de Prueba"}'
        );
        
        INSERT INTO public.profiles (id, email, full_name, role, company, created_at)
        VALUES (
            test_id,
            'test@digitalpro.agency',
            'Usuario de Prueba',
            'user',
            'Empresa Test',
            NOW()
        );
        
        RAISE NOTICE 'Usuario test creado';
    END IF;
    
END $$;
