-- ============================================================
-- 009_fix_handle_new_user.sql
-- Fixes constraint violations for long usernames and 
-- improves Google avatar extraction (picture metadata).
-- ============================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  _username TEXT;
  _display_name TEXT;
BEGIN
  -- 1. Try to get username from metadata (passed during Email Sign-Up)
  _username := NEW.raw_user_meta_data->>'username';
  
  -- 2. Fallback to extracting from email if metadata username is missing
  IF _username IS NULL OR _username = '' THEN
    _username := lower(regexp_replace(split_part(NEW.email, '@', 1), '[^a-z0-9_]', '', 'g'));
  END IF;

  -- Truncate to 15 chars to leave room for random suffix if needed (max 20)
  IF length(_username) > 15 THEN
    _username := substring(_username, 1, 15);
  END IF;

  -- 3. Safety fallback for very short or empty usernames
  IF _username IS NULL OR length(_username) < 3 THEN 
    _username := 'user_' || substring(NEW.id::text, 1, 6); 
  END IF;

  -- 4. Ensure uniqueness by appending random suffix if taken
  WHILE EXISTS(SELECT 1 FROM public.profiles WHERE username = _username) LOOP
    -- If we are at the limit, truncate more to fit the suffix
    IF length(_username) > 17 THEN
      _username := substring(_username, 1, 17);
    END IF;
    _username := _username || floor(random() * 100)::text;
  END LOOP;

  -- 5. Set display_name equal to the final unique username
  _display_name := _username;

  INSERT INTO public.profiles (id, username, display_name, avatar_url)
  VALUES (
    NEW.id, 
    _username, 
    _display_name,
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', NEW.raw_user_meta_data->>'picture')
  )
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.wallets (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
