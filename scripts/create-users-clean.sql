-- Crear usuarios limpios sin conflictos

-- 1. Eliminar usuarios existentes si existen
DELETE FROM public.profiles WHERE email IN ('diegodelp22@gmail.com', 'test@digitalpro.agency');

-- 2. Crear usuario administrador
INSERT INTO public.profiles (
    id,
    email,
    full_name,
    role,
    company,
    phone
) VALUES (
    uuid_generate_v4(),
    'diegodelp22@gmail.com',
    'Diego Delgado',
    'admin',
    'DigitalPro Agency',
    '+1234567890'
);

-- 3. Crear usuario de prueba
INSERT INTO public.profiles (
    id,
    email,
    full_name,
    role,
    company,
    phone
) VALUES (
    uuid_generate_v4(),
    'test@digitalpro.agency',
    'Usuario de Prueba',
    'user',
    'Empresa Test',
    '+0987654321'
);

-- 4. Crear propuestas de ejemplo
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
    features,
    additional_notes
) VALUES 
(
    uuid_generate_v4(),
    (SELECT id FROM public.profiles WHERE email = 'test@digitalpro.agency'),
    'Aplicación Web de E-commerce',
    'Desarrollo de una plataforma de comercio electrónico completa con carrito de compras, pagos y gestión de inventario.',
    'web-app',
    '10000-20000',
    '3-6months',
    'pending',
    'high',
    ARRAY['Carrito de compras', 'Pagos en línea', 'Gestión de inventario', 'Panel de administración'],
    'Necesitamos integración con Stripe y diseño responsive.'
),
(
    uuid_generate_v4(),
    (SELECT id FROM public.profiles WHERE email = 'test@digitalpro.agency'),
    'API REST para Mobile App',
    'Desarrollo de API REST para aplicación móvil con autenticación JWT y base de datos PostgreSQL.',
    'api',
    '5000-10000',
    '1-2months',
    'approved',
    'medium',
    ARRAY['Autenticación JWT', 'CRUD completo', 'Documentación API', 'Tests unitarios'],
    'La API debe ser escalable y bien documentada.'
),
(
    uuid_generate_v4(),
    (SELECT id FROM public.profiles WHERE email = 'test@digitalpro.agency'),
    'Sistema de Análisis con Python',
    'Desarrollo de sistema de análisis de datos con Python, pandas y visualizaciones interactivas.',
    'python-app',
    '3000-5000',
    '3-4weeks',
    'in_development',
    'medium',
    ARRAY['Análisis de datos', 'Visualizaciones', 'Reportes automáticos', 'Dashboard web'],
    'Necesitamos integración con bases de datos existentes.'
);

-- Verificar creación
SELECT 'Usuarios creados correctamente' as resultado,
       COUNT(*) as total_usuarios,
       COUNT(CASE WHEN role = 'admin' THEN 1 END) as admins,
       COUNT(CASE WHEN role = 'user' THEN 1 END) as users
FROM public.profiles;

SELECT 'Propuestas creadas correctamente' as resultado,
       COUNT(*) as total_propuestas
FROM public.proposals;
