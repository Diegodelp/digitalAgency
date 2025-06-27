-- Script para crear propuestas de ejemplo después de recrear usuarios

DO $$
DECLARE
    test_user_id UUID;
    proposal_count INTEGER;
BEGIN
    -- Obtener ID del usuario test recreado
    SELECT id INTO test_user_id 
    FROM public.profiles 
    WHERE email = 'test@digitalpro.agency' AND role = 'user';
    
    IF test_user_id IS NOT NULL THEN
        -- Verificar propuestas existentes
        SELECT COUNT(*) INTO proposal_count 
        FROM public.proposals 
        WHERE user_id = test_user_id;
        
        RAISE NOTICE 'Usuario test encontrado: %, Propuestas existentes: %', test_user_id, proposal_count;
        
        -- Crear propuestas si no existen
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
            
            RAISE NOTICE 'Propuestas de ejemplo creadas exitosamente';
        ELSE
            RAISE NOTICE 'Ya existen propuestas, no se crearon nuevas';
        END IF;
    ELSE
        RAISE NOTICE 'No se encontró el usuario test para crear propuestas';
    END IF;
END $$;

-- Verificar propuestas creadas
SELECT 
    'PROPUESTAS VERIFICACIÓN' as "Estado",
    p.title,
    p.status,
    p.priority,
    pr.email as "Usuario"
FROM public.proposals p
JOIN public.profiles pr ON p.user_id = pr.id
ORDER BY p.created_at DESC;
