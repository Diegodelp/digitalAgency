-- Script alternativo si el anterior no funciona
-- Este usa un enfoque más directo

-- 1. Limpiar usuarios problemáticos
DELETE FROM public.profiles WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');
DELETE FROM auth.users WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');

-- 2. Crear usuarios desde cero con método simplificado
DO $$
DECLARE
    diego_id UUID := gen_random_uuid();
    test_id UUID := gen_random_uuid();
BEGIN
    -- Crear Diego en auth.users
    INSERT INTO auth.users (
        id,
        instance_id,
        email,
        encrypted_password,
        email_confirmed_at,
        confirmation_sent_at,
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
        '$2a$10$' || encode(digest('admin123' || diego_id::text, 'sha256'), 'hex'),
        NOW(),
        NOW(),
        NOW(),
        NOW(),
        'authenticated',
        'authenticated',
        '{"provider": "email", "providers": ["email"]}',
        '{"full_name": "Diego Admin"}'
    );
    
    -- Crear perfil de Diego
    INSERT INTO public.profiles (id, email, full_name, role, company, created_at)
    VALUES (
        diego_id,
        'diegodelp22@gmail.com',
        'Diego - Administrador Principal',
        'admin',
        'DigitalPro Agency',
        NOW()
    );
    
    -- Crear usuario test en auth.users
    INSERT INTO auth.users (
        id,
        instance_id,
        email,
        encrypted_password,
        email_confirmed_at,
        confirmation_sent_at,
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
        '$2a$10$' || encode(digest('test123' || test_id::text, 'sha256'), 'hex'),
        NOW(),
        NOW(),
        NOW(),
        NOW(),
        'authenticated',
        'authenticated',
        '{"provider": "email", "providers": ["email"]}',
        '{"full_name": "Usuario de Prueba"}'
    );
    
    -- Crear perfil de test
    INSERT INTO public.profiles (id, email, full_name, role, company, created_at)
    VALUES (
        test_id,
        'test@digitalpro.agency',
        'Usuario de Prueba',
        'user',
        'Empresa Test',
        NOW()
    );
    
    RAISE NOTICE 'Usuarios creados con método alternativo';
    RAISE NOTICE 'Diego ID: %', diego_id;
    RAISE NOTICE 'Test ID: %', test_id;
    
END $$;
