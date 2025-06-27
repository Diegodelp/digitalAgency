-- Verificación final completa del sistema

-- 1. Resumen del sistema
SELECT 
    '=== RESUMEN FINAL DEL SISTEMA ===' as "Sección",
    '' as "Detalle",
    '' as "Valor";

-- 2. Estado de autenticación
SELECT 
    'AUTENTICACIÓN' as "Sección",
    'Usuarios en auth.users' as "Detalle",
    COUNT(*)::text as "Valor"
FROM auth.users
UNION ALL
SELECT 
    'AUTENTICACIÓN' as "Sección",
    'Usuarios con password' as "Detalle",
    COUNT(*)::text as "Valor"
FROM auth.users
WHERE encrypted_password IS NOT NULL AND encrypted_password != ''
UNION ALL
SELECT 
    'AUTENTICACIÓN' as "Sección",
    'Emails confirmados' as "Detalle",
    COUNT(*)::text as "Valor"
FROM auth.users
WHERE email_confirmed_at IS NOT NULL;

-- 3. Estado de perfiles
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

-- 4. Estado de propuestas
SELECT 
    'PROPUESTAS' as "Sección",
    'Total propuestas' as "Detalle",
    COUNT(*)::text as "Valor"
FROM public.proposals
UNION ALL
SELECT 
    'PROPUESTAS' as "Sección",
    'Pendientes' as "Detalle",
    COUNT(*)::text as "Valor"
FROM public.proposals
WHERE status = 'pending'
UNION ALL
SELECT 
    'PROPUESTAS' as "Sección",
    'Aprobadas/En desarrollo' as "Detalle",
    COUNT(*)::text as "Valor"
FROM public.proposals
WHERE status IN ('approved', 'in_development');

-- 5. Credenciales para login
SELECT 
    '=== CREDENCIALES PARA LOGIN ===' as "Tipo",
    p.email as "Email",
    CASE 
        WHEN p.email = 'diegodelp22@gmail.com' THEN 'admin123'
        WHEN p.email = 'test@digitalpro.agency' THEN 'test123'
        ELSE 'N/A'
    END as "Password",
    p.role as "Rol",
    CASE 
        WHEN p.role = 'admin' THEN '/admin/dashboard'
        ELSE '/dashboard'
    END as "Redirect"
FROM public.profiles p
WHERE p.email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency')
ORDER BY p.role DESC;

-- 6. Estado de sincronización
SELECT 
    '=== ESTADO DE SINCRONIZACIÓN ===' as "Info",
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
