-- Script para limpiar completamente y recrear el sistema de autenticación

-- 1. Eliminar todos los datos existentes de forma segura
DO $$
BEGIN
    -- Eliminar perfiles primero (por la foreign key)
    DELETE FROM profiles;
    
    -- Eliminar usuarios de auth
    DELETE FROM auth.users;
    
    -- Eliminar identidades si existen
    DELETE FROM auth.identities;
    
    -- Eliminar sesiones activas
    DELETE FROM auth.sessions;
    
    -- Eliminar tokens de refresh
    DELETE FROM auth.refresh_tokens;
    
    RAISE NOTICE 'Datos de autenticación eliminados correctamente';
END $$;

-- 2. Crear usuarios con IDs únicos y contraseñas hasheadas correctamente
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
    role
) VALUES 
(
    gen_random_uuid(),
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
    'authenticated'
),
(
    gen_random_uuid(),
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
    'authenticated'
);

-- 3. Crear perfiles usando los IDs de los usuarios recién creados
INSERT INTO profiles (
    id,
    email,
    full_name,
    role,
    company,
    created_at,
    updated_at
)
SELECT 
    u.id,
    u.email,
    CASE 
        WHEN u.email = 'diegodelp22@gmail.com' THEN 'Diego Delgado'
        WHEN u.email = 'test@digitalpro.agency' THEN 'Usuario Test'
    END as full_name,
    CASE 
        WHEN u.email = 'diegodelp22@gmail.com' THEN 'admin'::user_role
        WHEN u.email = 'test@digitalpro.agency' THEN 'user'::user_role
    END as role,
    CASE 
        WHEN u.email = 'diegodelp22@gmail.com' THEN 'DigitalPro Agency'
        WHEN u.email = 'test@digitalpro.agency' THEN 'Test Company'
    END as company,
    NOW(),
    NOW()
FROM auth.users u
WHERE u.email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');

-- 4. Crear identidades para los usuarios (necesario para el login)
INSERT INTO auth.identities (
    id,
    user_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
)
SELECT 
    gen_random_uuid(),
    u.id,
    json_build_object('sub', u.id::text, 'email', u.email),
    'email',
    NOW(),
    NOW(),
    NOW()
FROM auth.users u
WHERE u.email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');

-- 5. Verificar que todo se creó correctamente
SELECT 
    'USUARIOS CREADOS:' as info,
    u.id,
    u.email,
    u.email_confirmed_at IS NOT NULL as email_confirmed,
    p.full_name,
    p.role,
    p.company
FROM auth.users u
LEFT JOIN profiles p ON u.id = p.id
WHERE u.email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency')
ORDER BY u.email;

-- 6. Verificar identidades
SELECT 
    'IDENTIDADES CREADAS:' as info,
    i.provider,
    u.email
FROM auth.identities i
JOIN auth.users u ON i.user_id = u.id
WHERE u.email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');
