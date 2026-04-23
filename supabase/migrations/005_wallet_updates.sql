-- ============================================================
-- 005_wallet_updates.sql — Atomic Wallet Transactions
-- ================= ===========================================

-- Add withdrawable_balance to wallets if not exists
DO $$ 
BEGIN 
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='wallets' AND column_name='withdrawable_balance') THEN
    ALTER TABLE public.wallets ADD COLUMN withdrawable_balance INT NOT NULL DEFAULT 0;
  END IF;
END $$;

-- ── 1. Increment Column Helper ───────────────────────────────
CREATE OR REPLACE FUNCTION public.increment_column(p_id UUID, p_col TEXT)
RETURNS INT AS $$
DECLARE
  current_val INT;
BEGIN
  EXECUTE format('SELECT %I FROM public.profiles WHERE id = $1', p_col)
  INTO current_val
  USING p_id;
  RETURN current_val + 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── 2. Increment Column Amount Helper ────────────────────────
CREATE OR REPLACE FUNCTION public.increment_column_amount(p_id UUID, p_col TEXT, p_amount INT)
RETURNS INT AS $$
DECLARE
  current_val INT;
BEGIN
  EXECUTE format('SELECT %I FROM public.profiles WHERE id = $1', p_col)
  INTO current_val
  USING p_id;
  RETURN current_val + p_amount;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── 3. Escrow Coins (for dare creation) ──────────────────────
CREATE OR REPLACE FUNCTION public.dare_escrow_coins(p_user_id UUID, p_amount INT)
RETURNS void AS $$
BEGIN
  UPDATE public.wallets
  SET 
    coin_balance = coin_balance - p_amount,
    escrowed_balance = escrowed_balance + p_amount,
    lifetime_spent = lifetime_spent + p_amount,
    updated_at = NOW()
  WHERE user_id = p_user_id AND coin_balance >= p_amount;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Insufficient balance or wallet not found';
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── 4. Payout Dare (Atomic: Escrow -> Performer Earned) ──────
CREATE OR REPLACE FUNCTION public.dare_payout(
  p_dare_id UUID,
  p_performer_id UUID,
  p_poster_id UUID,
  p_payout_amount INT,
  p_platform_fee INT,
  p_bounty INT
)
RETURNS void AS $$
BEGIN
  -- 1. Deduct from poster's escrow
  UPDATE public.wallets
  SET escrowed_balance = escrowed_balance - p_bounty
  WHERE user_id = p_poster_id AND escrowed_balance >= p_bounty;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Escrow deduction failed for poster %', p_poster_id;
  END IF;

  -- 2. Credit to performer's withdrawable balance
  UPDATE public.wallets
  SET 
    withdrawable_balance = withdrawable_balance + p_payout_amount,
    lifetime_earned = lifetime_earned + p_payout_amount
  WHERE user_id = p_performer_id;

  -- 3. Mark dare as completed
  UPDATE public.dares
  SET status = 'completed', winner_performer_id = p_performer_id, updated_at = NOW()
  WHERE id = p_dare_id;

  -- 4. Record transaction (optional if done in edge function, but safer here)
  -- We'll record it in the edge function for better metadata.
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── 5. Initiate Withdrawal (Atomic: Earned -> Pending) ───────
CREATE OR REPLACE FUNCTION public.wallet_initiate_withdrawal(p_user_id UUID, p_amount INT)
RETURNS void AS $$
BEGIN
  UPDATE public.wallets
  SET 
    withdrawable_balance = withdrawable_balance - p_amount,
    pending_withdrawal = pending_withdrawal + p_amount
  WHERE user_id = p_user_id AND withdrawable_balance >= p_amount;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Insufficient withdrawable balance';
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
