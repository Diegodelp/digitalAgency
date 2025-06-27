-- Script completo para recrear el sistema de autenticación
-- Soluciona el error de tipos incompatibles

BEGIN;

-- 1. Limpiar datos existentes de forma segura
-- Primero eliminar refresh tokens
DELETE FROM auth.refresh_tokens 
WHERE user_id IN (
    SELECT id FROM auth.users 
    WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency')
);

-- Eliminar sesiones
DELETE FROM auth.sessions 
WHERE user_id IN (
    SELECT id FROM auth.users 
    WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency')
);

-- Eliminar identidades
DELETE FROM auth.identities 
WHERE user_id IN (
    SELECT id FROM auth.users 
    WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency')
);

-- Eliminar perfiles (usando email que es varchar)
DELETE FROM public.profiles 
WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');

-- Eliminar usuarios de auth
DELETE FROM auth.users 
WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');

-- 2. Crear usuarios nuevos con IDs específicos
-- Usuario Admin (Diego)
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
    confirmation_token,
    email_change_token_new,
    recovery_token
) VALUES (
    '11111111-1111-1111-1111-111111111111'::uuid,
    '00000000-0000-0000-0000-000000000000'::uuid,
    'diegodelp22@gmail.com',
    crypt('123456', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    'authenticated',
    'authenticated',
    '',
    '',
    ''
);

-- Usuario Test
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
    confirmation_token,
    email_change_token_new,
    recovery_token
) VALUES (
    '22222222-2222-2222-2222-222222222222'::uuid,
    '00000000-0000-0000-0000-000000000000'::uuid,
    'test@digitalpro.agency',
    crypt('123456', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    'authenticated',
    'authenticated',
    '',
    '',
    ''
);

-- 3. Crear identidades para permitir login
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
    '11111111-1111-1111-1111-111111111111'::uuid,
    '{"sub": "11111111-1111-1111-1111-111111111111", "email": "diegodelp22@gmail.com"}'::jsonb,
    'email',
    NOW(),
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    '22222222-2222-2222-2222-222222222222'::uuid,
    '{"sub": "22222222-2222-2222-2222-222222222222", "email": "test@digitalpro.agency"}'::jsonb,
    'email',
    NOW(),
    NOW(),
    NOW()
);

-- 4. Crear perfiles correspondientes
INSERT INTO public.profiles (
    id,
    email,
    full_name,
    role,
    company,
    created_at,
    updated_at
) VALUES 
(
    '11111111-1111-1111-1111-111111111111'::uuid,
    'diegodelp22@gmail.com',
    'Diego Delgado',
    'admin'::user_role,
    'DigitalPro Agency',
    NOW(),
    NOW()
),
(
    '22222222-2222-2222-2222-222222222222'::uuid,
    'test@digitalpro.agency',
    'Usuario Test',
    'user'::user_role,
    'Test Company',
    NOW(),
    NOW()
);

COMMIT;

-- Verificar que todo se creó correctamente
SELECT 'USUARIOS CREADOS:' as status;
SELECT email, id, created_at FROM auth.users WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');

SELECT 'PERFILES CREADOS:' as status;
SELECT email, full_name, role FROM public.profiles WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');

SELECT 'IDENTIDADES CREADAS:' as status;
SELECT provider, user_id FROM auth.identities WHERE user_id IN ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222');
