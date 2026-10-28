import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'lux.dart';

ThemeData buildLuxTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Lux.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Lux.gold,
      brightness: Brightness.light,
    ).copyWith(primary: Lux.crimson, surface: Lux.background),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
  );
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: c, width: w),
      );
  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.65),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: LuxText.serif(18, style: FontStyle.normal, color: Lux.dark.withValues(alpha: 0.6)),
      floatingLabelStyle: LuxText.serif(17, style: FontStyle.normal, color: Lux.crimson, weight: FontWeight.w600),
      errorStyle: LuxText.body(12, color: const Color(0xFFB3463B), opacity: 1),
      border: border(Lux.champagne),
      enabledBorder: border(Lux.champagne),
      focusedBorder: border(Lux.crimson, 1.6),
      errorBorder: border(const Color(0xFFB3463B)),
      focusedErrorBorder: border(const Color(0xFFB3463B), 1.6),
    ),
  );
}
