-- ── Community Board ──────────────────────────────────────────────────────────
-- Public, anonymous posting with upvote scoring.
-- No user IDs stored. Upvote spam prevention is client-side (localStorage).
-- Run in Supabase SQL editor.

-- Posts table
CREATE TABLE IF NOT EXISTS board_posts (
  id           uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  category     text        NOT NULL DEFAULT 'general'
                           CHECK (category IN ('general','shows','trails','tips')),
  display_name text        NOT NULL DEFAULT 'Community Member'
                           CHECK (length(trim(display_name)) > 0 AND length(display_name) <= 40),
  message      text        NOT NULL
                           CHECK (length(trim(message)) > 0 AND length(message) <= 500),
  score        integer     NOT NULL DEFAULT 0,
  created_at   timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS board_posts_created_at_idx ON board_posts (created_at DESC);
CREATE INDEX IF NOT EXISTS board_posts_score_idx      ON board_posts (score DESC);
CREATE INDEX IF NOT EXISTS board_posts_category_idx   ON board_posts (category);

-- RLS: public read + insert; no direct update (score modified via RPC only)
ALTER TABLE board_posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "board_posts public read"
  ON board_posts FOR SELECT USING (true);

CREATE POLICY "board_posts public insert"
  ON board_posts FOR INSERT
  WITH CHECK (
    length(trim(message)) > 0 AND length(message) <= 500
  );

-- Upvote RPC — SECURITY DEFINER so anon role can increment score without
-- needing an UPDATE policy on the table (prevents arbitrary column changes).
CREATE OR REPLACE FUNCTION public.upvote_board_post(post_id uuid)
RETURNS void
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  UPDATE board_posts SET score = score + 1 WHERE id = post_id;
$$;

-- Grant execute to anonymous and authenticated callers
GRANT EXECUTE ON FUNCTION public.upvote_board_post(uuid) TO anon, authenticated;

-- Optional: prune posts older than 90 days (run manually or via pg_cron)
-- DELETE FROM board_posts WHERE created_at < now() - interval '90 days';
