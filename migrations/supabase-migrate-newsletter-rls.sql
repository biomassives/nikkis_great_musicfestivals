-- ── Newsletter subscribers: tighten RLS ──────────────────────────────────────
--
-- All subscriber signups now go through the Vercel API function
-- (api/newsletter/subscribe.ts) which uses the service-role key and handles
-- honeypot filtering, deduplication, and welcome emails server-side.
--
-- The old "public anon insert" policy allowed the browser to write directly to
-- the table, bypassing all of that logic.  Remove it.
--
-- Run in Supabase SQL Editor → New Query.

-- 1. Drop any existing public-insert policy (name may vary; both common names
--    are dropped below; the IF EXISTS prevents errors if already removed).
DROP POLICY IF EXISTS "Public insert newsletter"      ON newsletter_subscribers;
DROP POLICY IF EXISTS "Allow public subscribe insert" ON newsletter_subscribers;
DROP POLICY IF EXISTS "Allow anon insert"             ON newsletter_subscribers;

-- 2. Ensure authenticated users (admin) retain full access.
--    These are likely already in place, but are re-stated here for clarity.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'newsletter_subscribers'
      AND policyname = 'Authenticated full access'
  ) THEN
    CREATE POLICY "Authenticated full access"
      ON newsletter_subscribers
      FOR ALL
      TO authenticated
      USING (true)
      WITH CHECK (true);
  END IF;
END $$;

-- 3. Confirm RLS is enabled on the table (should already be, but just in case).
ALTER TABLE newsletter_subscribers ENABLE ROW LEVEL SECURITY;
