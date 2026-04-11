<script setup lang="ts">
definePageMeta({ middleware: 'auth' })

const auth = useAuthStore()
const supabase = useSupabaseClient()
const user = useSupabaseUser()

const form = reactive({ name: '' })
const imageFile = ref<File | null>(null)
const imagePreview = ref<string | null>(null)
const saving = ref(false)
const uploadingImage = ref(false)
const success = ref('')
const error = ref('')

watch(() => auth.profile, (p) => {
  if (p) form.name = p.name
}, { immediate: true })

function handleImageChange(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  imageFile.value = file
  imagePreview.value = URL.createObjectURL(file)
}

async function uploadProfileImage() {
  if (!imageFile.value) return
  uploadingImage.value = true
  error.value = ''

  const ext = imageFile.value.name.split('.').pop()
  const path = `${user.value!.id}/avatar.${ext}`

  const { error: uploadErr } = await supabase.storage
    .from('profile-images')
    .upload(path, imageFile.value, { upsert: true })

  if (uploadErr) {
    error.value = 'Image upload failed.'
    uploadingImage.value = false
    return
  }

  const { data: { publicUrl } } = supabase.storage.from('profile-images').getPublicUrl(path)
  const result = await auth.updateProfile({ profile_image_url: publicUrl })
  if (result?.error) error.value = result.error.message
  else success.value = 'Profile image updated!'

  imageFile.value = null
  imagePreview.value = null
  uploadingImage.value = false
}

async function saveProfile() {
  if (!form.name.trim()) return
  saving.value = true
  error.value = ''
  const result = await auth.updateProfile({ name: form.name.trim() })
  saving.value = false
  if (result?.error) error.value = result.error.message
  else success.value = 'Profile updated successfully!'
  setTimeout(() => { success.value = '' }, 3000)
}

async function deleteAccount() {
  if (!confirm('Are you sure you want to delete your account? This action cannot be undone.')) return
  await supabase.from('profiles').delete().eq('id', user.value!.id)
  await auth.signOut()
}
</script>

<template>
  <div class="max-w-2xl">
    <h1 class="text-2xl font-bold text-gray-900 mb-6">Profile Settings</h1>

    <!-- Alerts -->
    <div v-if="success" class="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg text-sm mb-4">
      {{ success }}
    </div>
    <div v-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm mb-4">
      {{ error }}
    </div>

    <!-- Profile Image -->
    <div class="card mb-6">
      <h2 class="font-semibold text-gray-900 mb-4">Profile Photo</h2>
      <div class="flex items-center gap-6">
        <div class="w-20 h-20 rounded-full bg-primary-100 overflow-hidden flex-shrink-0 flex items-center justify-center">
          <img
            v-if="imagePreview || auth.profile?.profile_image_url"
            :src="imagePreview || auth.profile?.profile_image_url || ''"
            alt="Profile"
            class="w-full h-full object-cover"
          />
          <Icon v-else name="heroicons:user" class="w-10 h-10 text-primary-400" />
        </div>
        <div>
          <input type="file" accept="image/jpeg,image/jpg,image/png,image/gif" @change="handleImageChange" class="text-sm text-gray-500 file:mr-3 file:btn-secondary file:text-xs mb-2 block" />
          <p class="text-xs text-gray-400">JPEG, PNG or GIF. Max 5MB.</p>
          <button v-if="imageFile" @click="uploadProfileImage" :disabled="uploadingImage" class="btn-primary text-sm mt-2">
            <span v-if="uploadingImage" class="flex items-center gap-2">
              <Icon name="heroicons:arrow-path" class="w-4 h-4 animate-spin" />
              Uploading...
            </span>
            <span v-else>Upload Photo</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Account Details -->
    <div class="card mb-6">
      <h2 class="font-semibold text-gray-900 mb-4">Account Details</h2>
      <form @submit.prevent="saveProfile" class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Full Name</label>
          <input v-model="form.name" type="text" required class="input-field" />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
          <input :value="auth.profile?.email" type="email" disabled class="input-field bg-gray-50 text-gray-400 cursor-not-allowed" />
          <p class="text-xs text-gray-400 mt-1">Email cannot be changed here.</p>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Role</label>
          <div>
            <span class="badge" :class="{
              'badge-admin': auth.isAdmin,
              'badge-business': auth.isBusinessOwner,
              'bg-green-100 text-green-800': auth.isCommunityAdmin,
              'bg-gray-100 text-gray-800': auth.isUser,
            }">{{ auth.profile?.role }}</span>
          </div>
        </div>
        <button type="submit" :disabled="saving" class="btn-primary">
          <span v-if="saving" class="flex items-center gap-2">
            <Icon name="heroicons:arrow-path" class="w-4 h-4 animate-spin" />
            Saving...
          </span>
          <span v-else>Save Changes</span>
        </button>
      </form>
    </div>

    <!-- Danger Zone -->
    <div class="card border-red-200">
      <h2 class="font-semibold text-red-600 mb-2">Danger Zone</h2>
      <p class="text-sm text-gray-500 mb-4">Once you delete your account, there is no going back. Please be certain.</p>
      <button @click="deleteAccount" class="btn-danger text-sm">Delete Account</button>
    </div>
  </div>
</template>
