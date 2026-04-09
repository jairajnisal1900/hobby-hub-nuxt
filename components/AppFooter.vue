<template>
  <footer class="bg-gray-900 text-gray-300">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
        <!-- Brand -->
        <div>
          <div class="flex items-center gap-2 mb-4">
            <div class="w-8 h-8 bg-primary-600 rounded-lg flex items-center justify-center">
              <Icon name="heroicons:heart" class="w-5 h-5 text-white" />
            </div>
            <span class="text-white font-bold text-xl">Hobby Hub</span>
          </div>
          <p class="text-sm leading-relaxed">Connecting hobby enthusiasts worldwide. Find your community, discover events, and share your passion.</p>
        </div>

        <!-- Links -->
        <div>
          <h3 class="text-white font-semibold mb-4">Quick Links</h3>
          <ul class="space-y-2 text-sm">
            <li><NuxtLink to="/" class="hover:text-white transition-colors">Home</NuxtLink></li>
            <li><NuxtLink to="/about" class="hover:text-white transition-colors">About</NuxtLink></li>
            <li><NuxtLink to="/contact" class="hover:text-white transition-colors">Contact</NuxtLink></li>
            <li><NuxtLink to="/register" class="hover:text-white transition-colors">Join Now</NuxtLink></li>
          </ul>
        </div>

        <!-- Contact -->
        <div>
          <h3 class="text-white font-semibold mb-4">Connect</h3>
          <p class="text-sm">Have questions? We'd love to hear from you.</p>
          <NuxtLink to="/contact" class="inline-block mt-3 btn-primary text-sm">Get in Touch</NuxtLink>
        </div>
      </div>

      <div class="border-t border-gray-800 mt-10 pt-6 text-sm text-center">
        <p>&copy; {{ new Date().getFullYear() }} Hobby Hub. All rights reserved.</p>
      </div>
    </div>
  </footer>
</template>
