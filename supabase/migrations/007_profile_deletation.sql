-- 0. Enable the pg_cron extension
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- 1. Add the necessary columns to your profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_disabled BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS disabled_at TIMESTAMPTZ;

-- 2. Add an index to optimize the cleanup query
CREATE INDEX IF NOT EXISTS idx_profiles_is_disabled 
ON profiles(is_disabled) 
WHERE is_disabled = TRUE;

-- 3. Setup automatic deletion after 90 days
SELECT cron.schedule('delete-disabled-accounts', '0 0 * * *', $$
  DELETE FROM auth.users
  WHERE id IN (
    SELECT id FROM public.profiles
    WHERE is_disabled = TRUE
    AND disabled_at < NOW() - INTERVAL '90 days'
  );
$$);
