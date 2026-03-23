# Nikki's Great Music Festivals — Security & Maintenance Guide

A plain-language reference for keeping the site healthy, secure, and easy to update over time.

---

## How the Site Works (Big Picture)

```
Browser (Vue/Quasar SPA)
    │
    ├── Supabase (database + file storage + auth)
    │       Public data:  read by anyone (RLS open-read policies)
    │       Admin data:   written via anon key + admin secret guard
    │
    ├── Vercel (hosting + serverless API functions)
    │       /api/newsletter/*   — email sending, subscribe, unsubscribe
    │       /api/stripe-*       — payment processing
    │
    ├── Mailgun  (transactional email delivery)
    └── Stripe   (payments / support tiers)
```

The site has **no traditional login for visitors**. Nikki's admin area uses a simple password stored in `VITE_ADMIN_PASSWORD` — not Supabase Auth. This keeps things simple but means extra care with that password.

---

## Environment Variables

All secrets live in **Vercel → Project → Settings → Environment Variables**. Never commit them to git.

| Variable | What it is | Rotate if... |
|---|---|---|
| `VITE_SUPABASE_URL` | Public Supabase project URL | Project is deleted/recreated |
| `VITE_SUPABASE_ANON_KEY` | Public anon key (safe to expose in browser) | Suspected compromise |
| `SUPABASE_SERVICE_ROLE_KEY` | Full DB access — **keep secret** | Suspected compromise |
| `VITE_ADMIN_PASSWORD` | Admin area login | Shared with someone who should no longer have access |
| `ADMIN_SECRET` | Protects newsletter send endpoints | Suspected compromise |
| `VITE_ADMIN_SECRET` | Same value as above, used by browser | Rotate together |
| `VITE_SITE_URL` | Full site URL | Domain changes |
| `MAILGUN_API_KEY` | Mailgun sending key | Suspected compromise / Mailgun rotation |
| `MAILGUN_DOMAIN` | Sending domain (e.g. mg.yourdomain.com) | Domain changes |
| `MAILGUN_FROM` | From address shown in emails | Branding changes |
| `STRIPE_SECRET_KEY` | Stripe payments — **keep secret** | Suspected compromise |
| `STRIPE_WEBHOOK_SECRET` | Validates Stripe webhook calls | Webhook endpoint recreated |
| `VITE_STRIPE_PUBLISHABLE_KEY` | Public Stripe key (safe in browser) | Suspected compromise |

**How to rotate a secret:**
1. Generate a new value
2. Update it in Vercel Environment Variables
3. Redeploy (Vercel → Deployments → Redeploy latest)
4. Update `VITE_ADMIN_SECRET` and `ADMIN_SECRET` together — they must always match

---

## Supabase Row Level Security (RLS)

Supabase RLS policies control who can read or write each database table. Since the site uses the public anon key (no user login), most policies are intentionally open. Here is the current setup and what it means:

| Table | Read | Write | Notes |
|---|---|---|---|
| `news_articles` | Anyone | Anyone (anon) | Admin guards via UI password only |
| `map_points` | Anyone | Anyone (anon) | Same |
| `gallery_photos` | Anyone | Anyone (anon) | Same |
| `custom_pages` | Anyone | Anyone (anon) | Same |
| `merch_items` | Anyone | Anyone (anon) | Same |
| `newsletter_subscribers` | Anyone | Anyone (anon) | Subscribe/unsubscribe is intentional |
| `newsletters` | Anyone | Anyone (anon) | Draft edits via admin UI |
| `email_templates` | Anyone | Anyone (anon) | Edit via admin Templates tab |
| `cuteness_queue` | Anyone | Anyone (anon) | Stage via admin Cuteness tab |
| `site_settings` | Anyone | Anyone (anon) | Config values |

**What this means:** The database is protected by obscurity (the admin password) and the fact that the anon key is read-only for most use cases. This is fine for a personal/small-team site but means:

- Keep the `VITE_ADMIN_PASSWORD` strong and private
- Newsletter send endpoints (`/api/newsletter/send`, `/api/newsletter/send-cuteness`) require the `ADMIN_SECRET` header — these are the only server-side-protected write operations
- If you ever want stronger protection, Supabase Auth can be added later — the RLS policies would just change from `USING (true)` to `USING (auth.role() = 'authenticated')`

---

## Email System

### How emails are sent
All email goes through **Mailgun** via the serverless functions in `api/newsletter/`. The flow:

```
Admin clicks "Send"
  → Browser calls POST /api/newsletter/send  (with ADMIN_SECRET header)
    → Vercel function fetches newsletter + subscribers from Supabase
      → Loops through subscribers, calls Mailgun API per subscriber
        → Updates newsletter status to "sent" in Supabase
```

### Daily Cuteness
Nikki stages photos in the admin (Daily Cuteness tab) for future dates. Each day's email must be manually sent from the admin, or you can set up an automatic send — see "Vercel Cron" below.

### Email templates
Templates are stored in the `email_templates` Supabase table. Edit them any time from the **Newsletter → Templates tab** in admin. The variables that get replaced:

| Variable | Used in |
|---|---|
| `{{name}}` | All emails (subscriber's first name, or "Friend") |
| `{{email}}` | Welcome email |
| `{{unsubscribe_url}}` | All emails (required — always keep this) |
| `{{blocks_html}}` | Weekly digest |
| `{{subject}}` | Weekly digest header |
| `{{photo_url}}` | Daily Cuteness |
| `{{caption}}` | Daily Cuteness |
| `{{body_text}}` | Daily Cuteness |
| `{{date}}` | Daily Cuteness |

### Unsubscribes
When someone clicks Unsubscribe in an email, they hit `/api/newsletter/unsubscribe?token=xxx` which sets their status to `unsubscribed` in Supabase. They will never be emailed again unless they re-subscribe. You can see and manage all subscribers in the **Subscribers tab**.

---

## Vercel Cron (Optional — Auto Daily Cuteness)

To send the Daily Cuteness email automatically at a set time each day without manual intervention, add a cron job to `vercel.json`:

```json
"crons": [
  {
    "path": "/api/newsletter/send-cuteness",
    "schedule": "0 9 * * *"
  }
]
```

`0 9 * * *` means 9:00 AM UTC every day. Adjust to suit (UTC+0 — account for your timezone offset).

**Important:** The cron request won't have the `x-admin-secret` header, so you'd need to either:
- Add a check for the Vercel cron `Authorization` header (`Bearer` token Vercel sends automatically), or
- Accept the cron path without a secret (since it can only be triggered by Vercel's infrastructure)

Ask your developer to wire this up when you're ready.

---

## Stripe Payments

Stripe handles all payment processing. The site never sees or stores card numbers. Key things to know:

- **Webhook**: Stripe sends events to `/api/stripe-webhook` to confirm payments. If this stops working, check the Stripe Dashboard → Webhooks → recent deliveries for error details.
- **Test vs Live mode**: Stripe has separate test and live API keys. Make sure Vercel is using **live keys** in Production and **test keys** in Preview/dev environments.
- **Refunds**: Done directly in the Stripe Dashboard — the site has no refund UI.

---

## Regular Maintenance Checklist

### Monthly
- [ ] Check Mailgun sending stats — bounces and complaints above ~2% can hurt deliverability
- [ ] Review newsletter subscriber list for obvious spam signups
- [ ] Check Vercel deployment logs for any API errors (Vercel → Deployments → Functions tab)
- [ ] Make sure staged Daily Cuteness entries exist for upcoming weeks

### Every few months
- [ ] Log into Supabase and check database size (free tier limit: 500 MB)
- [ ] Check Vercel bandwidth usage (free tier limit: 100 GB/month)
- [ ] Review gallery storage in Supabase Storage (free tier limit: 1 GB)
- [ ] Update npm packages: `npm update` then `npm audit` to catch security issues

### Annually
- [ ] Rotate `ADMIN_SECRET` / `VITE_ADMIN_SECRET` as a precaution
- [ ] Review who has access to Vercel, Supabase, Mailgun, and Stripe accounts
- [ ] Renew domain / SSL if not on auto-renew (Vercel handles SSL automatically)

---

## If Something Breaks

### Site is down / shows errors
1. Check Vercel → Deployments — did the last deploy succeed?
2. Check Vercel → Functions logs for server errors
3. Check Supabase → Project → Reports for database issues

### Emails aren't sending
1. Check Mailgun Dashboard → Logs — is there an error on recent sends?
2. Verify `MAILGUN_API_KEY` and `MAILGUN_DOMAIN` are correct in Vercel env vars
3. Check that `ADMIN_SECRET` and `VITE_ADMIN_SECRET` match exactly

### Subscribers aren't being added
1. Check browser console for errors when submitting the subscribe form
2. Verify the `newsletter_subscribers` table RLS policy allows inserts
3. Check the Supabase SQL Editor: `SELECT * FROM newsletter_subscribers ORDER BY created_at DESC LIMIT 10`

### Admin area won't load / save
1. Check that `VITE_ADMIN_PASSWORD` is set correctly in Vercel env vars
2. Check browser console for Supabase errors (usually a mis-matched anon key or RLS denial)

---

## Backups

Supabase provides automatic daily backups on paid plans. On the free tier, backups are not automatic — recommended steps:

1. **Periodically export subscribers**: Admin → Subscribers tab → Export CSV. Keep a copy in a safe place.
2. **Schema backup**: The file `supabase-schema.sql` in the project root contains the original schema. Keep it updated when you add new tables.
3. **Photos**: Gallery photos are stored in Supabase Storage. Download a copy to local storage occasionally.

---

## Contacts & Accounts

Keep this list somewhere safe (not in this file — this file is in the git repo):

- **Vercel** account login
- **Supabase** project URL + service role key
- **Mailgun** account + API key + sending domain
- **Stripe** account + dashboard access
- **Domain registrar** login (for DNS management)
- **Developer contact** for technical issues

---

*Last updated: March 2026*
