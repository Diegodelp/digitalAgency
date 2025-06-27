-- Diagnóstico completo del sistema

-- 1. Verificar extensiones
SELECT 
    'Extensiones instaladas' as categoria,
    extname as nombre
FROM pg_extension 
WHERE extname IN ('uuid-ossp', 'pgcrypto');

-- 2. Verificar tablas existentes
SELECT 
    'Tablas existentes' as categoria,
    table_name as nombre
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('profiles', 'proposals');

-- 3. Verificar estructura de profiles
SELECT 
    'Columnas de profiles' as categoria,
    column_name as nombre,
    data_type as tipo
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'profiles'
ORDER BY ordinal_position;

-- 4. Verificar datos en profiles
SELECT 
    'Datos en profiles' as categoria,
    COUNT(*) as total,
    COUNT(CASE WHEN role = 'admin' THEN 1 END) as admins,
    COUNT(CASE WHEN role = 'user' THEN 1 END) as users
FROM public.profiles;

-- 5. Verificar políticas RLS
SELECT 
    'Políticas RLS' as categoria,
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN ('profiles', 'proposals');

-- 6. Verificar usuarios específicos
SELECT 
    'Usuarios específicos' as categoria,
    email,
    full_name,
    role,
    created_at
FROM public.profiles 
WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');
