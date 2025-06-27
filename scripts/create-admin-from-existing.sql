-- Script para convertir un usuario existente en administrador
-- IMPORTANTE: Reemplaza 'tu-email@gmail.com' con tu email real

DO $$
DECLARE
    admin_email TEXT := 'tu-email@gmail.com'; -- CAMBIA ESTO POR TU EMAIL
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
            'Administrador Principal',
            'admin',
            NOW()
        );
        
        RAISE NOTICE 'Perfil de administrador creado';
    ELSE
        -- Actualizar perfil existente
        UPDATE public.profiles 
        SET 
            role = 'admin',
            full_name = COALESCE(full_name, 'Administrador Principal')
        WHERE id = user_id;
        
        RAISE NOTICE 'Perfil actualizado a administrador';
    END IF;
    
    -- Verificar resultado
    SELECT 
        p.email,
        p.full_name,
        p.role,
        p.created_at
    FROM public.profiles p
    WHERE p.id = user_id;
    
    RAISE NOTICE 'Administrador configurado exitosamente: %', admin_email;
    
END $$;

-- Verificar administradores
SELECT 
    'Administradores' as "Tipo",
    email,
    full_name,
    role,
    created_at
FROM public.profiles 
WHERE role = 'admin';
