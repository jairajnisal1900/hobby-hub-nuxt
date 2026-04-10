<script setup lang="ts">
definePageMeta({ layout: 'public' })
</script>

<template>
  <div>
    <!-- Hero -->
    <section class="bg-gradient-to-br from-primary-600 to-primary-800 text-white py-24 px-4">
      <div class="max-w-4xl mx-auto text-center">
        <h1 class="text-5xl font-bold mb-6 leading-tight">Find Your Tribe.<br />Pursue Your Passion.</h1>
        <p class="text-xl text-primary-100 mb-10 max-w-2xl mx-auto">
          Hobby Hub connects enthusiasts from all walks of life. Join communities, attend events, and share what you love with people who care.
        </p>
        <div class="flex flex-col sm:flex-row gap-4 justify-center">
          <NuxtLink to="/register" class="bg-white text-primary-700 font-semibold px-8 py-3 rounded-lg hover:bg-primary-50 transition-colors text-lg">
            Get Started Free
          </NuxtLink>
          <NuxtLink to="/login" class="border-2 border-white text-white font-semibold px-8 py-3 rounded-lg hover:bg-white/10 transition-colors text-lg">
            Sign In
          </NuxtLink>
        </div>
      </div>
    </section>

    <!-- Features -->
    <section class="py-20 px-4 bg-white">
      <div class="max-w-6xl mx-auto">
        <h2 class="text-3xl font-bold text-center text-gray-900 mb-4">Everything You Need</h2>
        <p class="text-center text-gray-500 mb-12">A complete platform for hobby communities</p>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div class="text-center p-6">
            <div class="w-14 h-14 bg-primary-100 rounded-2xl flex items-center justify-center mx-auto mb-4">
              <Icon name="heroicons:user-group" class="w-7 h-7 text-primary-600" />
            </div>
            <h3 class="font-semibold text-lg text-gray-900 mb-2">Join Communities</h3>
            <p class="text-gray-500 text-sm">Browse communities that match your interests and apply to join. Connect with like-minded people.</p>
          </div>
          <div class="text-center p-6">
            <div class="w-14 h-14 bg-accent/20 rounded-2xl flex items-center justify-center mx-auto mb-4">
              <Icon name="heroicons:calendar" class="w-7 h-7 text-accent-dark" />
            </div>
            <h3 class="font-semibold text-lg text-gray-900 mb-2">Attend Events</h3>
            <p class="text-gray-500 text-sm">Discover and sign up for local events organized by business owners and community leaders.</p>
          </div>
          <div class="text-center p-6">
            <div class="w-14 h-14 bg-green-100 rounded-2xl flex items-center justify-center mx-auto mb-4">
              <Icon name="heroicons:chat-bubble-left-right" class="w-7 h-7 text-green-600" />
            </div>
            <h3 class="font-semibold text-lg text-gray-900 mb-2">Real-Time Chat</h3>
            <p class="text-gray-500 text-sm">Communicate with your community members through live chat. Stay connected and engaged.</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Roles section -->
    <section class="py-20 px-4 bg-gray-50">
      <div class="max-w-6xl mx-auto">
        <h2 class="text-3xl font-bold text-center text-gray-900 mb-12">Choose Your Role</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div class="card hover:shadow-md transition-shadow">
            <div class="w-10 h-10 bg-gray-100 rounded-xl flex items-center justify-center mb-4">
              <Icon name="heroicons:user" class="w-5 h-5 text-gray-600" />
            </div>
            <h3 class="font-semibold text-gray-900 mb-2">Hobbyist</h3>
            <p class="text-sm text-gray-500">Join communities, attend events, chat with members, and explore your interests.</p>
          </div>
          <div class="card hover:shadow-md transition-shadow">
            <div class="w-10 h-10 bg-primary-100 rounded-xl flex items-center justify-center mb-4">
              <Icon name="heroicons:shield-check" class="w-5 h-5 text-primary-600" />
            </div>
            <h3 class="font-semibold text-gray-900 mb-2">Community Admin</h3>
            <p class="text-sm text-gray-500">Create and manage communities, approve members, and moderate discussions.</p>
          </div>
          <div class="card hover:shadow-md transition-shadow">
            <div class="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center mb-4">
              <Icon name="heroicons:building-storefront" class="w-5 h-5 text-blue-600" />
            </div>
            <h3 class="font-semibold text-gray-900 mb-2">Business Owner</h3>
            <p class="text-sm text-gray-500">Create and manage events, grow your audience, and connect with hobbyists.</p>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA -->
    <section class="py-20 px-4 bg-primary-600 text-white text-center">
      <div class="max-w-2xl mx-auto">
        <h2 class="text-3xl font-bold mb-4">Ready to Join?</h2>
        <p class="text-primary-100 mb-8">Create your free account today and become part of the Hobby Hub community.</p>
        <NuxtLink to="/register" class="bg-white text-primary-700 font-semibold px-8 py-3 rounded-lg hover:bg-primary-50 transition-colors text-lg inline-block">
          Sign Up Now
        </NuxtLink>
      </div>
    </section>
  </div>
</template>
