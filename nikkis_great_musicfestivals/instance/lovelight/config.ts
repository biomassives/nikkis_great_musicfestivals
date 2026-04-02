// ─── Instance config — lovelight.cc ───────────────────────────────────────────
// Single source of truth for all lovelight-specific identity, theming, and
// defaults. Import via src/lib/instance.ts — don't import this file directly.

export interface InstanceTheme {
  primary: string      // main accent (Mondrian red)
  secondary: string    // secondary accent (Mondrian blue)
  accent: string       // highlight (Mondrian yellow)
  dark_bg: string      // dark mode page background
  light_bg: string     // light mode page background
  border: string       // standard Mondrian border color
  font_mono: string    // monospace font family
}

export interface InstanceSeason {
  label: string        // e.g. "Summer 2026"
  eyebrow: string      // short phrase for hero overlays
  start_date: string   // ISO date string, inclusive
  end_date: string     // ISO date string, inclusive
}

export interface InstanceMapCategory {
  id: string
  label: string
  icon: string
  color: string
}

export interface InstanceDefaults {
  story_title: string
  story_eyebrow: string
  story_closing: string
  story_image_url: string
  story_image_caption: string
  homepage_headline: string
  homepage_subhead: string
}

export interface InstanceConfig {
  // Identity
  slug: string
  site_name: string
  site_short_name: string
  admin_first_name: string
  domain: string
  contact_email: string

  // Header copy
  header_line1: string
  header_line2: string

  // Storage & session namespacing
  storage_bucket: string
  session_prefix: string   // e.g. "ngmf_" — prepended to all localStorage keys

  // Branding / theme
  theme: InstanceTheme

  // Season
  season: InstanceSeason

  // Map point categories
  map_categories: InstanceMapCategory[]

  // Default content (used when Supabase has no saved value yet)
  defaults: InstanceDefaults
}

// ── lovelight.cc configuration ────────────────────────────────────────────────

export const config: InstanceConfig = {
  slug:              'lovelight',
  site_name:         "Nikki's Great Music Festivals",
  site_short_name:   'lovelight',
  admin_first_name:  'Nikki',
  domain:            'lovelight.cc',
  contact_email:     'hello@lovelight.cc',

  header_line1: "Nikki's Great",
  header_line2: 'Music Festivals',

  storage_bucket: 'festival-media',
  session_prefix: 'ngmf_',

  theme: {
    primary:   '#cc1010',   // Mondrian red
    secondary: '#1040a8',   // Mondrian blue
    accent:    '#ffd600',   // Mondrian yellow
    dark_bg:   '#0a0018',   // deep navy-black
    light_bg:  '#faf9f6',   // warm off-white
    border:    '#000000',
    font_mono: "'Space Mono', monospace",
  },

  season: {
    label:      'Summer 2026',
    eyebrow:    'On the road again',
    start_date: '2026-06-01',
    end_date:   '2026-09-30',
  },

  map_categories: [
    { id: 'show',   label: 'Shows',          icon: 'music_note',    color: '#cc1010' },
    { id: 'senior', label: 'Senior Centers',  icon: 'elderly',       color: '#1040a8' },
    { id: 'nature', label: 'Nature / Trails', icon: 'forest',        color: '#2e7d32' },
  ],

  defaults: {
    story_title:          'The Music\nNever Stopped',
    story_eyebrow:        'Our Full Story',
    story_closing:        'Come with us.',
    story_image_url:      'https://picsum.photos/seed/mountain-evening/900/1400',
    story_image_caption:  'On the road',
    homepage_headline:    "Nikki's Great Music Festivals",
    homepage_subhead:     'Live music, open roads, and the communities they connect.',
  },
}
