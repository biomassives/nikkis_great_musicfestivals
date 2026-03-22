// ─── Artist data ──────────────────────────────────────────────────────────────
// Single source of truth for all artist roster entries.
// `featured: true` → appears on the homepage artist grid.
// All entries get a detail page at /artists/:id.

export interface ArtistLink {
  label: string
  url: string
  icon: string
}

export interface Artist {
  id: string           // URL slug, e.g. "billy-strings"
  name: string
  subtitle: string     // short genre / description
  icon: string         // Material icon name
  icon_color: string   // color key (used in COLOR_MAP on pages)
  badge_text: string
  badge_color: string
  bio_main: string     // ~160 chars — used on cards
  bio_sub: string      // single tagline sentence
  songs: string[]      // 3 signature songs
  featured: boolean    // true → homepage grid
  genres: string[]
  origin: string       // "Charlevoix, MI"
  active_since: string
  full_bio: string     // 2–4 paragraph rich bio for detail page
  links: ArtistLink[]
  touring_regions: string[]  // region IDs from map_regions
}

export const ARTISTS: Artist[] = [
  {
    id: 'billy-strings',
    name: 'Billy Strings',
    subtitle: 'Progressive Bluegrass · Newgrass · Psychedelic',
    icon: 'music_note', icon_color: 'amber',
    badge_text: 'Headline', badge_color: 'amber',
    featured: true,
    genres: ['Progressive Bluegrass', 'Newgrass', 'Psychedelic', 'Americana'],
    origin: 'Ionia County, MI',
    active_since: '2013',
    bio_main: "William Apostol — known to the world as Billy Strings — is a Grammy-winning flatpicker who bends time with a guitar. Raised on the old-time music of Michigan, he has become one of the most electrifying live performers in any genre, threading jaw-dropping technique through dark folk imagery and untethered improvisation.",
    bio_sub: "At Nikki's festivals, Billy's sets tend to stretch deep into the night.",
    songs: ['Home', 'Dust in a Baggie', 'Meet Me at the Creek'],
    full_bio: `William Apostol grew up in the small towns of northern Michigan, learning guitar from his father and step-father — both deeply rooted in the old-time and bluegrass traditions of Appalachia transplanted to the Great Lakes. He picked up the flatpick as a teenager and within a few years was playing at a level that turned heads at festivals across the Midwest.

His stage name Billy Strings is a nod to that childhood nickname, and the music has always carried that worn-in, hand-me-down quality — except played at a speed and intensity that nobody in the tradition had quite attempted before. His 2019 album *Home* won the Grammy for Best Bluegrass Album and introduced him to a wide audience that had never heard a flatpicker treat the instrument like Jimi Hendrix might.

Live, Billy and his band operate in a mode all their own. Sets can move from a note-perfect Doc Watson cover to a twenty-minute psychedelic excursion into tone and texture without warning or apology. The setlist is a map into whatever mood is in the room — and the room is always up for it.

At Nikki's Great Music Festivals, Billy has been a cornerstone act since the beginning. His connection to the Michigan origins of the tour and his genuine love for outdoor festival settings makes every show feel like a homecoming.`,
    links: [
      { label: 'Official Site', url: 'https://billystrings.com', icon: 'language' },
      { label: 'Spotify', url: 'https://open.spotify.com/artist/billystrings', icon: 'music_note' },
    ],
    touring_regions: ['great-lakes', 'mountain-west', 'pacific-northwest', 'northeast'],
  },

  {
    id: 'leftover-salmon',
    name: 'Leftover Salmon',
    subtitle: 'Polyethnic Cajun Slamgrass · Roots · Mountain Folk',
    icon: 'water', icon_color: 'deep-orange',
    badge_text: 'Legacy Act', badge_color: 'deep-orange',
    featured: true,
    genres: ['Slamgrass', 'Cajun', 'Bluegrass', 'Roots Rock'],
    origin: 'Boulder, CO',
    active_since: '1989',
    bio_main: `Colorado's Leftover Salmon invented "Polyethnic Cajun Slamgrass" — a label that sounds like a joke until you hear it, and then it makes perfect sense. Vince Herman and Mark Vann started cooking something strange and wonderful in the early '90s, and the band has been a cornerstone of the jam scene ever since.`,
    bio_sub: 'No two shows are the same.',
    songs: ['Zombie Jamboree', 'Salmon Run', 'Euphoria'],
    full_bio: `Leftover Salmon emerged from the thriving Boulder music scene in the late 1980s when Vince Herman's band The Salmon blended with Drew Emmitt's The Left Hand String Band. The collision was happy and loud — a genre that sounded like a bluegrass band that had grown up on Cajun two-steps, New Orleans second lines, and Rocky Mountain ski-town energy.

Their self-coined label "Polyethnic Cajun Slamgrass" is either the most accurate genre description in American music or a running joke — probably both. The slamgrass part refers to a specific technique: driving acoustic instruments at electric-band velocity, with the fiddle and mandolin trading leads while the guitar and bass lock into rhythms borrowed from a dozen traditions at once.

Vince Herman remains one of the most beloved frontmen in the jam scene — his raspy, full-voiced delivery and irreverent stage banter create a warm, inclusive atmosphere that makes first-timers feel like regulars. Over thirty-plus years, Leftover Salmon has outlasted scene trends, band changes, and the general tendency of jam bands to exhaust their audience.

They play because they love playing. You can hear it in every note.`,
    links: [
      { label: 'Official Site', url: 'https://leftover-salmon.com', icon: 'language' },
    ],
    touring_regions: ['mountain-west', 'southwest', 'pacific-northwest', 'great-lakes'],
  },

  {
    id: 'stringdusters',
    name: 'The Infamous Stringdusters',
    subtitle: 'Grammy Bluegrass · Acoustic Jam · Americana',
    icon: 'star', icon_color: 'purple',
    badge_text: 'Grammy Winners', badge_color: 'purple',
    featured: true,
    genres: ['Bluegrass', 'Acoustic Jam', 'Americana', 'Progressive'],
    origin: 'Nashville, TN',
    active_since: '2006',
    bio_main: "The Infamous Stringdusters have spent two decades proving that bluegrass is not a museum piece. Grammy-winning and perpetually evolving, the band writes originals that sound traditional until they don't, and then they improvise in ways that should not work but absolutely do.",
    bio_sub: 'Their sets reward attentive listening and dancing in equal measure.',
    songs: ['Fork in the Road', 'Silver Sky', 'Things You Left Behind'],
    full_bio: `The Infamous Stringdusters formed in Nashville in the mid-2000s when a group of young musicians from the bluegrass circuit — all deeply schooled in the tradition — decided they wanted to play the music as if it were alive right now, not preserved in amber. The result was a band that could win Grammy Awards while simultaneously making festival crowds lose their minds.

Andy Hall's resonator guitar sits at the center of the sound, equal parts Hawaiian steel, Dobro tradition, and something entirely his own. Around him, Jeremy Garrett on fiddle, Travis Book on upright bass, Chris Pandolfi on banjo, and Andy Falco on guitar form a unit that has been together long enough to communicate in musical shorthand.

Their improvisational language is rooted in bluegrass but extends into jazz and rock territory on the longer versions that live performances allow. A Stringdusters jam builds structure the way a bluegrass song does — tension and release, call and response — but the timescales stretch out and the destinations get further from home.

Their Grammy for *Laws of Gravity* in 2018 was overdue. The records have always been good. The shows are better.`,
    links: [
      { label: 'Official Site', url: 'https://infamous-stringdusters.com', icon: 'language' },
    ],
    touring_regions: ['southeast', 'northeast', 'great-lakes', 'mountain-west'],
  },

  {
    id: 'phish',
    name: 'Phish',
    subtitle: 'Psychedelic Jam · Experimental Rock · Vermont',
    icon: 'waves', icon_color: 'blue',
    badge_text: 'Jam Icons', badge_color: 'blue',
    featured: true,
    genres: ['Jam Rock', 'Psychedelic', 'Experimental', 'Progressive'],
    origin: 'Burlington, VT',
    active_since: '1983',
    bio_main: "Phish invented their own universe. Trey Anastasio, Mike Gordon, Jon Fishman, and Page McConnell have been stretching songs into 40-minute odysseys since the late '80s, building a touring fanbase that travels like a city. Their music ranges from acoustic bluegrass noodling to full-on electronic space explorations — always with precision, always with a wink.",
    bio_sub: 'No setlist is ever the same. That is the whole point.',
    songs: ['Tweezer', 'You Enjoy Myself', 'Bathtub Gin'],
    full_bio: `Phish began in a Burlington, Vermont dorm room in 1983 and has spent four decades evolving into something that no other band has managed to replicate: a genuine improvising rock band with a devoted traveling community, a rich internal mythology, and an ongoing creative output that gets stranger and more interesting with time.

Trey Anastasio's guitar is the center of gravity — a tone built on a custom setup that sits somewhere between David Gilmour's warmth and Jerry Garcia's looseness, with a melodic sensibility entirely its own. Mike Gordon's bass does things other bass players don't think to do. Jon Fishman plays a vacuum cleaner on stage sometimes. Page McConnell holds it all together at the keys while simultaneously expanding it.

Live, Phish operate on two levels: the "Type I" jam, where a song extends but stays near its theme, and the "Type II" jam, where the song dissolves entirely into open improvisation and may not return for half an hour. Both are possible in any given set. That uncertainty is part of the appeal.

The Phish phenomenon extends beyond the music — their fan community (the "phans") represent a genuine subculture, bringing their own arts and crafts, lot culture, and multi-night pilgrimage traditions that make a Phish run something more like a temporary city than a concert series. At outdoor festivals they are in their element.`,
    links: [
      { label: 'Official Site', url: 'https://phish.com', icon: 'language' },
    ],
    touring_regions: ['northeast', 'great-lakes', 'mountain-west'],
  },

  {
    id: 'jgb-melvin-seals',
    name: 'JGB feat. Melvin Seals',
    subtitle: 'Soul · R&B · Bay Area Dead Family',
    icon: 'piano', icon_color: 'green',
    badge_text: 'Dead Family', badge_color: 'green',
    featured: true,
    genres: ['Soul', 'R&B', 'Blues', 'Jam'],
    origin: 'San Francisco, CA',
    active_since: '1975',
    bio_main: "The Jerry Garcia Band with Melvin Seals at the Hammond B-3 organ is one of the most soulful configurations in American music. After Jerry passed, Melvin kept the flame burning — fronting JGB with rotating members and playing with a gospel fire that turns festival fields into Sunday revival tents.",
    bio_sub: 'Melvin Seals has been playing this music for over forty years. It shows.',
    songs: ['Tangled Up in Blue', 'The Harder They Come', 'Deal'],
    full_bio: `Melvin Seals joined the Jerry Garcia Band in 1980 and for the next fifteen years was the other voice in a two-way conversation that defined the JGB sound. Jerry's guitar and Melvin's Hammond B-3 organ spoke to each other the way longtime musical partners do — finishing each other's sentences, creating space, filling it, getting out of the way.

The JGB set list drew heavily from soul and R&B — Bob Dylan covers, reggae, gospel-inflected originals — creating something that felt distinct from the Grateful Dead's psychedelic folk cosmos. The JGB was looser, warmer, more nakedly emotional. Jerry's voice at its best on JGB material had a cracked, worn quality that made the songs feel like confessions.

After Jerry Garcia's death in 1995, Melvin Seals kept the music alive by fronting his own version of JGB with rotating members. The decision was not nostalgia — it was stewardship. Melvin plays these songs because they matter, because the community around them matters, and because the Hammond B-3 still has things to say.

Watching Melvin Seals work a crowd is a lesson in presence. He has the bearing of a gospel organist and the timing of a jazz musician. When the song goes somewhere unexpected, Melvin follows and so does everyone in the field.`,
    links: [
      { label: 'Melvin Seals', url: 'https://melvinseals.com', icon: 'language' },
    ],
    touring_regions: ['pacific-northwest', 'southwest', 'mountain-west', 'great-lakes'],
  },

  {
    id: 'govt-mule',
    name: "Gov't Mule",
    subtitle: 'Heavy Blues · Southern Rock · Power Jam',
    icon: 'flash_on', icon_color: 'red',
    badge_text: 'Heavy Blues', badge_color: 'red',
    featured: true,
    genres: ['Blues Rock', 'Southern Rock', 'Jam', 'Hard Rock'],
    origin: 'Decatur, AL',
    active_since: '1994',
    bio_main: "Warren Haynes founded Gov't Mule as a power-trio side project from the Allman Brothers Band, and it became one of the most beloved heavy jam acts in American rock. Steeped in Deep South blues and playing with muscular conviction, the Mule covers impossible territory in a single set — from slow-burn Delta blues to full-throttle electric storm.",
    bio_sub: 'The Mule plays hard, long, and loud. Bring earplugs. Use them anyway.',
    songs: ['Soulshine', 'Thorazine Shuffle', 'Mule'],
    full_bio: `Warren Haynes formed Gov't Mule in 1994 as a side project from his work with the Allman Brothers Band — a power trio format that stripped away the orchestral complexity of the ABB and replaced it with raw, loud, direct blues-rock. The original trio of Haynes, Allen Woody, and Matt Abts became one of the most critically and commercially admired heavy jam acts of the '90s.

When Allen Woody died in 2000, Haynes grieved and then kept going, cycling through an impressive list of bass players — Danny Louis joined the band in 2005 and has been a permanent fourth member since — and continuing to record and tour with undiminished intensity. The Mule has now logged more years without Woody than with him, and has grown into something larger than any of its phases.

Warren Haynes is one of the great American guitarists of his generation — a player whose tone is immediately identifiable, whose technique is flawless, and whose playing never sacrifices feeling for flash. He plays the guitar like it costs him something. The best Mule performances feel like exorcisms.

At outdoor festivals, Gov't Mule operate at their most dangerous. The extended improvisations breathe more freely, the volume finds its natural level, and Warren tends to push further than usual. Shows regularly exceed three hours. This is not unusual. It is the expectation.`,
    links: [
      { label: 'Official Site', url: 'https://govtmule.com', icon: 'language' },
    ],
    touring_regions: ['southeast', 'mountain-west', 'northeast', 'great-lakes'],
  },

  {
    id: 'dark-star-orchestra',
    name: 'Dark Star Orchestra',
    subtitle: 'Grateful Dead Tribute · Historical Recreations',
    icon: 'auto_awesome', icon_color: 'indigo',
    badge_text: 'GD Tribute', badge_color: 'indigo',
    featured: true,
    genres: ['Jam', 'Psychedelic Rock', 'Folk Rock', 'Tribute'],
    origin: 'Chicago, IL',
    active_since: '1997',
    bio_main: "Dark Star Orchestra does not merely cover the Grateful Dead — they recreate specific historical shows from the Dead's archives with forensic accuracy and genuine reverence. Each night's setlist is drawn from a real Dead concert, announced mid-show. You might land in Fillmore East 1970 or Veneta 1972 on any given night.",
    bio_sub: "The closest thing to seeing the Dead. Most nights, it is very close indeed.",
    songs: ['Dark Star', 'Eyes of the World', 'Playing in the Band'],
    full_bio: `Dark Star Orchestra was founded in Chicago in 1997 by guitarist John Kadlecik, who had spent years studying the Grateful Dead's catalog with an archivist's obsessiveness. The concept was unusual: rather than playing the Dead's greatest hits in a tribute-band format, DSO would recreate entire historical shows — setlist, arrangements, and sonic character — from specific nights in the Dead's touring history.

The mechanic is part of the appeal. Audience members don't know what era they're in until partway through the first set, when the band announces the date. Landing on a 1972 Europe show means one musical universe; landing on a late 1980s show means another. The Dead changed so profoundly across their touring years that each era has its own character, its own heroes, its own arrangements.

What sets DSO apart from other tribute acts is the quality of the musicianship and the seriousness of the historical project. They do not approximate. When they play a 1977 "Scarlet/Fire" from the Cornell Barton Hall show, they play it the way it was played on that night, using the recordings as a primary source. The result is educational in the best possible way — it reveals how dynamic and varied the Dead's music actually was.

For Deadheads who never got to see Garcia, DSO offers something no other band can: a genuine encounter with music that exists nowhere else in the current touring world. For new listeners, it is often their entry point into the larger Dead universe.`,
    links: [
      { label: 'Official Site', url: 'https://darkstarorchestra.net', icon: 'language' },
    ],
    touring_regions: ['mountain-west', 'southwest', 'pacific-northwest', 'great-lakes', 'southeast', 'northeast'],
  },

  {
    id: 'string-cheese-incident',
    name: 'String Cheese Incident',
    subtitle: 'Mountain Jam · Bluegrass · Reggae · Electronica',
    icon: 'celebration', icon_color: 'teal',
    badge_text: 'Colorado Jam', badge_color: 'teal',
    featured: true,
    genres: ['Jam', 'Bluegrass', 'Reggae', 'Electronica', 'Country'],
    origin: 'Crested Butte, CO',
    active_since: '1993',
    bio_main: "The String Cheese Incident emerged from the Colorado ski-town circuit in the early '90s and became the beating heart of the mountain jam scene. Bluegrass, reggae, Latin, electronica, and country-fried rock coexist in their sets without apology. Their community is one of the warmest in the touring world.",
    bio_sub: 'Their festivals feel like homecomings, even the first time.',
    songs: ['Born on the Wrong Planet', 'Texas', 'Just One Story'],
    full_bio: `The String Cheese Incident began in the ski town of Crested Butte, Colorado in 1993, when a group of young musicians who had been playing local gigs started fusing everything they loved about music into a single live experience. The result had no obvious precedent: acoustic instruments playing reggae rhythms, bluegrass flat-picking over Latin percussion, electronic textures layered into country songs.

Bill Nershi's acoustic guitar provides the melodic core while Michael Kang's electric mandolin adds a layer of shimmering texture that sounds like nothing else in American roots music. Keith Moseley, Michael Travis, and Kyle Hollingsworth complete the lineup — a band where every member contributes to arrangements that reward repeated listening.

SCI became one of the first jam bands to develop their own festival ecosystem, founding the Horning's Hideout and Harmony Festival events and approaching concert production with an environmental and community ethics that influenced the entire scene. They were thinking about the fan experience holistically before that was a common framework.

Their fanbase — the "Cheese" community — is multigenerational now. Parents bring children who bring their own friends. The music connects across age gaps in the way that the best campfire music always has.`,
    links: [
      { label: 'Official Site', url: 'https://stringcheeseincident.com', icon: 'language' },
    ],
    touring_regions: ['mountain-west', 'pacific-northwest', 'great-lakes', 'southwest'],
  },

  {
    id: 'old-crow-medicine-show',
    name: 'Old Crow Medicine Show',
    subtitle: 'Old-Time String Band · Appalachian Folk · Stomp',
    icon: 'forest', icon_color: 'amber',
    badge_text: 'Old Timey', badge_color: 'amber',
    featured: true,
    genres: ['Old-Time', 'String Band', 'Americana', 'Folk', 'Bluegrass'],
    origin: 'Boone, NC / Nashville, TN',
    active_since: '1998',
    bio_main: "Old Crow Medicine Show started on Doc Watson's front porch in Boone, NC, after Ketch Secor played for him and got invited to stay. From Nashville's deep well of Americana, OCMS carries the torch of string-band music into arenas while keeping it as raw and stomping as a barn dance.",
    bio_sub: "They play like the fire is about to go out. It never does.",
    songs: ['Wagon Wheel', 'I Hear Them All', "Take 'Em Away"],
    full_bio: `Old Crow Medicine Show's origin story is one of the best in American music. Ketch Secor and his bandmates were busking on the streets of Boone, North Carolina when they found themselves playing on the front porch of Doc Watson — the legendary flatpicking guitarist who had documented and preserved old-time music for fifty years. Doc liked what he heard and invited them to stay a while.

That encounter gave the band its direction: to carry Appalachian string-band music forward without softening it. OCMS plays fiddle tunes, banjo pieces, and stomp songs with the energy of a punk band and the historical awareness of folklorists. Their music sounds genuinely old because it is built from genuinely old materials — rhythms and progressions that predate rock and roll by a century.

Their song "Wagon Wheel" — built around a Bob Dylan sketch that Ketch Secor completed — became one of the most-covered songs of the 2000s and introduced a generation of listeners to the string-band sound. But "Wagon Wheel" is the entry point, not the destination. The deeper catalog is where OCMS earns their reputation: shape-note harmonies, fiddle breakdowns, rural imagery that never becomes kitsch.

At outdoor festivals, OCMS is often the set that people cite as a revelation. Put them on a stage in a field as the sun goes down, and something primal clicks into place. This is what this music was made for.`,
    links: [
      { label: 'Official Site', url: 'https://crowmedicine.com', icon: 'language' },
    ],
    touring_regions: ['southeast', 'northeast', 'great-lakes', 'mountain-west'],
  },

  // ── Not featured on homepage — has a detail page and appears on /artists ────

  {
    id: 'greensky-bluegrass',
    name: 'Greensky Bluegrass',
    subtitle: 'Progressive Bluegrass · Jam · Michigan Roots',
    icon: 'grass', icon_color: 'green',
    badge_text: 'Michigan Jam', badge_color: 'green',
    featured: false,
    genres: ['Progressive Bluegrass', 'Jam', 'Folk', 'Americana'],
    origin: 'Kalamazoo, MI',
    active_since: '2000',
    bio_main: "Greensky Bluegrass grew up playing Michigan bars and festivals, blending acoustic precision with the improvisational vocabulary of a jam band. Their five-piece lineup — mandolin, banjo, guitar, dobro, bass — plays songs that hit hard and then open into wide improvised spaces.",
    bio_sub: "Loud, fast, and genuinely moving. Michigan's finest export after Billy Strings.",
    songs: ['Burn Them', 'Leap Year', 'Worried Bout the Weather'],
    full_bio: `Greensky Bluegrass formed in Kalamazoo, Michigan in 2000 and spent the better part of a decade building an audience one bar and festival stage at a time. What they were building toward was a specific sound: bluegrass instrumentation played at jam-band dynamics, with original songs that had the emotional directness of country music and the structural ambition of jazz.

Paul Hoffman's mandolin leads the group's harmonic language — his playing sits at the intersection of David Grisman's speed and the raw urgency of old-time music. Anders Beck's resonator guitar (dobro) provides a sonic texture that most bluegrass bands save for ballads; Greensky deploys it aggressively, using its sustain and slide vocabulary in the middle of uptempo jams with genuinely startling effect.

The songs themselves are the foundation. Greensky writes originals with the attention to craft that the best Americana artists bring — verses that earn their choruses, bridges that genuinely surprise. "Worried Bout the Weather" became a fan favorite not because of any particular jam peak but because the song is just good: the kind of track that sounds inevitable once you know it.

Their following in the Midwest is devoted and large. In the broader jam world, they are the band that bluegrass purists find themselves unable to dislike and jam fans find themselves unable to stop watching. Both communities claim them. Both are right.`,
    links: [
      { label: 'Official Site', url: 'https://greenskybluegrass.com', icon: 'language' },
    ],
    touring_regions: ['great-lakes', 'mountain-west', 'northeast', 'pacific-northwest'],
  },
]

export function findArtist(id: string): Artist | undefined {
  return ARTISTS.find(a => a.id === id)
}
