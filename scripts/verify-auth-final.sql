-- Script para verificar que la autenticación funciona

-- 1. Verificar usuarios con contraseñas
SELECT 
    'VERIFICACIÓN FINAL' as "Estado",
    au.email,
    CASE 
        WHEN au.encrypted_password IS NOT NULL AND length(au.encrypted_password) > 10 THEN 'Password OK'
        ELSE 'Password FALTA'
    END as "Password_Status",
    CASE 
        WHEN au.email_confirmed_at IS NOT NULL THEN 'Email confirmado'
        ELSE 'Email NO confirmado'
    END as "Email_Status",
    p.role,
    p.full_name
FROM auth.users au
LEFT JOIN public.profiles p ON au.id = p.id
WHERE au.email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency')
ORDER BY p.role DESC NULLS LAST;

-- 2. Test de hash de contraseña (para verificar que crypt funciona)
SELECT 
    'TEST HASH' as "Test",
    'admin123' as "Password_Original",
    crypt('admin123', gen_salt('bf')) as "Hash_Generado",
    CASE 
        WHEN crypt('admin123', crypt('admin123', gen_salt('bf'))) = crypt('admin123', gen_salt('bf')) THEN 'Hash funciona'
        ELSE 'Hash NO funciona'
    END as "Estado_Hash";

-- 3. Verificar que los usuarios pueden autenticarse (simulación)
DO $$
DECLARE
    diego_hash TEXT;
    test_hash TEXT;
    diego_check BOOLEAN;
    test_check BOOLEAN;
BEGIN
    -- Obtener hashes almacenados
    SELECT encrypted_password INTO diego_hash 
    FROM auth.users 
    WHERE email = 'diegodelp22@gmail.com';
    
    SELECT encrypted_password INTO test_hash 
    FROM auth.users 
    WHERE email = 'test@digitalpro.agency';
    
    -- Verificar que las contraseñas coinciden
    diego_check := (crypt('admin123', diego_hash) = diego_hash);
    test_check := (crypt('test123', test_hash) = test_hash);
    
    RAISE NOTICE 'Diego password check: %', diego_check;
    RAISE NOTICE 'Test password check: %', test_check;
    
    IF diego_check AND test_check THEN
        RAISE NOTICE '✅ TODAS LAS CONTRASEÑAS FUNCIONAN CORRECTAMENTE';
    ELSE
        RAISE NOTICE '❌ HAY PROBLEMAS CON LAS CONTRASEÑAS';
    END IF;
    
END $$;

-- 4. Mostrar credenciales finales
SELECT 
    '=== CREDENCIALES PARA LOGIN ===' as "Info",
    'Usa estos datos en la aplicación:' as "Instrucciones";

SELECT 
    'ADMIN' as "Tipo",
    'diegodelp22@gmail.com' as "Email",
    'admin123' as "Password",
    '/admin/dashboard' as "Redirect"
UNION ALL
SELECT 
    'USER' as "Tipo",
    'test@digitalpro.agency' as "Email",
    'test123' as "Password",
    '/dashboard' as "Redirect";
