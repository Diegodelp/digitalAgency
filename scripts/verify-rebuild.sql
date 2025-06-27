-- Verificar que la reconstrucción funcionó

-- 1. Verificar estructura de tablas
SELECT 
    'ESTRUCTURA' as "Tipo",
    table_name as "Tabla",
    COUNT(*) as "Columnas"
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name IN ('profiles', 'proposals')
GROUP BY table_name
ORDER BY table_name;

-- 2. Verificar datos creados
SELECT 
    'DATOS' as "Tipo",
    'profiles' as "Tabla",
    COUNT(*) as "Registros",
    string_agg(DISTINCT role, ', ') as "Roles"
FROM public.profiles
UNION ALL
SELECT 
    'DATOS' as "Tipo",
    'proposals' as "Tabla",
    COUNT(*) as "Registros",
    string_agg(DISTINCT status, ', ') as "Estados"
FROM public.proposals;

-- 3. Mostrar usuarios creados
SELECT 
    '=== USUARIOS DISPONIBLES ===' as "Info",
    email as "Email",
    role as "Rol",
    full_name as "Nombre",
    company as "Empresa"
FROM public.profiles
ORDER BY role DESC;

-- 4. Mostrar propuestas
SELECT 
    '=== PROPUESTAS CREADAS ===' as "Info",
    p.title as "Título",
    p.status as "Estado",
    p.priority as "Prioridad",
    pr.email as "Usuario"
FROM public.proposals p
JOIN public.profiles pr ON p.user_id = pr.id
ORDER BY p.created_at DESC;

-- 5. Verificar políticas RLS
SELECT 
    'POLÍTICAS RLS' as "Tipo",
    schemaname as "Esquema",
    tablename as "Tabla",
    policyname as "Política"
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- 6. Estado final del sistema
SELECT 
    '=== ESTADO FINAL ===' as "Resumen",
    CASE 
        WHEN (SELECT COUNT(*) FROM public.profiles WHERE role = 'admin') > 0 
        THEN 'Admin creado ✅'
        ELSE 'Admin faltante ❌'
    END as "Admin",
    CASE 
        WHEN (SELECT COUNT(*) FROM public.profiles WHERE role = 'user') > 0 
        THEN 'Usuario creado ✅'
        ELSE 'Usuario faltante ❌'
    END as "Usuario",
    CASE 
        WHEN (SELECT COUNT(*) FROM public.proposals) > 0 
        THEN 'Propuestas creadas ✅'
        ELSE 'Sin propuestas ❌'
    END as "Propuestas";
