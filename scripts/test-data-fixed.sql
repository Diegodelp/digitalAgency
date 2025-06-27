-- Script para insertar datos de prueba con UUIDs válidos
-- Solo ejecutar si quieres datos de ejemplo

-- Generar un UUID válido para el usuario de prueba
DO $$
DECLARE
    test_user_id UUID := gen_random_uuid();
BEGIN
    -- Crear un usuario de prueba si no existe
    INSERT INTO auth.users (id, email, email_confirmed_at, created_at, updated_at)
    VALUES (
      test_user_id,
      'test@digitalpro.agency',
      NOW(),
      NOW(),
      NOW()
    ) ON CONFLICT (email) DO NOTHING;

    -- Crear perfil de prueba
    INSERT INTO public.profiles (id, email, full_name, role, company)
    VALUES (
      test_user_id,
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
      test_user_id,
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
      test_user_id,
      'API REST para E-commerce',
      'API completa para tienda online con autenticación, carrito de compras y pasarela de pagos.',
      'api',
      '3000-5000',
      '3-4weeks',
      'approved',
      'medium',
      ARRAY['API REST', 'Autenticación de usuarios', 'Integración de pagos', 'Base de datos']
    ),
    (
      test_user_id,
      'Dashboard de Métricas con IA',
      'Panel de control inteligente que muestre métricas de negocio con predicciones usando machine learning.',
      'ai-ml',
      '10000-20000',
      '3-6months',
      'in_development',
      'high',
      ARRAY['Machine Learning', 'Panel de administración', 'Análisis de datos', 'Diseño responsive']
    ) ON CONFLICT DO NOTHING;

    -- Mostrar información del usuario creado
    RAISE NOTICE 'Usuario de prueba creado con ID: %', test_user_id;
END $$;

-- Verificar que los datos se insertaron correctamente
SELECT 
  p.title,
  p.project_type,
  p.status,
  pr.email as user_email,
  pr.full_name
FROM public.proposals p
JOIN public.profiles pr ON p.user_id = pr.id
WHERE pr.email = 'test@digitalpro.agency';

-- Mostrar estadísticas
SELECT 
  'Total usuarios' as metric,
  COUNT(*) as value
FROM public.profiles
UNION ALL
SELECT 
  'Total propuestas' as metric,
  COUNT(*) as value
FROM public.proposals
UNION ALL
SELECT 
  'Propuestas pendientes' as metric,
  COUNT(*) as value
FROM public.proposals
WHERE status = 'pending'
UNION ALL
SELECT 
  'Propuestas aprobadas' as metric,
  COUNT(*) as value
FROM public.proposals
WHERE status = 'approved' OR status = 'in_development';
