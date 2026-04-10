<script setup lang="ts">
definePageMeta({ layout: 'public' })

const auth = useAuthStore()

onMounted(async () => {
  await auth.fetchProfile()
  const role = auth.role
  if (role === 'Admin') await navigateTo('/admin/dashboard')
  else if (role === 'CommunityAdmin') await navigateTo('/community/admin')
  else if (role === 'BusinessOwner') await navigateTo('/events')
  else await navigateTo('/home')
})
</script>

<template>
  <div class="min-h-screen flex items-center justify-center">
    <div class="text-center">
      <Icon name="heroicons:arrow-path" class="w-10 h-10 text-primary-600 animate-spin mx-auto mb-4" />
      <p class="text-gray-600">Setting up your account...</p>
    </div>
  </div>
</template>
