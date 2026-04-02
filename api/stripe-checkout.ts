import type { VercelRequest, VercelResponse } from '@vercel/node'
import Stripe from 'stripe'

const BASE_URL =
  process.env.SITE_URL ||
  (process.env.VERCEL_URL ? `https://${process.env.VERCEL_URL}` : 'http://localhost:9000')

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' })

  if (!process.env.STRIPE_SECRET_KEY) {
    return res.status(503).json({ error: 'Stripe not configured yet — add STRIPE_SECRET_KEY to Vercel env vars' })
  }

  const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
    apiVersion: '2026-03-25.dahlia',
  })

  const { priceId, customAmount, interval, mode = 'subscription' } = req.body as {
    priceId?: string
    customAmount?: number
    interval?: 'month' | 'year'
    mode?: 'subscription' | 'payment'
  }

  try {
    let sessionParams: Stripe.Checkout.SessionCreateParams

    if (customAmount && interval) {
      // Custom amount — create an inline price on the fly
      sessionParams = {
        mode: 'subscription',
        line_items: [{
          price_data: {
            currency: 'usd',
            product_data: { name: "Nikki's Festival — Custom Membership" },
            unit_amount: customAmount,
            recurring: { interval },
          },
          quantity: 1,
        }],
        success_url: `${BASE_URL}/support?success=1`,
        cancel_url:  `${BASE_URL}/support`,
      }
    } else if (priceId) {
      // Standard tier — use a pre-created Stripe Price ID
      sessionParams = {
        mode: mode as Stripe.Checkout.SessionCreateParams.Mode,
        line_items: [{ price: priceId, quantity: 1 }],
        success_url: `${BASE_URL}/support?success=1`,
        cancel_url:  `${BASE_URL}/support`,
      }
    } else {
      return res.status(400).json({ error: 'Provide either priceId or customAmount + interval' })
    }

    const session = await stripe.checkout.sessions.create(sessionParams)
    return res.status(200).json({ url: session.url })

  } catch (err) {
    console.error('[stripe-checkout]', err)
    if (err instanceof Stripe.errors.StripeError) {
      return res.status(500).json({
        error: err.message,
        type: err.type,
        code: err.code ?? null,
      })
    }
    const message = err instanceof Error ? err.message : 'Unknown error'
    return res.status(500).json({ error: message })
  }
}
