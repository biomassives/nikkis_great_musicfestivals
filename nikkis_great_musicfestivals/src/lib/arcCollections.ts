/**
 * Arc (Archive.org) Curated Collections
 *
 * Each collection groups archive.org recordings by musical theme and maps to
 * one or more tour regions. Admin-editable via /admin/archive — stored in
 * site_settings key 'arc_collections'. Falls back to ARC_COLLECTIONS_SEED.
 *
 * Seeded from /public/api/arc/*.json
 */

export interface ArcEntry {
  id: string        // archive.org identifier (path after /details/)
  label: string     // display label in the player
  notes?: string    // optional context notes (shown in admin)
}

export interface ArcCollection {
  id: string           // slug, e.g. 'jerryroots'
  title: string        // display title
  style: string        // one-line style / sub-genre description
  icon: string         // Material icon name
  color: string        // Quasar color name
  region_tags: string[] // map region IDs this collection is linked to
  entries: ArcEntry[]  // archive.org recordings
}

export const ARC_COLLECTIONS_SEED: ArcCollection[] = [
  // ── Jerry Garcia Acoustic & Roots ────────────────────────────────────────
  {
    id: 'jerryroots',
    title: 'Jerry Garcia Acoustic & Roots',
    style: 'Scruggs-Style Banjo · Bluegrass Fiddle · Jug Band Stomp',
    icon: 'queue_music',
    color: 'amber',
    region_tags: ['southeast', 'southwest'],
    entries: [
      {
        id: 'HartValleyDrifters1962',
        label: 'Hart Valley Drifters · 1962 — Early Folk & Flat-Picking',
        notes: 'Jerry at 20; pure old-timey folk and flat-picking.',
      },
      {
        id: 'oaity1973-10-08.sbd.ashley-field.19530.sbeok.shnf',
        label: 'Old & In The Way · The Boarding House, SF — Oct 8 1973',
        notes: 'Pinnacle Fiddle/Banjo/Bass/Mandolin quartet.',
      },
      {
        id: 'jerry-garcia-david-grisman-1991-08-25',
        label: 'Jerry Garcia & David Grisman · Dawg Music — Aug 25 1991',
        notes: 'Mellow acoustic storytelling; high-fidelity Dawg music.',
      },
    ],
  },

  // ── Phish Vermont Jazz-Grass Roots ───────────────────────────────────────
  {
    id: 'phishroots',
    title: 'Phish Vermont Jazz-Grass Roots',
    style: 'Vermont Jazz-Grass · Deconstructionist Bluegrass',
    icon: 'music_note',
    color: 'teal',
    region_tags: ['northeast'],
    entries: [
      {
        id: 'ph1994-11-16.aud.reilly.9474.sbeok.shnf',
        label: 'Phish w/ Rev. Jeff Mosier · Bluegrass Clinic — Nov 16 1994',
        notes: 'The band learning traditional stagecraft from a master.',
      },
      {
        id: 'MikeGordonWithTheGordonStoneTrio-October241993',
        label: 'Mike Gordon & Gordon Stone Trio · Burlington — Oct 24 1993',
        notes: 'Pedal steel and banjo mastery; Burlington heritage.',
      },
      {
        id: 'BadHat1994-09-12.flac',
        label: 'Bad Hat (Trey) · Acoustic Jazz-Grass — Sep 12 1994',
        notes: 'Trey exploring flat-picking boundaries.',
      },
    ],
  },

  // ── Larry Keel High-Speed Flat-Picking ───────────────────────────────────
  {
    id: 'larrykeel',
    title: 'Larry Keel High-Speed Flat-Picking',
    style: 'Appalachian Drive · High-Speed Flat-Picking',
    icon: 'library_music',
    color: 'deep-orange',
    region_tags: ['southeast', 'mountainwest'],
    entries: [
      {
        id: 'lke2019-11-15.litz.sbd.akg414.flac16',
        label: 'Larry Keel Experience · Boone, NC — Nov 15 2019 (w/ Billy Strings)',
        notes: '"Master meets the Student" tape.',
      },
      {
        id: 'lknb2007-06-23.flac16',
        label: 'Larry Keel & Natural Bridge · Telluride Bluegrass — Jun 23 2007',
        notes: 'High-altitude Mountain West vibe.',
      },
    ],
  },

  // ── Southern Old-Time String Band ─────────────────────────────────────────
  {
    id: 'oldtimey',
    title: 'Southern Old-Time String Band',
    style: 'Round Peak · Galax Style · Frontier Fiddle',
    icon: 'album',
    color: 'orange',
    region_tags: ['southeast'],
    entries: [
      {
        id: '78_soldiers-joy_gid-tanner-and-his-skillet-lickers',
        label: "Skillet Lickers · Soldier's Joy (78rpm)",
        notes: 'Round Peak fiddle style; Gid Tanner & Riley Puckett.',
      },
      {
        id: '78_dont-let-your-deal-go-down-blues',
        label: "Charlie Poole & NC Ramblers · Don't Let Your Deal Go Down (78rpm)",
        notes: 'Galax style clawhammer banjo.',
      },
      {
        id: '78_keep-my-skillet-good-and-greasy_uncle-dave-macon_gbia0001436a',
        label: 'Uncle Dave Macon · Keep My Skillet Good and Greasy (78rpm)',
        notes: 'Grandfather of high-energy banjo performance.',
      },
      {
        id: 'HighwoodsStringBandFireOnTheMountain',
        label: 'Highwoods String Band · Fire on the Mountain',
        notes: '1970s revival; bridged old-time to the Deadhead generation.',
      },
      {
        id: 'TommyJarrellFieldRecordings',
        label: 'Tommy Jarrell · Round Peak Style Field Recordings',
        notes: 'Kitchen tapes with Fred Cockerham.',
      },
      {
        id: 'GalaxOldFiddlersConvention',
        label: 'Galax Old Fiddlers Convention · Festival Field Recordings',
        notes: 'Search 1960–1980 recordings for the best tapes.',
      },
    ],
  },

  // ── Widespread Panic & Southern Gothic ───────────────────────────────────
  {
    id: 'panic',
    title: 'Southern Gothic & Panic Acoustic',
    style: 'Southern Gothic Acoustic · Muddy-Water Jam',
    icon: 'headphones',
    color: 'red',
    region_tags: ['southeast', 'southwest'],
    entries: [
      {
        id: 'wsp1996-01-20.aud.flac16',
        label: 'Widespread Panic Sit & Ski · Snow King, WY — Jan 20 1996',
        notes: 'Definitive acoustic Sit & Ski performance.',
      },
      {
        id: 'wsp1995-04-08.aud.schoeps.641.8744.sbeok.shnf',
        label: 'Brute (Vic Chesnutt + Panic) · Apr 8 1995',
        notes: 'Haunting Southern folk; heavy storytelling emphasis.',
      },
      {
        id: 'wsp1502025-12-31',
        label: "Widespread Panic w/ Billy Strings · New Year's 2023",
        notes: 'The bridge between Athens and the New Vanguard.',
      },
    ],
  },

  // ── Blue Ridge Legends: Porch to Stage ───────────────────────────────────
  {
    id: 'legendsappalachia',
    title: 'Blue Ridge Legends: Porch to Stage',
    style: 'Southern Appalachia · Boone / Asheville / Brevard',
    icon: 'terrain',
    color: 'green',
    region_tags: ['southeast'],
    entries: [
      {
        id: 'bs2017-07-30.akg.flac16',
        label: 'Billy Strings · RockyGrass Festival — Jul 30 2017',
        notes: 'Raw acoustic power; direct Doc Watson lineage.',
      },
      {
        id: 'sierraferrell2023-06-17',
        label: 'Sierra Ferrell · Jun 17 2023',
        notes: 'Heritage swing meets old-time fiddle; high senior appeal.',
      },
    ],
  },

  // ── The Intergenerational Heritage Map ───────────────────────────────────
  {
    id: 'livingmap',
    title: 'The Intergenerational Heritage Map',
    style: 'Full String Band Heritage · Cross-Regional Survey',
    icon: 'explore',
    color: 'indigo',
    region_tags: ['northeast', 'southeast', 'southwest', 'mountainwest', 'pacnw', 'greatlakes'],
    entries: [
      {
        id: 'HartValleyDrifters1962',
        label: "Hart Valley Drifters · 1962 — Jerry Garcia's Folk Roots",
        notes: 'The origin point of the whole lineage.',
      },
      {
        id: 'oaity1973-10-08.sbd.ashley-field.19530.sbeok.shnf',
        label: 'Old & In The Way · Boarding House 1973',
        notes: 'The Deadhead gateway to bluegrass.',
      },
      {
        id: 'ph1994-11-16.aud.reilly.9474.sbeok.shnf',
        label: 'Phish Bluegrass Clinic · 1994',
        notes: 'The student generation learns the tradition.',
      },
      {
        id: 'bs2017-07-30.akg.flac16',
        label: 'Billy Strings · RockyGrass 2017',
        notes: 'Modern traditionalism reaches a global audience.',
      },
      {
        id: 'sierraferrell2023-06-17',
        label: 'Sierra Ferrell · 2023',
        notes: 'Heritage swing meets the contemporary scene.',
      },
    ],
  },
]
