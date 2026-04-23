-- ============================================================
-- 004_indexes.sql  —  Performance Indexes
-- ============================================================

-- profiles
CREATE INDEX IF NOT EXISTS idx_profiles_username ON public.profiles (username);

-- wallets
CREATE INDEX IF NOT EXISTS idx_wallets_user_id ON public.wallets (user_id);

-- transactions
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON public.transactions (user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_dare_id ON public.transactions (dare_id);
CREATE INDEX IF NOT EXISTS idx_transactions_created ON public.transactions (created_at DESC);

-- dares
CREATE INDEX IF NOT EXISTS idx_dares_poster_id ON public.dares (poster_id);
CREATE INDEX IF NOT EXISTS idx_dares_performer_id ON public.dares (performer_id);
CREATE INDEX IF NOT EXISTS idx_dares_status ON public.dares (status);
CREATE INDEX IF NOT EXISTS idx_dares_category ON public.dares (category);
CREATE INDEX IF NOT EXISTS idx_dares_mode ON public.dares (dare_mode);
CREATE INDEX IF NOT EXISTS idx_dares_created ON public.dares (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_dares_expires ON public.dares (expires_at);
CREATE INDEX IF NOT EXISTS idx_dares_title_search ON public.dares USING gin (to_tsvector('english', title || ' ' || description));

-- dare_submissions
CREATE INDEX IF NOT EXISTS idx_dare_submissions_dare_id ON public.dare_submissions (dare_id);
CREATE INDEX IF NOT EXISTS idx_dare_submissions_performer_id ON public.dare_submissions (performer_id);

-- performer_posts
CREATE INDEX IF NOT EXISTS idx_performer_posts_performer_id ON public.performer_posts (performer_id);
CREATE INDEX IF NOT EXISTS idx_performer_posts_status ON public.performer_posts (status);
CREATE INDEX IF NOT EXISTS idx_performer_posts_created ON public.performer_posts (created_at DESC);

-- notifications
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications (user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON public.notifications (user_id, is_read) WHERE is_read = FALSE;

-- withdrawal_requests
CREATE INDEX IF NOT EXISTS idx_withdrawal_requests_user_id ON public.withdrawal_requests (user_id);
CREATE INDEX IF NOT EXISTS idx_withdrawal_requests_status ON public.withdrawal_requests (status);
