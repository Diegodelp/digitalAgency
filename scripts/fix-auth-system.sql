-- Script para corregir el sistema de autenticación

-- 1. Recrear la función handle_new_user con mejor manejo de errores
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Intentar insertar el perfil
  BEGIN
    INSERT INTO public.profiles (id, email, full_name, avatar_url, role)
    VALUES (
      NEW.id,
      NEW.email,
      COALESCE(
        NEW.raw_user_meta_data->>'full_name', 
        NEW.raw_user_meta_data->>'name',
        split_part(NEW.email, '@', 1)
      ),
      NEW.raw_user_meta_data->>'avatar_url',
      'user'
    );
    
    -- Log exitoso
    RAISE NOTICE 'Perfil creado exitosamente para usuario: % (ID: %)', NEW.email, NEW.id;
    
  EXCEPTION 
    WHEN unique_violation THEN
      -- Si ya existe, actualizar
      UPDATE public.profiles 
      SET 
        email = NEW.email,
        full_name = COALESCE(
          NEW.raw_user_meta_data->>'full_name', 
          NEW.raw_user_meta_data->>'name',
          public.profiles.full_name,
          split_part(NEW.email, '@', 1)
        ),
        avatar_url = COALESCE(NEW.raw_user_meta_data->>'avatar_url', public.profiles.avatar_url)
      WHERE id = NEW.id;
      
      RAISE NOTICE 'Perfil actualizado para usuario existente: % (ID: %)', NEW.email, NEW.id;
      
    WHEN OTHERS THEN
      -- Log del error
      RAISE NOTICE 'Error creando perfil para %: % %', NEW.email, SQLSTATE, SQLERRM;
  END;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Eliminar trigger existente y recrearlo
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 3. Crear función para migrar usuarios existentes
CREATE OR REPLACE FUNCTION public.migrate_existing_users()
RETURNS void AS $$
DECLARE
    user_record RECORD;
    profile_count INTEGER;
BEGIN
    -- Contar perfiles existentes
    SELECT COUNT(*) INTO profile_count FROM public.profiles;
    RAISE NOTICE 'Perfiles existentes antes de migración: %', profile_count;
    
    -- Migrar usuarios que no tienen perfil
    FOR user_record IN 
        SELECT au.id, au.email, au.raw_user_meta_data, au.created_at
        FROM auth.users au
        LEFT JOIN public.profiles p ON au.id = p.id
        WHERE p.id IS NULL
    LOOP
        BEGIN
            INSERT INTO public.profiles (id, email, full_name, avatar_url, role, created_at)
            VALUES (
                user_record.id,
                user_record.email,
                COALESCE(
                    user_record.raw_user_meta_data->>'full_name',
                    user_record.raw_user_meta_data->>'name',
                    split_part(user_record.email, '@', 1)
                ),
                user_record.raw_user_meta_data->>'avatar_url',
                'user',
                user_record.created_at
            );
            
            RAISE NOTICE 'Migrado usuario: % (ID: %)', user_record.email, user_record.id;
            
        EXCEPTION 
            WHEN OTHERS THEN
                RAISE NOTICE 'Error migrando usuario %: % %', user_record.email, SQLSTATE, SQLERRM;
        END;
    END LOOP;
    
    -- Contar perfiles después de migración
    SELECT COUNT(*) INTO profile_count FROM public.profiles;
    RAISE NOTICE 'Perfiles después de migración: %', profile_count;
END;
$$ LANGUAGE plpgsql;

-- 4. Ejecutar migración de usuarios existentes
SELECT public.migrate_existing_users();

-- 5. Verificar que todo funciona
SELECT 
    'Verificación final' as "Estado",
    (SELECT COUNT(*) FROM auth.users) as "Usuarios_Auth",
    (SELECT COUNT(*) FROM public.profiles) as "Perfiles_Public",
    CASE 
        WHEN (SELECT COUNT(*) FROM auth.users) = (SELECT COUNT(*) FROM public.profiles) 
        THEN 'SINCRONIZADO' 
        ELSE 'DESINCRONIZADO' 
    END as "Estado_Sync";
