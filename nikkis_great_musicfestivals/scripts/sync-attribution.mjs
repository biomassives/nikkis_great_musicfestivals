/**
 * sync-attribution.mjs
 *
 * Three-tier attribution protocol — Tier 3: Sync
 *
 * USAGE
 *   npm run attribution:check   — show queue state, write nothing
 *   npm run attribution:sync    — sync all DB-approved entries to JSON
 *   npm run attribution:sync -- --min 3   — only sync if 3+ entries are ready
 *
 * WORKFLOW (economises Vercel build minutes)
 *   1. Approve items one-by-one in the admin (DB-only, no git, no build)
 *   2. Run attribution:check periodically to see how many are queued
 *   3. When you have a worthwhile batch, run attribution:sync
 *   4. Review the git diff, commit → one Vercel build per batch
 *
 * RULES
 *   - Only rows with attribution_approved = true are written to JSON
 *   - Only filenames following the naming scheme (containing --) are indexed
 *   - Meta keys starting with _ are never touched
 *   - Existing manual edits to added/changes in the JSON are preserved
 */

import { createClient }  from '@supabase/supabase-js'
import { readFileSync, writeFileSync } from 'fs'
import { resolve, dirname } from 'path'
import { fileURLToPath }  from 'url'

const __dirname = dirname(fileURLToPath(import.meta.url))

// ── Args ──────────────────────────────────────────────────────────────────────

const args      = process.argv.slice(2)
const DRY_RUN   = args.includes('--check')   || args.includes('--dry-run')
const MIN_BATCH = parseInt(args.find(a => a.startsWith('--min='))?.split('=')[1]
                  ?? args[args.indexOf('--min') + 1]
                  ?? '1', 10) || 1

// ── Load env ──────────────────────────────────────────────────────────────────

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
    } catch { /* file absent — skip */ }
  }
  return env
}

const env = loadEnv(
  resolve(__dirname, '../.env.local'),
  resolve(__dirname, '../.env'),
)

const SUPABASE_URL = env.VITE_SUPABASE_URL
const SUPABASE_KEY = env.VITE_SUPABASE_KEY

if (!SUPABASE_URL || !SUPABASE_KEY) {
  console.error('✗ Missing VITE_SUPABASE_URL or VITE_SUPABASE_KEY in .env')
  process.exit(1)
}

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY)

// ── Paths ─────────────────────────────────────────────────────────────────────

const ATTRIBUTION_PATH = resolve(__dirname, '../public/photos/ATTRIBUTION.json')

// ── Helpers ───────────────────────────────────────────────────────────────────

function filenameFrom(url) {
  if (!url) return null
  return url.split('/').pop().split('?')[0]
}

function followsScheme(filename) {
  return filename?.includes('--') ?? false
}

function today() {
  return new Date().toISOString().slice(0, 10)
}

// ── Main ──────────────────────────────────────────────────────────────────────

async function main() {
  // ── Fetch approved rows ────────────────────────────────────────────────────

  const [{ data: photos, error: photosErr }, { data: regions, error: regionsErr }] = await Promise.all([
    supabase.from('gallery_photos').select('*').eq('attribution_approved', true),
    supabase.from('map_regions').select('*').eq('attribution_approved', true),
  ])

  if (photosErr) { console.error('✗ gallery_photos query failed:', photosErr.message); process.exit(1) }
  if (regionsErr) { console.error('✗ map_regions query failed:', regionsErr.message); process.exit(1) }

  // ── Fetch pending (approved = false, but author is set) ────────────────────

  const [{ data: pendingPhotos }, { data: pendingRegions }] = await Promise.all([
    supabase.from('gallery_photos').select('id, url, attribution_author')
      .eq('attribution_approved', false).not('attribution_author', 'is', null),
    supabase.from('map_regions').select('id, name, attribution_author')
      .eq('attribution_approved', false).not('attribution_author', 'is', null),
  ])

  // ── Build sync set ─────────────────────────────────────────────────────────

  const approved = []

  for (const photo of photos ?? []) {
    const filename = filenameFrom(photo.url)
    if (!filename || !followsScheme(filename)) continue
    approved.push({ type: 'gallery', filename, row: photo,
      used_in: [`gallery_photos / ${photo.category}${photo.caption ? ' / ' + photo.caption : ''}`] })
  }

  for (const region of regions ?? []) {
    const filename = filenameFrom(region.image_url)
    if (!filename || !followsScheme(filename)) continue
    approved.push({ type: 'region', filename, row: region,
      used_in: [`map_regions / ${region.name} / image_url`] })
  }

  const pendingCount = (pendingPhotos?.length ?? 0) + (pendingRegions?.length ?? 0)

  // ── Report ─────────────────────────────────────────────────────────────────

  console.log('\nAttribution queue status')
  console.log('─────────────────────────')
  console.log(`  Ready to sync (approved in DB, not yet in JSON): ${approved.length}`)
  console.log(`  Still pending review in admin:                   ${pendingCount}`)

  if (approved.length > 0) {
    console.log('\n  Ready:')
    for (const { filename } of approved) console.log(`    + ${filename}`)
  }
  if (pendingCount > 0) {
    console.log('\n  Pending review:')
    for (const r of [...(pendingPhotos ?? []), ...(pendingRegions ?? [])]) {
      const label = r.name ?? filenameFrom(r.url) ?? r.id
      console.log(`    · ${label}  (author: ${r.attribution_author})`)
    }
  }

  if (DRY_RUN) {
    console.log('\n[check mode — nothing written]\n')
    return
  }

  // ── Batch guard ────────────────────────────────────────────────────────────

  if (approved.length === 0) {
    console.log('\nNothing to sync.\n')
    return
  }

  if (approved.length < MIN_BATCH) {
    console.log(`\n⏳ Only ${approved.length} entr${approved.length === 1 ? 'y' : 'ies'} ready — waiting for a batch of ${MIN_BATCH}.`)
    console.log('   Keep approving in the admin, then re-run when the queue is larger.\n')
    return
  }

  // ── Write JSON ─────────────────────────────────────────────────────────────

  const raw      = readFileSync(ATTRIBUTION_PATH, 'utf8')
  const attrJson = JSON.parse(raw)

  for (const { filename, row, used_in } of approved) {
    const existing = attrJson[filename] ?? {}
    attrJson[filename] = {
      ...existing,
      author:      row.attribution_author      ?? existing.author      ?? null,
      source_url:  row.attribution_source_url  ?? existing.source_url  ?? null,
      license:     row.attribution_license     ?? existing.license     ?? null,
      license_url: row.attribution_license_url ?? existing.license_url ?? null,
      changes:     row.attribution_changes     ?? existing.changes     ?? null,
      added:       existing.added              ?? today(),
      used_in,
      approved:    true,
      approved_at: existing.approved_at        ?? today(),
    }
  }

  writeFileSync(ATTRIBUTION_PATH, JSON.stringify(attrJson, null, 2) + '\n', 'utf8')

  console.log(`\n✓ Synced ${approved.length} entr${approved.length === 1 ? 'y' : 'ies'} to ATTRIBUTION.json`)
  if (pendingCount > 0)
    console.log(`  ${pendingCount} item${pendingCount === 1 ? '' : 's'} still pending review — approve them before the next sync.`)
  console.log('\n  Next: git diff public/photos/ATTRIBUTION.json  →  commit  →  one Vercel build\n')
}

main().catch(err => { console.error(err); process.exit(1) })
