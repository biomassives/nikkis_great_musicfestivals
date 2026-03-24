import type { VercelRequest, VercelResponse } from '@vercel/node'
import { createClient } from '@supabase/supabase-js'
import { getAdminUser } from '../_auth'

const supabase = createClient(
  process.env.VITE_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
)

interface Block {
  type:       'intro' | 'news' | 'shows' | 'spotlight' | 'html'
  title?:     string
  body?:      string
  heading?:   string
  count?:     number
  text?:      string
  image_url?: string
  content?:   string
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  res.setHeader('Access-Control-Allow-Origin', '*')
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS')
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization')
  if (req.method === 'OPTIONS') return res.status(200).end()
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' })

  const user = await getAdminUser(req, res)
  if (!user) return

  const adminEmail = user.email
  if (!adminEmail) return res.status(400).json({ error: 'Admin account has no email' })

  const { newsletter_id } = (req.body ?? {}) as { newsletter_id?: string }
  if (!newsletter_id) return res.status(400).json({ error: 'newsletter_id required' })

  // Fetch the newsletter
  const { data: nlRows } = await supabase
    .from('newsletters').select('*').eq('id', newsletter_id).limit(1)
  const nl = nlRows?.[0] as Record<string, unknown> | undefined
  if (!nl) return res.status(404).json({ error: 'Newsletter not found' })

  // Fetch weekly base template
  const { data: tmplRows } = await supabase
    .from('email_templates').select('subject, html_body').eq('id', 'weekly').limit(1)
  const tmpl = tmplRows?.[0] as { subject: string; html_body: string } | undefined
  if (!tmpl) return res.status(500).json({ error: 'Weekly template not found — run setup SQL' })

  const blocks     = (nl['blocks'] as Block[] | null) ?? []
  const blocksHtml = await renderBlocks(blocks)
  const siteUrl    = process.env.VITE_SITE_URL ?? `https://${String(req.headers.host ?? '')}`
  const subject    = `[TEST] ${String(nl['subject'] ?? tmpl.subject)}`

  const html = tmpl.html_body
    .replace(/\{\{name\}\}/g,            user.user_metadata?.['full_name'] ?? 'Admin')
    .replace(/\{\{subject\}\}/g,         subject)
    .replace(/\{\{blocks_html\}\}/g,     blocksHtml)
    .replace(/\{\{unsubscribe_url\}\}/g, `${siteUrl}/admin`)  // no real unsub for test

  if (!process.env.MAILGUN_API_KEY) {
    return res.status(200).json({ ok: true, to: adminEmail, mailgun: false,
      message: 'MAILGUN_API_KEY not configured — email not sent' })
  }

  await sendMail({ to: adminEmail, subject, html })
  return res.status(200).json({ ok: true, to: adminEmail })
}

async function renderBlocks(blocks: Block[]): Promise<string> {
  const parts: string[] = []
  for (const b of blocks) {
    switch (b.type) {
      case 'intro':
        parts.push(`
          <h2 style="color:#1a0042;font-size:22px;margin:0 0 12px">${b.title ?? ''}</h2>
          <p style="color:#444;line-height:1.75;font-size:15px;margin:0 0 28px">
            ${(b.body ?? '').replace(/\n/g, '<br>')}
          </p>`)
        break
      case 'news': {
        const { data: articles } = await supabase
          .from('news_articles').select('title, date, body')
          .eq('published', true).order('created_at', { ascending: false }).limit(b.count ?? 3)
        if (articles?.length) {
          const rows = (articles as { title: string; date: string | null; body: string | null }[])
            .map(a => `<li style="margin-bottom:10px">
              <strong style="color:#1a0042">${a.title}</strong>
              ${a.date ? `<span style="color:#888;font-size:12px"> — ${a.date}</span>` : ''}
              ${a.body ? `<p style="color:#555;font-size:13px;margin:4px 0 0">${a.body.slice(0, 160)}…</p>` : ''}
            </li>`).join('')
          parts.push(`<h3 style="color:#1a0042;border-bottom:2px solid #7c4dff;padding-bottom:8px;margin:0 0 16px">
            ${b.heading ?? 'Latest News'}</h3>
            <ul style="padding-left:20px;margin:0 0 28px;color:#333">${rows}</ul>`)
        }
        break
      }
      case 'shows': {
        const today = new Date().toISOString().slice(0, 10)
        const { data: shows } = await supabase
          .from('map_points').select('name, date, description')
          .eq('category', 'show').gte('date', today).order('date').limit(6)
        if (shows?.length) {
          const rows = (shows as { name: string; date: string | null; description: string | null }[])
            .map(s => `<tr>
              <td style="padding:8px 12px 8px 0;color:#1a0042;font-weight:600">${s.name}</td>
              <td style="padding:8px 12px 8px 0;color:#7c4dff;font-size:13px">${s.date ?? ''}</td>
              <td style="padding:8px 0;color:#555;font-size:13px">${s.description ?? ''}</td>
            </tr>`).join('')
          parts.push(`<h3 style="color:#1a0042;border-bottom:2px solid #e040fb;padding-bottom:8px;margin:0 0 16px">
            ${b.heading ?? 'Upcoming Shows'}</h3>
            <table style="width:100%;border-collapse:collapse;margin:0 0 28px">${rows}</table>`)
        }
        break
      }
      case 'spotlight':
        parts.push(`
          <h3 style="color:#1a0042;border-bottom:2px solid #ffd700;padding-bottom:8px;margin:0 0 12px">
            ${b.heading ?? ''}</h3>
          ${b.image_url ? `<img src="${b.image_url}" alt="" style="max-width:100%;border-radius:8px;display:block;margin:0 0 12px">` : ''}
          <p style="color:#444;line-height:1.75;font-size:15px;margin:0 0 28px">
            ${(b.text ?? '').replace(/\n/g, '<br>')}
          </p>`)
        break
      case 'html':
        parts.push(b.content ?? '')
        break
    }
  }
  return parts.join('\n')
}

async function sendMail(opts: { to: string; subject: string; html: string }) {
  const domain = process.env.MAILGUN_DOMAIN!
  const from   = process.env.MAILGUN_FROM ?? `Nikki's Great Music Festivals <hello@${domain}>`
  const body   = new URLSearchParams({ from, to: opts.to, subject: opts.subject, html: opts.html })
  const key    = Buffer.from(`api:${process.env.MAILGUN_API_KEY}`).toString('base64')
  const r      = await fetch(`https://api.mailgun.net/v3/${domain}/messages`, {
    method:  'POST',
    headers: { Authorization: `Basic ${key}`, 'Content-Type': 'application/x-www-form-urlencoded' },
    body:    body.toString(),
  })
  if (!r.ok) throw new Error(await r.text())
}
