/**
 * Shared admin auth helper for Vercel serverless functions.
 * Verifies the Supabase JWT from the Authorization: Bearer header.
 */
import type { VercelRequest, VercelResponse } from '@vercel/node'
import { createClient } from '@supabase/supabase-js'
import type { User } from '@supabase/supabase-js'

function adminClient() {
  return createClient(
    process.env.VITE_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
  )
}

/** Returns the authenticated User or null (and sends 401 automatically). */
export async function getAdminUser(
  req: VercelRequest,
  res: VercelResponse,
): Promise<User | null> {
  const auth  = String(req.headers['authorization'] ?? '')
  const token = auth.startsWith('Bearer ') ? auth.slice(7) : ''

  if (!token) {
    res.status(401).json({ error: 'Unauthorized' })
    return null
  }

  const { data: { user }, error } = await adminClient().auth.getUser(token)
  if (error || !user) {
    res.status(401).json({ error: 'Unauthorized' })
    return null
  }

  return user
}

/** Convenience: returns true if authenticated, false (+ sends 401) otherwise. */
export async function requireAdminAuth(
  req: VercelRequest,
  res: VercelResponse,
): Promise<boolean> {
  return (await getAdminUser(req, res)) !== null
}
