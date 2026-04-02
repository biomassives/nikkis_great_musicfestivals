-- ─────────────────────────────────────────────────────────────────────────────
-- Show social features: stars, boosts, and fan board comments
-- Run in Supabase SQL Editor → Dashboard → SQL Editor → New query
-- ─────────────────────────────────────────────────────────────────────────────

-- Stars — one per browser (enforced client-side via localStorage)
CREATE TABLE IF NOT EXISTS show_stars (
  id         uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  show_id    text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Boosts — cheer/upvote count
CREATE TABLE IF NOT EXISTS show_boosts (
  id         uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  show_id    text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Fan board comments
CREATE TABLE IF NOT EXISTS show_comments (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  show_id     text NOT NULL,
  author_name text NOT NULL DEFAULT 'Anonymous',
  message     text NOT NULL,
  created_at  timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS show_stars_show_id    ON show_stars    (show_id);
CREATE INDEX IF NOT EXISTS show_boosts_show_id   ON show_boosts   (show_id);
CREATE INDEX IF NOT EXISTS show_comments_show_id ON show_comments (show_id);
CREATE INDEX IF NOT EXISTS show_comments_created ON show_comments (created_at);

-- RLS: public read + insert, no update/delete from client
ALTER TABLE show_stars    ENABLE ROW LEVEL SECURITY;
ALTER TABLE show_boosts   ENABLE ROW LEVEL SECURITY;
ALTER TABLE show_comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public read stars"      ON show_stars    FOR SELECT USING (true);
CREATE POLICY "public insert stars"    ON show_stars    FOR INSERT WITH CHECK (true);
CREATE POLICY "public read boosts"     ON show_boosts   FOR SELECT USING (true);
CREATE POLICY "public insert boosts"   ON show_boosts   FOR INSERT WITH CHECK (true);
CREATE POLICY "public read comments"   ON show_comments FOR SELECT USING (true);
CREATE POLICY "public insert comments" ON show_comments FOR INSERT WITH CHECK (
  length(trim(message)) > 0 AND length(message) <= 500
);
