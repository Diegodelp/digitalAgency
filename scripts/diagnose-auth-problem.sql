-- Script para diagnosticar el problema de autenticación

-- 1. Verificar estructura de auth.users
SELECT 
    'ESTRUCTURA auth.users' as "Info",
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'auth' 
AND table_name = 'users'
AND column_name IN ('id', 'email', 'encrypted_password', 'email_confirmed_at')
ORDER BY ordinal_position;

-- 2. Verificar usuarios en auth.users
SELECT 
    'USUARIOS EN auth.users' as "Tabla",
    id,
    email,
    CASE 
        WHEN encrypted_password IS NOT NULL AND encrypted_password != '' THEN 'Tiene contraseña'
        ELSE 'SIN CONTRASEÑA'
    END as "Estado_Password",
    email_confirmed_at,
    created_at
FROM auth.users
ORDER BY created_at DESC;

-- 3. Verificar perfiles en public.profiles
SELECT 
    'PERFILES EN public.profiles' as "Tabla",
    id,
    email,
    full_name,
    role,
    created_at
FROM public.profiles
ORDER BY created_at DESC;

-- 4. Verificar sincronización entre auth.users y public.profiles
SELECT 
    'SINCRONIZACIÓN' as "Estado",
    COALESCE(au.email, p.email) as "Email",
    CASE 
        WHEN au.id IS NOT NULL AND p.id IS NOT NULL THEN 'SINCRONIZADO'
        WHEN au.id IS NOT NULL AND p.id IS NULL THEN 'FALTA PERFIL'
        WHEN au.id IS NULL AND p.id IS NOT NULL THEN 'FALTA AUTH USER'
        ELSE 'ERROR'
    END as "Estado_Sync",
    CASE 
        WHEN au.encrypted_password IS NOT NULL AND au.encrypted_password != '' THEN 'Password OK'
        ELSE 'SIN PASSWORD'
    END as "Password_Status"
FROM auth.users au
FULL OUTER JOIN public.profiles p ON au.id = p.id
ORDER BY au.created_at DESC NULLS LAST;

-- 5. Verificar si podemos acceder a la función crypt
SELECT 
    'TEST CRYPT FUNCTION' as "Test",
    CASE 
        WHEN crypt('test', gen_salt('bf')) IS NOT NULL THEN 'crypt() funciona'
        ELSE 'crypt() no disponible'
    END as "Estado";
