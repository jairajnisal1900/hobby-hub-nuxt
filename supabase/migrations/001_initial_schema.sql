-- ============================================================
-- Hobby Hub - Supabase PostgreSQL Schema
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- PROFILES (extends auth.users)
-- ============================================================
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'User'
    CHECK (role IN ('Admin', 'User', 'CommunityAdmin', 'BusinessOwner')),
  profile_image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, name, email, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', ''),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'role', 'User')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- COMMUNITIES
-- ============================================================
CREATE TABLE communities (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT,
  created_by UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER communities_updated_at
  BEFORE UPDATE ON communities
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- COMMUNITY MEMBERS
-- ============================================================
CREATE TABLE community_members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  community_id UUID REFERENCES communities(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'approved')),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(community_id, user_id)
);

-- ============================================================
-- EVENTS
-- ============================================================
CREATE TABLE events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  status TEXT DEFAULT 'Pending'
    CHECK (status IN ('CheckedIn', 'Pending')),
  location TEXT NOT NULL,
  resource TEXT NOT NULL,
  address TEXT NOT NULL,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  created_by UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER events_updated_at
  BEFORE UPDATE ON events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- EVENT ATTENDEES
-- ============================================================
CREATE TABLE event_attendees (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  event_id UUID REFERENCES events(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  signed_up_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(event_id, user_id)
);

-- ============================================================
-- CHAT MESSAGES
-- ============================================================
CREATE TABLE chat_messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  message TEXT NOT NULL,
  sender_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  community_id UUID REFERENCES communities(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- CONTACTS
-- ============================================================
CREATE TABLE contacts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE communities ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_attendees ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;

-- Helper function: get current user role
CREATE OR REPLACE FUNCTION get_my_role()
RETURNS TEXT AS $$
  SELECT role FROM profiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER;

-- PROFILES policies
CREATE POLICY "profiles_read_all" ON profiles
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "profiles_update_own" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- COMMUNITIES policies
CREATE POLICY "communities_read_authenticated" ON communities
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "communities_insert_community_admin_or_admin" ON communities
  FOR INSERT WITH CHECK (
    get_my_role() IN ('CommunityAdmin', 'Admin')
    AND auth.uid() = created_by
  );

CREATE POLICY "communities_update_creator_or_admin" ON communities
  FOR UPDATE USING (
    auth.uid() = created_by OR get_my_role() = 'Admin'
  );

CREATE POLICY "communities_delete_creator_or_admin" ON communities
  FOR DELETE USING (
    auth.uid() = created_by OR get_my_role() = 'Admin'
  );

-- COMMUNITY MEMBERS policies
CREATE POLICY "community_members_read_authenticated" ON community_members
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "community_members_insert_own" ON community_members
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "community_members_update_community_creator_or_admin" ON community_members
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM communities
      WHERE id = community_id AND (created_by = auth.uid() OR get_my_role() = 'Admin')
    )
  );

CREATE POLICY "community_members_delete_own_or_admin" ON community_members
  FOR DELETE USING (
    auth.uid() = user_id
    OR get_my_role() = 'Admin'
    OR EXISTS (
      SELECT 1 FROM communities
      WHERE id = community_id AND created_by = auth.uid()
    )
  );

-- EVENTS policies
CREATE POLICY "events_read_authenticated" ON events
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "events_insert_business_owner_or_admin" ON events
  FOR INSERT WITH CHECK (
    get_my_role() IN ('BusinessOwner', 'Admin')
    AND auth.uid() = created_by
  );

CREATE POLICY "events_update_creator_or_admin" ON events
  FOR UPDATE USING (
    auth.uid() = created_by OR get_my_role() = 'Admin'
  );

CREATE POLICY "events_delete_creator_or_admin" ON events
  FOR DELETE USING (
    auth.uid() = created_by OR get_my_role() = 'Admin'
  );

-- EVENT ATTENDEES policies
CREATE POLICY "event_attendees_read_authenticated" ON event_attendees
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "event_attendees_insert_own" ON event_attendees
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "event_attendees_delete_own" ON event_attendees
  FOR DELETE USING (auth.uid() = user_id);

-- CHAT MESSAGES policies
CREATE POLICY "chat_messages_read_members" ON chat_messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM community_members
      WHERE community_id = chat_messages.community_id
        AND user_id = auth.uid()
        AND status = 'approved'
    )
  );

CREATE POLICY "chat_messages_insert_members" ON chat_messages
  FOR INSERT WITH CHECK (
    auth.uid() = sender_id
    AND EXISTS (
      SELECT 1 FROM community_members
      WHERE community_id = chat_messages.community_id
        AND user_id = auth.uid()
        AND status = 'approved'
    )
  );

-- CONTACTS policies
CREATE POLICY "contacts_insert_anyone" ON contacts
  FOR INSERT WITH CHECK (true);

CREATE POLICY "contacts_read_admin" ON contacts
  FOR SELECT USING (get_my_role() = 'Admin');

-- ============================================================
-- STORAGE BUCKETS
-- ============================================================
INSERT INTO storage.buckets (id, name, public)
VALUES
  ('profile-images', 'profile-images', true),
  ('community-images', 'community-images', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies
CREATE POLICY "profile_images_public_read" ON storage.objects
  FOR SELECT USING (bucket_id = 'profile-images');

CREATE POLICY "profile_images_auth_upload" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'profile-images'
    AND auth.role() = 'authenticated'
  );

CREATE POLICY "profile_images_owner_update" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'profile-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "community_images_public_read" ON storage.objects
  FOR SELECT USING (bucket_id = 'community-images');

CREATE POLICY "community_images_auth_upload" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'community-images'
    AND auth.role() = 'authenticated'
  );

-- ============================================================
-- REALTIME (enable for chat)
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;
