-- Script para recrear usuarios con contraseñas correctas

-- 1. Eliminar usuarios existentes problemáticos
DELETE FROM public.profiles WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');
DELETE FROM auth.users WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');

-- 2. Crear Diego con contraseña correcta
DO $$
DECLARE
    diego_id UUID := gen_random_uuid();
    diego_password_hash TEXT;
BEGIN
    -- Generar hash de contraseña usando el método correcto de Supabase
    diego_password_hash := crypt('admin123', gen_salt('bf', 10));
    
    -- Crear en auth.users
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        confirmation_sent_at,
        confirmation_token,
        recovery_sent_at,
        recovery_token,
        email_change_sent_at,
        email_change,
        email_change_token_new,
        email_change_token_current,
        phone_confirmed_at,
        phone_change_sent_at,
        phone_change_token,
        raw_app_meta_data,
        raw_user_meta_data,
        is_super_admin,
        created_at,
        updated_at,
        phone,
        phone_change,
        email_change_confirm_status,
        banned_until,
        reauthentication_token,
        reauthentication_sent_at,
        is_sso_user,
        deleted_at
    ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        diego_id,
        'authenticated',
        'authenticated',
        'diegodelp22@gmail.com',
        diego_password_hash,
        NOW(),
        NOW(),
        '',
        NULL,
        '',
        NULL,
        '',
        '',
        '',
        NULL,
        NULL,
        '',
        '{"provider": "email", "providers": ["email"]}',
        '{"full_name": "Diego Admin"}',
        FALSE,
        NOW(),
        NOW(),
        NULL,
        '',
        0,
        NULL,
        '',
        NULL,
        FALSE,
        NULL
    );
    
    -- Crear perfil
    INSERT INTO public.profiles (id, email, full_name, role, company, created_at)
    VALUES (
        diego_id,
        'diegodelp22@gmail.com',
        'Diego - Administrador Principal',
        'admin',
        'DigitalPro Agency',
        NOW()
    );
    
    RAISE NOTICE 'Diego creado exitosamente con ID: %', diego_id;
    
END $$;

-- 3. Crear usuario de prueba
DO $$
DECLARE
    test_id UUID := gen_random_uuid();
    test_password_hash TEXT;
BEGIN
    -- Generar hash de contraseña
    test_password_hash := crypt('test123', gen_salt('bf', 10));
    
    -- Crear en auth.users
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        confirmation_sent_at,
        confirmation_token,
        recovery_sent_at,
        recovery_token,
        email_change_sent_at,
        email_change,
        email_change_token_new,
        email_change_token_current,
        phone_confirmed_at,
        phone_change_sent_at,
        phone_change_token,
        raw_app_meta_data,
        raw_user_meta_data,
        is_super_admin,
        created_at,
        updated_at,
        phone,
        phone_change,
        email_change_confirm_status,
        banned_until,
        reauthentication_token,
        reauthentication_sent_at,
        is_sso_user,
        deleted_at
    ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        test_id,
        'authenticated',
        'authenticated',
        'test@digitalpro.agency',
        test_password_hash,
        NOW(),
        NOW(),
        '',
        NULL,
        '',
        NULL,
        '',
        '',
        '',
        NULL,
        NULL,
        '',
        '{"provider": "email", "providers": ["email"]}',
        '{"full_name": "Usuario de Prueba"}',
        FALSE,
        NOW(),
        NOW(),
        NULL,
        '',
        0,
        NULL,
        '',
        NULL,
        FALSE,
        NULL
    );
    
    -- Crear perfil
    INSERT INTO public.profiles (id, email, full_name, role, company, created_at)
    VALUES (
        test_id,
        'test@digitalpro.agency',
        'Usuario de Prueba',
        'user',
        'Empresa Test',
        NOW()
    );
    
    RAISE NOTICE 'Usuario de prueba creado exitosamente con ID: %', test_id;
    
END $$;

-- 4. Verificar creación
SELECT 
    'VERIFICACIÓN FINAL' as "Estado",
    au.email,
    p.full_name,
    p.role,
    CASE 
        WHEN au.encrypted_password IS NOT NULL THEN 'OK'
        ELSE 'ERROR'
    END as "Password_Status"
FROM auth.users au
JOIN public.profiles p ON au.id = p.id
WHERE au.email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency')
ORDER BY p.role DESC;
