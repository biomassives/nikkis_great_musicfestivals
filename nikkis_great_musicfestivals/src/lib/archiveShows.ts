/**
 * Curated archive.org recordings — freely streamable via the archive.org embed player.
 *
 * To add a new show:
 *   1. Find the recording on https://archive.org (search or browse collections)
 *   2. Copy the identifier from the URL: archive.org/details/<IDENTIFIER>
 *   3. Add an entry below and rebuild.
 *
 * Collections to browse:
 *   • 78rpm jazz & classics  →  archive.org/search?query=&and[]=collection%3A78rpm
 *   • Grateful Dead           →  archive.org/details/GratefulDead
 *   • etree live music        →  archive.org/details/etree
 */

export interface ArchiveShow {
  id: string
  label: string
}

export const ARCHIVE_SHOWS: ArchiveShow[] = [
  // ── Classic Jazz (78rpm) ─────────────────────────────────────────────────
  { id: '78_9958-Take-the-A-train',
    label: 'Duke Ellington · Take the A Train (1941 78rpm)' },
  { id: '78_st-james-infirmary_louis-armstrong-and-his-savoy-ballroom-five-louis-armstrong',
    label: 'Louis Armstrong · St. James Infirmary (1928 78rpm)' },
  { id: '78_sing-sing-sing_benny-goodman-and-his-orchestra-benny-goodman-gene-krupa',
    label: 'Benny Goodman · Sing Sing Sing (1937 78rpm)' },
  { id: '78_strange-fruit_billie-holiday-and-her-orchestra-billie-holiday',
    label: 'Billie Holiday · Strange Fruit (1939 78rpm)' },

  // ── Grateful Dead ─────────────────────────────────────────────────────────
  { id: 'gd1977-05-08.shure57.stevenson-ladner-beaumont.29662.sbefp.flac16',
    label: 'Grateful Dead · Cornell, May 8 1977' },
  { id: 'gd1972-08-27.sbd.hollister.174.sbeok.shnf',
    label: 'Grateful Dead · Veneta, Aug 27 1972' },
  { id: 'gd1973-11-11.sbd.unknown.14042.sbeok.shnf',
    label: 'Grateful Dead · Winterland, Nov 11 1973' },
  { id: 'gd1985-07-04.sbd.seamons.9517.sbeok.shnf',
    label: 'Grateful Dead · Autzen Stadium, Jul 4 1985' },
  { id: 'gd1991-09-10.sbd.miller.87991.sbeok.shnf',
    label: 'Grateful Dead · Madison Square Garden, Sep 1991' },

  // ── Contemporary ──────────────────────────────────────────────────────────
  { id: 'billystrings2026-02-06',
    label: 'Billy Strings · Athens, GA — Feb 6 2026' },
]
