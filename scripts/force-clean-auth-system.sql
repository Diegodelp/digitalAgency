-- Script para forzar la limpieza completa del sistema de autenticación
-- Maneja todos los casos de duplicados y dependencias

-- 1. Deshabilitar temporalmente las políticas RLS para evitar problemas
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- 2. Eliminar datos en el orden correcto para evitar violaciones de foreign key
DO $$
DECLARE
    rec RECORD;
BEGIN
    -- Eliminar todas las sesiones activas
    DELETE FROM auth.sessions;
    RAISE NOTICE 'Sesiones eliminadas';
    
    -- Eliminar todos los refresh tokens
    DELETE FROM auth.refresh_tokens;
    RAISE NOTICE 'Refresh tokens eliminados';
    
    -- Eliminar todas las identidades
    DELETE FROM auth.identities;
    RAISE NOTICE 'Identidades eliminadas';
    
    -- Eliminar todos los perfiles (esto debe ir antes que los usuarios por la FK)
    DELETE FROM profiles;
    RAISE NOTICE 'Perfiles eliminados';
    
    -- Eliminar todos los usuarios de auth
    DELETE FROM auth.users;
    RAISE NOTICE 'Usuarios eliminados';
    
    -- Resetear secuencias si existen
    PERFORM setval(pg_get_serial_sequence('profiles', 'id'), 1, false) WHERE pg_get_serial_sequence('profiles', 'id') IS NOT NULL;
    
    RAISE NOTICE 'Limpieza completa terminada';
END $$;

-- 3. Crear usuarios completamente nuevos con IDs únicos
DO $$
DECLARE
    admin_user_id UUID;
    test_user_id UUID;
BEGIN
    -- Generar IDs únicos
    admin_user_id := gen_random_uuid();
    test_user_id := gen_random_uuid();
    
    -- Crear usuario admin
    INSERT INTO auth.users (
        id,
        instance_id,
        email,
        encrypted_password,
        email_confirmed_at,
        created_at,
        updated_at,
        confirmation_token,
        email_change,
        email_change_token_new,
        recovery_token,
        aud,
        role,
        raw_app_meta_data,
        raw_user_meta_data,
        is_super_admin,
        phone,
        phone_confirmed_at,
        phone_change,
        phone_change_token,
        email_change_confirm_status,
        banned_until,
        reauthentication_token,
        reauthentication_sent_at
    ) VALUES (
        admin_user_id,
        '00000000-0000-0000-0000-000000000000',
        'diegodelp22@gmail.com',
        crypt('123456', gen_salt('bf')),
        NOW(),
        NOW(),
        NOW(),
        '',
        '',
        '',
        '',
        'authenticated',
        'authenticated',
        '{}',
        '{"full_name": "Diego Delgado"}',
        false,
        null,
        null,
        '',
        '',
        0,
        null,
        '',
        null
    );
    
    -- Crear usuario test
    INSERT INTO auth.users (
        id,
        instance_id,
        email,
        encrypted_password,
        email_confirmed_at,
        created_at,
        updated_at,
        confirmation_token,
        email_change,
        email_change_token_new,
        recovery_token,
        aud,
        role,
        raw_app_meta_data,
        raw_user_meta_data,
        is_super_admin,
        phone,
        phone_confirmed_at,
        phone_change,
        phone_change_token,
        email_change_confirm_status,
        banned_until,
        reauthentication_token,
        reauthentication_sent_at
    ) VALUES (
        test_user_id,
        '00000000-0000-0000-0000-000000000000',
        'test@digitalpro.agency',
        crypt('123456', gen_salt('bf')),
        NOW(),
        NOW(),
        NOW(),
        '',
        '',
        '',
        '',
        'authenticated',
        'authenticated',
        '{}',
        '{"full_name": "Usuario Test"}',
        false,
        null,
        null,
        '',
        '',
        0,
        null,
        '',
        null
    );
    
    -- Crear perfiles usando los IDs generados
    INSERT INTO profiles (
        id,
        email,
        full_name,
        role,
        company,
        created_at,
        updated_at
    ) VALUES 
    (
        admin_user_id,
        'diegodelp22@gmail.com',
        'Diego Delgado',
        'admin',
        'DigitalPro Agency',
        NOW(),
        NOW()
    ),
    (
        test_user_id,
        'test@digitalpro.agency',
        'Usuario Test',
        'user',
        'Test Company',
        NOW(),
        NOW()
    );
    
    -- Crear identidades para ambos usuarios
    INSERT INTO auth.identities (
        id,
        user_id,
        identity_data,
        provider,
        last_sign_in_at,
        created_at,
        updated_at
    ) VALUES 
    (
        gen_random_uuid(),
        admin_user_id,
        json_build_object(
            'sub', admin_user_id::text, 
            'email', 'diegodelp22@gmail.com',
            'email_verified', true,
            'phone_verified', false
        ),
        'email',
        NOW(),
        NOW(),
        NOW()
    ),
    (
        gen_random_uuid(),
        test_user_id,
        json_build_object(
            'sub', test_user_id::text, 
            'email', 'test@digitalpro.agency',
            'email_verified', true,
            'phone_verified', false
        ),
        'email',
        NOW(),
        NOW(),
        NOW()
    );
    
    RAISE NOTICE 'Usuarios creados con IDs: Admin=%, Test=%', admin_user_id, test_user_id;
END $$;

-- 4. Rehabilitar RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- 5. Verificación final
SELECT 
    'VERIFICACIÓN FINAL' as status,
    COUNT(*) as total_users
FROM auth.users 
WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');

SELECT 
    'USUARIOS CREADOS' as info,
    u.email,
    u.email_confirmed_at IS NOT NULL as confirmed,
    p.full_name,
    p.role,
    p.company
FROM auth.users u
JOIN profiles p ON u.id = p.id
WHERE u.email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency')
ORDER BY u.email;

SELECT 
    'IDENTIDADES CREADAS' as info,
    COUNT(*) as total_identities
FROM auth.identities i
JOIN auth.users u ON i.user_id = u.id
WHERE u.email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');
