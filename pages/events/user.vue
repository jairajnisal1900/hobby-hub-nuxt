<script setup lang="ts">
import type { Event } from '~/types'

definePageMeta({ middleware: 'auth' })

const supabase = useSupabaseClient()
const user = useSupabaseUser()

const events = ref<Event[]>([])
const mySignups = ref<string[]>([])
const loading = ref(true)
const signupLoading = ref<string | null>(null)

async function fetchData() {
  loading.value = true
  const [{ data: evts }, { data: attendances }] = await Promise.all([
    supabase
      .from('events')
      .select('*, attendees:event_attendees(count), creator:created_by(name)')
      .order('start_time'),
    supabase
      .from('event_attendees')
      .select('event_id')
      .eq('user_id', user.value!.id),
  ])
  events.value = (evts ?? []).map(e => ({
    ...e,
    attendee_count: e.attendees?.[0]?.count ?? 0,
  }))
  mySignups.value = (attendances ?? []).map(a => a.event_id)
  loading.value = false
}

async function signUp(eventId: string) {
  signupLoading.value = eventId
  const { error } = await supabase.from('event_attendees').insert({
    event_id: eventId,
    user_id: user.value!.id,
  })
  if (!error) {
    mySignups.value.push(eventId)
    const event = events.value.find(e => e.id === eventId)
    if (event) event.attendee_count = (event.attendee_count ?? 0) + 1
  }
  signupLoading.value = null
}

async function cancelSignup(eventId: string) {
  await supabase.from('event_attendees').delete().eq('event_id', eventId).eq('user_id', user.value!.id)
  mySignups.value = mySignups.value.filter(id => id !== eventId)
  const event = events.value.find(e => e.id === eventId)
  if (event && event.attendee_count) event.attendee_count -= 1
}

onMounted(fetchData)
</script>

<template>
  <div>
    <h1 class="text-2xl font-bold text-gray-900 mb-6">Discover Events</h1>

    <div v-if="loading" class="flex justify-center py-16">
      <Icon name="heroicons:arrow-path" class="w-8 h-8 text-primary-600 animate-spin" />
    </div>

    <div v-else-if="events.length === 0" class="card text-center py-16 text-gray-400">
      <Icon name="heroicons:calendar" class="w-12 h-12 mx-auto mb-3 opacity-50" />
      <p>No events available yet.</p>
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
      <div v-for="event in events" :key="event.id" class="card hover:shadow-md transition-shadow">
        <div class="flex items-start justify-between mb-3">
          <span class="badge" :class="event.status === 'CheckedIn' ? 'bg-green-100 text-green-800' : 'badge-pending'">
            {{ event.status }}
          </span>
          <span v-if="mySignups.includes(event.id)" class="badge badge-approved">Signed Up</span>
        </div>

        <h3 class="font-semibold text-gray-900 mb-3">{{ event.resource }}</h3>

        <div class="space-y-1.5 text-sm text-gray-500 mb-4">
          <div class="flex items-center gap-2">
            <Icon name="heroicons:map-pin" class="w-4 h-4 flex-shrink-0" />
            <span>{{ event.location }}</span>
          </div>
          <div class="flex items-center gap-2">
            <Icon name="heroicons:clock" class="w-4 h-4 flex-shrink-0" />
            <span>{{ new Date(event.start_time).toLocaleString() }}</span>
          </div>
          <div class="flex items-center gap-2">
            <Icon name="heroicons:users" class="w-4 h-4 flex-shrink-0" />
            <span>{{ event.attendee_count }} attending</span>
          </div>
        </div>

        <button
          v-if="mySignups.includes(event.id)"
          @click="cancelSignup(event.id)"
          class="btn-danger w-full text-sm"
        >
          Cancel Signup
        </button>
        <button
          v-else
          @click="signUp(event.id)"
          :disabled="signupLoading === event.id"
          class="btn-primary w-full text-sm"
        >
          <span v-if="signupLoading === event.id" class="flex items-center justify-center gap-2">
            <Icon name="heroicons:arrow-path" class="w-4 h-4 animate-spin" />
            Signing up...
          </span>
          <span v-else>Sign Up</span>
        </button>
      </div>
    </div>
  </div>
</template>
