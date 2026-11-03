import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/constants/wedding_config.dart';
import '../models/rsvp_models.dart';
import '../utils/card_download.dart';

/// Generates authentic Bengali wedding invitation and greeting cards (PNG)
/// styled in royal bridal red and gold foil calligraphy with traditional motifs.
class CardGeneratorService {
  const CardGeneratorService();

  static const double cardWidth = 1080;
  static const double cardHeight = 1520;

  /// Default invitation submission for guests previewing/downloading the card directly.
  static RsvpSubmission defaultInviteSubmission({String name = 'Honored Guest'}) =>
      RsvpSubmission(
        name: name,
        email: '',
        phone: '',
        attendance: Attendance.accepts,
        events: AttendingEvents.both,
        guests: 2,
        message: '',
      );

  /// Generates the high-resolution PNG bytes for an invite or greeting card.
  Future<Uint8List> generateCardBytes(RsvpSubmission submission) async {
    final isAccept = submission.attendance == Attendance.accepts;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, cardWidth, cardHeight));

    // 1. Royal Bengali Wedding Crimson/Velvet Background Gradient
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(cardWidth, cardHeight),
        [
          const Color(0xFF4A070E), // Deep Royal Maroon
          const Color(0xFF6F1119), // Bengali Crimson
          const Color(0xFF881723), // Vibrant Wedding Alta / Vermilion
          const Color(0xFF560911), // Deep Crimson Velvet
        ],
        [0.0, 0.35, 0.70, 1.0],
      );
    canvas.drawRect(const Rect.fromLTWH(0, 0, cardWidth, cardHeight), bgPaint);

    // Subtle ambient golden glow in the center
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        const Offset(cardWidth / 2, cardHeight * 0.42),
        cardWidth * 0.65,
        [
          const Color(0xFFFFD57A).withValues(alpha: .12),
          const Color(0xFFB8860B).withValues(alpha: .04),
          Colors.transparent,
        ],
        [0.0, 0.55, 1.0],
      );
    canvas.drawRect(const Rect.fromLTWH(0, 0, cardWidth, cardHeight), glowPaint);

    // 2. Bengali Ornate Gold Borders & Traditional Kalkas
    _drawBengaliOrnateBorders(canvas);

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
        ? 'Sayantika_Som_Bengali_Wedding_Invite_${sanitizedName.isEmpty ? 'Guest' : sanitizedName}.png'
        : 'Sayantika_Som_Wedding_Greeting_${sanitizedName.isEmpty ? 'Friend' : sanitizedName}.png';

    downloadCardImage(bytes, fileName);
    return bytes;
  }

  void _drawBengaliOrnateBorders(Canvas canvas) {
    const goldPrimary = Color(0xFFF3D588);
    const goldDeep = Color(0xFFC49A2C);
    const goldLight = Color(0xFFFFE8A8);

    // Outer primary gold border
    final outerBorder = Paint()
      ..color = goldPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(36, 36, cardWidth - 72, cardHeight - 72),
        const Radius.circular(22),
      ),
      outerBorder,
    );

    // Intermediate thin decorative accent border
    final midBorder = Paint()
      ..color = goldDeep.withValues(alpha: .65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(46, 46, cardWidth - 92, cardHeight - 92),
        const Radius.circular(16),
      ),
      midBorder,
    );

    // Inner beaded border (dotted pearls)
    final beadPaint = Paint()..color = goldLight.withValues(alpha: .55);
    const double step = 28.0;
    // Top & bottom beading
    for (double x = 70; x < cardWidth - 70; x += step) {
      canvas.drawCircle(Offset(x, 56), 1.8, beadPaint);
      canvas.drawCircle(Offset(x, cardHeight - 56), 1.8, beadPaint);
    }
    // Left & right beading
    for (double y = 70; y < cardHeight - 70; y += step) {
      canvas.drawCircle(Offset(56, y), 1.8, beadPaint);
      canvas.drawCircle(Offset(cardWidth - 56, y), 1.8, beadPaint);
    }

    // 4 Traditional Bengali Corner Kalkas (কল্কা / Paisley Motifs)
    _drawBengaliCornerKalka(canvas, 50, 50, 0, goldLight, goldPrimary, goldDeep);
    _drawBengaliCornerKalka(canvas, cardWidth - 50, 50, 1, goldLight, goldPrimary, goldDeep);
    _drawBengaliCornerKalka(canvas, cardWidth - 50, cardHeight - 50, 2, goldLight, goldPrimary, goldDeep);
    _drawBengaliCornerKalka(canvas, 50, cardHeight - 50, 3, goldLight, goldPrimary, goldDeep);
  }

  void _drawBengaliCornerKalka(
    Canvas canvas,
    double x,
    double y,
    int quadrant,
    Color light,
    Color mid,
    Color deep,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(quadrant * (math.pi / 2));

    final strokePaint = Paint()
      ..color = mid
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    // Traditional Bengali Kalka teardrop body
    final kalkaPath = Path()
      ..moveTo(8, 54)
      ..cubicTo(12, 28, 28, 12, 54, 8)
      ..cubicTo(40, 24, 34, 42, 16, 52)
      ..quadraticBezierTo(10, 54, 8, 54)
      ..close();
    canvas.drawPath(kalkaPath, strokePaint);

    // Inner spiral flourish
    final innerPaint = Paint()
      ..color = light
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final spiral = Path()
      ..moveTo(22, 22)
      ..quadraticBezierTo(34, 20, 36, 30)
      ..quadraticBezierTo(38, 40, 26, 42);
    canvas.drawPath(spiral, innerPaint);

    // Decorative stippling pearls
    final dotPaint = Paint()..color = light;
    canvas.drawCircle(const Offset(16, 16), 3.5, dotPaint);
    canvas.drawCircle(const Offset(30, 14), 2.0, dotPaint);
    canvas.drawCircle(const Offset(14, 30), 2.0, dotPaint);
    canvas.drawCircle(const Offset(44, 20), 2.0, dotPaint);

    // Radiating corner flourish
    final fanPaint = Paint()
      ..color = deep.withValues(alpha: .7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(6, 6), const Offset(20, 20), fanPaint);
    canvas.drawLine(const Offset(6, 12), const Offset(14, 20), fanPaint);
    canvas.drawLine(const Offset(12, 6), const Offset(20, 14), fanPaint);

    canvas.restore();
  }

  void _drawProjapatiButterfly(Canvas canvas, double cx, double cy, Color goldColor) {
    final paint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final fillPaint = Paint()
      ..color = goldColor.withValues(alpha: .3)
      ..style = PaintingStyle.fill;

    // Left wing
    final leftWing = Path()
      ..moveTo(cx, cy)
      ..cubicTo(cx - 16, cy - 20, cx - 38, cy - 14, cx - 32, cy + 4)
      ..cubicTo(cx - 26, cy + 14, cx - 12, cy + 8, cx, cy)
      ..close();
    canvas.drawPath(leftWing, fillPaint);
    canvas.drawPath(leftWing, paint);

    // Right wing
    final rightWing = Path()
      ..moveTo(cx, cy)
      ..cubicTo(cx + 16, cy - 20, cx + 38, cy - 14, cx + 32, cy + 4)
      ..cubicTo(cx + 26, cy + 14, cx + 12, cy + 8, cx, cy)
      ..close();
    canvas.drawPath(rightWing, fillPaint);
    canvas.drawPath(rightWing, paint);

    // Antennas
    final antennaPaint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final leftAnt = Path()
      ..moveTo(cx - 1, cy - 3)
      ..quadraticBezierTo(cx - 6, cy - 15, cx - 14, cy - 16);
    final rightAnt = Path()
      ..moveTo(cx + 1, cy - 3)
      ..quadraticBezierTo(cx + 6, cy - 15, cx + 14, cy - 16);
    canvas.drawPath(leftAnt, antennaPaint);
    canvas.drawPath(rightAnt, antennaPaint);

    // Center body
    canvas.drawCircle(Offset(cx, cy - 1), 3.2, Paint()..color = goldColor);
  }

  void _drawAcceptedInviteContent(Canvas canvas, RsvpSubmission s) {
    const goldPrimary = Color(0xFFFDE49E);
    const goldDeep = Color(0xFFE2B857);
    const ivory = Color(0xFFFFF9ED);
    const softCream = Color(0xFFF7E8D0);

    double y = 72;

    // 1. Traditional Bengali Invocation: শ্রী শ্রী প্রজাপতয়ে নমঃ
    y = _drawCenteredText(
      canvas,
      '॥ শ্রী শ্রী প্রজাপতয়ে নমঃ ॥',
      y: y,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 4.0,
      color: goldPrimary,
    );

    y += 10;
    // Auspicious Bengali Prajapati (Butterfly) Motif
    _drawProjapatiButterfly(canvas, cardWidth / 2, y + 10, goldDeep);
    y += 26;

    // 2. English & Bengali Heading
    y = _drawCenteredText(
      canvas,
      'WITH THE BLESSINGS OF BOTH FAMILIES',
      y: y,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 4.5,
      color: goldPrimary,
    );

    y += 8;

    y = _drawCenteredText(
      canvas,
      'SHUBHO BIBAHO · শুভ বিবাহ',
      y: y,
      fontSize: 27,
      fontWeight: FontWeight.w700,
      letterSpacing: 4.5,
      color: const Color(0xFFFFE6A0),
    );

    y += 16;
    _drawOrnamentalDivider(canvas, y);
    y += 22;

    // 3. Bride & Groom Calligraphy
    y = _drawCenteredText(
      canvas,
      'Sayantika',
      y: y,
      fontSize: 66,
      fontWeight: FontWeight.w600,
      color: ivory,
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
      color: ivory,
      fontFamily: 'Cinzel Decorative',
    );

    y += 14;
    _drawOrnamentalDivider(canvas, y);
    y += 24;

    // 4. Invitation Line & Guest Name
    y = _drawCenteredText(
      canvas,
      'Cordially invite the presence of',
      y: y,
      fontSize: 22,
      fontStyle: FontStyle.italic,
      color: softCream,
    );

    y += 6;

    y = _drawCenteredText(
      canvas,
      s.name.trim(),
      y: y,
      fontSize: 42,
      fontWeight: FontWeight.w700,
      color: const Color(0xFFFFE599),
      letterSpacing: 1.2,
    );

    y += 8;

    // 5. Seats & Events Badge
    final guestLabel = s.guests == 1
        ? '1 Guest Seat Reserved'
        : '${s.guests} Guest Seats Reserved';
    final eventBadge = s.events == AttendingEvents.both
        ? 'Wedding & Reception'
        : (s.events == AttendingEvents.weddingOnly
            ? 'Wedding Ceremony'
            : 'Reception Gala');

    y = _drawPillBadge(
      canvas,
      '$guestLabel  ·  $eventBadge',
      y: y,
      color: goldPrimary,
    );

    y += 20;

    // 6. Hearty Welcome Message
    y = _drawParagraph(
      canvas,
      'We are overjoyed to welcome you into our celebration of eternal love and togetherness! '
      'Your warm presence, prayers, and gracious blessings will make our special day truly complete.',
      y: y,
      fontSize: 21,
      height: 1.45,
      color: softCream,
      maxWidth: 860,
    );

    y += 26;

    // 7. Venue Details Filtered by Guest Event Selection
    switch (s.events) {
      case AttendingEvents.weddingOnly:
        _drawSingleVenueBox(
          canvas,
          y: y,
          boxHeight: 270,
          title: 'WEDDING CEREMONY · SHUBHO BIBAHO',
          subtitle: 'শুভ বিবাহ বাসর · সাতপাকে বাঁধা ও সিঁদুরদান',
          date: WeddingConfig.weddingDateLabel,
          time: WeddingConfig.weddingTimeLabel,
          venue: WeddingConfig.weddingVenueName,
          address: WeddingConfig.weddingVenueAddress,
          note: 'We eagerly anticipate your gracious presence to witness our sacred vows & union.',
        );
      case AttendingEvents.receptionOnly:
        _drawSingleVenueBox(
          canvas,
          y: y,
          boxHeight: 270,
          title: 'RECEPTION GALA · BOU BHAAT',
          subtitle: 'বৌভাত ও প্রীতিভোজ · শুভ মিলন উৎসব',
          date: WeddingConfig.receptionDateLabel,
          time: WeddingConfig.receptionTimeLabel,
          venue: WeddingConfig.receptionVenueName,
          address: WeddingConfig.receptionVenueAddress,
          note: 'We joyfully look forward to celebrating an enchanting evening of dining & joy with you.',
        );
      case AttendingEvents.both:
        _drawDualVenueBox(
          canvas,
          y: y,
          boxHeight: 396,
          weddingTitle: 'WEDDING CEREMONY · SHUBHO BIBAHO (শুভ বিবাহ)',
          weddingDate: WeddingConfig.weddingDateLabel,
          weddingTime: WeddingConfig.weddingTimeLabel,
          weddingVenue: WeddingConfig.weddingVenueName,
          weddingAddress: WeddingConfig.weddingVenueAddress,
          receptionTitle: 'RECEPTION GALA · BOU BHAAT (বৌভাত ও প্রীতিভোজ)',
          receptionDate: WeddingConfig.receptionDateLabel,
          receptionTime: WeddingConfig.receptionTimeLabel,
          receptionVenue: WeddingConfig.receptionVenueName,
          receptionAddress: WeddingConfig.receptionVenueAddress,
        );
    }

    // 8. Footer
    _drawFooter(canvas, '#SomKiSayantika · Aapnar Upasthiti Kamona Kori');
  }

  void _drawDeclinedGreetingContent(Canvas canvas, RsvpSubmission s) {
    const goldPrimary = Color(0xFFFDE49E);
    const goldDeep = Color(0xFFE2B857);
    const ivory = Color(0xFFFFF9ED);
    const softCream = Color(0xFFF7E8D0);

    double y = 110;

    // 1. Bengali Top Invocation
    y = _drawCenteredText(
      canvas,
      '॥ শ্রী শ্রী প্রজাপতয়ে নমঃ ॥',
      y: y,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 4.0,
      color: goldPrimary,
    );

    y += 12;
    _drawProjapatiButterfly(canvas, cardWidth / 2, y + 10, goldDeep);
    y += 30;

    // 2. Greeting Header
    y = _drawCenteredText(
      canvas,
      'WARMEST GREETINGS & BLESSINGS',
      y: y,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 5.0,
      color: goldPrimary,
    );

    y += 14;

    y = _drawCenteredText(
      canvas,
      'আন্তরিক শুভেচ্ছা ও ভালোবাসা',
      y: y,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: 3.5,
      color: const Color(0xFFFFE6A0),
    );

    y += 20;
    _drawOrnamentalDivider(canvas, y);
    y += 32;

    // 3. Couple Names
    y = _drawCenteredText(
      canvas,
      'Sayantika & Som',
      y: y,
      fontSize: 60,
      fontWeight: FontWeight.w600,
      color: ivory,
      fontFamily: 'Cinzel Decorative',
    );

    y += 18;
    _drawOrnamentalDivider(canvas, y);
    y += 42;

    // 4. Personalized greeting
    y = _drawCenteredText(
      canvas,
      'Dear ${s.name.trim()},',
      y: y,
      fontSize: 38,
      fontWeight: FontWeight.w700,
      color: const Color(0xFFFFE599),
    );

    y += 32;

    // 5. Heartfelt Message (strictly no venues)
    y = _drawParagraph(
      canvas,
      'Though we will dearly miss having you beside us in person on our wedding day, '
      'your warm wishes, prayers, and heartfelt blessings will accompany us as we step '
      'into this beautiful new chapter together.',
      y: y,
      fontSize: 25,
      height: 1.6,
      color: softCream,
      maxWidth: 840,
    );

    y += 34;

    y = _drawParagraph(
      canvas,
      'We hold your blessings close to our hearts with boundless gratitude. '
      'Wishing you and your family lasting peace, good health, and joyful moments always.',
      y: y,
      fontSize: 24,
      height: 1.6,
      color: softCream.withValues(alpha: .9),
      maxWidth: 840,
    );

    y += 56;

    y = _drawCenteredText(
      canvas,
      'With heartfelt love & gratitude,',
      y: y,
      fontSize: 24,
      fontStyle: FontStyle.italic,
      color: goldPrimary,
    );

    y += 12;

    _drawCenteredText(
      canvas,
      'Sayantika & Som',
      y: y,
      fontSize: 38,
      fontWeight: FontWeight.w700,
      color: ivory,
    );

    // Footer
    _drawFooter(canvas, '#SomKiSayantika · Thank You For Your Warm Blessings');
  }

  void _drawDualVenueBox(
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
    const goldPrimary = Color(0xFFFFDF85);
    const goldDeep = Color(0xFFF3D588);
    const ivory = Color(0xFFFFF9ED);
    const softCream = Color(0xFFF0DEC5);

    final boxRect = Rect.fromLTWH(90, y, cardWidth - 180, boxHeight);
    final bgPaint = Paint()
      ..color = const Color(0xFF33050A).withValues(alpha: .78)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0xFFE8D08D).withValues(alpha: .75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawRRect(RRect.fromRectAndRadius(boxRect, const Radius.circular(18)), bgPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(boxRect, const Radius.circular(18)), borderPaint);

    double cy = y + 20;

    // Wedding Block
    cy = _drawCenteredText(
      canvas,
      weddingTitle,
      y: cy,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: 2.2,
      color: goldPrimary,
    );

    cy += 5;
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
      fontSize: 23,
      fontWeight: FontWeight.w700,
      color: ivory,
    );

    cy += 4;
    cy = _drawCenteredText(
      canvas,
      weddingAddress,
      y: cy,
      fontSize: 16.5,
      color: softCream,
    );

    cy += 14;

    // Subtle divider
    final divPaint = Paint()
      ..color = const Color(0xFFE8D08D).withValues(alpha: .4)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(180, cy), Offset(cardWidth - 180, cy), divPaint);

    cy += 14;

    // Reception Block
    cy = _drawCenteredText(
      canvas,
      receptionTitle,
      y: cy,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: 2.2,
      color: goldPrimary,
    );

    cy += 5;
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
      fontSize: 23,
      fontWeight: FontWeight.w700,
      color: ivory,
    );

    cy += 4;
    _drawCenteredText(
      canvas,
      receptionAddress,
      y: cy,
      fontSize: 16.5,
      color: softCream,
    );
  }

  void _drawSingleVenueBox(
    Canvas canvas, {
    required double y,
    required double boxHeight,
    required String title,
    required String subtitle,
    required String date,
    required String time,
    required String venue,
    required String address,
    required String note,
  }) {
    const goldPrimary = Color(0xFFFFDF85);
    const goldDeep = Color(0xFFF3D588);
    const ivory = Color(0xFFFFF9ED);
    const softCream = Color(0xFFF0DEC5);

    final boxRect = Rect.fromLTWH(90, y, cardWidth - 180, boxHeight);
    final bgPaint = Paint()
      ..color = const Color(0xFF33050A).withValues(alpha: .78)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0xFFE8D08D).withValues(alpha: .8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawRRect(RRect.fromRectAndRadius(boxRect, const Radius.circular(18)), bgPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(boxRect, const Radius.circular(18)), borderPaint);

    double cy = y + 22;

    cy = _drawCenteredText(
      canvas,
      title,
      y: cy,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: 2.4,
      color: goldPrimary,
    );

    cy += 4;
    cy = _drawCenteredText(
      canvas,
      subtitle,
      y: cy,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
      color: goldDeep,
    );

    cy += 8;
    cy = _drawCenteredText(
      canvas,
      '$date · $time',
      y: cy,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: const Color(0xFFFFEAA7),
    );

    cy += 6;
    cy = _drawCenteredText(
      canvas,
      venue,
      y: cy,
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: ivory,
    );

    cy += 4;
    cy = _drawCenteredText(
      canvas,
      address,
      y: cy,
      fontSize: 17.5,
      color: softCream,
    );

    cy += 14;
    _drawCenteredText(
      canvas,
      note,
      y: cy,
      fontSize: 15.5,
      fontStyle: FontStyle.italic,
      color: goldDeep,
    );
  }

  void _drawOrnamentalDivider(Canvas canvas, double y) {
    const gold = Color(0xFFE8D08D);
    final linePaint = Paint()
      ..color = gold.withValues(alpha: .65)
      ..strokeWidth = 1.4;

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
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          fontFamilyFallback: const ['Cinzel', 'Georgia', 'serif'],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final pillW = tp.width + 40;
    final pillH = tp.height + 14;
    final pillRect = Rect.fromCenter(
      center: Offset(cardWidth / 2, y + pillH / 2),
      width: pillW,
      height: pillH,
    );

    final bg = Paint()
      ..color = color.withValues(alpha: .16)
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = color.withValues(alpha: .75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

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
    Color color = const Color(0xFFFFF9ED),
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
      fontSize: 16.5,
      letterSpacing: 3.5,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFF3D588),
    );
  }
}
