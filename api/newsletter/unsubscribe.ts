import type { VercelRequest, VercelResponse } from '@vercel/node'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.VITE_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
)

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method !== 'GET') return res.status(405).end()

  const token = String(req.query['token'] ?? '')
  let success = false

  if (token) {
    const { data } = await supabase
      .from('newsletter_subscribers')
      .update({ status: 'unsubscribed' })
      .eq('unsubscribe_token', token)
      .select('email')
    success = (data?.length ?? 0) > 0
  }

  res.setHeader('Content-Type', 'text/html; charset=utf-8')
  res.status(200).end(success ? UNSUBSCRIBED_PAGE : ERROR_PAGE)
}

const UNSUBSCRIBED_PAGE = `<!DOCTYPE html><html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Unsubscribed — Nikki's Great Music Festivals</title>
<style>
  body{margin:0;background:#f5f0ff;font-family:Arial,sans-serif;display:flex;align-items:center;justify-content:center;min-height:100vh}
  .card{background:#fff;border-radius:16px;padding:48px 40px;max-width:480px;width:90%;text-align:center;box-shadow:0 8px 40px rgba(124,77,255,.12)}
  .emoji{font-size:56px;margin-bottom:16px}
  h1{color:#1a0042;font-size:26px;margin:0 0 12px}
  p{color:#555;line-height:1.7;margin:0 0 24px}
  a{display:inline-block;background:#7c4dff;color:#fff;padding:12px 28px;border-radius:8px;text-decoration:none;font-weight:bold}
</style></head>
<body><div class="card">
  <div class="emoji">👋</div>
  <h1>You've been unsubscribed</h1>
  <p>We're sorry to see you go! You won't receive any more emails from us. If you change your mind, you can always re-subscribe on our site.</p>
  <a href="/">Back to Nikki's</a>
</div></body></html>`

const ERROR_PAGE = `<!DOCTYPE html><html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Oops — Nikki's Great Music Festivals</title>
<style>
  body{margin:0;background:#f5f0ff;font-family:Arial,sans-serif;display:flex;align-items:center;justify-content:center;min-height:100vh}
  .card{background:#fff;border-radius:16px;padding:48px 40px;max-width:480px;width:90%;text-align:center;box-shadow:0 8px 40px rgba(124,77,255,.12)}
  .emoji{font-size:56px;margin-bottom:16px}
  h1{color:#1a0042;font-size:26px;margin:0 0 12px}
  p{color:#555;line-height:1.7;margin:0 0 24px}
  a{display:inline-block;background:#7c4dff;color:#fff;padding:12px 28px;border-radius:8px;text-decoration:none;font-weight:bold}
</style></head>
<body><div class="card">
  <div class="emoji">🤔</div>
  <h1>Link not found</h1>
  <p>This unsubscribe link may have already been used or has expired. If you're still receiving emails you didn't want, please reply to any email and we'll remove you manually.</p>
  <a href="/">Back to Nikki's</a>
</div></body></html>`
