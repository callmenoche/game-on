-- Match title & description
ALTER TABLE matches
  ADD COLUMN title text,
  ADD COLUMN description text;

-- Onboarding flag: default true = existing users skip onboarding
ALTER TABLE profiles
  ADD COLUMN onboarded boolean NOT NULL DEFAULT true;

-- New users created by the trigger start as NOT onboarded
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, onboarded)
  VALUES (
    NEW.id,
    'user_' || substring(NEW.id::text, 1, 8),
    false
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;
