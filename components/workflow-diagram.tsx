"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"

export function WorkflowDiagram() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Flujo de Trabajo</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="text-center py-8">
          <p className="text-gray-600">
            El flujo de trabajo ahora se gestiona a través del sistema de roadmap interno de cada propuesta.
          </p>
        </div>
      </CardContent>
    </Card>
  )
}

export function ProjectWorkflow() {
  return <WorkflowDiagram />
}
