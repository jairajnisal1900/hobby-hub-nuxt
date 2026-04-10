import { defineStore } from 'pinia'
import type { Profile, UserRole } from '~/types'

export const useAuthStore = defineStore('auth', () => {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()

  const profile = ref<Profile | null>(null)
  const loading = ref(false)

  const isAuthenticated = computed(() => !!user.value)
  const role = computed<UserRole | null>(() => profile.value?.role ?? null)
  const isAdmin = computed(() => role.value === 'Admin')
  const isCommunityAdmin = computed(() => role.value === 'CommunityAdmin')
  const isBusinessOwner = computed(() => role.value === 'BusinessOwner')
  const isUser = computed(() => role.value === 'User')

  async function fetchProfile() {
    if (!user.value) return
    loading.value = true
    const { data } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.value.id)
      .single()
    profile.value = data
    loading.value = false
  }

  async function updateProfile(updates: Partial<Profile>) {
    if (!user.value) return
    const { data, error } = await supabase
      .from('profiles')
      .update(updates)
      .eq('id', user.value.id)
      .select()
      .single()
    if (!error && data) profile.value = data
    return { data, error }
  }

  async function signOut() {
    await supabase.auth.signOut()
    profile.value = null
    await navigateTo('/login')
  }

  watch(user, async (u) => {
    if (u) await fetchProfile()
    else profile.value = null
  }, { immediate: true })

  return {
    profile,
    loading,
    isAuthenticated,
    role,
    isAdmin,
    isCommunityAdmin,
    isBusinessOwner,
    isUser,
    fetchProfile,
    updateProfile,
    signOut,
  }
})
