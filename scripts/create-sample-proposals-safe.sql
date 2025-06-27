-- Script para crear propuestas de ejemplo de forma segura

DO $$
DECLARE
    test_user_id UUID;
    proposal_count INTEGER;
BEGIN
    -- Obtener ID del usuario de prueba
    SELECT p.id INTO test_user_id 
    FROM public.profiles p
    WHERE p.email = 'test@digitalpro.agency' AND p.role = 'user';
    
    IF test_user_id IS NOT NULL THEN
        -- Verificar si ya existen propuestas
        SELECT COUNT(*) INTO proposal_count 
        FROM public.proposals 
        WHERE user_id = test_user_id;
        
        RAISE NOTICE 'Usuario test encontrado: %, Propuestas existentes: %', test_user_id, proposal_count;
        
        -- Solo crear propuestas si no existen
        IF proposal_count = 0 THEN
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
            );
            
            RAISE NOTICE 'Se crearon 3 propuestas de ejemplo';
        ELSE
            RAISE NOTICE 'Ya existen propuestas, no se crearon nuevas';
        END IF;
    ELSE
        RAISE NOTICE 'No se encontró el usuario de prueba';
    END IF;
END $$;

-- Verificar propuestas
SELECT 
    'PROPUESTAS VERIFICACIÓN' as "Estado",
    COUNT(*) as "Total_Propuestas",
    string_agg(DISTINCT status, ', ') as "Estados"
FROM public.proposals;
