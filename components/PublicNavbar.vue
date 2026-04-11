<script setup lang="ts">
const isMenuOpen = ref(false)
</script>

<template>
  <nav class="bg-white shadow-sm border-b border-gray-100">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex justify-between h-16">
        <!-- Logo -->
        <div class="flex items-center">
          <NuxtLink to="/" class="flex items-center gap-2">
            <div class="w-8 h-8 bg-primary-600 rounded-lg flex items-center justify-center">
              <Icon name="heroicons:heart" class="w-5 h-5 text-white" />
            </div>
            <span class="text-xl font-bold text-gray-900">Hobby Hub</span>
          </NuxtLink>
        </div>

        <!-- Desktop nav -->
        <div class="hidden md:flex items-center gap-6">
          <NuxtLink to="/" class="text-gray-600 hover:text-primary-600 font-medium transition-colors">Home</NuxtLink>
          <NuxtLink to="/about" class="text-gray-600 hover:text-primary-600 font-medium transition-colors">About</NuxtLink>
          <NuxtLink to="/contact" class="text-gray-600 hover:text-primary-600 font-medium transition-colors">Contact</NuxtLink>
          <NuxtLink to="/login" class="btn-secondary text-sm">Login</NuxtLink>
          <NuxtLink to="/register" class="btn-primary text-sm">Get Started</NuxtLink>
        </div>

        <!-- Mobile menu button -->
        <div class="md:hidden flex items-center">
          <button @click="isMenuOpen = !isMenuOpen" class="text-gray-600 hover:text-gray-900">
            <Icon :name="isMenuOpen ? 'heroicons:x-mark' : 'heroicons:bars-3'" class="w-6 h-6" />
          </button>
        </div>
      </div>
    </div>

    <!-- Mobile menu -->
    <div v-if="isMenuOpen" class="md:hidden border-t border-gray-100">
      <div class="px-4 py-3 space-y-2">
        <NuxtLink to="/" class="block text-gray-600 hover:text-primary-600 py-2 font-medium">Home</NuxtLink>
        <NuxtLink to="/about" class="block text-gray-600 hover:text-primary-600 py-2 font-medium">About</NuxtLink>
        <NuxtLink to="/contact" class="block text-gray-600 hover:text-primary-600 py-2 font-medium">Contact</NuxtLink>
        <NuxtLink to="/login" class="block btn-secondary text-sm text-center mt-2">Login</NuxtLink>
        <NuxtLink to="/register" class="block btn-primary text-sm text-center mt-2">Get Started</NuxtLink>
      </div>
    </div>
  </nav>
</template>
