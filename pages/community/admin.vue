<script setup lang="ts">
import type { Community, CommunityMember } from '~/types'

definePageMeta({ middleware: 'auth' })

const auth = useAuthStore()
const supabase = useSupabaseClient()
const user = useSupabaseUser()

if (!auth.isCommunityAdmin && !auth.isAdmin) navigateTo('/home')

const communities = ref<Community[]>([])
const selectedCommunity = ref<Community | null>(null)
const members = ref<CommunityMember[]>([])
const loading = ref(true)
const imageFile = ref<File | null>(null)
const imagePreview = ref<string | null>(null)
const uploadingImage = ref(false)

const pendingMembers = computed(() => members.value.filter(m => m.status === 'pending'))
const approvedMembers = computed(() => members.value.filter(m => m.status === 'approved'))

async function fetchCommunities() {
  loading.value = true
  const { data } = await supabase
    .from('communities')
    .select('*')
    .eq('created_by', user.value!.id)
    .order('created_at', { ascending: false })
  communities.value = data ?? []
  if (data?.[0]) await selectCommunity(data[0])
  loading.value = false
}

async function selectCommunity(community: Community) {
  selectedCommunity.value = community
  const { data } = await supabase
    .from('community_members')
    .select('*, profile:user_id(name, email, profile_image_url)')
    .eq('community_id', community.id)
  members.value = data ?? []
}

async function updateMemberStatus(memberId: string, status: 'approved' | 'pending') {
  await supabase.from('community_members').update({ status }).eq('id', memberId)
  const m = members.value.find(m => m.id === memberId)
  if (m) m.status = status
}

async function removeMember(memberId: string) {
  await supabase.from('community_members').delete().eq('id', memberId)
  members.value = members.value.filter(m => m.id !== memberId)
}

async function deleteCommunity(communityId: string) {
  if (!confirm('Are you sure? This will delete the community and all its data.')) return
  await supabase.from('communities').delete().eq('id', communityId)
  communities.value = communities.value.filter(c => c.id !== communityId)
  if (selectedCommunity.value?.id === communityId) {
    selectedCommunity.value = communities.value[0] ?? null
    if (selectedCommunity.value) await selectCommunity(selectedCommunity.value)
    else members.value = []
  }
}

function handleImageChange(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  imageFile.value = file
  imagePreview.value = URL.createObjectURL(file)
}

async function uploadCommunityImage() {
  if (!imageFile.value || !selectedCommunity.value) return
  uploadingImage.value = true
  const ext = imageFile.value.name.split('.').pop()
  const path = `${selectedCommunity.value.id}/${Date.now()}.${ext}`
  const { error: uploadErr } = await supabase.storage.from('community-images').upload(path, imageFile.value, { upsert: true })
  if (!uploadErr) {
    const { data: { publicUrl } } = supabase.storage.from('community-images').getPublicUrl(path)
    await supabase.from('communities').update({ image_url: publicUrl }).eq('id', selectedCommunity.value.id)
    selectedCommunity.value.image_url = publicUrl
    imageFile.value = null
    imagePreview.value = null
  }
  uploadingImage.value = false
}

onMounted(fetchCommunities)
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold text-gray-900">Community Manager</h1>
      <NuxtLink to="/community/create" class="btn-primary flex items-center gap-2">
        <Icon name="heroicons:plus" class="w-4 h-4" />
        New Community
      </NuxtLink>
    </div>

    <div v-if="loading" class="flex justify-center py-16">
      <Icon name="heroicons:arrow-path" class="w-8 h-8 text-primary-600 animate-spin" />
    </div>

    <div v-else-if="communities.length === 0" class="card text-center py-16 text-gray-400">
      <Icon name="heroicons:user-group" class="w-12 h-12 mx-auto mb-3 opacity-50" />
      <p class="mb-4">You haven't created any communities yet.</p>
      <NuxtLink to="/community/create" class="btn-primary">Create Your First Community</NuxtLink>
    </div>

    <div v-else class="grid grid-cols-1 lg:grid-cols-4 gap-6">
      <!-- Community list -->
      <div class="card">
        <h2 class="font-semibold text-gray-900 mb-3 text-sm uppercase tracking-wide">My Communities</h2>
        <div class="space-y-1">
          <button
            v-for="c in communities"
            :key="c.id"
            @click="selectCommunity(c)"
            class="w-full text-left px-3 py-2.5 rounded-lg text-sm transition-colors"
            :class="selectedCommunity?.id === c.id ? 'bg-primary-50 text-primary-700 font-medium' : 'text-gray-600 hover:bg-gray-50'"
          >
            {{ c.name }}
          </button>
        </div>
      </div>

      <!-- Community detail -->
      <div class="lg:col-span-3 space-y-6" v-if="selectedCommunity">
        <!-- Community info -->
        <div class="card">
          <div class="flex items-start justify-between mb-4">
            <div>
              <h2 class="text-xl font-bold text-gray-900">{{ selectedCommunity.name }}</h2>
              <p class="text-gray-500 text-sm mt-1">{{ selectedCommunity.description }}</p>
            </div>
            <button @click="deleteCommunity(selectedCommunity.id)" class="text-red-400 hover:text-red-600 transition-colors">
              <Icon name="heroicons:trash" class="w-5 h-5" />
            </button>
          </div>

          <!-- Image upload -->
          <div class="border-t border-gray-100 pt-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Update Banner Image</label>
            <div class="flex gap-3 items-center">
              <div class="w-24 h-16 rounded-lg overflow-hidden bg-gray-100 flex-shrink-0">
                <img :src="imagePreview || selectedCommunity.image_url || ''" alt="" class="w-full h-full object-cover" />
              </div>
              <div>
                <input type="file" accept="image/*" @change="handleImageChange" class="text-sm text-gray-500 file:mr-3 file:btn-secondary file:text-xs" />
                <button v-if="imageFile" @click="uploadCommunityImage" :disabled="uploadingImage" class="btn-primary text-sm mt-2">
                  {{ uploadingImage ? 'Uploading...' : 'Upload Image' }}
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Pending requests -->
        <div class="card">
          <h3 class="font-semibold text-gray-900 mb-4">
            Pending Requests
            <span v-if="pendingMembers.length" class="ml-2 badge badge-pending">{{ pendingMembers.length }}</span>
          </h3>
          <div v-if="pendingMembers.length === 0" class="text-sm text-gray-400">No pending requests.</div>
          <div v-else class="space-y-3">
            <div v-for="m in pendingMembers" :key="m.id" class="flex items-center justify-between py-2 border-b border-gray-50 last:border-0">
              <div class="flex items-center gap-3">
                <div class="w-8 h-8 rounded-full bg-primary-100 flex items-center justify-center overflow-hidden">
                  <img v-if="(m.profile as any)?.profile_image_url" :src="(m.profile as any).profile_image_url" alt="" class="w-full h-full object-cover" />
                  <Icon v-else name="heroicons:user" class="w-4 h-4 text-primary-600" />
                </div>
                <div>
                  <p class="text-sm font-medium text-gray-900">{{ (m.profile as any)?.name }}</p>
                  <p class="text-xs text-gray-400">{{ (m.profile as any)?.email }}</p>
                </div>
              </div>
              <div class="flex gap-2">
                <button @click="updateMemberStatus(m.id, 'approved')" class="badge badge-approved cursor-pointer hover:bg-green-200">Approve</button>
                <button @click="removeMember(m.id)" class="badge bg-red-100 text-red-800 cursor-pointer hover:bg-red-200">Reject</button>
              </div>
            </div>
          </div>
        </div>

        <!-- Approved members -->
        <div class="card">
          <h3 class="font-semibold text-gray-900 mb-4">Members ({{ approvedMembers.length }})</h3>
          <div v-if="approvedMembers.length === 0" class="text-sm text-gray-400">No approved members yet.</div>
          <div v-else class="space-y-2">
            <div v-for="m in approvedMembers" :key="m.id" class="flex items-center justify-between py-2 border-b border-gray-50 last:border-0">
              <div class="flex items-center gap-3">
                <div class="w-8 h-8 rounded-full bg-primary-100 flex items-center justify-center overflow-hidden">
                  <img v-if="(m.profile as any)?.profile_image_url" :src="(m.profile as any).profile_image_url" alt="" class="w-full h-full object-cover" />
                  <Icon v-else name="heroicons:user" class="w-4 h-4 text-primary-600" />
                </div>
                <p class="text-sm font-medium text-gray-900">{{ (m.profile as any)?.name }}</p>
              </div>
              <button @click="removeMember(m.id)" class="text-red-400 hover:text-red-600 text-xs">Remove</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
