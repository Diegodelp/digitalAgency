-- Este script debe ejecutarse DESPUÉS de que hayas creado tu cuenta en Supabase
-- Reemplaza 'tu-email@gmail.com' con tu email real

-- Actualizar el perfil del usuario para hacerlo admin
UPDATE public.profiles 
SET role = 'admin', full_name = 'Administrador Principal'
WHERE email = 'tu-email@gmail.com'; -- Reemplaza con tu email real

-- Si el perfil no existe, puedes crearlo manualmente:
-- INSERT INTO public.profiles (id, email, full_name, role)
-- SELECT id, email, 'Administrador Principal', 'admin'
-- FROM auth.users 
-- WHERE email = 'tu-email@gmail.com'
-- ON CONFLICT (id) DO UPDATE SET role = 'admin';

-- Verificar que el admin fue creado correctamente
SELECT id, email, full_name, role, created_at 
FROM public.profiles 
WHERE role = 'admin';
