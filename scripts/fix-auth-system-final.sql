-- Limpiar y recrear el sistema de autenticación

-- 1. Eliminar usuarios existentes
DELETE FROM auth.users;
DELETE FROM profiles;

-- 2. Crear usuarios con contraseñas correctas
INSERT INTO auth.users (
  id,
  instance_id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES 
(
  '11111111-1111-1111-1111-111111111111',
  '00000000-0000-0000-0000-000000000000',
  'diegodelp22@gmail.com',
  crypt('123456', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
),
(
  '22222222-2222-2222-2222-222222222222',
  '00000000-0000-0000-0000-000000000000',
  'test@digitalpro.agency',
  crypt('123456', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
);

-- 3. Crear perfiles correspondientes
INSERT INTO profiles (
  id,
  email,
  full_name,
  role,
  company,
  created_at,
  updated_at
) VALUES 
(
  '11111111-1111-1111-1111-111111111111',
  'diegodelp22@gmail.com',
  'Diego Delgado',
  'admin',
  'DigitalPro Agency',
  NOW(),
  NOW()
),
(
  '22222222-2222-2222-2222-222222222222',
  'test@digitalpro.agency',
  'Usuario Test',
  'user',
  'Test Company',
  NOW(),
  NOW()
);

-- 4. Verificar que todo esté correcto
SELECT 
  u.email,
  u.email_confirmed_at,
  p.full_name,
  p.role
FROM auth.users u
JOIN profiles p ON u.id = p.id;
