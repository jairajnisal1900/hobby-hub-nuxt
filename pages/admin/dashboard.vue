<script setup lang="ts">
import type { Profile } from '~/types'

definePageMeta({ middleware: 'auth' })

const auth = useAuthStore()
const supabase = useSupabaseClient()

if (!auth.isAdmin) navigateTo('/home')

const users = ref<Profile[]>([])
const loading = ref(true)
const deleteLoading = ref<string | null>(null)

const stats = computed(() => {
  const counts = { Admin: 0, User: 0, CommunityAdmin: 0, BusinessOwner: 0 }
  users.value.forEach(u => counts[u.role]++)
  return counts
})

async function fetchUsers() {
  loading.value = true
  const { data } = await supabase.from('profiles').select('*').order('created_at', { ascending: false })
  users.value = data ?? []
  loading.value = false
}

async function deleteUser(id: string) {
  if (!confirm('Are you sure you want to delete this user?')) return
  deleteLoading.value = id
  await supabase.from('profiles').delete().eq('id', id)
  users.value = users.value.filter(u => u.id !== id)
  deleteLoading.value = null
}

onMounted(fetchUsers)
</script>

<template>
  <div>
    <h1 class="text-2xl font-bold text-gray-900 mb-6">Admin Dashboard</h1>

    <!-- Stats -->
    <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
      <div class="card text-center">
        <p class="text-3xl font-bold text-gray-900">{{ users.length }}</p>
        <p class="text-sm text-gray-500 mt-1">Total Users</p>
      </div>
      <div class="card text-center">
        <p class="text-3xl font-bold text-gray-900">{{ stats.User }}</p>
        <p class="text-sm text-gray-500 mt-1">Hobbyists</p>
      </div>
      <div class="card text-center">
        <p class="text-3xl font-bold text-gray-900">{{ stats.CommunityAdmin }}</p>
        <p class="text-sm text-gray-500 mt-1">Community Admins</p>
      </div>
      <div class="card text-center">
        <p class="text-3xl font-bold text-gray-900">{{ stats.BusinessOwner }}</p>
        <p class="text-sm text-gray-500 mt-1">Business Owners</p>
      </div>
    </div>

    <!-- Users table -->
    <div class="card">
      <h2 class="font-semibold text-gray-900 mb-4">All Users</h2>

      <div v-if="loading" class="flex justify-center py-12">
        <Icon name="heroicons:arrow-path" class="w-8 h-8 text-primary-600 animate-spin" />
      </div>

      <div v-else class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead>
            <tr class="border-b border-gray-100">
              <th class="text-left py-3 px-3 font-medium text-gray-500">User</th>
              <th class="text-left py-3 px-3 font-medium text-gray-500">Email</th>
              <th class="text-left py-3 px-3 font-medium text-gray-500">Role</th>
              <th class="text-left py-3 px-3 font-medium text-gray-500">Joined</th>
              <th class="py-3 px-3"></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="user in users" :key="user.id" class="border-b border-gray-50 hover:bg-gray-50 transition-colors">
              <td class="py-3 px-3">
                <div class="flex items-center gap-3">
                  <div class="w-8 h-8 rounded-full bg-primary-100 flex items-center justify-center overflow-hidden flex-shrink-0">
                    <img v-if="user.profile_image_url" :src="user.profile_image_url" alt="" class="w-full h-full object-cover" />
                    <Icon v-else name="heroicons:user" class="w-4 h-4 text-primary-600" />
                  </div>
                  <span class="font-medium text-gray-900">{{ user.name }}</span>
                </div>
              </td>
              <td class="py-3 px-3 text-gray-500">{{ user.email }}</td>
              <td class="py-3 px-3">
                <span class="badge" :class="{
                  'badge-admin': user.role === 'Admin',
                  'badge-business': user.role === 'BusinessOwner',
                  'bg-green-100 text-green-800': user.role === 'CommunityAdmin',
                  'bg-gray-100 text-gray-800': user.role === 'User',
                }">{{ user.role }}</span>
              </td>
              <td class="py-3 px-3 text-gray-500">{{ new Date(user.created_at).toLocaleDateString() }}</td>
              <td class="py-3 px-3">
                <button
                  v-if="user.id !== auth.profile?.id"
                  @click="deleteUser(user.id)"
                  :disabled="deleteLoading === user.id"
                  class="text-red-500 hover:text-red-700 transition-colors"
                >
                  <Icon :name="deleteLoading === user.id ? 'heroicons:arrow-path' : 'heroicons:trash'" class="w-4 h-4" :class="{ 'animate-spin': deleteLoading === user.id }" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>
