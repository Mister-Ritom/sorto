-- supabase/migrations/006_razorpay_payments.sql
--
-- Adds the add_coins() RPC used by verify-razorpay-payment edge function.
-- Called with service-role key so RLS is bypassed intentionally.

-- ── Ensure wallets table has needed columns ─────────────────────────────────
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'wallets' AND column_name = 'lifetime_coins_purchased'
  ) THEN
    ALTER TABLE wallets ADD COLUMN lifetime_coins_purchased INT NOT NULL DEFAULT 0;
  END IF;
END;
$$;

-- ── add_coins ─────────────────────────────────────────────────────────────────
-- Atomically increments coin_balance and lifetime_coins_purchased.
-- Only called after server-side Razorpay signature verification.

create or replace function add_coins(p_user_id uuid, p_amount int)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_amount <= 0 then
    raise exception 'Amount must be positive';
  end if;

  -- 1. Update spendable balance (always exists)
  update wallets
  set
    coin_balance = coin_balance + p_amount,
    updated_at   = now()
  where user_id = p_user_id;

  if not found then
    raise exception 'Wallet not found for user %', p_user_id;
  end if;

  -- 2. Try to update lifetime_coins_purchased (might be missing due to schema mismatch)
  begin
    execute 'update wallets set lifetime_coins_purchased = lifetime_coins_purchased + $1 where user_id = $2'
    using p_amount, p_user_id;
  exception when undefined_column then
    -- Silently ignore if column doesn't exist
    null;
  end;
end;
$$;

-- Grant execute to service role only (edge functions use service role key)
revoke all on function add_coins(uuid, int) from public;
revoke all on function add_coins(uuid, int) from anon;
revoke all on function add_coins(uuid, int) from authenticated;
grant execute on function add_coins(uuid, int) to service_role;

-- coin_amount already defined in 001_schema.sql — no action needed.
