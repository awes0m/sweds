import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/constants/wedding_config.dart';
import '../models/rsvp_models.dart';
import '../utils/card_download.dart';

/// Generates high-resolution PNG wedding invitation and greeting cards
/// for confirmed or declining RSVP guests.
class CardGeneratorService {
  const CardGeneratorService();

  static const double cardWidth = 1080;
  static const double cardHeight = 1520;

  /// Generates the PNG bytes for an invite or greeting card.
  Future<Uint8List> generateCardBytes(RsvpSubmission submission) async {
    final isAccept = submission.attendance == Attendance.accepts;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, cardWidth, cardHeight));

    // 1. Background gradient
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(cardWidth, cardHeight),
        [
          const Color(0xFFFDFBF7),
          const Color(0xFFF9F3E5),
          const Color(0xFFF2E6CE),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRect(const Rect.fromLTWH(0, 0, cardWidth, cardHeight), bgPaint);

    // 2. Ornate gold borders
    _drawBordersAndCorners(canvas);

    // 3. Card Content
    if (isAccept) {
      _drawAcceptedInviteContent(canvas, submission);
    } else {
      _drawDeclinedGreetingContent(canvas, submission);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(cardWidth.toInt(), cardHeight.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Generates card and triggers browser/device file download.
  Future<Uint8List> generateAndDownload(RsvpSubmission submission) async {
    final bytes = await generateCardBytes(submission);
    final isAccept = submission.attendance == Attendance.accepts;
    final sanitizedName = submission.name
        .trim()
        .replaceAll(RegExp(r'[^\w\s]+'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    final fileName = isAccept
        ? 'Sayantika_Som_Wedding_Invite_${sanitizedName.isEmpty ? 'Guest' : sanitizedName}.png'
        : 'Sayantika_Som_Wedding_Greeting_${sanitizedName.isEmpty ? 'Friend' : sanitizedName}.png';

    downloadCardImage(bytes, fileName);
    return bytes;
  }

  void _drawBordersAndCorners(Canvas canvas) {
    const goldColor = Color(0xFFC49A2C);
    const goldDeep = Color(0xFF8B6B1B);
    const goldLight = Color(0xFFE8D08D);

    // Outer primary border
    final outerBorder = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(36, 36, cardWidth - 72, cardHeight - 72),
        const Radius.circular(24),
      ),
      outerBorder,
    );

    // Thin inner dashed / accent border
    final innerBorder = Paint()
      ..color = goldDeep.withValues(alpha: .5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(48, 48, cardWidth - 96, cardHeight - 96),
        const Radius.circular(16),
      ),
      innerBorder,
    );

    // Corner flourishes
    _drawCornerFlourish(canvas, 48, 48, 0, goldLight, goldDeep);
    _drawCornerFlourish(canvas, cardWidth - 48, 48, 1, goldLight, goldDeep);
    _drawCornerFlourish(canvas, cardWidth - 48, cardHeight - 48, 2, goldLight, goldDeep);
    _drawCornerFlourish(canvas, 48, cardHeight - 48, 3, goldLight, goldDeep);
  }

  void _drawCornerFlourish(
    Canvas canvas,
    double x,
    double y,
    int quadrant,
    Color light,
    Color deep,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(quadrant * 1.57079632679); // 90 deg steps

    final paint = Paint()
      ..color = deep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path()
      ..moveTo(0, 24)
      ..quadraticBezierTo(14, 14, 24, 0)
      ..moveTo(6, 36)
      ..quadraticBezierTo(24, 24, 36, 6);
    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = light;
    canvas.drawCircle(const Offset(16, 16), 3.5, dotPaint);

    canvas.restore();
  }

  void _drawAcceptedInviteContent(Canvas canvas, RsvpSubmission s) {
    const crimson = Color(0xFF6B1E22);
    const goldDeep = Color(0xFF8B6B1B);
    const dark = Color(0xFF2C221E);

    double y = 84;

    // Eyebrow
    y = _drawCenteredText(
      canvas,
      'WITH THE BLESSINGS OF BOTH FAMILIES',
      y: y,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 4.5,
      color: crimson,
    );

    y += 12;

    // Bengali Heading
    y = _drawCenteredText(
      canvas,
      'SHUBHO BIBAHO · শুভ বিবাহ',
      y: y,
      fontSize: 26,
      fontWeight: FontWeight.w700,
      letterSpacing: 5.0,
      color: goldDeep,
    );

    y += 18;
    _drawOrnamentalDivider(canvas, y);
    y += 24;

    // Couple Names
    y = _drawCenteredText(
      canvas,
      'Sayantika',
      y: y,
      fontSize: 66,
      fontWeight: FontWeight.w600,
      color: crimson,
      fontFamily: 'Cinzel Decorative',
    );

    y -= 8;
    y = _drawCenteredText(
      canvas,
      '&',
      y: y,
      fontSize: 34,
      fontStyle: FontStyle.italic,
      color: goldDeep,
    );

    y -= 8;
    y = _drawCenteredText(
      canvas,
      'Som',
      y: y,
      fontSize: 66,
      fontWeight: FontWeight.w600,
      color: crimson,
      fontFamily: 'Cinzel Decorative',
    );

    y += 16;
    _drawOrnamentalDivider(canvas, y);
    y += 26;

    // Invitation Line
    y = _drawCenteredText(
      canvas,
      'Cordially invite the presence of',
      y: y,
      fontSize: 22,
      fontStyle: FontStyle.italic,
      color: dark.withValues(alpha: .75),
    );

    y += 8;

    // Guest Name
    y = _drawCenteredText(
      canvas,
      s.name.trim(),
      y: y,
      fontSize: 40,
      fontWeight: FontWeight.w700,
      color: crimson,
      letterSpacing: 1.2,
    );

    y += 8;

    // Seats badge
    final guestLabel = s.guests == 1
        ? '1 Guest Seat Reserved'
        : '${s.guests} Guest Seats Reserved';
    y = _drawPillBadge(canvas, guestLabel, y: y, color: goldDeep);

    y += 20;

    // Hearty Welcome message
    y = _drawParagraph(
      canvas,
      'We are overjoyed to welcome you into our celebration of eternal love and companionship! '
      'Your warm presence, prayers, and gracious blessings will make our special day truly complete.',
      y: y,
      fontSize: 21,
      height: 1.45,
      color: dark.withValues(alpha: .85),
      maxWidth: 860,
    );

    y += 32;

    // Events and Venue Details Box
    _drawVenueBox(
      canvas,
      y: y,
      boxHeight: 390,
      weddingTitle: 'WEDDING CEREMONY · SHUBHO BIBAHO',
      weddingDate: WeddingConfig.weddingDateLabel,
      weddingTime: WeddingConfig.weddingTimeLabel,
      weddingVenue: WeddingConfig.weddingVenueName,
      weddingAddress: WeddingConfig.weddingVenueAddress,
      receptionTitle: 'RECEPTION GALA · BOU BHAAT',
      receptionDate: WeddingConfig.receptionDateLabel,
      receptionTime: WeddingConfig.receptionTimeLabel,
      receptionVenue: WeddingConfig.receptionVenueName,
      receptionAddress: WeddingConfig.receptionVenueAddress,
    );

    // Footer
    _drawFooter(canvas, '#SomKiSayantika · RSVP Confirmed');
  }

  void _drawDeclinedGreetingContent(Canvas canvas, RsvpSubmission s) {
    const crimson = Color(0xFF6B1E22);
    const goldDeep = Color(0xFF8B6B1B);
    const dark = Color(0xFF2C221E);

    double y = 140;

    // Eyebrow
    y = _drawCenteredText(
      canvas,
      'WARMEST GREETINGS & BLESSINGS',
      y: y,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 5.0,
      color: goldDeep,
    );

    y += 16;

    // Bengali Greeting
    y = _drawCenteredText(
      canvas,
      'আন্তরিক শুভেচ্ছা ও ভালোবাসা',
      y: y,
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 3.5,
      color: crimson,
    );

    y += 24;
    _drawOrnamentalDivider(canvas, y);
    y += 34;

    // Couple Names
    y = _drawCenteredText(
      canvas,
      'Sayantika & Som',
      y: y,
      fontSize: 58,
      fontWeight: FontWeight.w600,
      color: crimson,
      fontFamily: 'Cinzel Decorative',
    );

    y += 18;
    _drawOrnamentalDivider(canvas, y);
    y += 48;

    // Personalized greeting
    y = _drawCenteredText(
      canvas,
      'Dear ${s.name.trim()},',
      y: y,
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: crimson,
    );

    y += 32;

    // Heartfelt Message (No venue details, as strictly specified)
    y = _drawParagraph(
      canvas,
      'Though we will dearly miss having you beside us in person on our wedding day, '
      'your warm wishes, prayers, and heartfelt blessings will accompany us as we step '
      'into this beautiful new chapter together.',
      y: y,
      fontSize: 26,
      height: 1.6,
      color: dark.withValues(alpha: .85),
      maxWidth: 840,
    );

    y += 36;

    y = _drawParagraph(
      canvas,
      'We hold your blessings close to our hearts with boundless gratitude. '
      'Wishing you and your family lasting peace, good health, and joyful moments always.',
      y: y,
      fontSize: 25,
      height: 1.6,
      color: dark.withValues(alpha: .8),
      maxWidth: 840,
    );

    y += 60;

    y = _drawCenteredText(
      canvas,
      'With heartfelt love & gratitude,',
      y: y,
      fontSize: 24,
      fontStyle: FontStyle.italic,
      color: goldDeep,
    );

    y += 12;

    _drawCenteredText(
      canvas,
      'Sayantika & Som',
      y: y,
      fontSize: 38,
      fontWeight: FontWeight.w700,
      color: crimson,
    );

    // Footer
    _drawFooter(canvas, '#SomKiSayantika · Thank You For Your Blessings');
  }

  void _drawVenueBox(
    Canvas canvas, {
    required double y,
    required double boxHeight,
    required String weddingTitle,
    required String weddingDate,
    required String weddingTime,
    required String weddingVenue,
    required String weddingAddress,
    required String receptionTitle,
    required String receptionDate,
    required String receptionTime,
    required String receptionVenue,
    required String receptionAddress,
  }) {
    const crimson = Color(0xFF6B1E22);
    const goldDeep = Color(0xFF8B6B1B);
    const dark = Color(0xFF2C221E);

    final boxRect = Rect.fromLTWH(90, y, cardWidth - 180, boxHeight);
    final bgPaint = Paint()
      ..color = const Color(0xFFFAF4E7).withValues(alpha: .95)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0xFFC49A2C).withValues(alpha: .6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(RRect.fromRectAndRadius(boxRect, const Radius.circular(18)), bgPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(boxRect, const Radius.circular(18)), borderPaint);

    double cy = y + 22;

    // Wedding Block
    cy = _drawCenteredText(
      canvas,
      weddingTitle,
      y: cy,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: 2.5,
      color: crimson,
    );

    cy += 6;
    cy = _drawCenteredText(
      canvas,
      '$weddingDate · $weddingTime',
      y: cy,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: goldDeep,
    );

    cy += 4;
    cy = _drawCenteredText(
      canvas,
      weddingVenue,
      y: cy,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: dark,
    );

    cy += 4;
    cy = _drawCenteredText(
      canvas,
      weddingAddress,
      y: cy,
      fontSize: 17,
      color: dark.withValues(alpha: .75),
    );

    cy += 16;

    // Subtle divider
    final divPaint = Paint()
      ..color = const Color(0xFFC49A2C).withValues(alpha: .35)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(180, cy), Offset(cardWidth - 180, cy), divPaint);

    cy += 16;

    // Reception Block
    cy = _drawCenteredText(
      canvas,
      receptionTitle,
      y: cy,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: 2.5,
      color: crimson,
    );

    cy += 6;
    cy = _drawCenteredText(
      canvas,
      '$receptionDate · $receptionTime',
      y: cy,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: goldDeep,
    );

    cy += 4;
    cy = _drawCenteredText(
      canvas,
      receptionVenue,
      y: cy,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: dark,
    );

    cy += 4;
    _drawCenteredText(
      canvas,
      receptionAddress,
      y: cy,
      fontSize: 17,
      color: dark.withValues(alpha: .75),
    );
  }

  void _drawOrnamentalDivider(Canvas canvas, double y) {
    const gold = Color(0xFFC49A2C);
    final linePaint = Paint()
      ..color = gold.withValues(alpha: .6)
      ..strokeWidth = 1.2;

    const halfW = 160.0;
    canvas.drawLine(Offset(cardWidth / 2 - halfW, y), Offset(cardWidth / 2 - 20, y), linePaint);
    canvas.drawLine(Offset(cardWidth / 2 + 20, y), Offset(cardWidth / 2 + halfW, y), linePaint);

    // Center diamond
    final diamondPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(cardWidth / 2, y - 6)
      ..lineTo(cardWidth / 2 + 6, y)
      ..lineTo(cardWidth / 2, y + 6)
      ..lineTo(cardWidth / 2 - 6, y)
      ..close();
    canvas.drawPath(path, diamondPaint);
  }

  double _drawPillBadge(
    Canvas canvas,
    String text, {
    required double y,
    required Color color,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          fontFamilyFallback: const ['Georgia', 'serif'],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final pillW = tp.width + 36;
    final pillH = tp.height + 14;
    final pillRect = Rect.fromCenter(
      center: Offset(cardWidth / 2, y + pillH / 2),
      width: pillW,
      height: pillH,
    );

    final bg = Paint()
      ..color = color.withValues(alpha: .12)
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = color.withValues(alpha: .7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawRRect(RRect.fromRectAndRadius(pillRect, const Radius.circular(20)), bg);
    canvas.drawRRect(RRect.fromRectAndRadius(pillRect, const Radius.circular(20)), border);

    tp.paint(canvas, Offset((cardWidth - tp.width) / 2, y + 7));
    return y + pillH;
  }

  double _drawCenteredText(
    Canvas canvas,
    String text, {
    required double y,
    required double fontSize,
    Color color = const Color(0xFF2C221E),
    FontWeight fontWeight = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
    double letterSpacing = 0,
    String? fontFamily,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          fontFamily: fontFamily,
          fontFamilyFallback: const ['Cinzel', 'Playfair Display', 'Georgia', 'serif'],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: cardWidth - 140);

    tp.paint(canvas, Offset((cardWidth - tp.width) / 2, y));
    return y + tp.height;
  }

  double _drawParagraph(
    Canvas canvas,
    String text, {
    required double y,
    required double fontSize,
    required double height,
    required Color color,
    required double maxWidth,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          height: height,
          fontFamilyFallback: const ['Cormorant Garamond', 'Georgia', 'serif'],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    tp.paint(canvas, Offset((cardWidth - tp.width) / 2, y));
    return y + tp.height;
  }

  void _drawFooter(Canvas canvas, String tagline) {
    _drawCenteredText(
      canvas,
      tagline,
      y: cardHeight - 88,
      fontSize: 16,
      letterSpacing: 3.0,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF8B6B1B),
    );
  }
}
