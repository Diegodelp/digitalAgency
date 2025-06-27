-- Script para registrar manualmente a Diego si no existe en auth.users

DO $$
DECLARE
    diego_email TEXT := 'diegodelp22@gmail.com';
    diego_id UUID;
    user_exists BOOLEAN := FALSE;
BEGIN
    -- Verificar si Diego ya existe en auth.users
    SELECT EXISTS(SELECT 1 FROM auth.users WHERE email = diego_email) INTO user_exists;
    
    IF user_exists THEN
        -- Si existe, obtener su ID
        SELECT id INTO diego_id FROM auth.users WHERE email = diego_email;
        RAISE NOTICE 'Diego ya existe en auth.users con ID: %', diego_id;
    ELSE
        -- Si no existe, crearlo
        diego_id := gen_random_uuid();
        
        INSERT INTO auth.users (
            id, 
            email, 
            encrypted_password,
            email_confirmed_at, 
            created_at, 
            updated_at,
            raw_user_meta_data,
            aud,
            role
        ) VALUES (
            diego_id,
            diego_email,
            crypt('admin123', gen_salt('bf')), -- Contraseña temporal: admin123
            NOW(),
            NOW(),
            NOW(),
            '{"full_name": "Diego - Admin"}',
            'authenticated',
            'authenticated'
        );
        
        RAISE NOTICE 'Diego creado en auth.users con ID: % y contraseña temporal: admin123', diego_id;
    END IF;
    
    -- Crear o actualizar perfil de administrador
    INSERT INTO public.profiles (id, email, full_name, role, company, created_at)
    VALUES (
        diego_id,
        diego_email,
        'Diego - Administrador Principal',
        'admin',
        'DigitalPro Agency',
        NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
        role = 'admin',
        full_name = 'Diego - Administrador Principal',
        company = 'DigitalPro Agency';
    
    RAISE NOTICE 'Perfil de administrador creado/actualizado para Diego';
    
END $$;

-- Verificar que todo está correcto
SELECT 
    'Estado Final' as "Tipo",
    au.email as "Email",
    p.full_name as "Nombre",
    p.role as "Rol",
    p.company as "Empresa",
    au.created_at as "Creado"
FROM auth.users au
JOIN public.profiles p ON au.id = p.id
WHERE au.email = 'diegodelp22@gmail.com';
