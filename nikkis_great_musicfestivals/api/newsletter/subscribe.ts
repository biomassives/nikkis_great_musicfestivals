import type { VercelRequest, VercelResponse } from '@vercel/node'
import { createClient } from '@supabase/supabase-js'
import { randomBytes } from 'crypto'

const supabase = createClient(
  process.env.VITE_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
)

const siteUrl = process.env.VITE_SITE_URL ?? ''

function setCorsHeaders(req: VercelRequest, res: VercelResponse) {
  const origin = String(req.headers.origin ?? '')
  const allowed =
    origin === siteUrl ||
    /^https?:\/\/localhost(:\d+)?$/.test(origin) ||
    /^https:\/\/[a-z0-9-]+\.vercel\.app$/.test(origin)
  res.setHeader('Access-Control-Allow-Origin', allowed ? origin : siteUrl || 'same-origin')
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS')
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type')
  res.setHeader('Vary', 'Origin')
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  setCorsHeaders(req, res)
  if (req.method === 'OPTIONS') return res.status(200).end()
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' })

  const { email, name, website, lists = ['newsletter'] } = (req.body ?? {}) as {
    email?:   string
    name?:    string
    website?: string    // honeypot — must be empty for real users
    lists?:   ('newsletter' | 'cuteness')[]
  }

  // Server-side honeypot check: if the field is populated it's a bot;
  // silently pretend success so the bot doesn't retry with a different strategy.
  if (website && website.trim()) {
    return res.status(200).json({ ok: true })
  }

  if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return res.status(400).json({ error: 'Invalid email address' })
  }

  // Look up existing subscriber
  const { data: existing } = await supabase
    .from('newsletter_subscribers')
    .select('email, status, unsubscribe_token')
    .eq('email', email)
    .limit(1)

  type Sub = { email: string; status: string; unsubscribe_token?: string }
  const sub = (existing as Sub[] | null)?.[0]

  // Already active — no duplicate welcome email, tell the frontend so it can
  // show an "already subscribed" confirmation rather than a generic success.
  if (sub?.status === 'active') {
    return res.status(409).json({ error: 'Already subscribed', alreadySubscribed: true })
  }

  // Cryptographically-random token (not Math.random)
  const token = sub?.unsubscribe_token ?? randomBytes(32).toString('hex')

  if (sub) {
    // Inactive / bounced / previously unsubscribed — reactivate
    const updates: Record<string, unknown> = { status: 'active' }
    if (name) updates.name = name
    if (lists.includes('newsletter')) updates.subscribed_newsletter = true
    if (lists.includes('cuteness'))   updates.subscribed_cuteness   = true
    await supabase.from('newsletter_subscribers').update(updates).eq('email', email)
  } else {
    await supabase.from('newsletter_subscribers').insert({
      email,
      name:                  name ?? null,
      status:                'active',
      unsubscribe_token:     token,
      subscribed_newsletter: lists.includes('newsletter'),
      subscribed_cuteness:   lists.includes('cuteness'),
    })
  }

  // Send welcome email if Mailgun is configured
  if (process.env.MAILGUN_API_KEY) {
    const { data: tmplRows } = await supabase
      .from('email_templates').select('subject, html_body').eq('id', 'welcome').limit(1)
    const tmpl = tmplRows?.[0] as { subject: string; html_body: string } | undefined
    if (tmpl?.html_body) {
      const unsubUrl = `${siteUrl}/api/newsletter/unsubscribe?token=${token}`
      const html = tmpl.html_body
        .replace(/\{\{name\}\}/g,            name ?? 'Friend')
        .replace(/\{\{email\}\}/g,           email)
        .replace(/\{\{unsubscribe_url\}\}/g, unsubUrl)
      await sendMail({ to: email, subject: tmpl.subject, html, ...(name ? { toName: name } : {}) })
    }
  }

  return res.status(200).json({ ok: true })
}

async function sendMail(opts: { to: string; toName?: string; subject: string; html: string }) {
  const domain  = process.env.MAILGUN_DOMAIN!
  const from    = process.env.MAILGUN_FROM ?? `Nikki's Great Music Festivals <hello@${domain}>`
  const replyTo = process.env.MAILGUN_REPLY_TO
  const toAddr  = opts.toName ? `${opts.toName} <${opts.to}>` : opts.to
  const body    = new URLSearchParams({ from, to: toAddr, subject: opts.subject, html: opts.html })
  if (replyTo) body.set('h:Reply-To', replyTo)
  const key = Buffer.from(`api:${process.env.MAILGUN_API_KEY}`).toString('base64')
  await fetch(`https://api.mailgun.net/v3/${domain}/messages`, {
    method:  'POST',
    headers: { Authorization: `Basic ${key}`, 'Content-Type': 'application/x-www-form-urlencoded' },
    body:    body.toString(),
  })
}
