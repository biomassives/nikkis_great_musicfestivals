import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL as string
const supabaseKey = import.meta.env.VITE_SUPABASE_KEY as string

export const supabase = createClient(supabaseUrl, supabaseKey)

export interface MapRegion {
  id: string
  name: string
  description: string | null
  center_lat: number
  center_lng: number
  zoom: number
  display_order: number
  image_url: string | null
  attribution_author:      string | null
  attribution_source_url:  string | null
  attribution_license:     string | null
  attribution_license_url: string | null
  attribution_changes:     string | null
  attribution_approved:    boolean
}

export interface GallerySection {
  slug: string
  label: string
  description: string
  icon: string
  color: string
}

export interface MerchSection {
  slug: string
  label: string
  description: string
  icon: string
  color: string
}

export interface GalleryPhoto {
  id: string
  category: string
  url: string
  caption: string | null
  display_order: number
  published: boolean
  attribution_author:      string | null
  attribution_source_url:  string | null
  attribution_license:     string | null
  attribution_license_url: string | null
  attribution_changes:     string | null
  attribution_approved:    boolean
}

export interface Newsletter {
  id: string
  title: string
  subject: string | null
  body: string | null
  sent_at: string | null
  created_at: string
}

export interface MapPoint {
  id: string
  region_id: string
  category: 'show' | 'senior' | 'nature'
  name: string
  lat: number
  lng: number
  date: string | null
  description: string | null
  image_url: string | null
}

export interface NewsArticle {
  id: string
  title: string
  date: string | null
  icon: string
  color: string
  body: string | null
  tags: string[]
  image_url: string | null
  published: boolean
  created_at: string
}

export interface HomepageArtist {
  id: string          // slug, e.g. "billy-strings"
  name: string
  subtitle: string    // genre / description line
  icon: string        // Material icon name
  icon_color: string  // Quasar color name
  badge_text: string
  badge_color: string
  bio_main: string
  bio_sub: string
  songs: string[]
}

export interface MerchItem {
  id: string
  category: string
  name: string
  description: string | null
  price: string | null
  image_url: string | null
  badge: string | null
  sold_out: boolean
  published: boolean
  display_order: number
  created_at: string
}

export interface ChangelogEntry {
  id: string
  created_at: string
  category: string
  summary: string
  description: string | null
  author: string | null
  tags: string[]
}

export interface ArcEntry {
  id: string
  label: string
  notes?: string
}

export interface ArcCollection {
  id: string
  title: string
  style: string
  icon: string
  color: string
  region_tags: string[]
  entries: ArcEntry[]
}
