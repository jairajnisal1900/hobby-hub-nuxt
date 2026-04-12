<script setup lang="ts">
import type { Community, CommunityMember } from '~/types'
definePageMeta({ middleware: 'auth' })

const supabase = useSupabaseClient()
const user = useSupabaseUser()

const communities = ref<Community[]>([])
const myMemberships = ref<CommunityMember[]>([])
const loading = ref(true)
const joinLoading = ref<string | null>(null)
const search = ref('')

const filtered = computed(() =>
  communities.value.filter(c =>
    c.name.toLowerCase().includes(search.value.toLowerCase()) ||
    c.description.toLowerCase().includes(search.value.toLowerCase())
  )
)

function getMemberStatus(communityId: string) {
  return myMemberships.value.find(m => m.community_id === communityId)?.status ?? null
}

async function fetchData() {
  loading.value = true
  const [{ data: cs }, { data: ms }] = await Promise.all([
    supabase.from('communities').select('*, creator:created_by(name), member_count:community_members(count)').order('created_at', { ascending: false }),
    supabase.from('community_members').select('*').eq('user_id', user.value!.id),
  ])
  communities.value = cs ?? []
  myMemberships.value = ms ?? []
  loading.value = false
}

async function joinCommunity(communityId: string) {
  joinLoading.value = communityId
  const { error } = await supabase.from('community_members').insert({
    community_id: communityId,
    user_id: user.value!.id,
    status: 'pending',
  })
  if (!error) {
    myMemberships.value.push({ id: crypto.randomUUID(), community_id: communityId, user_id: user.value!.id, status: 'pending', joined_at: new Date().toISOString() })
  }
  joinLoading.value = null
}

async function leaveCommunity(communityId: string) {
  await supabase.from('community_members').delete().eq('community_id', communityId).eq('user_id', user.value!.id)
  myMemberships.value = myMemberships.value.filter(m => m.community_id !== communityId)
}

onMounted(fetchData)
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold text-gray-900">Communities</h1>
    </div>

    <!-- Search -->
    <div class="relative mb-6">
      <Icon name="heroicons:magnifying-glass" class="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
      <input v-model="search" type="text" placeholder="Search communities..." class="input-field pl-10" />
    </div>

    <div v-if="loading" class="flex justify-center py-16">
      <Icon name="heroicons:arrow-path" class="w-8 h-8 text-primary-600 animate-spin" />
    </div>

    <div v-else-if="filtered.length === 0" class="text-center py-16 text-gray-400">
      <Icon name="heroicons:user-group" class="w-12 h-12 mx-auto mb-3 opacity-50" />
      <p>No communities found.</p>
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div v-for="community in filtered" :key="community.id" class="card hover:shadow-md transition-shadow flex flex-col">
        <!-- Image -->
        <div class="h-40 bg-gradient-to-br from-primary-100 to-primary-200 rounded-lg mb-4 overflow-hidden">
          <img v-if="community.image_url" :src="community.image_url" :alt="community.name" class="w-full h-full object-cover" />
          <div v-else class="w-full h-full flex items-center justify-center">
            <Icon name="heroicons:user-group" class="w-12 h-12 text-primary-400" />
          </div>
        </div>

        <h3 class="font-semibold text-gray-900 mb-1">{{ community.name }}</h3>
        <p class="text-sm text-gray-500 mb-3 flex-1 line-clamp-2">{{ community.description }}</p>

        <div class="flex items-center justify-between mt-auto">
          <NuxtLink :to="`/community/${community.id}`" class="text-primary-600 text-sm font-medium hover:underline">
            View Details
          </NuxtLink>

          <div>
            <template v-if="getMemberStatus(community.id) === 'approved'">
              <button @click="leaveCommunity(community.id)" class="text-sm text-red-500 hover:text-red-700">Leave</button>
            </template>
            <template v-else-if="getMemberStatus(community.id) === 'pending'">
              <span class="badge badge-pending">Pending</span>
            </template>
            <template v-else>
              <button
                @click="joinCommunity(community.id)"
                :disabled="joinLoading === community.id"
                class="btn-primary text-sm py-1.5"
              >
                <span v-if="joinLoading === community.id">...</span>
                <span v-else>Join</span>
              </button>
            </template>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
