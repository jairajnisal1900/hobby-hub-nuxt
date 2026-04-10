<script setup lang="ts">
import type { UserRole } from '~/types'
definePageMeta({ layout: 'public', middleware: 'guest' })

const supabase = useSupabaseClient()

const form = reactive({
  name: '',
  email: '',
  password: '',
  confirmPassword: '',
  role: 'User' as UserRole,
})
const loading = ref(false)
const error = ref('')
const success = ref(false)

const roles: { value: UserRole; label: string; description: string }[] = [
  { value: 'User', label: 'Hobbyist', description: 'Join communities and attend events' },
  { value: 'CommunityAdmin', label: 'Community Admin', description: 'Create and manage hobby communities' },
  { value: 'BusinessOwner', label: 'Business Owner', description: 'Create and organize events' },
]

async function handleRegister() {
  error.value = ''
  if (form.password !== form.confirmPassword) {
    error.value = 'Passwords do not match.'
    return
  }
  if (form.password.length < 6) {
    error.value = 'Password must be at least 6 characters.'
    return
  }

  loading.value = true
  try {
    const { error: err } = await supabase.auth.signUp({
      email: form.email,
      password: form.password,
      options: {
        data: { name: form.name, role: form.role },
      },
    })
    if (err) throw err
    success.value = true
  } catch (e: any) {
    error.value = e.message || 'Registration failed. Please try again.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-primary-50 to-primary-100 flex items-center justify-center px-4 py-12">
    <div class="w-full max-w-md">
      <div class="text-center mb-8">
        <NuxtLink to="/" class="inline-flex items-center gap-2 mb-6">
          <div class="w-10 h-10 bg-primary-600 rounded-xl flex items-center justify-center">
            <Icon name="heroicons:heart" class="w-6 h-6 text-white" />
          </div>
          <span class="text-2xl font-bold text-gray-900">Hobby Hub</span>
        </NuxtLink>
        <h1 class="text-2xl font-bold text-gray-900">Create your account</h1>
        <p class="text-gray-500 mt-1">Join the Hobby Hub community</p>
      </div>

      <!-- Success state -->
      <div v-if="success" class="card text-center">
        <div class="w-14 h-14 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
          <Icon name="heroicons:check" class="w-7 h-7 text-green-600" />
        </div>
        <h2 class="text-xl font-semibold text-gray-900 mb-2">Check your email!</h2>
        <p class="text-gray-500 text-sm">We've sent a confirmation link to <strong>{{ form.email }}</strong>. Click the link to activate your account.</p>
        <NuxtLink to="/login" class="btn-primary inline-block mt-6">Back to Login</NuxtLink>
      </div>

      <div v-else class="card">
        <form @submit.prevent="handleRegister" class="space-y-4">
          <div v-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">
            {{ error }}
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Full Name</label>
            <input v-model="form.name" type="text" required placeholder="John Doe" class="input-field" />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
            <input v-model="form.email" type="email" required placeholder="you@example.com" class="input-field" />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Password</label>
            <input v-model="form.password" type="password" required placeholder="Min. 6 characters" class="input-field" />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Confirm Password</label>
            <input v-model="form.confirmPassword" type="password" required placeholder="Repeat password" class="input-field" />
          </div>

          <!-- Role selection -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">I want to join as...</label>
            <div class="space-y-2">
              <label
                v-for="r in roles"
                :key="r.value"
                class="flex items-start gap-3 p-3 border rounded-lg cursor-pointer transition-colors"
                :class="form.role === r.value ? 'border-primary-500 bg-primary-50' : 'border-gray-200 hover:border-gray-300'"
              >
                <input v-model="form.role" :value="r.value" type="radio" class="mt-0.5" />
                <div>
                  <p class="font-medium text-gray-900 text-sm">{{ r.label }}</p>
                  <p class="text-xs text-gray-500">{{ r.description }}</p>
                </div>
              </label>
            </div>
          </div>

          <button type="submit" :disabled="loading" class="btn-primary w-full">
            <span v-if="loading" class="flex items-center justify-center gap-2">
              <Icon name="heroicons:arrow-path" class="w-4 h-4 animate-spin" />
              Creating account...
            </span>
            <span v-else>Create Account</span>
          </button>
        </form>

        <p class="text-center text-sm text-gray-500 mt-6">
          Already have an account?
          <NuxtLink to="/login" class="text-primary-600 hover:underline font-medium">Sign in</NuxtLink>
        </p>
      </div>
    </div>
  </div>
</template>
