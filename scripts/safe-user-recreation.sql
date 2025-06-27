-- Script seguro para recrear usuarios manejando conflictos

-- 1. Primero verificar qué existe actualmente
SELECT 
    'ESTADO ACTUAL' as "Info",
    'auth.users' as "Tabla",
    COUNT(*) as "Total",
    string_agg(email, ', ') as "Emails"
FROM auth.users
WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency')
UNION ALL
SELECT 
    'ESTADO ACTUAL' as "Info",
    'public.profiles' as "Tabla", 
    COUNT(*) as "Total",
    string_agg(email, ', ') as "Emails"
FROM public.profiles
WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');

-- 2. Función para limpiar y recrear usuarios de forma segura
DO $$
DECLARE
    diego_id UUID;
    test_id UUID;
    diego_exists_auth BOOLEAN := FALSE;
    diego_exists_profile BOOLEAN := FALSE;
    test_exists_auth BOOLEAN := FALSE;
    test_exists_profile BOOLEAN := FALSE;
BEGIN
    -- Verificar existencia actual
    SELECT EXISTS(SELECT 1 FROM auth.users WHERE email = 'diegodelp22@gmail.com') INTO diego_exists_auth;
    SELECT EXISTS(SELECT 1 FROM public.profiles WHERE email = 'diegodelp22@gmail.com') INTO diego_exists_profile;
    SELECT EXISTS(SELECT 1 FROM auth.users WHERE email = 'test@digitalpro.agency') INTO test_exists_auth;
    SELECT EXISTS(SELECT 1 FROM public.profiles WHERE email = 'test@digitalpro.agency') INTO test_exists_profile;
    
    RAISE NOTICE 'Estado inicial - Diego: auth=%, profile=% | Test: auth=%, profile=%', 
                 diego_exists_auth, diego_exists_profile, test_exists_auth, test_exists_profile;
    
    -- Limpiar Diego si existe
    IF diego_exists_profile THEN
        DELETE FROM public.profiles WHERE email = 'diegodelp22@gmail.com';
        RAISE NOTICE 'Perfil de Diego eliminado';
    END IF;
    
    IF diego_exists_auth THEN
        DELETE FROM auth.users WHERE email = 'diegodelp22@gmail.com';
        RAISE NOTICE 'Usuario auth de Diego eliminado';
    END IF;
    
    -- Limpiar Test si existe
    IF test_exists_profile THEN
        DELETE FROM public.profiles WHERE email = 'test@digitalpro.agency';
        RAISE NOTICE 'Perfil de Test eliminado';
    END IF;
    
    IF test_exists_auth THEN
        DELETE FROM auth.users WHERE email = 'test@digitalpro.agency';
        RAISE NOTICE 'Usuario auth de Test eliminado';
    END IF;
    
    -- Generar nuevos IDs
    diego_id := gen_random_uuid();
    test_id := gen_random_uuid();
    
    RAISE NOTICE 'Nuevos IDs generados - Diego: %, Test: %', diego_id, test_id;
    
    -- Crear Diego desde cero
    BEGIN
        INSERT INTO auth.users (
            id,
            instance_id,
            email,
            encrypted_password,
            email_confirmed_at,
            confirmation_sent_at,
            created_at,
            updated_at,
            aud,
            role,
            raw_app_meta_data,
            raw_user_meta_data,
            confirmation_token,
            recovery_token,
            email_change_token_new,
            email_change_token_current
        ) VALUES (
            diego_id,
            '00000000-0000-0000-0000-000000000000',
            'diegodelp22@gmail.com',
            crypt('admin123', gen_salt('bf')),
            NOW(),
            NOW(),
            NOW(),
            NOW(),
            'authenticated',
            'authenticated',
            '{"provider": "email", "providers": ["email"]}',
            '{"full_name": "Diego Admin"}',
            '',
            '',
            '',
            ''
        );
        
        RAISE NOTICE 'Diego creado en auth.users';
        
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE NOTICE 'Error creando Diego en auth.users: %', SQLERRM;
    END;
    
    -- Crear perfil de Diego
    BEGIN
        INSERT INTO public.profiles (id, email, full_name, role, company, created_at)
        VALUES (
            diego_id,
            'diegodelp22@gmail.com',
            'Diego - Administrador Principal',
            'admin',
            'DigitalPro Agency',
            NOW()
        );
        
        RAISE NOTICE 'Perfil de Diego creado';
        
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE NOTICE 'Error creando perfil de Diego: %', SQLERRM;
    END;
    
    -- Crear usuario Test desde cero
    BEGIN
        INSERT INTO auth.users (
            id,
            instance_id,
            email,
            encrypted_password,
            email_confirmed_at,
            confirmation_sent_at,
            created_at,
            updated_at,
            aud,
            role,
            raw_app_meta_data,
            raw_user_meta_data,
            confirmation_token,
            recovery_token,
            email_change_token_new,
            email_change_token_current
        ) VALUES (
            test_id,
            '00000000-0000-0000-0000-000000000000',
            'test@digitalpro.agency',
            crypt('test123', gen_salt('bf')),
            NOW(),
            NOW(),
            NOW(),
            NOW(),
            'authenticated',
            'authenticated',
            '{"provider": "email", "providers": ["email"]}',
            '{"full_name": "Usuario de Prueba"}',
            '',
            '',
            '',
            ''
        );
        
        RAISE NOTICE 'Usuario Test creado en auth.users';
        
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE NOTICE 'Error creando usuario Test en auth.users: %', SQLERRM;
    END;
    
    -- Crear perfil de Test
    BEGIN
        INSERT INTO public.profiles (id, email, full_name, role, company, created_at)
        VALUES (
            test_id,
            'test@digitalpro.agency',
            'Usuario de Prueba',
            'user',
            'Empresa Test',
            NOW()
        );
        
        RAISE NOTICE 'Perfil de Test creado';
        
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE NOTICE 'Error creando perfil de Test: %', SQLERRM;
    END;
    
    RAISE NOTICE '=== RECREACIÓN COMPLETADA ===';
    
END $$;
