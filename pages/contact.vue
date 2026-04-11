<script setup lang="ts">
definePageMeta({ layout: 'public' })

const supabase = useSupabaseClient()

const form = reactive({ name: '', email: '', message: '' })
const loading = ref(false)
const success = ref(false)
const error = ref('')

async function handleSubmit() {
  loading.value = true
  error.value = ''
  const { error: err } = await supabase.from('contacts').insert(form)
  loading.value = false
  if (err) {
    error.value = 'Failed to send message. Please try again.'
  } else {
    success.value = true
    Object.assign(form, { name: '', email: '', message: '' })
  }
}
</script>

<template>
  <div>
    <!-- Hero -->
    <section class="bg-gradient-to-br from-primary-600 to-primary-800 text-white py-16 px-4 text-center">
      <h1 class="text-4xl font-bold mb-4">Contact Us</h1>
      <p class="text-primary-100 text-xl">We'd love to hear from you</p>
    </section>

    <section class="py-16 px-4">
      <div class="max-w-2xl mx-auto">
        <div v-if="success" class="card text-center mb-8">
          <div class="w-14 h-14 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <Icon name="heroicons:check" class="w-7 h-7 text-green-600" />
          </div>
          <h2 class="text-xl font-semibold text-gray-900 mb-2">Message Sent!</h2>
          <p class="text-gray-500">We'll get back to you as soon as possible.</p>
          <button @click="success = false" class="btn-primary mt-4">Send Another Message</button>
        </div>

        <div v-else class="card">
          <h2 class="text-xl font-semibold text-gray-900 mb-6">Send us a message</h2>

          <div v-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm mb-4">
            {{ error }}
          </div>

          <form @submit.prevent="handleSubmit" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Name</label>
              <input v-model="form.name" type="text" required placeholder="Your name" class="input-field" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
              <input v-model="form.email" type="email" required placeholder="you@example.com" class="input-field" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Message</label>
              <textarea v-model="form.message" required rows="5" placeholder="Your message..." class="input-field resize-none"></textarea>
            </div>
            <button type="submit" :disabled="loading" class="btn-primary w-full">
              <span v-if="loading" class="flex items-center justify-center gap-2">
                <Icon name="heroicons:arrow-path" class="w-4 h-4 animate-spin" />
                Sending...
              </span>
              <span v-else>Send Message</span>
            </button>
          </form>
        </div>

        <!-- Contact info -->
        <div class="mt-8 grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div class="text-center p-4">
            <Icon name="heroicons:envelope" class="w-6 h-6 text-primary-600 mx-auto mb-2" />
            <p class="text-sm text-gray-500">support@hobbyhub.com</p>
          </div>
          <div class="text-center p-4">
            <Icon name="heroicons:map-pin" class="w-6 h-6 text-primary-600 mx-auto mb-2" />
            <p class="text-sm text-gray-500">Boston, MA</p>
          </div>
          <div class="text-center p-4">
            <Icon name="heroicons:clock" class="w-6 h-6 text-primary-600 mx-auto mb-2" />
            <p class="text-sm text-gray-500">Mon–Fri, 9am–5pm</p>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>
