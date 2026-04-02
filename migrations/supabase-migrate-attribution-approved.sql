-- Adds attribution_approved column to gallery_photos and map_regions.
-- Run this if you already ran supabase-migrate-photo-attribution.sql
-- (which predates this column).

alter table gallery_photos
  add column if not exists attribution_approved boolean not null default false;

alter table map_regions
  add column if not exists attribution_approved boolean not null default false;
