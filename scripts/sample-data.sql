-- Script opcional para insertar datos de prueba
-- Solo ejecutar si quieres datos de ejemplo

-- Insertar algunas propuestas de ejemplo (solo si tienes usuarios de prueba)
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
  (SELECT id FROM public.profiles WHERE email = 'test@digitalpro.agency' LIMIT 1),
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
  (SELECT id FROM public.profiles WHERE email = 'test@digitalpro.agency' LIMIT 1),
  'API REST para E-commerce',
  'API completa para tienda online con autenticación, carrito de compras y pasarela de pagos.',
  'api',
  '3000-5000',
  '3-4weeks',
  'in_review',
  'medium',
  ARRAY['API REST', 'Autenticación de usuarios', 'Integración de pagos', 'Base de datos']
);

-- Verificar que los datos se insertaron correctamente
SELECT 
  p.title,
  p.project_type,
  p.status,
  pr.email as user_email
FROM public.proposals p
JOIN public.profiles pr ON p.user_id = pr.id;
