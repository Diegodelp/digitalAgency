"use client"

import type React from "react"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { signIn } from "@/lib/auth-utils"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Loader2, User, Shield } from "lucide-react"
import Link from "next/link"

export default function LoginPage() {
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [error, setError] = useState("")
  const [loading, setLoading] = useState(false)
  const router = useRouter()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError("")
    setLoading(true)

    try {
      const { user, error } = await signIn(email, password)

      if (error) {
        setError(error)
        return
      }

      if (user) {
        // Redirigir al dashboard
        router.push("/dashboard")
        router.refresh()
      }
    } catch (err) {
      setError("Error inesperado al iniciar sesión")
      console.error("Login error:", err)
    } finally {
      setLoading(false)
    }
  }

  const handleQuickLogin = async (userType: "admin" | "user") => {
    setError("")
    setLoading(true)

    const credentials = {
      admin: { email: "diegodelp22@gmail.com", password: "123456" },
      user: { email: "test@digitalpro.agency", password: "123456" },
    }

    try {
      const { user, error } = await signIn(credentials[userType].email, credentials[userType].password)

      if (error) {
        setError(error)
        return
      }

      if (user) {
        router.push("/dashboard")
        router.refresh()
      }
    } catch (err) {
      setError("Error inesperado al iniciar sesión")
      console.error("Quick login error:", err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100 p-4">
      <Card className="w-full max-w-md">
        <CardHeader className="space-y-1">
          <CardTitle className="text-2xl font-bold text-center">Iniciar Sesión</CardTitle>
          <CardDescription className="text-center">Accede a tu cuenta de DigitalPro Agency</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {error && (
            <Alert variant="destructive">
              <AlertDescription>{error}</AlertDescription>
            </Alert>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                placeholder="tu@email.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                disabled={loading}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="password">Contraseña</Label>
              <Input
                id="password"
                type="password"
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                disabled={loading}
              />
            </div>

            <Button type="submit" className="w-full" disabled={loading}>
              {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              Iniciar Sesión
            </Button>
          </form>

          <div className="relative">
            <div className="absolute inset-0 flex items-center">
              <span className="w-full border-t" />
            </div>
            <div className="relative flex justify-center text-xs uppercase">
              <span className="bg-background px-2 text-muted-foreground">Acceso rápido para pruebas</span>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-2">
            <Button
              variant="outline"
              onClick={() => handleQuickLogin("admin")}
              disabled={loading}
              className="flex items-center gap-2"
            >
              <Shield className="h-4 w-4" />
              Admin
            </Button>
            <Button
              variant="outline"
              onClick={() => handleQuickLogin("user")}
              disabled={loading}
              className="flex items-center gap-2"
            >
              <User className="h-4 w-4" />
              Usuario
            </Button>
          </div>

          <div className="text-center text-sm">
            <span className="text-muted-foreground">¿No tienes cuenta? </span>
            <Link href="/auth/register" className="text-primary hover:underline">
              Regístrate aquí
            </Link>
          </div>

          <div className="text-xs text-muted-foreground text-center space-y-1">
            <p>
              <strong>Credenciales de prueba:</strong>
            </p>
            <p>Admin: diegodelp22@gmail.com / 123456</p>
            <p>Usuario: test@digitalpro.agency / 123456</p>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
