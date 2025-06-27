-- Script para diagnosticar y corregir problemas de login

-- 1. Verificar usuarios en auth.users
SELECT 
    'USUARIOS EN AUTH.USERS' as "Tabla",
    id,
    email,
    email_confirmed_at,
    created_at,
    CASE 
        WHEN encrypted_password IS NOT NULL THEN 'Tiene contraseña'
        ELSE 'Sin contraseña'
    END as "Estado_Password"
FROM auth.users
ORDER BY created_at DESC;

-- 2. Verificar perfiles
SELECT 
    'PERFILES EN PUBLIC.PROFILES' as "Tabla",
    id,
    email,
    full_name,
    role,
    created_at
FROM public.profiles
ORDER BY created_at DESC;

-- 3. Verificar sincronización
SELECT 
    'SINCRONIZACIÓN' as "Estado",
    CASE 
        WHEN au.id IS NOT NULL AND p.id IS NOT NULL THEN 'SINCRONIZADO'
        WHEN au.id IS NOT NULL AND p.id IS NULL THEN 'FALTA PERFIL'
        WHEN au.id IS NULL AND p.id IS NOT NULL THEN 'FALTA AUTH'
        ELSE 'ERROR'
    END as "Estado",
    COALESCE(au.email, p.email) as "Email"
FROM auth.users au
FULL OUTER JOIN public.profiles p ON au.id = p.id
ORDER BY au.created_at DESC NULLS LAST;
