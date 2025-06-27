-- Script para verificar que todo esté correcto

-- 1. Verificar usuarios y perfiles
SELECT 
    'VERIFICACIÓN USUARIOS' as "Estado",
    au.email,
    p.full_name,
    p.role,
    CASE 
        WHEN au.encrypted_password IS NOT NULL THEN 'Contraseña OK'
        ELSE 'Sin contraseña'
    END as "Password_Status",
    CASE 
        WHEN au.email_confirmed_at IS NOT NULL THEN 'Email confirmado'
        ELSE 'Email no confirmado'
    END as "Email_Status"
FROM auth.users au
LEFT JOIN public.profiles p ON au.id = p.id
WHERE au.email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency')
ORDER BY p.role DESC NULLS LAST;

-- 2. Verificar que no hay usuarios huérfanos
SELECT 
    'USUARIOS HUÉRFANOS' as "Problema",
    au.email as "Email_Auth",
    'Sin perfil' as "Estado"
FROM auth.users au
LEFT JOIN public.profiles p ON au.id = p.id
WHERE p.id IS NULL;

-- 3. Verificar que no hay perfiles huérfanos
SELECT 
    'PERFILES HUÉRFANOS' as "Problema",
    p.email as "Email_Profile",
    'Sin usuario auth' as "Estado"
FROM public.profiles p
LEFT JOIN auth.users au ON p.id = au.id
WHERE au.id IS NULL;

-- 4. Mostrar credenciales finales
SELECT 
    '=== CREDENCIALES PARA LOGIN ===' as "Info",
    'diegodelp22@gmail.com' as "Email_Admin",
    'admin123' as "Password_Admin",
    'test@digitalpro.agency' as "Email_User",
    'test123' as "Password_User";
