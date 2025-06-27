"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Progress } from "@/components/ui/progress"
import { CheckCircle, Clock, Play, AlertCircle, Calendar, User, MessageSquare } from "lucide-react"
import { supabase, type ProposalRoadmapStep } from "@/lib/supabase"

interface ProposalRoadmapProps {
  proposalId: string
  isAdmin?: boolean
}

export function ProposalRoadmap({ proposalId, isAdmin = false }: ProposalRoadmapProps) {
  const [roadmapSteps, setRoadmapSteps] = useState<ProposalRoadmapStep[]>([])
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    loadRoadmap()
  }, [proposalId])

  const loadRoadmap = async () => {
    try {
      const { data, error } = await supabase
        .from("proposal_roadmap")
        .select("*")
        .eq("proposal_id", proposalId)
        .order("step_order", { ascending: true })

      if (error) throw error
      setRoadmapSteps(data || [])
    } catch (error) {
      console.error("Error loading roadmap:", error)
    } finally {
      setIsLoading(false)
    }
  }

  const updateStepStatus = async (stepId: string, newStatus: ProposalRoadmapStep["status"]) => {
    try {
      const updates: any = { status: newStatus }

      if (newStatus === "in_progress") {
        updates.started_at = new Date().toISOString()
      } else if (newStatus === "completed") {
        updates.completed_at = new Date().toISOString()

        // Calculate actual days
        const step = roadmapSteps.find((s) => s.id === stepId)
        if (step?.started_at) {
          const startDate = new Date(step.started_at)
          const endDate = new Date()
          const diffTime = Math.abs(endDate.getTime() - startDate.getTime())
          const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
          updates.actual_days = diffDays
        }
      }

      const { error } = await supabase.from("proposal_roadmap").update(updates).eq("id", stepId)

      if (error) throw error

      // If completing a step, start the next one
      if (newStatus === "completed") {
        const currentStep = roadmapSteps.find((s) => s.id === stepId)
        if (currentStep) {
          const nextStep = roadmapSteps.find((s) => s.step_order === currentStep.step_order + 1)
          if (nextStep && nextStep.status === "not_started") {
            await supabase
              .from("proposal_roadmap")
              .update({
                status: "in_progress",
                started_at: new Date().toISOString(),
              })
              .eq("id", nextStep.id)
          }
        }
      }

      loadRoadmap()
    } catch (error) {
      console.error("Error updating step:", error)
    }
  }

  const getStatusIcon = (status: ProposalRoadmapStep["status"]) => {
    switch (status) {
      case "completed":
        return <CheckCircle className="w-5 h-5 text-green-600" />
      case "in_progress":
        return <Play className="w-5 h-5 text-blue-600" />
      case "not_started":
        return <Clock className="w-5 h-5 text-gray-400" />
      case "blocked":
        return <AlertCircle className="w-5 h-5 text-red-600" />
    }
  }

  const getStatusColor = (status: ProposalRoadmapStep["status"]) => {
    switch (status) {
      case "completed":
        return "bg-green-100 text-green-800 border-green-200"
      case "in_progress":
        return "bg-blue-100 text-blue-800 border-blue-200"
      case "not_started":
        return "bg-gray-100 text-gray-600 border-gray-200"
      case "blocked":
        return "bg-red-100 text-red-800 border-red-200"
    }
  }

  const getStatusText = (status: ProposalRoadmapStep["status"]) => {
    switch (status) {
      case "completed":
        return "Completado"
      case "in_progress":
        return "En Progreso"
      case "not_started":
        return "Pendiente"
      case "blocked":
        return "Bloqueado"
    }
  }

  const calculateProgress = () => {
    if (roadmapSteps.length === 0) return 0
    const completedSteps = roadmapSteps.filter((step) => step.status === "completed").length
    return (completedSteps / roadmapSteps.length) * 100
  }

  const getTotalEstimatedDays = () => {
    return roadmapSteps.reduce((total, step) => total + step.estimated_days, 0)
  }

  const getTotalActualDays = () => {
    const completedSteps = roadmapSteps.filter((step) => step.status === "completed")
    return completedSteps.reduce((total, step) => total + (step.actual_days || 0), 0)
  }

  if (isLoading) {
    return (
      <Card>
        <CardContent className="p-6">
          <div className="text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto mb-4"></div>
            <p className="text-gray-600">Cargando roadmap...</p>
          </div>
        </CardContent>
      </Card>
    )
  }

  if (roadmapSteps.length === 0) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Roadmap del Proyecto</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-center py-8">
            <Calendar className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">Roadmap no disponible</h3>
            <p className="text-gray-600">El roadmap se creará automáticamente cuando la propuesta sea aprobada</p>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <span>Roadmap del Proyecto</span>
          <Badge variant="outline" className="text-sm">
            {Math.round(calculateProgress())}% Completado
          </Badge>
        </CardTitle>
        <div className="space-y-2">
          <Progress value={calculateProgress()} className="w-full" />
          <div className="flex justify-between text-sm text-gray-600">
            <span>Estimado: {getTotalEstimatedDays()} días</span>
            <span>Actual: {getTotalActualDays()} días</span>
          </div>
        </div>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {roadmapSteps.map((step, index) => (
            <div key={step.id} className="relative">
              <div
                className={`flex items-start space-x-4 p-4 rounded-lg border-2 transition-all ${
                  step.status === "in_progress"
                    ? "border-blue-500 bg-blue-50"
                    : step.status === "completed"
                      ? "border-green-500 bg-green-50"
                      : "border-gray-200 hover:border-gray-300"
                }`}
              >
                <div className="flex-shrink-0 mt-1">{getStatusIcon(step.status)}</div>

                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between mb-2">
                    <h3 className="text-lg font-semibold text-gray-900">
                      {step.step_order}. {step.title}
                    </h3>
                    <Badge className={getStatusColor(step.status)}>{getStatusText(step.status)}</Badge>
                  </div>

                  {step.description && <p className="text-gray-600 mb-3">{step.description}</p>}

                  <div className="flex items-center space-x-4 text-sm text-gray-500 mb-3">
                    <span>Estimado: {step.estimated_days} días</span>
                    {step.actual_days && <span>Actual: {step.actual_days} días</span>}
                    {step.started_at && <span>Iniciado: {new Date(step.started_at).toLocaleDateString()}</span>}
                    {step.completed_at && <span>Completado: {new Date(step.completed_at).toLocaleDateString()}</span>}
                  </div>

                  {step.notes && (
                    <div className="bg-gray-50 p-3 rounded-md mb-3">
                      <p className="text-sm text-gray-700">{step.notes}</p>
                    </div>
                  )}

                  {isAdmin && (
                    <div className="flex items-center space-x-2">
                      {step.status === "not_started" && (
                        <Button size="sm" onClick={() => updateStepStatus(step.id, "in_progress")}>
                          <Play className="w-4 h-4 mr-2" />
                          Iniciar
                        </Button>
                      )}
                      {step.status === "in_progress" && (
                        <>
                          <Button
                            size="sm"
                            className="bg-green-600 hover:bg-green-700"
                            onClick={() => updateStepStatus(step.id, "completed")}
                          >
                            <CheckCircle className="w-4 h-4 mr-2" />
                            Completar
                          </Button>
                          <Button size="sm" variant="destructive" onClick={() => updateStepStatus(step.id, "blocked")}>
                            <AlertCircle className="w-4 h-4 mr-2" />
                            Bloquear
                          </Button>
                        </>
                      )}
                      {step.status === "blocked" && (
                        <Button size="sm" onClick={() => updateStepStatus(step.id, "in_progress")}>
                          <Play className="w-4 h-4 mr-2" />
                          Reanudar
                        </Button>
                      )}
                    </div>
                  )}

                  {!isAdmin && step.status === "in_progress" && (
                    <div className="flex items-center space-x-2 text-sm text-blue-600">
                      <User className="w-4 h-4" />
                      <span>Nuestro equipo está trabajando en esta etapa</span>
                    </div>
                  )}
                </div>
              </div>

              {index < roadmapSteps.length - 1 && (
                <div className="flex justify-center my-2">
                  <div className="w-px h-6 bg-gray-300"></div>
                </div>
              )}
            </div>
          ))}
        </div>

        {!isAdmin && (
          <div className="mt-6 p-4 bg-blue-50 rounded-lg">
            <div className="flex items-start space-x-3">
              <MessageSquare className="w-5 h-5 text-blue-600 mt-0.5" />
              <div>
                <h4 className="font-medium text-blue-900">¿Tienes preguntas?</h4>
                <p className="text-sm text-blue-700 mt-1">
                  Nuestro equipo te mantendrá informado sobre el progreso. Si tienes alguna pregunta, no dudes en
                  contactarnos.
                </p>
              </div>
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  )
}
