-- ============================================================
-- 002_rls.sql  —  Row Level Security Policies
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dares ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dare_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.performer_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.withdrawal_requests ENABLE ROW LEVEL SECURITY;

-- ────────────────────────────────────────────────────────────
-- PROFILES
-- ────────────────────────────────────────────────────────────
-- Everyone can read profiles (public feed)
CREATE POLICY "profiles_read" ON public.profiles
  FOR SELECT USING (TRUE);

-- Only the user can update their own profile
CREATE POLICY "profiles_update_self" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- Insert allowed on signup (via trigger)
CREATE POLICY "profiles_insert_self" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- ────────────────────────────────────────────────────────────
-- WALLETS  (read-only for client — all writes via Edge Functions)
-- ────────────────────────────────────────────────────────────
CREATE POLICY "wallets_read_own" ON public.wallets
  FOR SELECT USING (auth.uid() = user_id);

-- NO INSERT/UPDATE/DELETE policies → client cannot write to wallets

-- ────────────────────────────────────────────────────────────
-- TRANSACTIONS  (read-only for client)
-- ────────────────────────────────────────────────────────────
CREATE POLICY "transactions_read_own" ON public.transactions
  FOR SELECT USING (auth.uid() = user_id);

-- ────────────────────────────────────────────────────────────
-- DARES
-- ────────────────────────────────────────────────────────────
-- Anyone can read open dares
CREATE POLICY "dares_read" ON public.dares
  FOR SELECT USING (TRUE);

-- Poster can insert (but dare_create Edge Function does it)
CREATE POLICY "dares_insert_poster" ON public.dares
  FOR INSERT WITH CHECK (auth.uid() = poster_id);

-- Poster can update their dares status (limited — enforced in EF)
CREATE POLICY "dares_update_poster" ON public.dares
  FOR UPDATE USING (auth.uid() = poster_id);

-- ────────────────────────────────────────────────────────────
-- DARE SUBMISSIONS
-- ────────────────────────────────────────────────────────────
-- Poster can see submissions for their dare
CREATE POLICY "dare_submissions_poster_read" ON public.dare_submissions
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.dares d
      WHERE d.id = dare_id AND d.poster_id = auth.uid()
    )
  );

-- Performer can see their own submissions
CREATE POLICY "dare_submissions_performer_read" ON public.dare_submissions
  FOR SELECT USING (auth.uid() = performer_id);

-- Performer inserts (via Edge Function dare_submit_proof)
CREATE POLICY "dare_submissions_insert_performer" ON public.dare_submissions
  FOR INSERT WITH CHECK (auth.uid() = performer_id);

-- ────────────────────────────────────────────────────────────
-- PERFORMER POSTS
-- ────────────────────────────────────────────────────────────
-- Everyone can read open posts
CREATE POLICY "performer_posts_read" ON public.performer_posts
  FOR SELECT USING (TRUE);

-- Performer creates their own posts
CREATE POLICY "performer_posts_insert" ON public.performer_posts
  FOR INSERT WITH CHECK (auth.uid() = performer_id);

-- Performer updates their own posts
CREATE POLICY "performer_posts_update" ON public.performer_posts
  FOR UPDATE USING (auth.uid() = performer_id);

-- ────────────────────────────────────────────────────────────
-- NOTIFICATIONS
-- ────────────────────────────────────────────────────────────
-- User reads their own notifications
CREATE POLICY "notifications_read" ON public.notifications
  FOR SELECT USING (auth.uid() = user_id);

-- User marks their own notifications as read
CREATE POLICY "notifications_update" ON public.notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- ────────────────────────────────────────────────────────────
-- WITHDRAWAL REQUESTS
-- ────────────────────────────────────────────────────────────
-- User reads their own requests
CREATE POLICY "withdrawal_requests_read" ON public.withdrawal_requests
  FOR SELECT USING (auth.uid() = user_id);

-- Insert via Edge Function only — no client-side insert allowed
