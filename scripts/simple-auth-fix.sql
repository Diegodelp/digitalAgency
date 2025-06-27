-- Script simple para recrear usuarios sin errores de esquema
BEGIN;

-- Eliminar usuarios existentes de forma segura
DELETE FROM auth.refresh_tokens WHERE user_id IN (
    SELECT id FROM auth.users WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency')
);

DELETE FROM auth.sessions WHERE user_id IN (
    SELECT id FROM auth.users WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency')
);

DELETE FROM auth.identities WHERE user_id IN (
    SELECT id FROM auth.users WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency')
);

DELETE FROM public.profiles WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');

DELETE FROM auth.users WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');

-- Crear usuarios nuevos
INSERT INTO auth.users (
    id,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    aud,
    role
) VALUES 
(
    gen_random_uuid(),
    'diegodelp22@gmail.com',
    crypt('123456', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    'authenticated',
    'authenticated'
),
(
    gen_random_uuid(),
    'test@digitalpro.agency',
    crypt('123456', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    'authenticated',
    'authenticated'
);

-- Crear perfiles
INSERT INTO public.profiles (id, email, full_name, role, company, created_at, updated_at)
SELECT 
    u.id,
    u.email,
    CASE 
        WHEN u.email = 'diegodelp22@gmail.com' THEN 'Diego Delgado'
        ELSE 'Usuario Test'
    END,
    CASE 
        WHEN u.email = 'diegodelp22@gmail.com' THEN 'admin'::user_role
        ELSE 'user'::user_role
    END,
    CASE 
        WHEN u.email = 'diegodelp22@gmail.com' THEN 'DigitalPro Agency'
        ELSE 'Test Company'
    END,
    NOW(),
    NOW()
FROM auth.users u
WHERE u.email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');

COMMIT;

-- Verificar
SELECT 'Usuarios creados:' as status, email, id FROM auth.users WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');
SELECT 'Perfiles creados:' as status, email, full_name, role FROM public.profiles WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');
