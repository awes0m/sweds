import 'package:flutter/foundation.dart';

@immutable
class SectionSpec {
  const SectionSpec(this.id, this.label, this.heightFactor,
      {this.pinned = false, this.minHeight = 0});
  final String id, label;
  final double heightFactor, minHeight;

  /// Pinned sections are "stages": the content sticks to the viewport while
  /// the extra scroll distance scrubs the scene (progress 0..1).
  final bool pinned;
}

/// Index constants for [kSections].
abstract final class Sec {
  static const hero = 0,
      story = 1,
      proposal = 2,
      timeline = 3,
      venue = 4,
      gallery = 5,
      countdown = 6,
      rsvp = 7,
      footer = 8;
}

const kSections = <SectionSpec>[
  SectionSpec('home', 'Home', 1.75, pinned: true),
  SectionSpec('story', 'Our Story', 3.6, pinned: true),
  SectionSpec('proposal', 'Proposal', 2.2, pinned: true),
  SectionSpec('celebrations', 'Celebrations', 4.2, pinned: true),
  SectionSpec('venue', 'Venue', 2.0, pinned: true),
  SectionSpec('gallery', 'Gallery', 1.7, minHeight: 1500),
  SectionSpec('countdown', 'Countdown', 1.1, minHeight: 760),
  SectionSpec('rsvp', 'RSVP', 1.25, minHeight: 1000),
  SectionSpec('footer', 'Farewell', 0.8, minHeight: 520),
];

@immutable
class SectionLayout {
  const SectionLayout(this.spec, this.top, this.height, this.viewport);
  final SectionSpec spec;
  final double top, height, viewport;

  double get pinTravel => height - viewport;

  /// Pinned: 0..1 across the pinned travel.
  /// Flow: 0..1 from "top touches bottom of screen" to "bottom leaves top".
  double progressAt(double offset) {
    if (spec.pinned) return ((offset - top) / pinTravel).clamp(0.0, 1.0);
    return ((offset - top + viewport) / (height + viewport)).clamp(0.0, 1.0);
  }
}
