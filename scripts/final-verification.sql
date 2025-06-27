-- Script final de verificación completa

-- 1. Resumen completo del sistema
SELECT 
    '=== RESUMEN DEL SISTEMA ===' as "Sección",
    '' as "Detalle",
    '' as "Valor";

-- 2. Usuarios y autenticación
SELECT 
    'AUTENTICACIÓN' as "Sección",
    'Total usuarios en auth.users' as "Detalle",
    COUNT(*)::text as "Valor"
FROM auth.users
UNION ALL
SELECT 
    'AUTENTICACIÓN' as "Sección",
    'Usuarios con contraseña' as "Detalle",
    COUNT(*)::text as "Valor"
FROM auth.users
WHERE encrypted_password IS NOT NULL
UNION ALL
SELECT 
    'AUTENTICACIÓN' as "Sección",
    'Emails confirmados' as "Detalle",
    COUNT(*)::text as "Valor"
FROM auth.users
WHERE email_confirmed_at IS NOT NULL;

-- 3. Perfiles
SELECT 
    'PERFILES' as "Sección",
    'Total perfiles' as "Detalle",
    COUNT(*)::text as "Valor"
FROM public.profiles
UNION ALL
SELECT 
    'PERFILES' as "Sección",
    'Administradores' as "Detalle",
    COUNT(*)::text as "Valor"
FROM public.profiles
WHERE role = 'admin'
UNION ALL
SELECT 
    'PERFILES' as "Sección",
    'Usuarios normales' as "Detalle",
    COUNT(*)::text as "Valor"
FROM public.profiles
WHERE role = 'user';

-- 4. Propuestas
SELECT 
    'PROPUESTAS' as "Sección",
    'Total propuestas' as "Detalle",
    COUNT(*)::text as "Valor"
FROM public.proposals
UNION ALL
SELECT 
    'PROPUESTAS' as "Sección",
    'Propuestas pendientes' as "Detalle",
    COUNT(*)::text as "Valor"
FROM public.proposals
WHERE status = 'pending'
UNION ALL
SELECT 
    'PROPUESTAS' as "Sección",
    'Propuestas aprobadas' as "Detalle",
    COUNT(*)::text as "Valor"
FROM public.proposals
WHERE status = 'approved' OR status = 'in_development';

-- 5. Detalles de usuarios para login
SELECT 
    '=== USUARIOS PARA LOGIN ===' as "Sección",
    p.email as "Email",
    p.role as "Rol",
    CASE 
        WHEN p.email = 'diegodelp22@gmail.com' THEN 'admin123'
        WHEN p.email = 'test@digitalpro.agency' THEN 'test123'
        ELSE 'N/A'
    END as "Password"
FROM public.profiles p
WHERE p.email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency')
ORDER BY p.role DESC;

-- 6. Estado de sincronización
SELECT 
    '=== SINCRONIZACIÓN ===' as "Sección",
    CASE 
        WHEN (SELECT COUNT(*) FROM auth.users) = (SELECT COUNT(*) FROM public.profiles) 
        THEN 'SINCRONIZADO ✅'
        ELSE 'DESINCRONIZADO ❌'
    END as "Estado",
    CONCAT(
        (SELECT COUNT(*) FROM auth.users)::text, 
        ' auth.users / ', 
        (SELECT COUNT(*) FROM public.profiles)::text, 
        ' profiles'
    ) as "Detalle";
