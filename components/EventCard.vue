<script setup lang="ts">
import type { Event } from '~/types'
import { format } from 'date-fns'

const props = defineProps<{
  event: Event
  showActions?: boolean
}>()

const emit = defineEmits<{
  signup: [id: string]
  edit: [event: Event]
  delete: [id: string]
}>()
</script>

<template>
  <div class="card hover:shadow-md transition-shadow">
    <div class="flex items-start justify-between mb-3">
      <span class="badge" :class="event.status === 'CheckedIn' ? 'bg-green-100 text-green-800' : 'badge-pending'">
        {{ event.status }}
      </span>
      <div class="flex gap-2" v-if="showActions">
        <button @click="emit('edit', event)" class="text-gray-400 hover:text-primary-600 transition-colors">
          <Icon name="heroicons:pencil" class="w-4 h-4" />
        </button>
        <button @click="emit('delete', event.id)" class="text-gray-400 hover:text-red-600 transition-colors">
          <Icon name="heroicons:trash" class="w-4 h-4" />
        </button>
      </div>
    </div>

    <h3 class="font-semibold text-gray-900 mb-1">{{ event.resource }}</h3>

    <div class="space-y-1.5 mt-3 text-sm text-gray-500">
      <div class="flex items-center gap-2">
        <Icon name="heroicons:map-pin" class="w-4 h-4 flex-shrink-0" />
        <span>{{ event.location }}</span>
      </div>
      <div class="flex items-center gap-2">
        <Icon name="heroicons:building-office" class="w-4 h-4 flex-shrink-0" />
        <span>{{ event.address }}</span>
      </div>
      <div class="flex items-center gap-2">
        <Icon name="heroicons:clock" class="w-4 h-4 flex-shrink-0" />
        <span>{{ format(new Date(event.start_time), 'MMM d, yyyy h:mm a') }}</span>
      </div>
      <div class="flex items-center gap-2">
        <Icon name="heroicons:arrow-right" class="w-4 h-4 flex-shrink-0" />
        <span>{{ format(new Date(event.end_time), 'MMM d, yyyy h:mm a') }}</span>
      </div>
      <div v-if="event.attendee_count !== undefined" class="flex items-center gap-2">
        <Icon name="heroicons:users" class="w-4 h-4 flex-shrink-0" />
        <span>{{ event.attendee_count }} attendees</span>
      </div>
    </div>

    <button
      v-if="!showActions"
      @click="emit('signup', event.id)"
      class="btn-primary w-full mt-4 text-sm"
    >
      Sign Up
    </button>
  </div>
</template>
