import type { VercelRequest, VercelResponse } from '@vercel/node'
import Stripe from 'stripe'
import { createClient } from '@supabase/supabase-js'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY ?? '', {
  apiVersion: '2026-02-25.clover',
})

const supabase = createClient(
  process.env.VITE_SUPABASE_URL ?? '',
  process.env.SUPABASE_SERVICE_ROLE_KEY ?? '' // service role key for server-side writes
)

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method !== 'POST') return res.status(405).end()

  const sig = req.headers['stripe-signature']
  if (!sig || !process.env.STRIPE_WEBHOOK_SECRET) {
    return res.status(400).json({ error: 'Missing stripe signature or webhook secret' })
  }

  let event: Stripe.Event
  try {
    const rawBody = await getRawBody(req)
    event = stripe.webhooks.constructEvent(rawBody, sig, process.env.STRIPE_WEBHOOK_SECRET)
  } catch (err) {
    const msg = err instanceof Error ? err.message : 'Unknown'
    return res.status(400).json({ error: `Webhook signature failed: ${msg}` })
  }

  switch (event.type) {
    case 'checkout.session.completed': {
      const session = event.data.object as Stripe.Checkout.Session
      await supabase.from('members').upsert({
        stripe_customer_id:    session.customer as string,
        stripe_subscription_id: session.subscription as string,
        email:                 session.customer_email ?? session.customer_details?.email,
        status:                'active',
        updated_at:            new Date().toISOString(),
      }, { onConflict: 'stripe_customer_id' })
      break
    }
    case 'customer.subscription.deleted':
    case 'customer.subscription.updated': {
      const sub = event.data.object as Stripe.Subscription
      await supabase.from('members')
        .update({ status: sub.status, updated_at: new Date().toISOString() })
        .eq('stripe_subscription_id', sub.id)
      break
    }
  }

  return res.status(200).json({ received: true })
}

async function getRawBody(req: VercelRequest): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    const chunks: Buffer[] = []
    req.on('data', (chunk: Buffer) => chunks.push(chunk))
    req.on('end', () => resolve(Buffer.concat(chunks)))
    req.on('error', reject)
  })
}
