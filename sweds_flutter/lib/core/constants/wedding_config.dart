/// Single source of truth for every piece of wedding content.
abstract final class WeddingConfig {
  static const bride = 'Sayantika';
  static const groom = 'Som';
  static const hashtag = '#SomKiSayantika';
  static final DateTime date = DateTime(2026, 12, 13, 19);
  static const dateLabel = '13 · 12 · 2026';
  static const rsvpBy = '13 December 2026';

  static const venueName = 'Weding Heritage Palace,Midnapore';
  static const venueCity = 'Midnapore, West Bengal';
  static const venueCityShort = 'Midnapore';
  static const venueAddress =
      'Palace Grounds, Gopegarh Heritage Enclave, Midnapore, West Bengal 721101';
  static const mapsUrl =
      'https://www.google.com/maps/search/?api=1&query=Midnapore+West+Bengal';

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
  StoryChapter(
    date: 'November 2022',
    title: 'The First Spark',
    body:
        'A chance conversation, a bustling Kolkata café, and cups of steaming '
        'Darjeeling tea that stretched from afternoon into twilight. What started '
        'as friendship sparked into something deeply profound.',
    image: 'story_1',
    seed: 0,
  ),
  StoryChapter(
    date: 'Autumn 2023',
    title: 'Growing in Love',
    body:
        'Evening strolls along the ghats, endless playlists, shared values and '
        'dreams. In every smile, we found a sanctuary and quietly realized that our '
        'hearts had discovered their lifelong home.',
    image: 'story_2',
    seed: 1,
  ),
  StoryChapter(
    date: 'December 2024',
    title: 'Two Families, One Heart',
    body:
        'When love is true, it yearns for family blessings. The afternoon our '
        'parents met over warm cha and mishti, warmth filled the room. Both families '
        'embraced our love wholeheartedly, turning our story into a shared celebration.',
    image: 'story_3',
    seed: 2,
  ),
  StoryChapter(
    date: 'March 2025',
    title: 'The Ashirbaad',
    body:
        'Echoes of the sacred shankha and joyous uludhwani as our elders blessed us '
        'with dhan-durba, gold, and boundless love. A union chosen by our hearts and '
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
    'Ashirbaad & Aiburobhat',
    '9 December',
    '6:00 PM',
    'Auspicious pre-wedding elder blessings with dhan-durba, followed by the traditional bachelor feast.',
    'Heritage Courtyard',
  ),
  WeddingEvent(
    'Gaye Holud & Mehendi',
    '10 December',
    '11:00 AM',
    'Fragrant turmeric paste, intricate henna, vibrant marigolds, and the joy of wedding tattwa gifts.',
    'Lakeside Pavilion',
  ),
  WeddingEvent(
    'Sangeet & Adda',
    '11 December',
    '7:30 PM',
    'An evening of Rabindra Sangeet, beats, celebratory dhol, dance, and spirited Bengali adda.',
    'The Grand Ballroom',
  ),
  WeddingEvent(
    'Shubho Bibaho',
    '12 December',
    '7:00 PM',
    'Saat Paak, Shubho Drishti, Mala Badal, and Sindoor Daan beneath a canopy of jasmine and tuberoses.',
    'Rajbari Mandap',
  ),
  WeddingEvent(
    'Bou Bhaat & Reception',
    '13 December',
    '8:00 PM',
    'Welcoming the new bride with the traditional rice ceremony, followed by an opulent gala dinner.',
    'Palace Gardens',
  ),
];

const kVenueSchedule = <(String, String)>[
  ('4:30 PM', 'Bor Jatri & Royal Boron with Conch Shells & Uludhwani'),
  ('6:00 PM', 'Saat Paak & Shubho Drishti beneath Betel Leaves'),
  ('7:30 PM', 'Mala Badal, Vedic Pheras & Sindoor Daan'),
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
