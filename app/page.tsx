import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { ArrowRight, Code, Database, Globe, Zap, Users, CheckCircle, Brain } from "lucide-react"

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100">
      {/* Header */}
      <header className="border-b bg-white/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <div className="w-8 h-8 bg-gradient-to-r from-blue-600 to-purple-600 rounded-lg flex items-center justify-center">
              <Code className="w-5 h-5 text-white" />
            </div>
            <span className="text-xl font-bold text-gray-900">DigitalPro Agency</span>
          </div>
          <nav className="hidden md:flex items-center space-x-6">
            <Link href="#servicios" className="text-gray-600 hover:text-gray-900 transition-colors">
              Servicios
            </Link>
            <Link href="#tecnologias" className="text-gray-600 hover:text-gray-900 transition-colors">
              Tecnologías
            </Link>
            <Link href="#proceso" className="text-gray-600 hover:text-gray-900 transition-colors">
              Proceso
            </Link>
            <Link href="#contacto" className="text-gray-600 hover:text-gray-900 transition-colors">
              Contacto
            </Link>
          </nav>
          <div className="flex items-center space-x-3">
            <Link href="/auth/login">
              <Button variant="ghost">Iniciar Sesión</Button>
            </Link>
            <Link href="/auth/register">
              <Button>Registrarse</Button>
            </Link>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="py-20 px-4">
        <div className="container mx-auto text-center">
          <Badge className="mb-4 bg-blue-100 text-blue-800 hover:bg-blue-100">
            🚀 Transformamos ideas en realidad digital
          </Badge>
          <h1 className="text-5xl md:text-6xl font-bold text-gray-900 mb-6 leading-tight">
            Desarrollo de
            <span className="bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
              {" "}
              Productos Digitales
            </span>
          </h1>
          <p className="text-xl text-gray-600 mb-8 max-w-3xl mx-auto leading-relaxed">
            Especializados en aplicaciones web, APIs robustas, desarrollo con Python y soluciones personalizadas.
            Conectamos tu visión con la tecnología más avanzada.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link href="/auth/register">
              <Button
                size="lg"
                className="bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700"
              >
                Solicitar Propuesta
                <ArrowRight className="ml-2 w-4 h-4" />
              </Button>
            </Link>
            <Link href="#servicios">
              <Button size="lg" variant="outline">
                Ver Servicios
              </Button>
            </Link>
          </div>
        </div>
      </section>

      {/* Services Section */}
      <section id="servicios" className="py-20 px-4 bg-white">
        <div className="container mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-gray-900 mb-4">Nuestros Servicios</h2>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              Ofrecemos soluciones digitales completas adaptadas a las necesidades de tu negocio
            </p>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            <Card className="border-0 shadow-lg hover:shadow-xl transition-shadow">
              <CardHeader>
                <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center mb-4">
                  <Globe className="w-6 h-6 text-blue-600" />
                </div>
                <CardTitle>Aplicaciones Web</CardTitle>
                <CardDescription>
                  Desarrollo de aplicaciones web modernas y escalables con las últimas tecnologías
                </CardDescription>
              </CardHeader>
              <CardContent>
                <ul className="space-y-2 text-sm text-gray-600">
                  <li className="flex items-center">
                    <CheckCircle className="w-4 h-4 text-green-500 mr-2" />
                    React, Next.js, Vue.js
                  </li>
                  <li className="flex items-center">
                    <CheckCircle className="w-4 h-4 text-green-500 mr-2" />
                    Diseño responsive
                  </li>
                  <li className="flex items-center">
                    <CheckCircle className="w-4 h-4 text-green-500 mr-2" />
                    Optimización SEO
                  </li>
                </ul>
              </CardContent>
            </Card>

            <Card className="border-0 shadow-lg hover:shadow-xl transition-shadow">
              <CardHeader>
                <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center mb-4">
                  <Database className="w-6 h-6 text-purple-600" />
                </div>
                <CardTitle>APIs y Backend</CardTitle>
                <CardDescription>
                  Creación de APIs robustas y sistemas backend escalables para tu aplicación
                </CardDescription>
              </CardHeader>
              <CardContent>
                <ul className="space-y-2 text-sm text-gray-600">
                  <li className="flex items-center">
                    <CheckCircle className="w-4 h-4 text-green-500 mr-2" />
                    REST y GraphQL APIs
                  </li>
                  <li className="flex items-center">
                    <CheckCircle className="w-4 h-4 text-green-500 mr-2" />
                    Bases de datos optimizadas
                  </li>
                  <li className="flex items-center">
                    <CheckCircle className="w-4 h-4 text-green-500 mr-2" />
                    Seguridad avanzada
                  </li>
                </ul>
              </CardContent>
            </Card>

            <Card className="border-0 shadow-lg hover:shadow-xl transition-shadow">
              <CardHeader>
                <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center mb-4">
                  <Brain className="w-6 h-6 text-green-600" />
                </div>
                <CardTitle>Desarrollo con Python</CardTitle>
                <CardDescription>
                  Soluciones avanzadas con Python para IA, análisis de datos y automatización
                </CardDescription>
              </CardHeader>
              <CardContent>
                <ul className="space-y-2 text-sm text-gray-600">
                  <li className="flex items-center">
                    <CheckCircle className="w-4 h-4 text-green-500 mr-2" />
                    Machine Learning & IA
                  </li>
                  <li className="flex items-center">
                    <CheckCircle className="w-4 h-4 text-green-500 mr-2" />
                    Análisis de datos
                  </li>
                  <li className="flex items-center">
                    <CheckCircle className="w-4 h-4 text-green-500 mr-2" />
                    Automatización de procesos
                  </li>
                </ul>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Technologies Section */}
      <section id="tecnologias" className="py-20 px-4 bg-slate-50">
        <div className="container mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-gray-900 mb-4">Tecnologías que Dominamos</h2>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              Trabajamos con las tecnologías más modernas y demandadas del mercado
            </p>
          </div>

          <div className="grid md:grid-cols-4 gap-8">
            <div className="text-center">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Frontend</h3>
              <div className="space-y-2">
                {["React", "Next.js", "Vue.js", "TypeScript", "Tailwind CSS"].map((tech) => (
                  <Badge key={tech} variant="secondary" className="mr-2 mb-2">
                    {tech}
                  </Badge>
                ))}
              </div>
            </div>

            <div className="text-center">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Backend</h3>
              <div className="space-y-2">
                {["Node.js", "Python", "Django", "FastAPI", "Express.js"].map((tech) => (
                  <Badge key={tech} variant="secondary" className="mr-2 mb-2">
                    {tech}
                  </Badge>
                ))}
              </div>
            </div>

            <div className="text-center">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Base de Datos</h3>
              <div className="space-y-2">
                {["PostgreSQL", "MongoDB", "Supabase", "Redis", "MySQL"].map((tech) => (
                  <Badge key={tech} variant="secondary" className="mr-2 mb-2">
                    {tech}
                  </Badge>
                ))}
              </div>
            </div>

            <div className="text-center">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Python & IA</h3>
              <div className="space-y-2">
                {["TensorFlow", "PyTorch", "Pandas", "NumPy", "Scikit-learn"].map((tech) => (
                  <Badge key={tech} variant="secondary" className="mr-2 mb-2">
                    {tech}
                  </Badge>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Process Section */}
      <section id="proceso" className="py-20 px-4 bg-white">
        <div className="container mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-gray-900 mb-4">Nuestro Proceso</h2>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              Un proceso estructurado que garantiza resultados excepcionales con seguimiento en ClickUp
            </p>
          </div>
          <div className="grid md:grid-cols-4 gap-8">
            {[
              {
                step: "01",
                title: "Propuesta",
                description: "Envía tu idea y requisitos a través de nuestra plataforma",
                icon: Users,
              },
              {
                step: "02",
                title: "Análisis & ClickUp",
                description: "Analizamos tu proyecto y creamos tareas en ClickUp con deadlines",
                icon: Zap,
              },
              {
                step: "03",
                title: "Desarrollo",
                description: "Desarrollamos tu producto con actualizaciones constantes y seguimiento",
                icon: Code,
              },
              {
                step: "04",
                title: "Entrega",
                description: "Entregamos el producto final con soporte continuo",
                icon: CheckCircle,
              },
            ].map((item, index) => (
              <div key={index} className="text-center">
                <div className="w-16 h-16 bg-gradient-to-r from-blue-600 to-purple-600 rounded-full flex items-center justify-center mx-auto mb-4">
                  <item.icon className="w-8 h-8 text-white" />
                </div>
                <div className="text-sm font-semibold text-blue-600 mb-2">PASO {item.step}</div>
                <h3 className="text-xl font-bold text-gray-900 mb-2">{item.title}</h3>
                <p className="text-gray-600">{item.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 px-4 bg-gradient-to-r from-blue-600 to-purple-600">
        <div className="container mx-auto text-center">
          <h2 className="text-4xl font-bold text-white mb-4">¿Listo para comenzar tu proyecto?</h2>
          <p className="text-xl text-blue-100 mb-8 max-w-2xl mx-auto">
            Únete a nuestra plataforma y conecta con nuestro equipo de expertos en desarrollo web y Python
          </p>
          <Link href="/auth/register">
            <Button size="lg" className="bg-white text-blue-600 hover:bg-gray-100">
              Crear Cuenta Gratuita
              <ArrowRight className="ml-2 w-4 h-4" />
            </Button>
          </Link>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-white py-12 px-4">
        <div className="container mx-auto">
          <div className="grid md:grid-cols-4 gap-8">
            <div>
              <div className="flex items-center space-x-2 mb-4">
                <div className="w-8 h-8 bg-gradient-to-r from-blue-600 to-purple-600 rounded-lg flex items-center justify-center">
                  <Code className="w-5 h-5 text-white" />
                </div>
                <span className="text-xl font-bold">DigitalPro Agency</span>
              </div>
              <p className="text-gray-400">Transformamos ideas en productos digitales excepcionales</p>
            </div>
            <div>
              <h4 className="font-semibold mb-4">Servicios</h4>
              <ul className="space-y-2 text-gray-400">
                <li>Aplicaciones Web</li>
                <li>APIs y Backend</li>
                <li>Desarrollo con Python</li>
                <li>Inteligencia Artificial</li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold mb-4">Tecnologías</h4>
              <ul className="space-y-2 text-gray-400">
                <li>React & Next.js</li>
                <li>Python & Django</li>
                <li>Node.js & APIs</li>
                <li>Machine Learning</li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold mb-4">Contacto</h4>
              <p className="text-gray-400">
                info@digitalpro.agency
                <br />
                +1 (555) 123-4567
              </p>
            </div>
          </div>
          <div className="border-t border-gray-800 mt-8 pt-8 text-center text-gray-400">
            <p>&copy; 2024 DigitalPro Agency. Todos los derechos reservados.</p>
          </div>
        </div>
      </footer>
    </div>
  )
}
