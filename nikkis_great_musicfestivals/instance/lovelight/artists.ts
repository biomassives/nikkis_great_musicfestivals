// ─── Artist data — lovelight.cc ───────────────────────────────────────────────
// Re-exports everything from src/lib/artists.ts.
// This file is the canonical import point for lovelight instance code.
// src/lib/artists.ts stays in place so existing page imports don't break.

export { ARTISTS, findArtist } from 'src/lib/artists'
export type { Artist, ArtistLink } from 'src/lib/artists'
