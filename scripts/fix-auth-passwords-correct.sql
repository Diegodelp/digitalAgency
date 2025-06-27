-- Script para corregir las contraseñas correctamente

-- 1. Verificar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 2. Función para crear/actualizar usuarios con contraseñas correctas
DO $$
DECLARE
    diego_id UUID;
    test_id UUID;
    diego_password TEXT;
    test_password TEXT;
BEGIN
    -- Generar hashes de contraseñas
    diego_password := crypt('admin123', gen_salt('bf'));
    test_password := crypt('test123', gen_salt('bf'));
    
    RAISE NOTICE 'Hashes generados correctamente';
    
    -- Manejar Diego
    SELECT id INTO diego_id FROM auth.users WHERE email = 'diegodelp22@gmail.com';
    
    IF diego_id IS NOT NULL THEN
        -- Diego existe, actualizar contraseña
        UPDATE auth.users 
        SET 
            encrypted_password = diego_password,
            email_confirmed_at = COALESCE(email_confirmed_at, NOW()),
            updated_at = NOW(),
            raw_app_meta_data = COALESCE(raw_app_meta_data, '{}'),
            raw_user_meta_data = COALESCE(raw_user_meta_data, '{"full_name": "Diego Admin"}'),
            aud = COALESCE(aud, 'authenticated'),
            role = COALESCE(role, 'authenticated')
        WHERE id = diego_id;
        
        RAISE NOTICE 'Diego actualizado en auth.users';
    ELSE
        -- Diego no existe, crearlo
        diego_id := gen_random_uuid();
        
        INSERT INTO auth.users (
            id,
            instance_id,
            email,
            encrypted_password,
            email_confirmed_at,
            created_at,
            updated_at,
            aud,
            role,
            raw_app_meta_data,
            raw_user_meta_data
        ) VALUES (
            diego_id,
            '00000000-0000-0000-0000-000000000000',
            'diegodelp22@gmail.com',
            diego_password,
            NOW(),
            NOW(),
            NOW(),
            'authenticated',
            'authenticated',
            '{"provider": "email", "providers": ["email"]}',
            '{"full_name": "Diego Admin"}'
        );
        
        RAISE NOTICE 'Diego creado en auth.users con ID: %', diego_id;
    END IF;
    
    -- Crear/actualizar perfil de Diego
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
    
    -- Manejar usuario test
    SELECT id INTO test_id FROM auth.users WHERE email = 'test@digitalpro.agency';
    
    IF test_id IS NOT NULL THEN
        -- Test user existe, actualizar contraseña
        UPDATE auth.users 
        SET 
            encrypted_password = test_password,
            email_confirmed_at = COALESCE(email_confirmed_at, NOW()),
            updated_at = NOW(),
            raw_app_meta_data = COALESCE(raw_app_meta_data, '{}'),
            raw_user_meta_data = COALESCE(raw_user_meta_data, '{"full_name": "Usuario de Prueba"}'),
            aud = COALESCE(aud, 'authenticated'),
            role = COALESCE(role, 'authenticated')
        WHERE id = test_id;
        
        RAISE NOTICE 'Usuario test actualizado en auth.users';
    ELSE
        -- Test user no existe, crearlo
        test_id := gen_random_uuid();
        
        INSERT INTO auth.users (
            id,
            instance_id,
            email,
            encrypted_password,
            email_confirmed_at,
            created_at,
            updated_at,
            aud,
            role,
            raw_app_meta_data,
            raw_user_meta_data
        ) VALUES (
            test_id,
            '00000000-0000-0000-0000-000000000000',
            'test@digitalpro.agency',
            test_password,
            NOW(),
            NOW(),
            NOW(),
            'authenticated',
            'authenticated',
            '{"provider": "email", "providers": ["email"]}',
            '{"full_name": "Usuario de Prueba"}'
        );
        
        RAISE NOTICE 'Usuario test creado en auth.users con ID: %', test_id;
    END IF;
    
    -- Crear/actualizar perfil de test
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
    
    RAISE NOTICE 'Usuarios configurados correctamente';
    
END $$;
