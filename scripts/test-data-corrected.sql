-- Script para insertar datos de prueba con UUIDs válidos
-- Solo ejecutar si quieres datos de ejemplo

-- Generar un UUID válido para el usuario de prueba
DO $$
DECLARE
    test_user_id UUID := gen_random_uuid();
    proposal_1_id UUID := gen_random_uuid();
    proposal_2_id UUID := gen_random_uuid();
    proposal_3_id UUID := gen_random_uuid();
BEGIN
    -- Verificar si el usuario de prueba ya existe
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'test@digitalpro.agency') THEN
        -- Crear un usuario de prueba
        INSERT INTO auth.users (id, email, email_confirmed_at, created_at, updated_at)
        VALUES (
          test_user_id,
          'test@digitalpro.agency',
          NOW(),
          NOW(),
          NOW()
        );

        -- Crear perfil de prueba
        INSERT INTO public.profiles (id, email, full_name, role, company)
        VALUES (
          test_user_id,
          'test@digitalpro.agency',
          'Usuario de Prueba',
          'user',
          'Empresa Test'
        );

        RAISE NOTICE 'Usuario de prueba creado con ID: %', test_user_id;
    ELSE
        -- Obtener el ID del usuario existente
        SELECT au.id INTO test_user_id 
        FROM auth.users au 
        WHERE au.email = 'test@digitalpro.agency';
        
        RAISE NOTICE 'Usuario de prueba ya existe con ID: %', test_user_id;
    END IF;

    -- Verificar si ya existen propuestas para este usuario
    IF NOT EXISTS (SELECT 1 FROM public.proposals WHERE user_id = test_user_id) THEN
        -- Insertar propuestas de ejemplo
        INSERT INTO public.proposals (
          id,
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
          proposal_1_id,
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
          proposal_2_id,
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
          proposal_3_id,
          test_user_id,
          'Dashboard de Métricas con IA',
          'Panel de control inteligente que muestre métricas de negocio con predicciones usando machine learning.',
          'ai-ml',
          '10000-20000',
          '3-6months',
          'in_development',
          'high',
          ARRAY['Machine Learning', 'Panel de administración', 'Análisis de datos', 'Diseño responsive']
        );

        RAISE NOTICE 'Propuestas de prueba creadas: %, %, %', proposal_1_id, proposal_2_id, proposal_3_id;
    ELSE
        RAISE NOTICE 'Ya existen propuestas para el usuario de prueba';
    END IF;

END $$;

-- Verificar que los datos se insertaron correctamente
SELECT 
  p.id,
  p.title,
  p.project_type,
  p.status,
  pr.email as user_email,
  pr.full_name
FROM public.proposals p
JOIN public.profiles pr ON p.user_id = pr.id
WHERE pr.email = 'test@digitalpro.agency'
ORDER BY p.created_at;
