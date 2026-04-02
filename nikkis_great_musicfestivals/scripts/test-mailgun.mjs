/**
 * test-mailgun.mjs
 * Sends a real test email via Mailgun using local .env credentials.
 * Run from nikkis_great_musicfestivals/:
 *   node scripts/test-mailgun.mjs you@example.com
 */

import { readFileSync } from 'fs'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'

const __dirname = dirname(fileURLToPath(import.meta.url))

function loadEnv(...paths) {
  const env = {}
  for (const p of paths) {
    try {
      readFileSync(p, 'utf8')
        .split('\n')
        .filter(l => l.includes('=') && !l.startsWith('#') && l.trim())
        .forEach(l => {
          const eq  = l.indexOf('=')
          const key = l.slice(0, eq).trim()
          const val = l.slice(eq + 1).trim().replace(/^["']|["']$/g, '')
          if (key && !(key in env)) env[key] = val
        })
    } catch { /* absent — skip */ }
  }
  return env
}

const env = loadEnv(
  resolve(__dirname, '../.env.local'),
  resolve(__dirname, '../.env'),
)

const to     = process.argv[2]
const key    = env.MAILGUN_API_KEY
const domain = env.MAILGUN_DOMAIN
const from   = env.MAILGUN_FROM ?? `test <hello@${domain}>`

if (!to)     { console.error('Usage: node scripts/test-mailgun.mjs <to@address>'); process.exit(1) }
if (!key)    { console.error('✗ MAILGUN_API_KEY not found in .env.local'); process.exit(1) }
if (!domain) { console.error('✗ MAILGUN_DOMAIN not found in .env.local'); process.exit(1) }

console.log(`Sending test email to ${to}`)
console.log(`  domain : ${domain}`)
console.log(`  from   : ${from}`)

const body = new URLSearchParams({
  from,
  to,
  subject: '[lovelight] Mailgun test',
  html: '<p>Mailgun is working. You can delete this.</p>',
})

const res = await fetch(`https://api.mailgun.net/v3/${domain}/messages`, {
  method:  'POST',
  headers: {
    Authorization: `Basic ${Buffer.from(`api:${key}`).toString('base64')}`,
    'Content-Type': 'application/x-www-form-urlencoded',
  },
  body: body.toString(),
})

const text = await res.text()
if (res.ok) {
  console.log(`✓ Mailgun accepted the message (${res.status})`)
  console.log(`  ${text}`)
} else {
  console.error(`✗ Mailgun rejected (${res.status})`)
  console.error(`  ${text}`)
}
