-- Script para convertir diegodelp22@gmail.com en administrador

DO $$
DECLARE
    admin_email TEXT := 'diegodelp22@gmail.com';
    user_id UUID;
    profile_exists BOOLEAN := FALSE;
BEGIN
    -- Buscar el usuario en auth.users
    SELECT id INTO user_id 
    FROM auth.users 
    WHERE email = admin_email;
    
    IF user_id IS NULL THEN
        RAISE EXCEPTION 'No se encontró usuario con email: %. Primero regístrate en la aplicación.', admin_email;
    END IF;
    
    RAISE NOTICE 'Usuario encontrado con ID: %', user_id;
    
    -- Verificar si existe el perfil
    SELECT EXISTS(SELECT 1 FROM public.profiles WHERE id = user_id) INTO profile_exists;
    
    IF NOT profile_exists THEN
        -- Crear perfil si no existe
        INSERT INTO public.profiles (id, email, full_name, role, created_at)
        VALUES (
            user_id,
            admin_email,
            'Diego - Administrador Principal',
            'admin',
            NOW()
        );
        
        RAISE NOTICE 'Perfil de administrador creado para Diego';
    ELSE
        -- Actualizar perfil existente
        UPDATE public.profiles 
        SET 
            role = 'admin',
            full_name = COALESCE(full_name, 'Diego - Administrador Principal')
        WHERE id = user_id;
        
        RAISE NOTICE 'Perfil de Diego actualizado a administrador';
    END IF;
    
END $$;

-- Verificar que Diego es ahora administrador
SELECT 
    'Verificación Admin' as "Estado",
    email,
    full_name,
    role,
    created_at
FROM public.profiles 
WHERE email = 'diegodelp22@gmail.com';
