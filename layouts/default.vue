<script setup lang="ts">
const auth = useAuthStore()
const isSidebarOpen = ref(true)
</script>

<template>
  <div class="flex h-screen bg-gray-50 overflow-hidden">
    <!-- Sidebar -->
    <AppSidebar :is-open="isSidebarOpen" @toggle="isSidebarOpen = !isSidebarOpen" />

    <!-- Main content -->
    <div class="flex-1 flex flex-col overflow-hidden" :class="isSidebarOpen ? 'ml-64' : 'ml-16'">
      <AppNavbar @toggle-sidebar="isSidebarOpen = !isSidebarOpen" />
      <main class="flex-1 overflow-y-auto p-6">
        <slot />
      </main>
    </div>
  </div>
</template>
