-- Script para diagnosticar problemas de autenticación y creación de perfiles

-- 1. Verificar si existen usuarios en auth.users
SELECT 
    'Usuarios en auth.users' as "Tabla",
    COUNT(*) as "Total",
    string_agg(email, ', ') as "Emails"
FROM auth.users;

-- 2. Verificar si existen perfiles en public.profiles
SELECT 
    'Perfiles en public.profiles' as "Tabla",
    COUNT(*) as "Total",
    string_agg(email, ', ') as "Emails"
FROM public.profiles;

-- 3. Verificar si los triggers existen
SELECT 
    'Triggers' as "Tipo",
    trigger_name as "Nombre",
    event_object_table as "Tabla",
    action_timing || ' ' || event_manipulation as "Evento"
FROM information_schema.triggers 
WHERE trigger_schema = 'public' OR trigger_schema = 'auth'
ORDER BY event_object_table;

-- 4. Verificar si las funciones existen
SELECT 
    'Funciones' as "Tipo",
    proname as "Nombre",
    pronamespace::regnamespace as "Schema"
FROM pg_proc 
WHERE proname IN ('handle_new_user', 'handle_updated_at', 'create_proposal_roadmap')
ORDER BY proname;

-- 5. Verificar políticas RLS
SELECT 
    'Políticas RLS' as "Tipo",
    schemaname,
    tablename,
    policyname,
    cmd as "Comando"
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- 6. Verificar si RLS está habilitado
SELECT 
    'RLS Status' as "Tipo",
    schemaname,
    tablename,
    rowsecurity as "RLS_Habilitado"
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('profiles', 'proposals', 'proposal_roadmap')
ORDER BY tablename;

-- 7. Mostrar estructura de la tabla profiles
SELECT 
    'Estructura profiles' as "Tipo",
    column_name as "Columna",
    data_type as "Tipo",
    is_nullable as "Nullable",
    column_default as "Default"
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'profiles'
ORDER BY ordinal_position;
