-- Script opcional para insertar datos de prueba
-- Solo ejecutar si quieres datos de ejemplo

-- Crear un usuario de prueba si no existe
INSERT INTO auth.users (id, email, email_confirmed_at, created_at, updated_at)
VALUES (
  'test-user-uuid-12345',
  'test@digitalpro.agency',
  NOW(),
  NOW(),
  NOW()
) ON CONFLICT (email) DO NOTHING;

-- Crear perfil de prueba
INSERT INTO public.profiles (id, email, full_name, role, company)
VALUES (
  'test-user-uuid-12345',
  'test@digitalpro.agency',
  'Usuario de Prueba',
  'user',
  'Empresa Test'
) ON CONFLICT (id) DO UPDATE SET
  full_name = 'Usuario de Prueba',
  company = 'Empresa Test';

-- Insertar propuestas de ejemplo
INSERT INTO public.proposals (
  user_id,
  title,
  description,
  project_type,
  budget_range,
  timeline,
  status,
  priority,
  features
) VALUES 
(
  'test-user-uuid-12345',
  'Sistema de Análisis de Datos con Python',
  'Necesito un sistema que analice datos de ventas y genere reportes automáticos usando Python y machine learning.',
  'python-app',
  '5000-10000',
  '1-2months',
  'pending',
  'high',
  ARRAY['Machine Learning', 'Análisis de datos', 'Automatización de procesos', 'Panel de administración']
),
(
  'test-user-uuid-12345',
  'API REST para E-commerce',
  'API completa para tienda online con autenticación, carrito de compras y pasarela de pagos.',
  'api',
  '3000-5000',
  '3-4weeks',
  'approved',
  'medium',
  ARRAY['API REST', 'Autenticación de usuarios', 'Integración de pagos', 'Base de datos']
) ON CONFLICT DO NOTHING;

-- Verificar que los datos se insertaron correctamente
SELECT 
  p.title,
  p.project_type,
  p.status,
  pr.email as user_email
FROM public.proposals p
JOIN public.profiles pr ON p.user_id = pr.id;
