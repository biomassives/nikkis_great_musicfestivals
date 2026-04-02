import type { VercelRequest, VercelResponse } from '@vercel/node'
import { createClient } from '@supabase/supabase-js'
import { requireAdminAuth } from '../_auth'

const supabase = createClient(
  process.env.VITE_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
)

interface CutenessEntry {
  id:             string
  scheduled_date: string
  photo_url:      string
  caption:        string | null
  body_text:      string | null
  subject:        string
  status:         string
}

interface Subscriber {
  email:             string
  name:              string | null
  unsubscribe_token: string
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' })
  if (!await requireAdminAuth(req, res)) return

  const { date = new Date().toISOString().slice(0, 10) } = (req.body ?? {}) as { date?: string }

  // Fetch queued entry for this date
  const { data: entries } = await supabase
    .from('cuteness_queue')
    .select('*')
    .eq('scheduled_date', date)
    .limit(1)
  const entry = entries?.[0] as CutenessEntry | undefined
  if (!entry) return res.status(404).json({ error: `No cuteness entry staged for ${date}` })
  if (entry.status === 'sent') return res.status(409).json({ error: 'Already sent for this date' })

  // Fetch cuteness email template
  const { data: tmplRows } = await supabase
    .from('email_templates').select('subject, html_body').eq('id', 'cuteness').limit(1)
  const tmpl = tmplRows?.[0] as { subject: string; html_body: string } | undefined
  if (!tmpl) return res.status(500).json({ error: 'Cuteness email template not found — run setup SQL' })

  // Fetch cuteness subscribers
  const { data: subsData } = await supabase
    .from('newsletter_subscribers')
    .select('email, name, unsubscribe_token')
    .eq('status', 'active')
    .eq('subscribed_cuteness', true)
  const subs = (subsData ?? []) as Subscriber[]

  const siteUrl = process.env.VITE_SITE_URL ?? `https://${String(req.headers.host ?? '')}`
  const subject = entry.subject || tmpl.subject
  let sent = 0

  for (const sub of subs) {
    const unsubUrl = `${siteUrl}/api/newsletter/unsubscribe?token=${sub.unsubscribe_token}`
    const html = tmpl.html_body
      .replace(/\{\{name\}\}/g,            sub.name ?? 'Friend')
      .replace(/\{\{email\}\}/g,           sub.email)
      .replace(/\{\{unsubscribe_url\}\}/g, unsubUrl)
      .replace(/\{\{photo_url\}\}/g,       entry.photo_url)
      .replace(/\{\{caption\}\}/g,         entry.caption ?? '')
      .replace(/\{\{body_text\}\}/g,       (entry.body_text ?? '').replace(/\n/g, '<br>'))
      .replace(/\{\{date\}\}/g,            new Date(entry.scheduled_date + 'T12:00:00').toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' }))
    try {
      await sendMail({ to: sub.email, toName: sub.name, subject, html })
      sent++
    } catch { /* continue */ }
  }

  await supabase.from('cuteness_queue').update({
    status:  'sent',
    sent_at: new Date().toISOString(),
  }).eq('id', entry.id)

  return res.status(200).json({ ok: true, sent, date })
}

async function sendMail(opts: { to: string; toName: string | null; subject: string; html: string }) {
  const domain  = process.env.MAILGUN_DOMAIN!
  const from    = process.env.MAILGUN_FROM ?? `Nikki's Great Music Festivals <hello@${domain}>`
  const replyTo = process.env.MAILGUN_REPLY_TO
  const toAddr  = opts.toName ? `${opts.toName} <${opts.to}>` : opts.to
  const body    = new URLSearchParams({ from, to: toAddr, subject: opts.subject, html: opts.html })
  if (replyTo) body.set('h:Reply-To', replyTo)
  const key  = Buffer.from(`api:${process.env.MAILGUN_API_KEY}`).toString('base64')
  const host = process.env.MAILGUN_REGION === 'eu' ? 'api.eu.mailgun.net' : 'api.mailgun.net'
  const r    = await fetch(`https://${host}/v3/${domain}/messages`, {
    method:  'POST',
    headers: { Authorization: `Basic ${key}`, 'Content-Type': 'application/x-www-form-urlencoded' },
    body:    body.toString(),
  })
  if (!r.ok) throw new Error(await r.text())
}
