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

  // ── Phish ─────────────────────────────────────────────────────────────────
  { id: 'Phish2024-08-09.Litz.Lee.NeumannU89i.Flac24',
    label: 'Phish · Bethel Woods, NY — Aug 9 2024' },

  // ── String Cheese Incident ────────────────────────────────────────────────
  { id: 'sci2001-07-04.sbd.flac16',
    label: 'String Cheese Incident · Red Rocks, CO — Jul 4 2001' },
  { id: 'sci2010-07-25',
    label: 'String Cheese Incident · Red Rocks Amphitheater — Jul 25 2010' },

  // ── Widespread Panic ──────────────────────────────────────────────────────
  { id: 'wsp2013-11-09.ak40.flac24',
    label: 'Widespread Panic · Asheville Civic Center — Nov 9 2013' },
  { id: 'wsp2007-09-22.mk41.mk5.flac16',
    label: 'Widespread Panic · FedExForum, Memphis TN — Sep 22 2007' },

  // ── Greensky Bluegrass ────────────────────────────────────────────────────
  { id: 'gsbg2021-09-19.akg61.stearns.flac16',
    label: 'Greensky Bluegrass · Red Rocks Amphitheatre — Sep 19 2021' },

  // ── Umphrey\'s McGee ──────────────────────────────────────────────────────
  { id: 'um2004-07-03.flac',
    label: "Umphrey's McGee · Summerfest, Milwaukee WI — Jul 3 2004" },

  // ── Railroad Earth ────────────────────────────────────────────────────────
  { id: 'rre2009-09-05.mimna.bsc1-k4.flac16',
    label: 'Railroad Earth · Red Rocks Amphitheatre — Sep 5 2009' },

  // ── Leftover Salmon ───────────────────────────────────────────────────────
  { id: 'los1997-04-11.flac16',
    label: 'Leftover Salmon · The Rock — Apr 11 1997' },

  // ── Billy Strings ─────────────────────────────────────────────────────────
  { id: 'billystrings2026-02-06',
    label: 'Billy Strings · Athens, GA — Feb 6 2026' },
  { id: 'billystrings2018-06-21.koto.digihoarders.16441',
    label: 'Billy Strings · Town Park, Telluride CO — Jun 21 2018' },
  { id: 'billystrings2019-04-13.litz.schoepsMK41v.flac16',
    label: 'Billy Strings · Bender Jamboree, Las Vegas — Apr 13 2019' },
]
