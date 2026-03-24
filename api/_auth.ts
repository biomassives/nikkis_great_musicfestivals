/**
 * Shared admin auth helper for Vercel serverless functions.
 * Verifies the Supabase JWT from the Authorization header.
 * Returns true if the request is authenticated; sends 401 and returns false otherwise.
 */
import type { VercelRequest, VercelResponse } from '@vercel/node'
import { createClient } from '@supabase/supabase-js'

export async function requireAdminAuth(
  req: VercelRequest,
  res: VercelResponse,
): Promise<boolean> {
  const auth  = String(req.headers['authorization'] ?? '')
  const token = auth.startsWith('Bearer ') ? auth.slice(7) : ''

  if (!token) {
    res.status(401).json({ error: 'Unauthorized' })
    return false
  }

  const supabase = createClient(
    process.env.VITE_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
  )

  const { data: { user }, error } = await supabase.auth.getUser(token)
  if (error || !user) {
    res.status(401).json({ error: 'Unauthorized' })
    return false
  }

  return true
}
