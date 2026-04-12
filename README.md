# HobbyHub — Community-Driven Hobby Discovery Platform

A full-stack web application that connects people through shared hobbies and interests. Users can create and join communities, organize events, and chat in real time — all backed by role-based access control and database-enforced security.

> Built with Nuxt 3 and Supabase to explore SSR, Vue 3 Composition API patterns, real-time features, and Row-Level Security on managed Postgres.

---

## ✨ Features

- 🔐 **Authentication** — Email/password sign-up and login via Supabase Auth, with email confirmation flow
- 👥 **Communities** — Create, browse, and join hobby communities with membership approval workflows
- 📅 **Events** — Business owners can create events with location, schedule, and check-in tracking; users can RSVP
- 💬 **Real-Time Chat** — Community members can chat in real time via Supabase Realtime subscriptions
- 🛡️ **Role-Based Access** — Four distinct roles (Admin, User, CommunityAdmin, BusinessOwner) enforced at both middleware and database level
- 🔒 **Row-Level Security** — Postgres RLS policies ensure users can only access and mutate their own data
- 🖼️ **Image Uploads** — Profile and community images stored in Supabase Storage with public read access
- 📱 **Responsive Design** — Mobile-first UI built with Tailwind CSS and a custom sky-blue color palette
- 🧭 **Route Protection** — Nuxt middleware guards for authenticated, guest-only, and role-restricted routes
- 📬 **Contact Form** — Public contact form that stores submissions for admin review

---

## 🧰 Tech Stack

| Layer | Technology |
|---|---|
| Framework | Nuxt 3 (Vue 3 Composition API, SSR) |
| Language | TypeScript (strict mode) |
| State Management | Pinia |
| Styling | Tailwind CSS 3 with custom design tokens |
| Utilities | VueUse |
| Icons | Nuxt Icon |
| Rich Text | Vue Quill Editor |
| Date Handling | date-fns |
| Notifications | Vue Toastification |
| Backend | Supabase (PostgreSQL + Auth + Storage + Realtime) |

---

## 🚀 Local Development

### Prerequisites
- Node.js 18+
- A Supabase project ([free tier works](https://supabase.com))

### Setup
```bash
git clone https://github.com/jairajnisal1900/hobby-hub-nuxt.git
cd hobby-hub-nuxt
npm install

# Configure environment
cp .env.example .env
# Fill in your Supabase credentials:
#   SUPABASE_URL=https://your-project.supabase.co
#   SUPABASE_KEY=your-supabase-anon-key

# Run the database migrations in your Supabase SQL editor
# (see supabase/migrations/)

# Start dev server
npm run dev
```

App runs on `http://localhost:3000`.

---

## 🗄️ Database Schema

Schema, triggers, RLS policies, and storage buckets are defined in `supabase/migrations/`.

### Core Tables

| Table | Purpose |
|---|---|
| `profiles` | Extends Supabase `auth.users` — stores name, email, role, and avatar |
| `communities` | User-created hobby groups with descriptions and images |
| `community_members` | Join requests with pending/approved status |
| `events` | Scheduled events with location, time, and check-in status |
| `event_attendees` | RSVP tracking for events |
| `chat_messages` | Real-time messages scoped to communities |
| `contacts` | Public contact form submissions |

### User Roles

| Role | Permissions |
|---|---|
| `Admin` | Full access — manage all users, communities, events, and contact submissions |
| `CommunityAdmin` | Create and manage communities, approve/reject member requests |
| `BusinessOwner` | Create and manage events |
| `User` | Browse communities, join/leave, RSVP to events, participate in chat |

### Row-Level Security

All tables enforce RLS. Key policies include:
- Users can read public data but can only update/delete their own rows
- Community creators can manage membership approvals
- Chat messages are restricted to approved community members
- Contact submissions are insert-open but read-restricted to admins

### Storage Buckets

- `profile-images` — Public-read, authenticated upload, owner-only update
- `community-images` — Public-read, authenticated upload

---

## 📂 Project Structure

```
pages/
├── index.vue              Landing page (public)
├── login.vue              Sign in
├── register.vue           Sign up with role selection
├── confirm.vue            Email confirmation callback
├── home.vue               Authenticated dashboard
├── about.vue              About page (public)
├── contact.vue            Contact form (public)
├── admin/
│   └── dashboard.vue      Admin panel with platform stats
├── community/
│   ├── index.vue          Browse all communities
│   ├── [id].vue           Community detail + chat
│   ├── create.vue         Create new community
│   └── admin.vue          Manage community members
├── events/
│   ├── index.vue          Browse all events
│   ├── create.vue         Create new event
│   └── user.vue           User's registered events
└── profile/
    └── settings.vue       Edit profile and avatar

components/
├── AppNavbar.vue          Authenticated navigation bar
├── AppSidebar.vue         Side navigation with role-aware links
├── AppFooter.vue          Site footer
├── PublicNavbar.vue        Public page navigation
└── EventCard.vue          Reusable event display card

layouts/
├── default.vue            Authenticated layout (navbar + sidebar)
└── public.vue             Public layout (public navbar + footer)

middleware/
├── auth.ts                Redirect unauthenticated users
├── guest.ts               Redirect authenticated users away from login
└── role.ts                Role-based route guard

stores/
└── auth.ts                Pinia store for user session + profile

types/
└── index.ts               TypeScript interfaces for all entities

supabase/
└── migrations/
    ├── 001_initial_schema.sql   Tables, triggers, RLS, storage
    └── 002_fix_trigger.sql      Trigger patch
```

---

## 🎓 What I Learned

- **Nuxt 3 SSR + middleware** — Route guards that run on both server and client, handling redirects gracefully
- **Supabase RLS over app-layer auth** — Database-enforced authorization is more robust than relying on middleware alone; a misconfigured API endpoint can't leak data when RLS is in place
- **Real-time architecture** — Supabase Realtime subscriptions for live chat, scoped per community with proper RLS filtering
- **Role-based access patterns** — Implementing four distinct user roles across UI rendering, route middleware, and database policies
- **Pinia + Composition API** — Reactive auth state management with computed role checks that propagate across the entire app
- **TypeScript strict mode** — End-to-end type safety from database types through Pinia stores to Vue components

