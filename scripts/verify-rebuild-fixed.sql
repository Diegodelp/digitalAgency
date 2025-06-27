-- Verificación completa del sistema reconstruido

-- 1. Verificar tablas creadas
SELECT 'Verificación de tablas' as categoria,
       table_name as nombre,
       'Existe' as estado
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('profiles', 'proposals');

-- 2. Verificar usuarios creados
SELECT 'Usuarios en sistema' as categoria,
       email,
       full_name,
       role,
       company
FROM public.profiles
ORDER BY role DESC, email;

-- 3. Verificar propuestas creadas
SELECT 'Propuestas en sistema' as categoria,
       p.title,
       p.status,
       p.priority,
       pr.email as usuario_email
FROM public.proposals p
JOIN public.profiles pr ON p.user_id = pr.id
ORDER BY p.created_at DESC;

-- 4. Verificar estadísticas
SELECT 'Estadísticas del sistema' as categoria,
       'Total usuarios: ' || COUNT(*) as detalle
FROM public.profiles
UNION ALL
SELECT 'Estadísticas del sistema' as categoria,
       'Usuarios admin: ' || COUNT(*) as detalle
FROM public.profiles WHERE role = 'admin'
UNION ALL
SELECT 'Estadísticas del sistema' as categoria,
       'Usuarios normales: ' || COUNT(*) as detalle
FROM public.profiles WHERE role = 'user'
UNION ALL
SELECT 'Estadísticas del sistema' as categoria,
       'Total propuestas: ' || COUNT(*) as detalle
FROM public.proposals
UNION ALL
SELECT 'Estadísticas del sistema' as categoria,
       'Propuestas pendientes: ' || COUNT(*) as detalle
FROM public.proposals WHERE status = 'pending';

-- 5. Verificar estado RLS
SELECT 'Estado RLS' as categoria,
       schemaname,
       tablename,
       rowsecurity as rls_habilitado
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('profiles', 'proposals');

-- 6. Mensaje final
SELECT 'Sistema listo para usar' as resultado,
       'RLS deshabilitado para evitar problemas de recursión' as nota,
       'Usar acceso directo en login' as recomendacion;
