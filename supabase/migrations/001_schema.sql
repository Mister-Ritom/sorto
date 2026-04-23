-- ============================================================
-- 001_schema.sql  —  Sorto Core Schema
-- Run in Supabase SQL Editor (or via supabase db push)
-- ============================================================

-- EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ────────────────────────────────────────────────────────────
-- PROFILES
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.profiles (
  id                    UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username              TEXT UNIQUE NOT NULL CHECK (length(username) BETWEEN 3 AND 20),
  display_name          TEXT,
  bio                   TEXT CHECK (length(bio) <= 300),
  avatar_url            TEXT,
  role                  TEXT NOT NULL DEFAULT 'both' CHECK (role IN ('poster', 'performer', 'both')),
  interests             TEXT[] NOT NULL DEFAULT '{}',
  notification_granted  BOOLEAN NOT NULL DEFAULT FALSE,
  onboarding_done       BOOLEAN NOT NULL DEFAULT FALSE,
  total_dares_posted    INT NOT NULL DEFAULT 0,
  total_dares_completed INT NOT NULL DEFAULT 0,
  total_earned_coins    INT NOT NULL DEFAULT 0,
  reputation_score      INT NOT NULL DEFAULT 0,
  poster_strikes        INT NOT NULL DEFAULT 0,
  is_banned             BOOLEAN NOT NULL DEFAULT FALSE,
  attribution_source    TEXT,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ────────────────────────────────────────────────────────────
-- WALLETS
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.wallets (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id             UUID UNIQUE NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  coin_balance        INT NOT NULL DEFAULT 0 CHECK (coin_balance >= 0),
  escrowed_balance    INT NOT NULL DEFAULT 0 CHECK (escrowed_balance >= 0),
  pending_withdrawal  INT NOT NULL DEFAULT 0 CHECK (pending_withdrawal >= 0),
  lifetime_earned     INT NOT NULL DEFAULT 0,
  lifetime_spent      INT NOT NULL DEFAULT 0,
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ────────────────────────────────────────────────────────────
-- TRANSACTIONS
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.transactions (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id           UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  dare_id           UUID,  -- FK added after dares table
  type              TEXT NOT NULL CHECK (type IN (
                      'topup_native', 'topup_web',
                      'dare_lock', 'dare_unlock', 'dare_earn',
                      'platform_fee', 'withdrawal_request',
                      'withdrawal_complete', 'refund'
                    )),
  amount            INT NOT NULL,   -- always positive
  direction         TEXT NOT NULL CHECK (direction IN ('credit', 'debit')),
  provider_txn_id   TEXT,
  metadata          JSONB,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ────────────────────────────────────────────────────────────
-- DARES
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.dares (
  id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  poster_id             UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  performer_id          UUID REFERENCES public.profiles(id),
  title                 TEXT NOT NULL CHECK (length(title) BETWEEN 10 AND 100),
  description           TEXT NOT NULL CHECK (length(description) BETWEEN 20 AND 1000),
  category              TEXT NOT NULL,
  tags                  TEXT[] NOT NULL DEFAULT '{}',
  bounty_amount         INT NOT NULL CHECK (bounty_amount >= 10),
  platform_fee_pct      FLOAT NOT NULL DEFAULT 0.20,
  dare_mode             TEXT NOT NULL DEFAULT 'solo' CHECK (dare_mode IN ('solo', 'open_split', 'open_best')),
  status                TEXT NOT NULL DEFAULT 'open'
                          CHECK (status IN ('open', 'locked', 'under_review', 'completed', 'rejected', 'cancelled', 'disputed')),
  proof_video_url       TEXT,
  proof_text            TEXT,
  moderation_result     JSONB,
  moderation_model      TEXT,
  judging_deadline      TIMESTAMPTZ,
  winner_performer_id   UUID REFERENCES public.profiles(id),
  expires_at            TIMESTAMPTZ,
  submission_count      INT NOT NULL DEFAULT 0,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Back-fill FK on transactions
ALTER TABLE public.transactions
  ADD CONSTRAINT fk_transactions_dare
  FOREIGN KEY (dare_id) REFERENCES public.dares(id) ON DELETE SET NULL;

-- ────────────────────────────────────────────────────────────
-- DARE SUBMISSIONS
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.dare_submissions (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  dare_id           UUID NOT NULL REFERENCES public.dares(id) ON DELETE CASCADE,
  performer_id      UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  proof_video_url   TEXT,
  proof_text        TEXT,
  ai_verdict        TEXT CHECK (ai_verdict IN ('approved', 'rejected', 'escalated', 'pending')),
  ai_confidence     FLOAT,
  ai_harm_score     FLOAT,
  ai_raw_response   JSONB,
  poster_verdict    TEXT CHECK (poster_verdict IN ('approved', 'rejected', 'winner')),
  poster_note       TEXT,
  is_contested      BOOLEAN NOT NULL DEFAULT FALSE,
  contest_reason    TEXT,
  admin_verdict     TEXT CHECK (admin_verdict IN ('approved', 'rejected', 'split')),
  payout_amount     INT,
  settled_at        TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (dare_id, performer_id)  -- one submission per performer per dare in solo; removed for open modes
);

-- ────────────────────────────────────────────────────────────
-- PERFORMER POSTS
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.performer_posts (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  performer_id    UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title           TEXT NOT NULL CHECK (length(title) BETWEEN 10 AND 100),
  description     TEXT NOT NULL CHECK (length(description) BETWEEN 20 AND 1000),
  category        TEXT NOT NULL,
  asking_price    INT NOT NULL CHECK (asking_price >= 50),
  status          TEXT NOT NULL DEFAULT 'open'
                    CHECK (status IN ('open', 'funded', 'under_review', 'completed', 'cancelled')),
  funder_id       UUID REFERENCES public.profiles(id),
  proof_video_url TEXT,
  deadline        TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ────────────────────────────────────────────────────────────
-- NOTIFICATIONS
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.notifications (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type        TEXT NOT NULL,
  title       TEXT NOT NULL,
  body        TEXT NOT NULL,
  dare_id     UUID REFERENCES public.dares(id) ON DELETE CASCADE,
  is_read     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ────────────────────────────────────────────────────────────
-- WITHDRAWAL REQUESTS
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.withdrawal_requests (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  coin_amount     INT NOT NULL CHECK (coin_amount >= 100),
  inr_amount      INT NOT NULL,  -- coin_amount * 1
  upi_id          TEXT NOT NULL,
  status          TEXT NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'reversed')),
  razorpay_payout_id TEXT,
  failure_reason  TEXT,
  processed_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
