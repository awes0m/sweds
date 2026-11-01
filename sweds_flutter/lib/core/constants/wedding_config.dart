/// Single source of truth for every piece of wedding content.
abstract final class WeddingConfig {
  static const bride = 'Sayantika';
  static const groom = 'Som';
  static const hashtag = '#SomKiSayantika';
  static final DateTime date = DateTime(2026, 12, 13, 19);
  static const dateLabel = '13 · 12 · 2026';
  static const rsvpBy = '13 December 2026';

  static const venueName = 'Lodge Wedding Palace,Midnapore';
  static const venueCity = 'Midnapore, West Bengal';
  static const venueCityShort = 'Midnapore';
  static const venueAddress = 'Keranitola, Midnapore, West Bengal 721101';
  static const mapsUrl = 'https://maps.app.goo.gl/xm3wLHpkViL3BQHSA';

  static Duration remaining() {
    final d = date.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }
}

class StoryChapter {
  const StoryChapter({
    required this.date,
    required this.title,
    required this.body,
    required this.image,
    required this.seed,
  });
  final String date, title, body, image;
  final int seed;
}

const kStory = <StoryChapter>[
  Story Chapter(
    date: 'December 2025',
    title: 'The First Spark',
    body:
        'A chance encounter at a family gathering,'
        'over a delicate cup of tea, began with a simple conversation. '
        'what seemed like an ordinary moment blossomed into an  unexpected friendship.',
    image: 'story_1',
    seed: 0,
  ),
  StoryChapter(
    date: ' As The Seasons Unfold',
    title: 'Growing in Love',
    body:
        'From leisurely evening strolls through the city to cherished movie dates, '
        'sharing values, dreams,and little moments,'
        'we found our hearts walking gently in the same direction.',
    image: 'story_2',
    seed: 1,
  ),
  StoryChapter(
    date: 'April 2026',
    title: 'Two Families, One Heart',
    body:
        'And then came a beautiful day when two families came together, '
        'hearts met with warmth,and their blessings gently embraced a bond  '
        'that had blossomed into something truly special.',
    image: 'story_3',
    seed: 2,
  ),
  StoryChapter(
    date: 'September 2025',
    title: 'The Engagement',
    body:
        'Echoes of the sacred shankha and joyous uludhwani as our elders blessed us '
        'with dhan-durba, and boundless love. A union chosen by our hearts and '
        'joyously arranged with the blessings of both our families.',
    image: 'story_4',
    seed: 3,
  ),
];

class WeddingEvent {
  const WeddingEvent(this.name, this.date, this.time, this.blurb, this.place);
  final String name, date, time, blurb, place;
}

const kEvents = <WeddingEvent>[
  WeddingEvent(
    'Aiburobhat',
    '12 December 2026',
    'Bride-11:00 AM, Groom-1:00 PM',
    'Auspicious pre-wedding elder blessings with dhan-durba, followed by the traditional bachelor feast.',
    'Groom Home/Bride Home',
  ),
  WeddingEvent(
    'Gaye Holud',
    '13 December 2026',
    '9:00 AM',
    'Fragrant turmeric paste, intricate henna, vibrant marigolds, and the joy of wedding tattwa gifts.',
    'Groom home -> Lodge Wedding Palace, Midnapore',
  ),
  WeddingEvent(
    'Shubho Bibaho',
    '13 December',
    '7:00 PM onwards',
    'Saat Paak, Shubho Drishti, Mala Badal, and Sindoor Daan beneath a canopy of jasmine and tuberoses.',
    'Lodge Wedding Palace, Midnapore',
  ),
  WeddingEvent(
    'Bodhu Boron & Adda',
    '14 December',
    'Evening',
    'Welcome the new Bride and Groom with open hearts, spirited Bengali adda and love.',
    'Groom Residence in Haldia',
  ),
  WeddingEvent(
    'Bou Bhaat & Reception',
    '15 December',
    '8:00 PM',
    'Welcoming the new bride with the traditional rice ceremony, followed by an opulent gala dinner.',
    'Groom Residence, Haldia',
  ),
];

const kVenueSchedule = <(String, String)>[
  ('6:00 PM', 'Bor Jatri & Royal Boron with Conch Shells & Uludhwani'),
  ('9:00 PM', 'Saat Paak & Shubho Drishti beneath Betel Leaves'),
  ('10:30 PM', 'Mala Badal, Vedic Pheras & Sindoor Daan'),
  ('9:00 PM', 'Traditional Grand Bengali Feast & Celebrations'),
];

class GalleryItem {
  const GalleryItem(this.name, this.seed, this.aspect);
  final String name;
  final int seed;
  final double aspect; // width / height
}

const kGallery = <GalleryItem>[
  GalleryItem('gallery_1', 0, 0.78),
  GalleryItem('gallery_2', 1, 1.0),
  GalleryItem('gallery_3', 2, 0.9),
  GalleryItem('gallery_4', 3, 1.05),
  GalleryItem('gallery_5', 4, 0.82),
  GalleryItem('gallery_6', 5, 0.74),
];
