-- Script simple y directo para crear Diego como admin

-- Paso 1: Crear Diego en auth.users si no existe
DO $$
DECLARE
    diego_id UUID := gen_random_uuid();
BEGIN
    -- Intentar insertar Diego en auth.users
    BEGIN
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
            'diegodelp22@gmail.com',
            crypt('admin123', gen_salt('bf')),
            NOW(),
            NOW(),
            NOW(),
            '{"full_name": "Diego Admin"}',
            'authenticated',
            'authenticated'
        );
        
        RAISE NOTICE 'Diego creado en auth.users con ID: %', diego_id;
        
    EXCEPTION 
        WHEN unique_violation THEN
            -- Si ya existe, obtener su ID
            SELECT id INTO diego_id FROM auth.users WHERE email = 'diegodelp22@gmail.com';
            RAISE NOTICE 'Diego ya existe en auth.users con ID: %', diego_id;
    END;
    
    -- Crear perfil de admin para Diego
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
        
        RAISE NOTICE 'Perfil de admin creado para Diego';
        
    EXCEPTION 
        WHEN unique_violation THEN
            -- Si ya existe, actualizarlo
            UPDATE public.profiles 
            SET 
                role = 'admin',
                full_name = 'Diego - Administrador Principal',
                company = 'DigitalPro Agency'
            WHERE id = diego_id;
            
            RAISE NOTICE 'Perfil de Diego actualizado a admin';
    END;
    
END $$;

-- Verificar que Diego es admin
SELECT 
    'DIEGO ADMIN CREADO' as "Estado",
    email,
    full_name,
    role,
    company
FROM public.profiles 
WHERE email = 'diegodelp22@gmail.com';

-- Mostrar credenciales
SELECT 
    'CREDENCIALES' as "Info",
    'diegodelp22@gmail.com' as "Email",
    'admin123' as "Password",
    'Ve a /auth/login' as "URL";
