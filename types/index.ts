export type UserRole = 'Admin' | 'User' | 'CommunityAdmin' | 'BusinessOwner'

export interface Profile {
  id: string
  name: string
  email: string
  role: UserRole
  profile_image_url: string | null
  created_at: string
  updated_at: string
}

export interface Community {
  id: string
  name: string
  description: string
  image_url: string | null
  created_by: string
  created_at: string
  updated_at: string
  creator?: Profile
  members?: CommunityMember[]
  member_count?: number
}

export interface CommunityMember {
  id: string
  community_id: string
  user_id: string
  status: 'pending' | 'approved'
  joined_at: string
  profile?: Profile
}

export interface Event {
  id: string
  status: 'CheckedIn' | 'Pending'
  location: string
  resource: string
  address: string
  start_time: string
  end_time: string
  created_by: string
  created_at: string
  updated_at: string
  creator?: Profile
  attendees?: EventAttendee[]
  attendee_count?: number
}

export interface EventAttendee {
  id: string
  event_id: string
  user_id: string
  signed_up_at: string
  profile?: Profile
}

export interface ChatMessage {
  id: string
  message: string
  sender_id: string
  community_id: string
  created_at: string
  sender?: Profile
}

export interface Contact {
  id: string
  name: string
  email: string
  message: string
  created_at: string
}

export interface AdminStats {
  total_users: number
  users_by_role: Record<UserRole, number>
  total_communities: number
  total_events: number
}
