<script setup lang="ts">
definePageMeta({ middleware: 'auth' })

const auth = useAuthStore()
const supabase = useSupabaseClient()

const stats = ref({ communities: 0, events: 0, members: 0 })

onMounted(async () => {
  const [{ count: c }, { count: e }, { count: m }] = await Promise.all([
    supabase.from('communities').select('*', { count: 'exact', head: true }),
    supabase.from('events').select('*', { count: 'exact', head: true }),
    supabase.from('profiles').select('*', { count: 'exact', head: true }),
  ])
  stats.value = { communities: c ?? 0, events: e ?? 0, members: m ?? 0 }
})
</script>

<template>
  <div>
    <!-- Welcome banner -->
    <div class="bg-gradient-to-r from-primary-600 to-primary-700 rounded-2xl p-8 text-white mb-8">
      <h1 class="text-2xl font-bold mb-1">Welcome back, {{ auth.profile?.name }}!</h1>
      <p class="text-primary-100">Ready to explore your hobbies today?</p>
    </div>

    <!-- Stats -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-6 mb-8">
      <div class="card flex items-center gap-4">
        <div class="w-12 h-12 bg-primary-100 rounded-xl flex items-center justify-center">
          <Icon name="heroicons:user-group" class="w-6 h-6 text-primary-600" />
        </div>
        <div>
          <p class="text-2xl font-bold text-gray-900">{{ stats.communities }}</p>
          <p class="text-sm text-gray-500">Communities</p>
        </div>
      </div>
      <div class="card flex items-center gap-4">
        <div class="w-12 h-12 bg-accent/20 rounded-xl flex items-center justify-center">
          <Icon name="heroicons:calendar" class="w-6 h-6 text-accent-dark" />
        </div>
        <div>
          <p class="text-2xl font-bold text-gray-900">{{ stats.events }}</p>
          <p class="text-sm text-gray-500">Events</p>
        </div>
      </div>
      <div class="card flex items-center gap-4">
        <div class="w-12 h-12 bg-green-100 rounded-xl flex items-center justify-center">
          <Icon name="heroicons:users" class="w-6 h-6 text-green-600" />
        </div>
        <div>
          <p class="text-2xl font-bold text-gray-900">{{ stats.members }}</p>
          <p class="text-sm text-gray-500">Members</p>
        </div>
      </div>
    </div>

    <!-- Quick actions based on role -->
    <div class="card">
      <h2 class="font-semibold text-gray-900 mb-4">Quick Actions</h2>
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <template v-if="auth.isUser">
          <NuxtLink to="/community" class="flex items-center gap-3 p-4 border border-gray-200 rounded-xl hover:border-primary-300 hover:bg-primary-50 transition-colors">
            <Icon name="heroicons:user-group" class="w-5 h-5 text-primary-600" />
            <span class="font-medium text-gray-700">Browse Communities</span>
          </NuxtLink>
          <NuxtLink to="/events/user" class="flex items-center gap-3 p-4 border border-gray-200 rounded-xl hover:border-primary-300 hover:bg-primary-50 transition-colors">
            <Icon name="heroicons:calendar" class="w-5 h-5 text-primary-600" />
            <span class="font-medium text-gray-700">Discover Events</span>
          </NuxtLink>
        </template>
        <template v-if="auth.isCommunityAdmin">
          <NuxtLink to="/community/create" class="flex items-center gap-3 p-4 border border-gray-200 rounded-xl hover:border-primary-300 hover:bg-primary-50 transition-colors">
            <Icon name="heroicons:plus-circle" class="w-5 h-5 text-primary-600" />
            <span class="font-medium text-gray-700">Create Community</span>
          </NuxtLink>
          <NuxtLink to="/community/admin" class="flex items-center gap-3 p-4 border border-gray-200 rounded-xl hover:border-primary-300 hover:bg-primary-50 transition-colors">
            <Icon name="heroicons:shield-check" class="w-5 h-5 text-primary-600" />
            <span class="font-medium text-gray-700">Manage Communities</span>
          </NuxtLink>
        </template>
        <template v-if="auth.isBusinessOwner">
          <NuxtLink to="/events/create" class="flex items-center gap-3 p-4 border border-gray-200 rounded-xl hover:border-primary-300 hover:bg-primary-50 transition-colors">
            <Icon name="heroicons:plus-circle" class="w-5 h-5 text-primary-600" />
            <span class="font-medium text-gray-700">Create Event</span>
          </NuxtLink>
          <NuxtLink to="/events" class="flex items-center gap-3 p-4 border border-gray-200 rounded-xl hover:border-primary-300 hover:bg-primary-50 transition-colors">
            <Icon name="heroicons:calendar" class="w-5 h-5 text-primary-600" />
            <span class="font-medium text-gray-700">My Events</span>
          </NuxtLink>
        </template>
        <template v-if="auth.isAdmin">
          <NuxtLink to="/admin/dashboard" class="flex items-center gap-3 p-4 border border-gray-200 rounded-xl hover:border-primary-300 hover:bg-primary-50 transition-colors">
            <Icon name="heroicons:chart-bar" class="w-5 h-5 text-primary-600" />
            <span class="font-medium text-gray-700">Admin Dashboard</span>
          </NuxtLink>
        </template>
        <NuxtLink to="/profile/settings" class="flex items-center gap-3 p-4 border border-gray-200 rounded-xl hover:border-primary-300 hover:bg-primary-50 transition-colors">
          <Icon name="heroicons:cog-6-tooth" class="w-5 h-5 text-primary-600" />
          <span class="font-medium text-gray-700">Profile Settings</span>
        </NuxtLink>
      </div>
    </div>
  </div>
</template>
