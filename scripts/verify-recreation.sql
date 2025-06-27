-- Script para verificar que la recreación funcionó

-- 1. Verificar usuarios recreados
SELECT 
    'USUARIOS RECREADOS' as "Estado",
    au.email,
    au.id,
    CASE 
        WHEN au.encrypted_password IS NOT NULL AND length(au.encrypted_password) > 10 THEN 'Password OK'
        ELSE 'Password PROBLEMA'
    END as "Password_Status",
    au.email_confirmed_at,
    p.role,
    p.full_name
FROM auth.users au
LEFT JOIN public.profiles p ON au.id = p.id
WHERE au.email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency')
ORDER BY p.role DESC NULLS LAST;

-- 2. Test de contraseñas
DO $$
DECLARE
    diego_hash TEXT;
    test_hash TEXT;
    diego_check BOOLEAN;
    test_check BOOLEAN;
BEGIN
    -- Obtener hashes
    SELECT encrypted_password INTO diego_hash 
    FROM auth.users 
    WHERE email = 'diegodelp22@gmail.com';
    
    SELECT encrypted_password INTO test_hash 
    FROM auth.users 
    WHERE email = 'test@digitalpro.agency';
    
    -- Verificar contraseñas
    IF diego_hash IS NOT NULL THEN
        diego_check := (crypt('admin123', diego_hash) = diego_hash);
        RAISE NOTICE 'Diego password check: %', diego_check;
    ELSE
        RAISE NOTICE 'Diego no tiene hash de contraseña';
    END IF;
    
    IF test_hash IS NOT NULL THEN
        test_check := (crypt('test123', test_hash) = test_hash);
        RAISE NOTICE 'Test password check: %', test_check;
    ELSE
        RAISE NOTICE 'Test no tiene hash de contraseña';
    END IF;
    
END $$;

-- 3. Mostrar credenciales finales
SELECT 
    '=== CREDENCIALES FINALES ===' as "Info",
    'Email' as "Campo",
    'Password' as "Valor",
    'Rol' as "Tipo"
UNION ALL
SELECT 
    'LOGIN ADMIN' as "Info",
    'diegodelp22@gmail.com' as "Campo",
    'admin123' as "Valor",
    'admin' as "Tipo"
UNION ALL
SELECT 
    'LOGIN USER' as "Info",
    'test@digitalpro.agency' as "Campo",
    'test123' as "Valor",
    'user' as "Tipo";
