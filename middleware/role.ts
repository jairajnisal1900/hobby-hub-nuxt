import type { UserRole } from '~/types'

export default defineNuxtRouteMiddleware((to) => {
  const user = useSupabaseUser()
  const auth = useAuthStore()

  if (!user.value) return navigateTo('/login')

  const requiredRole = to.meta.requiredRole as UserRole | undefined
  if (requiredRole && auth.role !== requiredRole && !auth.isAdmin) {
    return navigateTo('/home')
  }
})
