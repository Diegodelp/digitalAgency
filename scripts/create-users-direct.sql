-- Crear usuarios directamente usando la función de Supabase

-- 1. Crear usuario administrador
DO $$
DECLARE
    admin_id UUID;
    user_id UUID;
BEGIN
    -- Generar IDs únicos
    admin_id := uuid_generate_v4();
    user_id := uuid_generate_v4();
    
    RAISE NOTICE 'Creando usuarios con IDs: Admin=%, User=%', admin_id, user_id;
    
    -- Crear perfil de administrador
    INSERT INTO public.profiles (
        id,
        email,
        full_name,
        role,
        company,
        created_at
    ) VALUES (
        admin_id,
        'diegodelp22@gmail.com',
        'Diego - Administrador Principal',
        'admin',
        'DigitalPro Agency',
        NOW()
    );
    
    RAISE NOTICE 'Perfil de admin creado: %', admin_id;
    
    -- Crear perfil de usuario test
    INSERT INTO public.profiles (
        id,
        email,
        full_name,
        role,
        company,
        created_at
    ) VALUES (
        user_id,
        'test@digitalpro.agency',
        'Usuario de Prueba',
        'user',
        'Empresa Test',
        NOW()
    );
    
    RAISE NOTICE 'Perfil de usuario creado: %', user_id;
    
    -- Crear propuestas de ejemplo para el usuario test
    INSERT INTO public.proposals (
        user_id,
        title,
        description,
        project_type,
        budget_range,
        timeline,
        status,
        priority,
        features,
        created_at
    ) VALUES 
    (
        user_id,
        'Sistema de Análisis de Datos con Python',
        'Sistema completo de análisis de datos usando Python, pandas, y machine learning para generar reportes automáticos de ventas y métricas de negocio.',
        'python-app',
        '5000-10000',
        '1-2months',
        'pending',
        'high',
        ARRAY['Machine Learning', 'Análisis de datos', 'Automatización de procesos', 'Panel de administración'],
        NOW() - INTERVAL '2 days'
    ),
    (
        user_id,
        'API REST para E-commerce',
        'API completa para tienda online con autenticación JWT, carrito de compras, pasarela de pagos Stripe y gestión completa de inventario.',
        'api',
        '3000-5000',
        '3-4weeks',
        'approved',
        'medium',
        ARRAY['API REST', 'Autenticación de usuarios', 'Integración de pagos', 'Base de datos'],
        NOW() - INTERVAL '1 day'
    ),
    (
        user_id,
        'Dashboard Analytics con IA',
        'Panel de control inteligente con predicciones usando machine learning, visualizaciones interactivas con D3.js y reportes automáticos.',
        'ai-ml',
        '10000-20000',
        '3-6months',
        'in_development',
        'high',
        ARRAY['Machine Learning', 'Panel de administración', 'Análisis de datos', 'Diseño responsive'],
        NOW() - INTERVAL '3 hours'
    );
    
    RAISE NOTICE 'Propuestas de ejemplo creadas';
    
    -- Mostrar resumen
    RAISE NOTICE '=== USUARIOS CREADOS ===';
    RAISE NOTICE 'Admin: diegodelp22@gmail.com (ID: %)', admin_id;
    RAISE NOTICE 'User: test@digitalpro.agency (ID: %)', user_id;
    RAISE NOTICE 'Propuestas creadas: 3';
    
END $$;
