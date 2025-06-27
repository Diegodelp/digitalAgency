"use client"

import type React from "react"

import { useState, useEffect } from "react"
import Link from "next/link"
import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Checkbox } from "@/components/ui/checkbox"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { ArrowLeft, Code, Send, CheckCircle } from "lucide-react"
import { supabase } from "@/lib/supabase"

export default function NewProposalPage() {
  const [user, setUser] = useState<any>(null)
  const [formData, setFormData] = useState({
    title: "",
    description: "",
    project_type: "",
    budget_range: "",
    timeline: "",
    requirements: "",
    additional_info: "",
  })
  const [selectedFeatures, setSelectedFeatures] = useState<string[]>([])
  const [isLoading, setIsLoading] = useState(false)
  const [success, setSuccess] = useState(false)
  const [error, setError] = useState("")
  const router = useRouter()

  useEffect(() => {
    const getUser = async () => {
      const {
        data: { user },
      } = await supabase.auth.getUser()
      if (!user) {
        router.push("/auth/login")
        return
      }
      setUser(user)
    }
    getUser()
  }, [router])

  const projectTypes = [
    { value: "web-app", label: "Aplicación Web" },
    { value: "api", label: "API / Backend" },
    { value: "python-app", label: "Aplicación Python" },
    { value: "ai-ml", label: "IA / Machine Learning" },
    { value: "mobile-app", label: "Aplicación Móvil" },
    { value: "ecommerce", label: "E-commerce" },
    { value: "data-analysis", label: "Análisis de Datos" },
    { value: "automation", label: "Automatización" },
    { value: "custom", label: "Desarrollo Personalizado" },
  ]

  const budgetRanges = [
    { value: "1000-3000", label: "$1,000 - $3,000" },
    { value: "3000-5000", label: "$3,000 - $5,000" },
    { value: "5000-10000", label: "$5,000 - $10,000" },
    { value: "10000-20000", label: "$10,000 - $20,000" },
    { value: "20000-50000", label: "$20,000 - $50,000" },
    { value: "50000+", label: "$50,000+" },
  ]

  const timelineOptions = [
    { value: "1-2weeks", label: "1-2 semanas" },
    { value: "3-4weeks", label: "3-4 semanas" },
    { value: "1-2months", label: "1-2 meses" },
    { value: "3-6months", label: "3-6 meses" },
    { value: "6months+", label: "Más de 6 meses" },
  ]

  const features = [
    "Autenticación de usuarios",
    "Panel de administración",
    "Base de datos",
    "API REST",
    "Diseño responsive",
    "Integración de pagos",
    "Notificaciones",
    "Análisis y reportes",
    "Integración con terceros",
    "Optimización SEO",
    "Machine Learning",
    "Análisis de datos",
    "Automatización de procesos",
    "Scraping de datos",
    "Chatbot con IA",
    "Procesamiento de imágenes",
  ]

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    })
  }

  const handleSelectChange = (name: string, value: string) => {
    setFormData({
      ...formData,
      [name]: value,
    })
  }

  const handleFeatureToggle = (feature: string) => {
    setSelectedFeatures((prev) => (prev.includes(feature) ? prev.filter((f) => f !== feature) : [...prev, feature]))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    setError("")

    // Validaciones básicas
    if (!formData.title || !formData.description || !formData.project_type) {
      setError("Por favor completa todos los campos obligatorios")
      setIsLoading(false)
      return
    }

    if (!user) {
      setError("Debes estar autenticado para enviar una propuesta")
      setIsLoading(false)
      return
    }

    try {
      const { error: insertError } = await supabase.from("proposals").insert({
        user_id: user.id,
        title: formData.title,
        description: formData.description,
        project_type: formData.project_type,
        budget_range: formData.budget_range,
        timeline: formData.timeline,
        requirements: formData.requirements,
        additional_info: formData.additional_info,
        features: selectedFeatures,
        status: "pending",
        priority: "medium",
      })

      if (insertError) throw insertError

      setSuccess(true)

      // Redirigir después de 3 segundos
      setTimeout(() => {
        router.push("/dashboard")
      }, 3000)
    } catch (err: any) {
      setError(err.message || "Error al enviar la propuesta. Por favor, intenta de nuevo.")
    } finally {
      setIsLoading(false)
    }
  }

  if (success) {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
        <Card className="w-full max-w-md border-0 shadow-lg">
          <CardContent className="pt-6">
            <div className="text-center">
              <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <CheckCircle className="w-8 h-8 text-green-600" />
              </div>
              <h2 className="text-2xl font-bold text-gray-900 mb-2">¡Propuesta Enviada!</h2>
              <p className="text-gray-600 mb-4">
                Tu propuesta ha sido enviada exitosamente. Nuestro equipo la revisará y te contactará pronto. Se creará
                automáticamente una tarea en ClickUp para el seguimiento.
              </p>
              <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600 mx-auto"></div>
              <p className="text-sm text-gray-500 mt-2">Redirigiendo al dashboard...</p>
            </div>
          </CardContent>
        </Card>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-slate-50">
      {/* Header */}
      <header className="bg-white border-b">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <Link href="/dashboard" className="flex items-center space-x-2 text-gray-600 hover:text-gray-900">
            <ArrowLeft className="w-5 h-5" />
            <span>Volver al Dashboard</span>
          </Link>

          <Link href="/" className="flex items-center space-x-2">
            <div className="w-8 h-8 bg-gradient-to-r from-blue-600 to-purple-600 rounded-lg flex items-center justify-center">
              <Code className="w-5 h-5 text-white" />
            </div>
            <span className="text-xl font-bold text-gray-900">DigitalPro Agency</span>
          </Link>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        <div className="max-w-3xl mx-auto">
          <div className="mb-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-2">Nueva Propuesta de Proyecto</h1>
            <p className="text-gray-600">
              Completa el formulario con los detalles de tu proyecto. Incluimos desarrollo con Python, IA y análisis de
              datos.
            </p>
          </div>

          <Card className="border-0 shadow-lg">
            <CardHeader>
              <CardTitle>Detalles del Proyecto</CardTitle>
              <CardDescription>Proporciona toda la información necesaria para evaluar tu proyecto</CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-6">
                {error && (
                  <Alert className="border-red-200 bg-red-50">
                    <AlertDescription className="text-red-800">{error}</AlertDescription>
                  </Alert>
                )}

                {/* Información Básica */}
                <div className="space-y-4">
                  <h3 className="text-lg font-semibold text-gray-900">Información Básica</h3>

                  <div className="space-y-2">
                    <Label htmlFor="title">Título del Proyecto *</Label>
                    <Input
                      id="title"
                      name="title"
                      placeholder="Ej: Sistema de análisis de datos con Python"
                      value={formData.title}
                      onChange={handleInputChange}
                      required
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="description">Descripción del Proyecto *</Label>
                    <Textarea
                      id="description"
                      name="description"
                      placeholder="Describe detalladamente qué necesitas, objetivos del proyecto, funcionalidades principales..."
                      rows={4}
                      value={formData.description}
                      onChange={handleInputChange}
                      required
                    />
                  </div>

                  <div className="grid md:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label>Tipo de Proyecto *</Label>
                      <Select onValueChange={(value) => handleSelectChange("project_type", value)}>
                        <SelectTrigger>
                          <SelectValue placeholder="Selecciona el tipo de proyecto" />
                        </SelectTrigger>
                        <SelectContent>
                          {projectTypes.map((type) => (
                            <SelectItem key={type.value} value={type.value}>
                              {type.label}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="space-y-2">
                      <Label>Presupuesto Estimado</Label>
                      <Select onValueChange={(value) => handleSelectChange("budget_range", value)}>
                        <SelectTrigger>
                          <SelectValue placeholder="Selecciona tu presupuesto" />
                        </SelectTrigger>
                        <SelectContent>
                          {budgetRanges.map((range) => (
                            <SelectItem key={range.value} value={range.value}>
                              {range.label}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label>Tiempo Estimado</Label>
                    <Select onValueChange={(value) => handleSelectChange("timeline", value)}>
                      <SelectTrigger>
                        <SelectValue placeholder="¿Cuándo necesitas el proyecto?" />
                      </SelectTrigger>
                      <SelectContent>
                        {timelineOptions.map((option) => (
                          <SelectItem key={option.value} value={option.value}>
                            {option.label}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                {/* Funcionalidades */}
                <div className="space-y-4">
                  <h3 className="text-lg font-semibold text-gray-900">Funcionalidades Requeridas</h3>
                  <p className="text-sm text-gray-600">
                    Selecciona las funcionalidades que necesitas (incluye opciones de Python e IA):
                  </p>

                  <div className="grid md:grid-cols-2 gap-3">
                    {features.map((feature) => (
                      <div key={feature} className="flex items-center space-x-2">
                        <Checkbox
                          id={feature}
                          checked={selectedFeatures.includes(feature)}
                          onCheckedChange={() => handleFeatureToggle(feature)}
                        />
                        <Label htmlFor={feature} className="text-sm">
                          {feature}
                        </Label>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Requisitos Técnicos */}
                <div className="space-y-4">
                  <h3 className="text-lg font-semibold text-gray-900">Requisitos Técnicos</h3>

                  <div className="space-y-2">
                    <Label htmlFor="requirements">Requisitos Específicos</Label>
                    <Textarea
                      id="requirements"
                      name="requirements"
                      placeholder="Tecnologías específicas (Python, frameworks, librerías de ML), integraciones necesarias, requisitos de rendimiento..."
                      rows={3}
                      value={formData.requirements}
                      onChange={handleInputChange}
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="additional_info">Información Adicional</Label>
                    <Textarea
                      id="additional_info"
                      name="additional_info"
                      placeholder="Cualquier información adicional que consideres relevante..."
                      rows={3}
                      value={formData.additional_info}
                      onChange={handleInputChange}
                    />
                  </div>
                </div>

                {/* Botones */}
                <div className="flex items-center justify-between pt-6 border-t">
                  <Link href="/dashboard">
                    <Button type="button" variant="outline">
                      Cancelar
                    </Button>
                  </Link>

                  <Button type="submit" disabled={isLoading}>
                    {isLoading ? (
                      <>
                        <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                        Enviando...
                      </>
                    ) : (
                      <>
                        <Send className="w-4 h-4 mr-2" />
                        Enviar Propuesta
                      </>
                    )}
                  </Button>
                </div>
              </form>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}
