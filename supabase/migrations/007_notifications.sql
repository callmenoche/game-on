-- ── Notifications table ──────────────────────────────────────────────────────

CREATE TABLE notifications (
  id         UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type       TEXT        NOT NULL,   -- 'match_joined' | 'match_confirmed' | 'match_cancelled'
  match_id   UUID        REFERENCES matches(id) ON DELETE CASCADE,
  actor_id   UUID        REFERENCES auth.users(id) ON DELETE SET NULL,
  body       TEXT        NOT NULL,
  read_at    TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Users can only read their own notifications
CREATE POLICY "notif_read_own" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

-- Users can mark their own as read
CREATE POLICY "notif_update_own" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;

-- ── Trigger: notify creator when a real user joins their match ───────────────

CREATE OR REPLACE FUNCTION fn_notify_on_join()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_creator UUID;
BEGIN
  SELECT creator_id INTO v_creator FROM matches WHERE id = NEW.match_id;
  -- Only notify for real users (not guests) who are not the creator
  IF NEW.user_id IS NOT NULL AND NEW.user_id != v_creator THEN
    INSERT INTO notifications (user_id, type, match_id, actor_id, body)
    VALUES (v_creator, 'match_joined', NEW.match_id, NEW.user_id,
            'Someone joined your match!');
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_notify_on_join
  AFTER INSERT ON match_participants
  FOR EACH ROW EXECUTE FUNCTION fn_notify_on_join();

-- ── Trigger: notify all participants when match is confirmed ─────────────────

CREATE OR REPLACE FUNCTION fn_notify_on_confirm()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF OLD.confirmed_at IS NULL AND NEW.confirmed_at IS NOT NULL THEN
    INSERT INTO notifications (user_id, type, match_id, actor_id, body)
    SELECT mp.user_id,
           'match_confirmed',
           NEW.id,
           NEW.creator_id,
           'Your match has been confirmed! See you there 🎉'
    FROM match_participants mp
    WHERE mp.match_id = NEW.id
      AND mp.user_id IS NOT NULL
      AND mp.user_id != NEW.creator_id;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_notify_on_confirm
  AFTER UPDATE ON matches
  FOR EACH ROW EXECUTE FUNCTION fn_notify_on_confirm();

-- ── Trigger: notify participants when match is cancelled ─────────────────────

CREATE OR REPLACE FUNCTION fn_notify_on_cancel()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF OLD.status != 'cancelled' AND NEW.status = 'cancelled' THEN
    INSERT INTO notifications (user_id, type, match_id, actor_id, body)
    SELECT mp.user_id,
           'match_cancelled',
           NEW.id,
           NEW.creator_id,
           'A match you joined has been cancelled.'
    FROM match_participants mp
    WHERE mp.match_id = NEW.id
      AND mp.user_id IS NOT NULL
      AND mp.user_id != NEW.creator_id;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_notify_on_cancel
  AFTER UPDATE ON matches
  FOR EACH ROW EXECUTE FUNCTION fn_notify_on_cancel();
