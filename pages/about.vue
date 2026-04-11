<script setup lang="ts">
definePageMeta({ layout: 'public' })
</script>

<template>
  <div>
    <!-- Hero -->
    <section class="bg-gradient-to-br from-primary-600 to-primary-800 text-white py-20 px-4 text-center">
      <h1 class="text-4xl font-bold mb-4">About Hobby Hub</h1>
      <p class="text-primary-100 text-xl max-w-2xl mx-auto">Connecting passionate individuals through shared interests since 2024.</p>
    </section>

    <!-- Mission -->
    <section class="py-20 px-4 bg-white">
      <div class="max-w-4xl mx-auto">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-12 items-center">
          <div>
            <h2 class="text-3xl font-bold text-gray-900 mb-6">Our Mission</h2>
            <p class="text-gray-500 leading-relaxed mb-4">
              Hobby Hub was born from a simple idea: everyone deserves to find their community. Whether you're passionate about hiking, coding, cooking, or crafting — there's a place for you here.
            </p>
            <p class="text-gray-500 leading-relaxed">
              We built this platform as a capstone project to demonstrate how technology can bring people together and transform personal interests into shared experiences.
            </p>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div class="card text-center">
              <p class="text-3xl font-bold text-primary-600 mb-1">500+</p>
              <p class="text-sm text-gray-500">Communities</p>
            </div>
            <div class="card text-center">
              <p class="text-3xl font-bold text-primary-600 mb-1">10k+</p>
              <p class="text-sm text-gray-500">Members</p>
            </div>
            <div class="card text-center">
              <p class="text-3xl font-bold text-primary-600 mb-1">1k+</p>
              <p class="text-sm text-gray-500">Events Hosted</p>
            </div>
            <div class="card text-center">
              <p class="text-3xl font-bold text-primary-600 mb-1">50+</p>
              <p class="text-sm text-gray-500">Hobby Categories</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- How it works -->
    <section class="py-20 px-4 bg-gray-50">
      <div class="max-w-4xl mx-auto">
        <h2 class="text-3xl font-bold text-center text-gray-900 mb-12">How It Works</h2>
        <div class="space-y-8">
          <div class="flex gap-6">
            <div class="flex-shrink-0 w-10 h-10 bg-primary-600 rounded-full text-white flex items-center justify-center font-bold">1</div>
            <div>
              <h3 class="font-semibold text-gray-900 text-lg mb-1">Create Your Account</h3>
              <p class="text-gray-500">Sign up as a Hobbyist, Community Admin, or Business Owner depending on how you want to participate.</p>
            </div>
          </div>
          <div class="flex gap-6">
            <div class="flex-shrink-0 w-10 h-10 bg-primary-600 rounded-full text-white flex items-center justify-center font-bold">2</div>
            <div>
              <h3 class="font-semibold text-gray-900 text-lg mb-1">Find Your Community</h3>
              <p class="text-gray-500">Browse communities by interest, apply to join, and get approved by community administrators.</p>
            </div>
          </div>
          <div class="flex gap-6">
            <div class="flex-shrink-0 w-10 h-10 bg-primary-600 rounded-full text-white flex items-center justify-center font-bold">3</div>
            <div>
              <h3 class="font-semibold text-gray-900 text-lg mb-1">Connect & Engage</h3>
              <p class="text-gray-500">Chat with members in real-time, sign up for events, and build lasting connections with fellow enthusiasts.</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA -->
    <section class="py-16 px-4 bg-white text-center">
      <h2 class="text-2xl font-bold text-gray-900 mb-4">Ready to get started?</h2>
      <div class="flex gap-4 justify-center">
        <NuxtLink to="/register" class="btn-primary">Create Account</NuxtLink>
        <NuxtLink to="/contact" class="btn-secondary">Contact Us</NuxtLink>
      </div>
    </section>
  </div>
</template>
