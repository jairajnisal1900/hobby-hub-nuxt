<script setup lang="ts">
import type { Event } from '~/types'
import { format } from 'date-fns'

definePageMeta({ middleware: 'auth' })

const auth = useAuthStore()
const supabase = useSupabaseClient()
const user = useSupabaseUser()

if (!auth.isBusinessOwner && !auth.isAdmin) navigateTo('/home')

const events = ref<Event[]>([])
const loading = ref(true)
const editingEvent = ref<Event | null>(null)
const showEditModal = ref(false)

async function fetchEvents() {
  loading.value = true
  const { data } = await supabase
    .from('events')
    .select('*, attendees:event_attendees(count)')
    .eq('created_by', user.value!.id)
    .order('start_time', { ascending: false })
  events.value = (data ?? []).map(e => ({
    ...e,
    attendee_count: e.attendees?.[0]?.count ?? 0,
  }))
  loading.value = false
}

async function deleteEvent(id: string) {
  if (!confirm('Delete this event?')) return
  await supabase.from('events').delete().eq('id', id)
  events.value = events.value.filter(e => e.id !== id)
}

function openEdit(event: Event) {
  editingEvent.value = { ...event }
  showEditModal.value = true
}

async function saveEdit() {
  if (!editingEvent.value) return
  const { id, status, location, resource, address, start_time, end_time } = editingEvent.value
  const { error } = await supabase.from('events').update({ status, location, resource, address, start_time, end_time }).eq('id', id)
  if (!error) {
    const idx = events.value.findIndex(e => e.id === id)
    if (idx !== -1) events.value[idx] = { ...events.value[idx], ...editingEvent.value }
    showEditModal.value = false
  }
}

onMounted(fetchEvents)
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold text-gray-900">My Events</h1>
      <NuxtLink to="/events/create" class="btn-primary flex items-center gap-2">
        <Icon name="heroicons:plus" class="w-4 h-4" />
        Create Event
      </NuxtLink>
    </div>

    <div v-if="loading" class="flex justify-center py-16">
      <Icon name="heroicons:arrow-path" class="w-8 h-8 text-primary-600 animate-spin" />
    </div>

    <div v-else-if="events.length === 0" class="card text-center py-16 text-gray-400">
      <Icon name="heroicons:calendar" class="w-12 h-12 mx-auto mb-3 opacity-50" />
      <p class="mb-4">You haven't created any events yet.</p>
      <NuxtLink to="/events/create" class="btn-primary">Create Your First Event</NuxtLink>
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
      <EventCard
        v-for="event in events"
        :key="event.id"
        :event="event"
        :show-actions="true"
        @edit="openEdit"
        @delete="deleteEvent"
      />
    </div>

    <!-- Edit modal -->
    <Teleport to="body">
      <div v-if="showEditModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
        <div class="bg-white rounded-2xl p-6 w-full max-w-lg shadow-xl">
          <div class="flex items-center justify-between mb-5">
            <h2 class="text-lg font-bold text-gray-900">Edit Event</h2>
            <button @click="showEditModal = false" class="text-gray-400 hover:text-gray-600">
              <Icon name="heroicons:x-mark" class="w-5 h-5" />
            </button>
          </div>

          <div v-if="editingEvent" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Resource / Title</label>
              <input v-model="editingEvent.resource" type="text" class="input-field" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Location</label>
              <input v-model="editingEvent.location" type="text" class="input-field" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Address</label>
              <input v-model="editingEvent.address" type="text" class="input-field" />
            </div>
            <div class="grid grid-cols-2 gap-3">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Start</label>
                <input v-model="editingEvent.start_time" type="datetime-local" class="input-field" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">End</label>
                <input v-model="editingEvent.end_time" type="datetime-local" class="input-field" />
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
              <select v-model="editingEvent.status" class="input-field">
                <option value="Pending">Pending</option>
                <option value="CheckedIn">Checked In</option>
              </select>
            </div>

            <div class="flex gap-3 pt-2">
              <button @click="showEditModal = false" class="btn-secondary flex-1">Cancel</button>
              <button @click="saveEdit" class="btn-primary flex-1">Save Changes</button>
            </div>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>
