-- Crear función RPC para obtener perfiles sin problemas de RLS

CREATE OR REPLACE FUNCTION get_profile_by_email(profile_email TEXT)
RETURNS TABLE (
    id UUID,
    email TEXT,
    full_name TEXT,
    role TEXT,
    company TEXT,
    phone TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) 
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.email,
        p.full_name,
        p.role,
        p.company,
        p.phone,
        p.avatar_url,
        p.created_at,
        p.updated_at
    FROM public.profiles p
    WHERE p.email = profile_email
    LIMIT 1;
END;
$$;

-- Dar permisos para ejecutar la función
GRANT EXECUTE ON FUNCTION get_profile_by_email(TEXT) TO anon, authenticated;

SELECT 'Función RPC creada correctamente' as resultado;
