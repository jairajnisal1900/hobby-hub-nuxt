<script setup lang="ts">
import type { Community, CommunityMember, ChatMessage } from '~/types'
import { format } from 'date-fns'

definePageMeta({ middleware: 'auth' })

const route = useRoute()
const supabase = useSupabaseClient()
const user = useSupabaseUser()
const communityId = route.params.id as string

const community = ref<Community | null>(null)
const members = ref<CommunityMember[]>([])
const messages = ref<ChatMessage[]>([])
const newMessage = ref('')
const loading = ref(true)
const sendingMessage = ref(false)
const chatContainer = ref<HTMLElement | null>(null)

const isMember = computed(() =>
  members.value.some(m => m.user_id === user.value?.id && m.status === 'approved')
)

async function fetchCommunity() {
  const [{ data: c }, { data: ms }, { data: msgs }] = await Promise.all([
    supabase.from('communities').select('*, creator:created_by(name, email)').eq('id', communityId).single(),
    supabase.from('community_members').select('*, profile:user_id(name, profile_image_url)').eq('community_id', communityId),
    supabase.from('chat_messages').select('*, sender:sender_id(name, profile_image_url)').eq('community_id', communityId).order('created_at'),
  ])
  community.value = c
  members.value = ms ?? []
  messages.value = msgs ?? []
  loading.value = false
}

async function sendMessage() {
  if (!newMessage.value.trim() || !isMember.value) return
  sendingMessage.value = true

  const messageText = newMessage.value.trim()
  newMessage.value = ''

  const { data, error } = await supabase
    .from('chat_messages')
    .insert({
      message: messageText,
      sender_id: user.value!.id,
      community_id: communityId,
    })
    .select('*, sender:sender_id(name, profile_image_url)')
    .single()

  if (!error && data && !messages.value.find(m => m.id === data.id)) {
    messages.value.push(data)
    scrollToBottom()
  }

  sendingMessage.value = false
}

function scrollToBottom() {
  nextTick(() => {
    if (chatContainer.value) chatContainer.value.scrollTop = chatContainer.value.scrollHeight
  })
}

onMounted(async () => {
  await fetchCommunity()
  scrollToBottom()

  // Subscribe to realtime — handles messages from other users
  supabase.channel(`community-chat-${communityId}`)
    .on('postgres_changes', {
      event: 'INSERT',
      schema: 'public',
      table: 'chat_messages',
      filter: `community_id=eq.${communityId}`,
    }, async (payload) => {
      // Skip if already added optimistically (own message)
      if (messages.value.find(m => m.id === payload.new.id)) return

      const { data } = await supabase
        .from('chat_messages')
        .select('*, sender:sender_id(name, profile_image_url)')
        .eq('id', payload.new.id)
        .single()
      if (data) {
        messages.value.push(data)
        scrollToBottom()
      }
    })
    .subscribe()
})

onUnmounted(() => {
  supabase.channel(`community-chat-${communityId}`).unsubscribe()
})

watch(messages, scrollToBottom)
</script>

<template>
  <div>
    <div v-if="loading" class="flex justify-center py-16">
      <Icon name="heroicons:arrow-path" class="w-8 h-8 text-primary-600 animate-spin" />
    </div>

    <template v-else-if="community">
      <!-- Header -->
      <div class="card mb-6">
        <div class="h-48 bg-gradient-to-br from-primary-100 to-primary-200 rounded-xl mb-4 overflow-hidden">
          <img v-if="community.image_url" :src="community.image_url" :alt="community.name" class="w-full h-full object-cover" />
          <div v-else class="w-full h-full flex items-center justify-center">
            <Icon name="heroicons:user-group" class="w-16 h-16 text-primary-400" />
          </div>
        </div>
        <div class="flex items-start justify-between">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">{{ community.name }}</h1>
            <p class="text-gray-500 mt-1">{{ community.description }}</p>
            <p class="text-sm text-gray-400 mt-2">Created by {{ (community.creator as any)?.name }}</p>
          </div>
          <span class="badge bg-primary-100 text-primary-800">{{ members.filter(m => m.status === 'approved').length }} members</span>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Members list -->
        <div class="card">
          <h2 class="font-semibold text-gray-900 mb-4">Members</h2>
          <div class="space-y-3">
            <div v-for="member in members.filter(m => m.status === 'approved')" :key="member.id" class="flex items-center gap-3">
              <div class="w-8 h-8 rounded-full bg-primary-100 flex items-center justify-center overflow-hidden flex-shrink-0">
                <img v-if="(member.profile as any)?.profile_image_url" :src="(member.profile as any).profile_image_url" alt="" class="w-full h-full object-cover" />
                <Icon v-else name="heroicons:user" class="w-4 h-4 text-primary-600" />
              </div>
              <span class="text-sm text-gray-700">{{ (member.profile as any)?.name }}</span>
            </div>
            <p v-if="members.filter(m => m.status === 'approved').length === 0" class="text-sm text-gray-400">No approved members yet.</p>
          </div>
        </div>

        <!-- Chat -->
        <div class="lg:col-span-2 card flex flex-col" style="height: 500px;">
          <h2 class="font-semibold text-gray-900 mb-4">Community Chat</h2>

          <div v-if="!isMember" class="flex-1 flex items-center justify-center text-gray-400 text-sm text-center">
            <div>
              <Icon name="heroicons:lock-closed" class="w-8 h-8 mx-auto mb-2 opacity-50" />
              <p>Join the community to access the chat.</p>
            </div>
          </div>

          <template v-else>
            <!-- Messages -->
            <div ref="chatContainer" class="flex-1 overflow-y-auto space-y-3 mb-4 pr-1">
              <div v-for="msg in messages" :key="msg.id" class="flex gap-3" :class="msg.sender_id === user?.id ? 'flex-row-reverse' : ''">
                <div class="w-7 h-7 rounded-full bg-primary-100 flex items-center justify-center overflow-hidden flex-shrink-0">
                  <img v-if="(msg.sender as any)?.profile_image_url" :src="(msg.sender as any).profile_image_url" alt="" class="w-full h-full object-cover" />
                  <Icon v-else name="heroicons:user" class="w-4 h-4 text-primary-600" />
                </div>
                <div :class="msg.sender_id === user?.id ? 'items-end' : 'items-start'" class="flex flex-col max-w-xs">
                  <span class="text-xs text-gray-400 mb-1">{{ (msg.sender as any)?.name }}</span>
                  <div :class="msg.sender_id === user?.id ? 'bg-primary-600 text-white' : 'bg-gray-100 text-gray-800'" class="px-3 py-2 rounded-xl text-sm">
                    {{ msg.message }}
                  </div>
                  <span class="text-xs text-gray-400 mt-1">{{ format(new Date(msg.created_at), 'h:mm a') }}</span>
                </div>
              </div>
              <p v-if="messages.length === 0" class="text-center text-gray-400 text-sm py-8">No messages yet. Say hello!</p>
            </div>

            <!-- Input -->
            <div class="flex gap-2">
              <input
                v-model="newMessage"
                @keydown.enter.prevent="sendMessage"
                type="text"
                placeholder="Type a message..."
                class="input-field flex-1"
              />
              <button @click="sendMessage" :disabled="sendingMessage || !newMessage.trim()" class="btn-primary px-4">
                <Icon name="heroicons:paper-airplane" class="w-4 h-4" />
              </button>
            </div>
          </template>
        </div>
      </div>
    </template>

    <div v-else class="text-center py-16 text-gray-400">Community not found.</div>
  </div>
</template>
