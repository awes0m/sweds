import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class Lux {
  static const background = Color(0xFFFAEEEB);
  static const ivory = Color(0xFFFFFDF8);
  static const champagne = Color(0xFFE8D7C3);
  static const gold = Color(0xFFD4AF37);
  static const goldDeep = Color(0xFF9E751D);
  static const goldLight = Color(0xFFF7E2A2);
  static const rose = Color(0xFFE8B8B0);
  static const dark = Color(0xFF281E1A);

  // Bengali Royal Palette additions:
  static const crimson = Color(0xFF8B1E2D);
  static const crimsonDeep = Color(0xFF5E0E1B);
  static const crimsonLight = Color(0xFFB82D3E);
  static const alta = Color(0xFF9E1B32);
  static const marigold = Color(0xFFE67E22);
  static const terracotta = Color(0xFFB85333);
  static const sandalwood = Color.fromARGB(255, 240, 154, 15);

  // (base, bloom, fog) stops the background moves through as you scroll.
  static const _stops = <List<Color>>[
    [
      Color(0xFFFAF0EE),
      Color(0xFFFFCF90),
      Color(0xFFE8C5BB),
    ], // warm red-gold base
    [
      Color(0xFFFAE8E5),
      Color(0xFFEEA89C),
      Color(0xFFE0C4BB),
    ], // richer rose/crimson
    [Color(0xFFFCF0E5), Color(0xFFFFD580), Color(0xFFEDD5B0)], // golden amber
    [
      Color(0xFFF5E0DC),
      Color(0xFFD4836E),
      Color(0xFFD9B09A),
    ], // deep terracotta/crimson
  ];

  static (Color, Color, Color) sceneColors(double t) {
    final x = t.clamp(0.0, 1.0) * (_stops.length - 1);
    final i = x.floor().clamp(0, _stops.length - 2);
    final f = x - i;
    Color l(int k) => Color.lerp(_stops[i][k], _stops[i + 1][k], f)!;
    return (l(0), l(1), l(2));
  }
}

abstract final class LuxText {
  /// Playfair Display — headings.
  static TextStyle display(
    double size, {
    Color color = Lux.dark,
    FontWeight weight = FontWeight.w400,
    double height = 1.05,
    double spacing = -0.5,
    FontStyle style = FontStyle.normal,
  }) => GoogleFonts.playfairDisplay(
    fontSize: size,
    color: color,
    fontWeight: weight,
    height: height,
    letterSpacing: spacing,
    fontStyle: style,
  );

  /// Cormorant Garamond — secondary / editorial voice.
  static TextStyle serif(
    double size, {
    Color color = Lux.dark,
    FontWeight weight = FontWeight.w400,
    FontStyle style = FontStyle.italic,
    double spacing = 0,
    double height = 1.2,
  }) => GoogleFonts.cormorantGaramond(
    fontSize: size,
    color: color,
    fontWeight: weight,
    fontStyle: style,
    letterSpacing: spacing,
    height: height,
  );

  /// Inter — body copy.
  static TextStyle body(
    double size, {
    Color color = Lux.dark,
    double opacity = 0.78,
    FontWeight weight = FontWeight.w400,
    double height = 1.6,
    double spacing = 0,
  }) => GoogleFonts.inter(
    fontSize: size,
    color: color.withValues(alpha: opacity),
    fontWeight: weight,
    height: height,
    letterSpacing: spacing,
  );

  static TextStyle eyebrow([Color color = Lux.crimson]) =>
      GoogleFonts.cormorantGaramond(
        fontSize: 15,
        letterSpacing: 5,
        fontWeight: FontWeight.w700,
        color: color,
      );

  /// Hollow giant numerals used as depth layers.
  static TextStyle outline(double size) => GoogleFonts.playfairDisplay(
    fontSize: size,
    height: 1,
    foreground: Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Lux.gold.withValues(alpha: 0.5),
  );
}

extension LuxContext on BuildContext {
  /// Interpolates a size between a phone (380) and desktop (1600) width.
  double fluid(
    double min,
    double max, {
    double minW = 380,
    double maxW = 1600,
  }) {
    final w = MediaQuery.sizeOf(this).width;
    final t = ((w - minW) / (maxW - minW)).clamp(0.0, 1.0);
    return min + (max - min) * t;
  }
}
