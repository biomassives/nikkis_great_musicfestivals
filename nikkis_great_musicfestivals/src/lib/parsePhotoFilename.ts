/**
 * Photo filename parser — intersectionalCMS naming scheme
 *
 * Scheme:
 *   {description}--{author}--{source}--{date}--{license-slug}[--{change}...].ext
 *
 * Rules:
 *   - Words within a field : single hyphen   e.g. "allman-bros-museum"
 *   - Field separator      : double hyphen   "--"
 *   - All lowercase
 *   - date  : YYYY | YYYY-MM | YYYY-MM-DD
 *   - license slugs — see LICENSE_MAP below
 *   - Trailing --{change} fields are optional and repeatable
 *
 * Examples:
 *   allman-bros-museum-macon-georgia--ser-amantio-di-nicolao--wikimedia-commons--2021-09--cc-by-sa-4.jpg
 *   grateful-dead-cornell-1977--unknown--archive-org--1977-05-08--cc-by-nc-4.jpg
 *   red-rocks-sunrise--nikki-willson--own-work--2024-07--cc-by-sa-4.jpg
 */

export const LICENSE_MAP: Record<string, { label: string; url: string }> = {
  'cc-by-sa-4':    { label: 'CC BY-SA 4.0',    url: 'https://creativecommons.org/licenses/by-sa/4.0/'      },
  'cc-by-sa-3':    { label: 'CC BY-SA 3.0',    url: 'https://creativecommons.org/licenses/by-sa/3.0/'      },
  'cc-by-4':       { label: 'CC BY 4.0',        url: 'https://creativecommons.org/licenses/by/4.0/'         },
  'cc-by-3':       { label: 'CC BY 3.0',        url: 'https://creativecommons.org/licenses/by/3.0/'         },
  'cc-by-nc-4':    { label: 'CC BY-NC 4.0',     url: 'https://creativecommons.org/licenses/by-nc/4.0/'      },
  'cc-by-nc-sa-4': { label: 'CC BY-NC-SA 4.0',  url: 'https://creativecommons.org/licenses/by-nc-sa/4.0/'   },
  'cc-by-nd-4':    { label: 'CC BY-ND 4.0',     url: 'https://creativecommons.org/licenses/by-nd/4.0/'      },
  'cc0':           { label: 'CC0 1.0',           url: 'https://creativecommons.org/publicdomain/zero/1.0/'   },
  'pd':            { label: 'Public Domain',     url: 'https://creativecommons.org/publicdomain/mark/1.0/'   },
}

export interface ParsedPhotoMeta {
  description:  string        // human-readable, spaces restored, title-cased
  author:       string        // human-readable
  source:       string        // platform name, human-readable
  date:         string        // as written: YYYY | YYYY-MM | YYYY-MM-DD
  licenseSlug:  string        // raw slug from filename
  licenseLabel: string        // "CC BY-SA 4.0"
  licenseUrl:   string        // deed URL, empty string if unknown slug
  changes:      string | null // extra fields joined with ", "
  valid:        boolean       // true when all five required fields are present
}

/**
 * Parse a filename following the naming scheme above.
 * Returns null if the filename has fewer than 5 double-hyphen-separated fields
 * (i.e. does not follow the scheme at all).
 */
export function parsePhotoFilename(filename: string): ParsedPhotoMeta | null {
  const base  = filename.replace(/\.[^.]+$/, '').toLowerCase()
  const parts = base.split('--')
  if (parts.length < 5) return null

  const [description = '', author = '', source = '', date = '', licenseSlug = '', ...extras] = parts
  const license = LICENSE_MAP[licenseSlug]

  return {
    description:  toTitle(description),
    author:       toTitle(author),
    source:       toTitle(source),
    date,
    licenseSlug,
    licenseLabel: license?.label ?? licenseSlug,
    licenseUrl:   license?.url   ?? '',
    changes:      extras.length  ? extras.map(toTitle).join(', ') : null,
    valid:        !!(description && author && date && licenseSlug),
  }
}

/** Convert a hyphen-slug to Title Case words. */
function toTitle(slug: string): string {
  return slug
    .replace(/-/g, ' ')
    .replace(/\b\w/g, c => c.toUpperCase())
}
