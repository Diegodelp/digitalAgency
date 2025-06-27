-- Script para crear propuestas de ejemplo después de arreglar los usuarios

DO $$
DECLARE
    test_user_id UUID;
    proposal_count INTEGER;
BEGIN
    -- Obtener ID del usuario de prueba
    SELECT id INTO test_user_id 
    FROM auth.users 
    WHERE email = 'test@digitalpro.agency';
    
    IF test_user_id IS NOT NULL THEN
        -- Verificar si ya existen propuestas
        SELECT COUNT(*) INTO proposal_count 
        FROM public.proposals 
        WHERE user_id = test_user_id;
        
        IF proposal_count = 0 THEN
            -- Crear propuestas de ejemplo
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
                test_user_id,
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
                test_user_id,
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
                test_user_id,
                'Dashboard Analytics con IA',
                'Panel de control inteligente con predicciones usando machine learning, visualizaciones interactivas con D3.js y reportes automáticos.',
                'ai-ml',
                '10000-20000',
                '3-6months',
                'in_development',
                'high',
                ARRAY['Machine Learning', 'Panel de administración', 'Análisis de datos', 'Diseño responsive'],
                NOW() - INTERVAL '3 hours'
            ),
            (
                test_user_id,
                'Aplicación Web de Gestión de Proyectos',
                'Sistema completo de gestión de proyectos con kanban boards, seguimiento de tiempo, colaboración en equipo y reportes.',
                'web-app',
                '20000-50000',
                '6months+',
                'in_review',
                'medium',
                ARRAY['Autenticación de usuarios', 'Panel de administración', 'Base de datos', 'Notificaciones', 'Diseño responsive'],
                NOW() - INTERVAL '5 hours'
            );
            
            RAISE NOTICE 'Se crearon 4 propuestas de ejemplo';
        ELSE
            RAISE NOTICE 'Ya existen % propuestas para el usuario de prueba', proposal_count;
        END IF;
    ELSE
        RAISE NOTICE 'No se encontró el usuario de prueba';
    END IF;
END $$;

-- Verificar propuestas creadas
SELECT 
    'PROPUESTAS CREADAS' as "Estado",
    p.title,
    p.status,
    p.priority,
    p.budget_range,
    pr.email as "Usuario"
FROM public.proposals p
JOIN public.profiles pr ON p.user_id = pr.id
ORDER BY p.created_at DESC;
