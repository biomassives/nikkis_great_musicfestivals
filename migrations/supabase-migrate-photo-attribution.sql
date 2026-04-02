-- ─── Photo Attribution Columns ───────────────────────────────────────────────
-- Adds CC license metadata to gallery_photos and map_regions so every
-- third-party image can be credited correctly in the UI.
--
-- Two-tier workflow:
--   Tier 1 — Pre-fill: filename parser auto-populates these fields on import
--   Tier 2 — Edit & approve: admin review queue confirms/corrects and sets
--             attribution_approved = true before the credit goes live
--
-- Fields:
--   attribution_author      — creator name (link text for source_url)
--   attribution_source_url  — canonical URL of the original work
--   attribution_license     — human-readable license name, e.g. "CC BY-SA 4.0"
--   attribution_license_url — URL to the license deed
--   attribution_changes     — optional description of modifications, e.g. "cropped"
--   attribution_approved    — false until an admin has reviewed and confirmed

alter table gallery_photos
  add column if not exists attribution_author      text,
  add column if not exists attribution_source_url  text,
  add column if not exists attribution_license     text,
  add column if not exists attribution_license_url text,
  add column if not exists attribution_changes     text,
  add column if not exists attribution_approved    boolean not null default false;

alter table map_regions
  add column if not exists attribution_author      text,
  add column if not exists attribution_source_url  text,
  add column if not exists attribution_license     text,
  add column if not exists attribution_license_url text,
  add column if not exists attribution_changes     text,
  add column if not exists attribution_approved    boolean not null default false;
