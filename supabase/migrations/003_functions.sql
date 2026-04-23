-- ============================================================
-- 003_functions.sql  —  DB Helper Functions & Triggers
-- ============================================================

-- ── Auto-create profile + wallet on signup ───────────────────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  _username TEXT;
BEGIN
  -- Extract a sanitised username from email
  _username := lower(regexp_replace(split_part(NEW.email, '@', 1), '[^a-z0-9_]', '', 'g'));
  IF length(_username) < 3 THEN _username := 'user_' || substring(NEW.id::text, 1, 6); END IF;
  -- Ensure uniqueness by appending random suffix if taken
  WHILE EXISTS(SELECT 1 FROM public.profiles WHERE username = _username) LOOP
    _username := _username || floor(random() * 1000)::text;
  END LOOP;

  INSERT INTO public.profiles (id, username)
  VALUES (NEW.id, _username)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.wallets (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop and re-create trigger to avoid duplicates
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ── Increment submission count on new submission ─────────────
CREATE OR REPLACE FUNCTION public.increment_submission_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.dares
  SET submission_count = submission_count + 1,
      updated_at = NOW()
  WHERE id = NEW.dare_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_dare_submission_insert ON public.dare_submissions;
CREATE TRIGGER on_dare_submission_insert
  AFTER INSERT ON public.dare_submissions
  FOR EACH ROW EXECUTE FUNCTION public.increment_submission_count();

-- ── Update profile stats on dare completion ──────────────────
CREATE OR REPLACE FUNCTION public.update_dare_stats()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    -- Increment poster's total_dares_posted
    UPDATE public.profiles SET total_dares_posted = total_dares_posted + 1 WHERE id = NEW.poster_id;
    -- Increment performer's total_dares_completed if known
    IF NEW.winner_performer_id IS NOT NULL THEN
      UPDATE public.profiles
      SET total_dares_completed = total_dares_completed + 1
      WHERE id = NEW.winner_performer_id;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_dare_status_update ON public.dares;
CREATE TRIGGER on_dare_status_update
  AFTER UPDATE ON public.dares
  FOR EACH ROW EXECUTE FUNCTION public.update_dare_stats();

-- ── Send in-app notification helper ──────────────────────────
CREATE OR REPLACE FUNCTION public.send_notification(
  _user_id UUID,
  _type TEXT,
  _title TEXT,
  _body TEXT,
  _dare_id UUID DEFAULT NULL
)
RETURNS void AS $$
BEGIN
  INSERT INTO public.notifications (user_id, type, title, body, dare_id)
  VALUES (_user_id, _type, _title, _body, _dare_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── Get dare with submission count (performance helper) ────────
CREATE OR REPLACE FUNCTION public.get_dare_feed(
  p_limit INT DEFAULT 20,
  p_offset INT DEFAULT 0,
  p_category TEXT DEFAULT NULL,
  p_mode TEXT DEFAULT NULL,
  p_status TEXT DEFAULT 'open'
)
RETURNS SETOF public.dares AS $$
BEGIN
  RETURN QUERY
  SELECT d.*
  FROM public.dares d
  WHERE
    (p_category IS NULL OR d.category = p_category) AND
    (p_mode IS NULL OR d.dare_mode = p_mode) AND
    (p_status IS NULL OR d.status = p_status)
  ORDER BY d.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql STABLE;
