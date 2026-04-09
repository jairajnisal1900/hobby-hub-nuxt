<script setup lang="ts">
defineProps<{ isOpen: boolean }>()
defineEmits<{ toggle: [] }>()

const auth = useAuthStore()

const adminLinks = [
  { to: '/admin/dashboard', icon: 'heroicons:chart-bar', label: 'Dashboard' },
]

const userLinks = [
  { to: '/home', icon: 'heroicons:home', label: 'Home' },
  { to: '/community', icon: 'heroicons:user-group', label: 'My Communities' },
  { to: '/events/user', icon: 'heroicons:calendar', label: 'Events' },
  { to: '/profile/settings', icon: 'heroicons:cog-6-tooth', label: 'Settings' },
]

const communityAdminLinks = [
  { to: '/home', icon: 'heroicons:home', label: 'Home' },
  { to: '/community/admin', icon: 'heroicons:shield-check', label: 'Manage Community' },
  { to: '/community/create', icon: 'heroicons:plus-circle', label: 'Create Community' },
  { to: '/community', icon: 'heroicons:user-group', label: 'All Communities' },
  { to: '/profile/settings', icon: 'heroicons:cog-6-tooth', label: 'Settings' },
]

const businessOwnerLinks = [
  { to: '/home', icon: 'heroicons:home', label: 'Home' },
  { to: '/events', icon: 'heroicons:calendar', label: 'My Events' },
  { to: '/events/create', icon: 'heroicons:plus-circle', label: 'Create Event' },
  { to: '/profile/settings', icon: 'heroicons:cog-6-tooth', label: 'Settings' },
]

const navLinks = computed(() => {
  if (auth.isAdmin) return adminLinks
  if (auth.isCommunityAdmin) return communityAdminLinks
  if (auth.isBusinessOwner) return businessOwnerLinks
  return userLinks
})
</script>

<template>
  <aside
    class="fixed left-0 top-0 h-full bg-white border-r border-gray-100 shadow-sm transition-all duration-300 z-40 flex flex-col"
    :class="isOpen ? 'w-64' : 'w-16'"
  >
    <!-- Logo -->
    <div class="h-16 flex items-center px-4 border-b border-gray-100 flex-shrink-0">
      <NuxtLink to="/home" class="flex items-center gap-3 overflow-hidden">
        <div class="w-8 h-8 bg-primary-600 rounded-lg flex items-center justify-center flex-shrink-0">
          <Icon name="heroicons:heart" class="w-5 h-5 text-white" />
        </div>
        <span v-if="isOpen" class="text-lg font-bold text-gray-900 whitespace-nowrap">Hobby Hub</span>
      </NuxtLink>
    </div>

    <!-- Role badge -->
    <div v-if="isOpen && auth.profile" class="px-4 py-3 border-b border-gray-100">
      <span class="badge" :class="{
        'badge-admin': auth.isAdmin,
        'badge-business': auth.isBusinessOwner,
        'bg-green-100 text-green-800': auth.isCommunityAdmin,
        'bg-gray-100 text-gray-800': auth.isUser,
      }">
        {{ auth.profile.role }}
      </span>
    </div>

    <!-- Nav links -->
    <nav class="flex-1 py-4 overflow-y-auto">
      <NuxtLink
        v-for="link in navLinks"
        :key="link.to"
        :to="link.to"
        class="flex items-center gap-3 px-4 py-2.5 text-gray-600 hover:bg-primary-50 hover:text-primary-700 transition-colors mx-2 rounded-lg"
        active-class="bg-primary-50 text-primary-700 font-medium"
      >
        <Icon :name="link.icon" class="w-5 h-5 flex-shrink-0" />
        <span v-if="isOpen" class="whitespace-nowrap">{{ link.label }}</span>
      </NuxtLink>
    </nav>

    <!-- Sign out -->
    <div class="border-t border-gray-100 p-4">
      <button
        @click="auth.signOut"
        class="flex items-center gap-3 w-full text-gray-500 hover:text-red-600 transition-colors"
      >
        <Icon name="heroicons:arrow-right-on-rectangle" class="w-5 h-5 flex-shrink-0" />
        <span v-if="isOpen" class="text-sm">Sign Out</span>
      </button>
    </div>
  </aside>
</template>
