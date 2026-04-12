<script setup lang="ts">
definePageMeta({ middleware: 'auth' })

const auth = useAuthStore()
const supabase = useSupabaseClient()
const user = useSupabaseUser()

if (!auth.isCommunityAdmin && !auth.isAdmin) navigateTo('/home')

const form = reactive({ name: '', description: '' })
const imageFile = ref<File | null>(null)
const imagePreview = ref<string | null>(null)
const loading = ref(false)
const error = ref('')

function handleImageChange(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  imageFile.value = file
  imagePreview.value = URL.createObjectURL(file)
}

async function handleSubmit() {
  if (!form.name.trim() || !form.description.trim()) {
    error.value = 'Name and description are required.'
    return
  }
  loading.value = true
  error.value = ''

  let imageUrl: string | null = null
  if (imageFile.value) {
    const ext = imageFile.value.name.split('.').pop()
    const path = `${user.value!.id}/${Date.now()}.${ext}`
    const { error: uploadErr } = await supabase.storage.from('community-images').upload(path, imageFile.value)
    if (uploadErr) {
      error.value = 'Image upload failed.'
      loading.value = false
      return
    }
    const { data: { publicUrl } } = supabase.storage.from('community-images').getPublicUrl(path)
    imageUrl = publicUrl
  }

  const { error: err } = await supabase.from('communities').insert({
    name: form.name.trim(),
    description: form.description.trim(),
    image_url: imageUrl,
    created_by: user.value!.id,
  })

  loading.value = false
  if (err) {
    error.value = err.message
  } else {
    await navigateTo('/community/admin')
  }
}
</script>

<template>
  <div class="max-w-2xl">
    <div class="flex items-center gap-3 mb-6">
      <NuxtLink to="/community/admin" class="text-gray-400 hover:text-gray-600">
        <Icon name="heroicons:arrow-left" class="w-5 h-5" />
      </NuxtLink>
      <h1 class="text-2xl font-bold text-gray-900">Create Community</h1>
    </div>

    <div class="card">
      <div v-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm mb-4">
        {{ error }}
      </div>

      <form @submit.prevent="handleSubmit" class="space-y-5">
        <!-- Image upload -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Community Banner</label>
          <div
            class="border-2 border-dashed border-gray-300 rounded-xl h-48 flex items-center justify-center overflow-hidden cursor-pointer hover:border-primary-400 transition-colors"
            @click="($refs.imageInput as HTMLInputElement).click()"
          >
            <img v-if="imagePreview" :src="imagePreview" alt="Preview" class="w-full h-full object-cover" />
            <div v-else class="text-center text-gray-400">
              <Icon name="heroicons:photo" class="w-10 h-10 mx-auto mb-2" />
              <p class="text-sm">Click to upload image</p>
            </div>
          </div>
          <input ref="imageInput" type="file" accept="image/*" class="hidden" @change="handleImageChange" />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Community Name *</label>
          <input v-model="form.name" type="text" required placeholder="e.g. Mountain Hikers" class="input-field" />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Description *</label>
          <textarea v-model="form.description" required rows="4" placeholder="Describe your community..." class="input-field resize-none"></textarea>
        </div>

        <div class="flex gap-3">
          <NuxtLink to="/community/admin" class="btn-secondary">Cancel</NuxtLink>
          <button type="submit" :disabled="loading" class="btn-primary">
            <span v-if="loading" class="flex items-center gap-2">
              <Icon name="heroicons:arrow-path" class="w-4 h-4 animate-spin" />
              Creating...
            </span>
            <span v-else>Create Community</span>
          </button>
        </div>
      </form>
    </div>
  </div>
</template>
