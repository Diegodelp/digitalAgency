-- Este script debe ejecutarse DESPUÉS del script anterior
-- Reemplaza 'tu-email@gmail.com' con tu email real

-- Primero, asegúrate de que tu usuario existe en auth.users
-- (esto se hace registrándote normalmente en la aplicación)

-- Luego actualiza el perfil para hacerlo admin
UPDATE public.profiles 
SET role = 'admin', full_name = 'Administrador Principal'
WHERE email = 'tu-email@gmail.com'; -- Reemplaza con tu email real

-- Si el perfil no existe, créalo manualmente (solo si es necesario)
INSERT INTO public.profiles (id, email, full_name, role)
SELECT id, email, 'Administrador Principal', 'admin'
FROM auth.users 
WHERE email = 'tu-email@gmail.com' -- Reemplaza con tu email real
ON CONFLICT (id) DO UPDATE SET 
  role = 'admin',
  full_name = 'Administrador Principal';

-- Verificar que el admin fue creado correctamente
SELECT id, email, full_name, role, created_at 
FROM public.profiles 
WHERE role = 'admin';
