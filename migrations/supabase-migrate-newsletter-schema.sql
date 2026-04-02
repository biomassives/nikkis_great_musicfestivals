-- ══════════════════════════════════════════════════════════════════════════════
--  Newsletter full schema migration
--  Safe to run on an existing DB — uses ADD COLUMN IF NOT EXISTS, CREATE IF NOT EXISTS.
--  Run AFTER supabase-migrate-newsletter-rls.sql if you haven't already.
-- ══════════════════════════════════════════════════════════════════════════════

-- ── 1. Extend newsletter_subscribers ─────────────────────────────────────────
--  The old schema only had id, email, created_at.
--  The subscribe/send/unsubscribe APIs all need these additional columns.

ALTER TABLE newsletter_subscribers
  ADD COLUMN IF NOT EXISTS name                  text,
  ADD COLUMN IF NOT EXISTS status                text NOT NULL DEFAULT 'active',
  ADD COLUMN IF NOT EXISTS unsubscribe_token     text UNIQUE,
  ADD COLUMN IF NOT EXISTS subscribed_newsletter boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS subscribed_cuteness   boolean NOT NULL DEFAULT false;

-- Back-fill token for any existing rows that were inserted before this migration
UPDATE newsletter_subscribers
  SET unsubscribe_token = gen_random_uuid()::text
  WHERE unsubscribe_token IS NULL;

-- Make token non-nullable now that all rows have one
ALTER TABLE newsletter_subscribers
  ALTER COLUMN unsubscribe_token SET NOT NULL;

-- ── 2. Extend newsletters ─────────────────────────────────────────────────────
--  Old schema: id, title, subject, body, sent_at, created_at
--  APIs also use: blocks (JSONB), status, recipient_count

ALTER TABLE newsletters
  ADD COLUMN IF NOT EXISTS blocks          jsonb,
  ADD COLUMN IF NOT EXISTS status          text NOT NULL DEFAULT 'draft',
  ADD COLUMN IF NOT EXISTS recipient_count int;

-- ── 3. email_templates table ──────────────────────────────────────────────────
--  Used by send-test, send, and send-cuteness APIs.
--  Template variables:
--    welcome  → {{name}}, {{email}}, {{unsubscribe_url}}
--    weekly   → {{name}}, {{subject}}, {{blocks_html}}, {{unsubscribe_url}}
--    cuteness → {{name}}, {{email}}, {{photo_url}}, {{caption}}, {{body_text}}, {{date}}, {{unsubscribe_url}}

CREATE TABLE IF NOT EXISTS email_templates (
  id         text PRIMARY KEY,   -- 'welcome' | 'weekly' | 'cuteness'
  subject    text NOT NULL,
  html_body  text NOT NULL,
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE email_templates ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies
    WHERE tablename = 'email_templates' AND policyname = 'Authenticated manage templates') THEN
    CREATE POLICY "Authenticated manage templates"
      ON email_templates FOR ALL TO authenticated
      USING (true) WITH CHECK (true);
  END IF;
END $$;

-- Seed the three templates (skips if already present)
INSERT INTO email_templates (id, subject, html_body) VALUES

('welcome',
 'Welcome to Nikki''s Great Music Festivals!',
$$<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
<body style="margin:0;padding:0;background:#f5f0ff;font-family:Georgia,serif">
  <table width="100%" cellpadding="0" cellspacing="0">
    <tr><td align="center" style="padding:32px 16px">
      <table width="600" cellpadding="0" cellspacing="0" style="background:#fff;border-radius:12px;overflow:hidden;max-width:600px">
        <tr><td style="background:linear-gradient(135deg,#1a0042,#7c4dff);padding:36px 40px;text-align:center">
          <h1 style="color:#fff;margin:0;font-size:26px;letter-spacing:1px">Nikki's Great Music Festivals</h1>
          <p style="color:#e0d0ff;margin:8px 0 0;font-size:14px">Tour maps · Live music · Community</p>
        </td></tr>
        <tr><td style="padding:36px 40px">
          <h2 style="color:#1a0042;font-size:22px;margin:0 0 16px">Hey {{name}} — you're in! 🎉</h2>
          <p style="color:#444;line-height:1.75;font-size:15px;margin:0 0 20px">
            Thanks for joining the adventure. You'll hear from us with show dates, trail stories,
            artist interviews, and the occasional adorable photo from the road.
          </p>
          <p style="color:#444;line-height:1.75;font-size:15px;margin:0 0 32px">
            — Nikki
          </p>
          <hr style="border:none;border-top:1px solid #ede8f7;margin:0 0 24px">
          <p style="color:#aaa;font-size:11px;text-align:center;margin:0">
            You're receiving this because {{email}} signed up at nikkisgreatmusicfestivals.com.<br>
            <a href="{{unsubscribe_url}}" style="color:#7c4dff">Unsubscribe</a>
          </p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>$$),

('weekly',
 'Nikki''s Great Music Festivals — Newsletter',
$$<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
<body style="margin:0;padding:0;background:#f5f0ff;font-family:Georgia,serif">
  <table width="100%" cellpadding="0" cellspacing="0">
    <tr><td align="center" style="padding:32px 16px">
      <table width="600" cellpadding="0" cellspacing="0" style="background:#fff;border-radius:12px;overflow:hidden;max-width:600px">
        <tr><td style="background:linear-gradient(135deg,#1a0042,#7c4dff);padding:36px 40px;text-align:center">
          <h1 style="color:#fff;margin:0;font-size:26px;letter-spacing:1px">Nikki's Great Music Festivals</h1>
          <p style="color:#e0d0ff;margin:8px 0 0;font-size:14px">{{subject}}</p>
        </td></tr>
        <tr><td style="padding:36px 40px">
          <p style="color:#555;font-size:14px;margin:0 0 28px">Hey {{name}},</p>
          {{blocks_html}}
          <hr style="border:none;border-top:1px solid #ede8f7;margin:32px 0 24px">
          <p style="color:#aaa;font-size:11px;text-align:center;margin:0">
            Nikki's Great Music Festivals · On the road somewhere beautiful<br>
            <a href="{{unsubscribe_url}}" style="color:#7c4dff">Unsubscribe</a>
          </p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>$$),

('cuteness',
 'Your Daily Cuteness 🐾',
$$<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
<body style="margin:0;padding:0;background:#fff5fb;font-family:Georgia,serif">
  <table width="100%" cellpadding="0" cellspacing="0">
    <tr><td align="center" style="padding:32px 16px">
      <table width="560" cellpadding="0" cellspacing="0" style="background:#fff;border-radius:16px;overflow:hidden;max-width:560px;box-shadow:0 2px 16px rgba(200,100,200,0.1)">
        <tr><td style="background:linear-gradient(135deg,#e040fb,#f48fb1);padding:28px 36px;text-align:center">
          <h1 style="color:#fff;margin:0;font-size:22px">Daily Cuteness 🐾</h1>
          <p style="color:rgba(255,255,255,0.85);margin:6px 0 0;font-size:13px">{{date}}</p>
        </td></tr>
        <tr><td style="padding:32px 36px;text-align:center">
          <img src="{{photo_url}}" alt="{{caption}}" style="max-width:100%;border-radius:12px;display:block;margin:0 auto 16px">
          <p style="color:#c2185b;font-weight:bold;font-size:16px;margin:0 0 12px">{{caption}}</p>
          <p style="color:#555;line-height:1.75;font-size:14px;margin:0 0 32px;text-align:left">{{body_text}}</p>
          <hr style="border:none;border-top:1px solid #fce4ec;margin:0 0 20px">
          <p style="color:#ccc;font-size:11px;margin:0">
            From Nikki's Great Music Festivals · <a href="{{unsubscribe_url}}" style="color:#e040fb">Unsubscribe</a>
          </p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>$$)

ON CONFLICT (id) DO NOTHING;

-- ── 4. cuteness_queue table ───────────────────────────────────────────────────
--  Used by send-cuteness API and the Daily Cuteness admin tab.

CREATE TABLE IF NOT EXISTS cuteness_queue (
  id             uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  scheduled_date date        NOT NULL UNIQUE,
  photo_url      text        NOT NULL,
  caption        text,
  body_text      text,
  subject        text        NOT NULL DEFAULT 'Your Daily Cuteness 🐾',
  status         text        NOT NULL DEFAULT 'staged',   -- staged | sent
  sent_at        timestamptz,
  created_at     timestamptz DEFAULT now()
);

ALTER TABLE cuteness_queue ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies
    WHERE tablename = 'cuteness_queue' AND policyname = 'Authenticated manage cuteness') THEN
    CREATE POLICY "Authenticated manage cuteness"
      ON cuteness_queue FOR ALL TO authenticated
      USING (true) WITH CHECK (true);
  END IF;
END $$;
