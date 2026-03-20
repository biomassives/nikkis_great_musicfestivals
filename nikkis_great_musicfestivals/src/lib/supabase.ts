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
}

export interface GalleryPhoto {
  id: string
  category: 'outdoor' | 'concert' | 'cuteness'
  url: string
  caption: string | null
  display_order: number
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
