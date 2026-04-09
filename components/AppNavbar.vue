<script setup lang="ts">
const emit = defineEmits<{ toggleSidebar: [] }>()
const auth = useAuthStore()

const profileMenuOpen = ref(false)
const profileMenuRef = ref<HTMLElement | null>(null)

onClickOutside(profileMenuRef, () => { profileMenuOpen.value = false })
</script>

<template>
  <header class="h-16 bg-white border-b border-gray-100 flex items-center justify-between px-6 flex-shrink-0">
    <!-- Toggle sidebar -->
    <button @click="emit('toggleSidebar')" class="text-gray-500 hover:text-gray-700">
      <Icon name="heroicons:bars-3" class="w-6 h-6" />
    </button>

    <!-- Right side -->
    <div class="flex items-center gap-4">
      <!-- Profile menu -->
      <div class="relative" ref="profileMenuRef">
        <button @click="profileMenuOpen = !profileMenuOpen" class="flex items-center gap-2 hover:bg-gray-50 rounded-lg px-2 py-1.5 transition-colors">
          <div class="w-8 h-8 rounded-full bg-primary-100 flex items-center justify-center overflow-hidden">
            <img v-if="auth.profile?.profile_image_url" :src="auth.profile.profile_image_url" alt="Profile" class="w-full h-full object-cover" />
            <Icon v-else name="heroicons:user" class="w-5 h-5 text-primary-600" />
          </div>
          <div class="hidden md:block text-left">
            <p class="text-sm font-medium text-gray-900">{{ auth.profile?.name }}</p>
            <p class="text-xs text-gray-500">{{ auth.profile?.role }}</p>
          </div>
          <Icon name="heroicons:chevron-down" class="w-4 h-4 text-gray-400" />
        </button>

        <Transition enter-active-class="transition ease-out duration-100" enter-from-class="opacity-0 scale-95" enter-to-class="opacity-100 scale-100" leave-active-class="transition ease-in duration-75" leave-from-class="opacity-100 scale-100" leave-to-class="opacity-0 scale-95">
          <div v-if="profileMenuOpen" class="absolute right-0 mt-2 w-48 bg-white rounded-xl shadow-lg border border-gray-100 py-1 z-50">
            <NuxtLink to="/profile/settings" class="flex items-center gap-2 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50">
              <Icon name="heroicons:user-circle" class="w-4 h-4" />
              Profile Settings
            </NuxtLink>
            <hr class="my-1 border-gray-100" />
            <button @click="auth.signOut" class="w-full flex items-center gap-2 px-4 py-2 text-sm text-red-600 hover:bg-red-50">
              <Icon name="heroicons:arrow-right-on-rectangle" class="w-4 h-4" />
              Sign Out
            </button>
          </div>
        </Transition>
      </div>
    </div>
  </header>
</template>
