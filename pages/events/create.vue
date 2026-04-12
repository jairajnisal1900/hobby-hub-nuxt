<script setup lang="ts">
definePageMeta({ middleware: 'auth' })

const auth = useAuthStore()
const supabase = useSupabaseClient()
const user = useSupabaseUser()

if (!auth.isBusinessOwner && !auth.isAdmin) navigateTo('/home')

const form = reactive({
  resource: '',
  location: '',
  address: '',
  start_time: '',
  end_time: '',
  status: 'Pending' as 'Pending' | 'CheckedIn',
})
const loading = ref(false)
const error = ref('')

async function handleSubmit() {
  if (!form.resource || !form.location || !form.address || !form.start_time || !form.end_time) {
    error.value = 'All fields are required.'
    return
  }
  if (new Date(form.end_time) <= new Date(form.start_time)) {
    error.value = 'End time must be after start time.'
    return
  }

  loading.value = true
  error.value = ''

  const { error: err } = await supabase.from('events').insert({
    ...form,
    created_by: user.value!.id,
  })

  loading.value = false
  if (err) {
    error.value = err.message
  } else {
    await navigateTo('/events')
  }
}
</script>

<template>
  <div class="max-w-2xl">
    <div class="flex items-center gap-3 mb-6">
      <NuxtLink to="/events" class="text-gray-400 hover:text-gray-600">
        <Icon name="heroicons:arrow-left" class="w-5 h-5" />
      </NuxtLink>
      <h1 class="text-2xl font-bold text-gray-900">Create Event</h1>
    </div>

    <div class="card">
      <div v-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm mb-4">
        {{ error }}
      </div>

      <form @submit.prevent="handleSubmit" class="space-y-5">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Event Title / Resource *</label>
          <input v-model="form.resource" type="text" placeholder="e.g. Weekend Photography Walk" class="input-field" />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Location *</label>
          <input v-model="form.location" type="text" placeholder="e.g. Central Park" class="input-field" />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Full Address *</label>
          <input v-model="form.address" type="text" placeholder="e.g. Central Park, New York, NY 10024" class="input-field" />
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Start Date & Time *</label>
            <input v-model="form.start_time" type="datetime-local" class="input-field" />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">End Date & Time *</label>
            <input v-model="form.end_time" type="datetime-local" class="input-field" />
          </div>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
          <select v-model="form.status" class="input-field">
            <option value="Pending">Pending</option>
            <option value="CheckedIn">Checked In</option>
          </select>
        </div>

        <div class="flex gap-3">
          <NuxtLink to="/events" class="btn-secondary">Cancel</NuxtLink>
          <button type="submit" :disabled="loading" class="btn-primary">
            <span v-if="loading" class="flex items-center gap-2">
              <Icon name="heroicons:arrow-path" class="w-4 h-4 animate-spin" />
              Creating...
            </span>
            <span v-else>Create Event</span>
          </button>
        </div>
      </form>
    </div>
  </div>
</template>
