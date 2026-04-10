<script setup lang="ts">
definePageMeta({ layout: 'public', middleware: 'guest' })

const supabase = useSupabaseClient()
const auth = useAuthStore()

const form = reactive({ email: '', password: '' })
const loading = ref(false)
const error = ref('')

async function handleLogin() {
  error.value = ''
  loading.value = true
  try {
    const { error: err } = await supabase.auth.signInWithPassword({
      email: form.email,
      password: form.password,
    })
    if (err) throw err
    await auth.fetchProfile()
    const role = auth.role
    if (role === 'Admin') await navigateTo('/admin/dashboard')
    else if (role === 'CommunityAdmin') await navigateTo('/community/admin')
    else if (role === 'BusinessOwner') await navigateTo('/events')
    else await navigateTo('/home')
  } catch (e: any) {
    error.value = e.message || 'Invalid email or password.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-primary-50 to-primary-100 flex items-center justify-center px-4">
    <div class="w-full max-w-md">
      <div class="text-center mb-8">
        <NuxtLink to="/" class="inline-flex items-center gap-2 mb-6">
          <div class="w-10 h-10 bg-primary-600 rounded-xl flex items-center justify-center">
            <Icon name="heroicons:heart" class="w-6 h-6 text-white" />
          </div>
          <span class="text-2xl font-bold text-gray-900">Hobby Hub</span>
        </NuxtLink>
        <h1 class="text-2xl font-bold text-gray-900">Welcome back</h1>
        <p class="text-gray-500 mt-1">Sign in to your account</p>
      </div>

      <div class="card">
        <form @submit.prevent="handleLogin" class="space-y-4">
          <div v-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">
            {{ error }}
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
            <input v-model="form.email" type="email" required placeholder="you@example.com" class="input-field" />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Password</label>
            <input v-model="form.password" type="password" required placeholder="••••••••" class="input-field" />
          </div>

          <button type="submit" :disabled="loading" class="btn-primary w-full">
            <span v-if="loading" class="flex items-center justify-center gap-2">
              <Icon name="heroicons:arrow-path" class="w-4 h-4 animate-spin" />
              Signing in...
            </span>
            <span v-else>Sign In</span>
          </button>
        </form>

        <p class="text-center text-sm text-gray-500 mt-6">
          Don't have an account?
          <NuxtLink to="/register" class="text-primary-600 hover:underline font-medium">Create one</NuxtLink>
        </p>
      </div>
    </div>
  </div>
</template>
