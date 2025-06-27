import { supabase } from "./supabase"
import type { User } from "@supabase/supabase-js"

export interface UserProfile {
  id: string
  email: string
  full_name: string | null
  role: "admin" | "user"
  company: string | null
  created_at: string
  updated_at: string
}

export async function getCurrentUser(): Promise<User | null> {
  try {
    const {
      data: { user },
      error,
    } = await supabase.auth.getUser()

    if (error) {
      console.error("Error getting current user:", error)
      return null
    }

    return user
  } catch (error) {
    console.error("Error in getCurrentUser:", error)
    return null
  }
}

export async function getUserProfile(userId: string): Promise<UserProfile | null> {
  try {
    if (!userId) {
      console.error("No userId provided to getUserProfile")
      return null
    }

    const { data, error } = await supabase.from("profiles").select("*").eq("id", userId).single()

    if (error) {
      console.error("Error getting user profile:", error)
      return null
    }

    return data
  } catch (error) {
    console.error("Error in getUserProfile:", error)
    return null
  }
}

export async function getCurrentUserProfile(): Promise<UserProfile | null> {
  try {
    const user = await getCurrentUser()

    if (!user) {
      console.log("No authenticated user found")
      return null
    }

    const profile = await getUserProfile(user.id)

    if (!profile) {
      console.error("No profile found for user:", user.id)
      return null
    }

    return profile
  } catch (error) {
    console.error("Error in getCurrentUserProfile:", error)
    return null
  }
}

export async function signIn(email: string, password: string) {
  try {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    if (error) {
      console.error("Sign in error:", error)
      return { user: null, error: error.message }
    }

    return { user: data.user, error: null }
  } catch (error) {
    console.error("Error in signIn:", error)
    return { user: null, error: "Error inesperado al iniciar sesión" }
  }
}

export async function signOut() {
  try {
    const { error } = await supabase.auth.signOut()

    if (error) {
      console.error("Sign out error:", error)
      return { error: error.message }
    }

    return { error: null }
  } catch (error) {
    console.error("Error in signOut:", error)
    return { error: "Error inesperado al cerrar sesión" }
  }
}

export async function signUp(email: string, password: string, fullName: string, company?: string) {
  try {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: fullName,
          company: company || null,
        },
      },
    })

    if (error) {
      console.error("Sign up error:", error)
      return { user: null, error: error.message }
    }

    return { user: data.user, error: null }
  } catch (error) {
    console.error("Error in signUp:", error)
    return { user: null, error: "Error inesperado al registrarse" }
  }
}

export function isAdmin(profile: UserProfile | null): boolean {
  return profile?.role === "admin"
}

export function isUser(profile: UserProfile | null): boolean {
  return profile?.role === "user"
}
