import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/constants/wedding_config.dart';
import '../models/rsvp_models.dart';
import '../utils/card_download.dart';

/// Generates authentic Bengali wedding invitation and greeting cards (PNG & PDF)
/// styled in royal bridal red and gold foil calligraphy with traditional motifs.
/// The generated PDF contains interactive clickable links for Google Maps locations
/// and the feast menu (https://sweds26.web.app/menu).
class CardGeneratorService {
  const CardGeneratorService();

  static const double cardWidth = 1080;
  static const double cardHeight = 1520;
  static const String menuUrl = 'https://sweds26.web.app/menu';

  /// Coordinates for the clickable action buttons on the card (used for both Canvas and PDF).
  static Rect getWeddingMapButtonRect(AttendingEvents events) {
    if (events == AttendingEvents.both) {
      const y = 1076.0;
      const w = (cardWidth - 220) / 2;
      return const Rect.fromLTWH(100, y, w, 50);
    }
    return const Rect.fromLTWH(180, 960, cardWidth - 360, 52);
  }

  static Rect getReceptionMapButtonRect(AttendingEvents events) {
    if (events == AttendingEvents.both) {
      const y = 1076.0;
      const w = (cardWidth - 220) / 2;
      return const Rect.fromLTWH(100 + w + 20, y, w, 50);
    }
    return const Rect.fromLTWH(180, 960, cardWidth - 360, 52);
  }

  static Rect getMenuButtonRect(AttendingEvents events) {
    if (events == AttendingEvents.both) {
      return const Rect.fromLTWH(140, 1140, cardWidth - 280, 54);
    }
    return const Rect.fromLTWH(140, 1030, cardWidth - 280, 54);
  }

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

  /// Generates card and triggers PNG download.
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

  /// Generates the invitation card PDF file with interactive, clickable links:
  /// - Clickable Google Maps links for the accepted events
  /// - Clickable Feast Menu button linking to "https://sweds26.web.app/menu"
  Future<Uint8List> generateInvitePdfBytes(RsvpSubmission submission) async {
    final isAccept = submission.attendance == Attendance.accepts;
    final cardPngBytes = await generateCardBytes(submission);

    final pdf = pw.Document(
      title: isAccept
          ? 'Wedding Invitation - ${submission.name}'
          : 'Wedding Greeting - ${submission.name}',
      author: 'Sayantika & Som',
    );

    final bgImage = pw.MemoryImage(cardPngBytes);
    const pageFormat = PdfPageFormat(cardWidth, cardHeight);

    final linkOverlays = <pw.Widget>[];

    if (isAccept) {
      // 1. Google Maps link for Wedding (if events == both or weddingOnly)
      if (submission.events == AttendingEvents.both ||
          submission.events == AttendingEvents.weddingOnly) {
        final r = getWeddingMapButtonRect(submission.events);
        linkOverlays.add(
          pw.Positioned(
            left: r.left,
            top: r.top,
            child: pw.UrlLink(
              destination: WeddingConfig.weddingMapsUrl,
              child: pw.SizedBox(
                width: r.width,
                height: r.height,
              ),
            ),
          ),
        );
      }

      // 2. Google Maps link for Reception (if events == both or receptionOnly)
      if (submission.events == AttendingEvents.both ||
          submission.events == AttendingEvents.receptionOnly) {
        final r = getReceptionMapButtonRect(submission.events);
        linkOverlays.add(
          pw.Positioned(
            left: r.left,
            top: r.top,
            child: pw.UrlLink(
              destination: WeddingConfig.receptionMapsUrl,
              child: pw.SizedBox(
                width: r.width,
                height: r.height,
              ),
            ),
          ),
        );
      }

      // 3. Feast Menu link: https://sweds26.web.app/menu
      final menuRect = getMenuButtonRect(submission.events);
      linkOverlays.add(
        pw.Positioned(
          left: menuRect.left,
          top: menuRect.top,
          child: pw.UrlLink(
            destination: menuUrl,
            child: pw.SizedBox(
              width: menuRect.width,
              height: menuRect.height,
            ),
          ),
        ),
      );
    } else {
      // Feast Menu link for greeting
      final menuRect = getMenuButtonRect(submission.events);
      linkOverlays.add(
        pw.Positioned(
          left: menuRect.left,
          top: menuRect.top,
          child: pw.UrlLink(
            destination: menuUrl,
            child: pw.SizedBox(
              width: menuRect.width,
              height: menuRect.height,
            ),
          ),
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Image(bgImage, fit: pw.BoxFit.fill),
              ),
              ...linkOverlays,
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Generates the invitation PDF file and triggers the browser download.
  Future<Uint8List> generateAndDownloadPdf(RsvpSubmission submission) async {
    final bytes = await generateInvitePdfBytes(submission);
    final isAccept = submission.attendance == Attendance.accepts;
    final sanitizedName = submission.name
        .trim()
        .replaceAll(RegExp(r'[^\w\s]+'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    final fileName = isAccept
        ? 'Sayantika_Som_Bengali_Wedding_Invite_${sanitizedName.isEmpty ? 'Guest' : sanitizedName}.pdf'
        : 'Sayantika_Som_Wedding_Greeting_${sanitizedName.isEmpty ? 'Friend' : sanitizedName}.pdf';

    downloadCardPdf(bytes, fileName);
    return bytes;
  }

  void _drawBengaliOrnateBorders(Canvas canvas) {
    const goldPrimary = Color(0xFFF3D588);
    const goldDeep = Color(0xFFC49A2C);

    final outerPaint = Paint()
      ..color = goldPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final innerPaint = Paint()
      ..color = goldDeep.withValues(alpha: .75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    const outerMargin = 32.0;
    const innerMargin = 44.0;

    // Outer & Inner Rectangles
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          outerMargin,
          outerMargin,
          cardWidth - outerMargin * 2,
          cardHeight - outerMargin * 2,
        ),
        const Radius.circular(22),
      ),
      outerPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          innerMargin,
          innerMargin,
          cardWidth - innerMargin * 2,
          cardHeight - innerMargin * 2,
        ),
        const Radius.circular(16),
      ),
      innerPaint,
    );

    // 4 Corner Traditional Kalkas / Paisley Motifs
    _drawTraditionalCornerMotif(canvas, innerMargin, innerMargin, 0);
    _drawTraditionalCornerMotif(canvas, cardWidth - innerMargin, innerMargin, math.pi / 2);
    _drawTraditionalCornerMotif(canvas, cardWidth - innerMargin, cardHeight - innerMargin, math.pi);
    _drawTraditionalCornerMotif(canvas, innerMargin, cardHeight - innerMargin, -math.pi / 2);
  }

  void _drawTraditionalCornerMotif(Canvas canvas, double x, double y, double rotation) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rotation);

    const gold = Color(0xFFF5DC96);
    final paint = Paint()
      ..color = gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final kalkaPath = Path()
      ..moveTo(0, 0)
      ..lineTo(36, 0)
      ..cubicTo(48, 8, 48, 28, 28, 38)
      ..cubicTo(16, 44, 4, 34, 0, 0)
      ..close();
    canvas.drawPath(kalkaPath, paint);

    canvas.drawCircle(const Offset(22, 20), 4, Paint()..color = gold);

    final fanPaint = Paint()
      ..color = gold.withValues(alpha: .8)
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

    y += 24;

    // 7. Venue Details Filtered by Guest Event Selection
    switch (s.events) {
      case AttendingEvents.weddingOnly:
        _drawSingleVenueBox(
          canvas,
          y: y,
          boxHeight: 250,
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
          boxHeight: 250,
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

    // 8. Interactive Clickable Action Buttons (Active in the PDF download)
    if (s.events == AttendingEvents.both) {
      final weddingRect = getWeddingMapButtonRect(s.events);
      final receptionRect = getReceptionMapButtonRect(s.events);
      final menuRect = getMenuButtonRect(s.events);

      _drawLinkButton(
        canvas,
        weddingRect,
        label: '📍 Wedding Map (Midnapore) ↗',
        borderColor: goldDeep,
        textColor: goldPrimary,
        bgColor: const Color(0xFF3B060C).withValues(alpha: .75),
        fontSize: 16.0,
      );

      _drawLinkButton(
        canvas,
        receptionRect,
        label: '📍 Reception Map (Haldia) ↗',
        borderColor: goldDeep,
        textColor: goldPrimary,
        bgColor: const Color(0xFF3B060C).withValues(alpha: .75),
        fontSize: 16.0,
      );

      _drawLinkButton(
        canvas,
        menuRect,
        label: '🍽️ Royal Feast Menu · https://sweds26.web.app/menu ↗',
        borderColor: goldPrimary,
        textColor: ivory,
        bgColor: const Color(0xFF4A0810).withValues(alpha: .85),
        fontSize: 18.0,
      );
    } else if (s.events == AttendingEvents.weddingOnly) {
      final weddingRect = getWeddingMapButtonRect(s.events);
      final menuRect = getMenuButtonRect(s.events);

      _drawLinkButton(
        canvas,
        weddingRect,
        label: '📍 Open Wedding Ceremony in Google Maps ↗',
        borderColor: goldDeep,
        textColor: goldPrimary,
        bgColor: const Color(0xFF3B060C).withValues(alpha: .75),
        fontSize: 17.5,
      );

      _drawLinkButton(
        canvas,
        menuRect,
        label: '🍽️ Royal Feast Menu · https://sweds26.web.app/menu ↗',
        borderColor: goldPrimary,
        textColor: ivory,
        bgColor: const Color(0xFF4A0810).withValues(alpha: .85),
        fontSize: 18.0,
      );
    } else {
      final receptionRect = getReceptionMapButtonRect(s.events);
      final menuRect = getMenuButtonRect(s.events);

      _drawLinkButton(
        canvas,
        receptionRect,
        label: '📍 Open Reception Gala in Google Maps ↗',
        borderColor: goldDeep,
        textColor: goldPrimary,
        bgColor: const Color(0xFF3B060C).withValues(alpha: .75),
        fontSize: 17.5,
      );

      _drawLinkButton(
        canvas,
        menuRect,
        label: '🍽️ Royal Feast Menu · https://sweds26.web.app/menu ↗',
        borderColor: goldPrimary,
        textColor: ivory,
        bgColor: const Color(0xFF4A0810).withValues(alpha: .85),
        fontSize: 18.0,
      );
    }

    // 9. Footer
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
      'SHUBHO BIBAHO · শুভ বিবাহ',
      y: y,
      fontSize: 29,
      fontWeight: FontWeight.w700,
      letterSpacing: 4.5,
      color: const Color(0xFFFFE6A0),
    );

    y += 20;
    _drawOrnamentalDivider(canvas, y);
    y += 30;

    // 3. Bride & Groom Calligraphy
    y = _drawCenteredText(
      canvas,
      'Sayantika & Som',
      y: y,
      fontSize: 60,
      fontWeight: FontWeight.w600,
      color: ivory,
      fontFamily: 'Cinzel Decorative',
    );

    y += 24;
    _drawOrnamentalDivider(canvas, y);
    y += 36;

    // 4. Personalized Dear Guest
    y = _drawCenteredText(
      canvas,
      'Dearest ${s.name.trim()},',
      y: y,
      fontSize: 38,
      fontWeight: FontWeight.w700,
      color: const Color(0xFFFFE599),
    );

    y += 24;

    // 5. Gracious Blessing & Memory Message
    y = _drawParagraph(
      canvas,
      'Though we will dearly miss your smiling face at our wedding mandap and celebrations, '
      'your heartfelt wishes, warm prayers, and blessings are forever treasured in our hearts.\n\n'
      'We embark upon this sacred journey of marriage surrounded by the love of cherished friends and family like you.',
      y: y,
      fontSize: 24,
      height: 1.55,
      color: softCream,
      maxWidth: 860,
    );

    y += 44;

    // 6. Signoff
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

    // Menu link button
    final menuRect = getMenuButtonRect(s.events);
    _drawLinkButton(
      canvas,
      menuRect,
      label: '🍽️ Royal Feast Menu · https://sweds26.web.app/menu ↗',
      borderColor: goldPrimary,
      textColor: ivory,
      bgColor: const Color(0xFF4A0810).withValues(alpha: .85),
      fontSize: 18.0,
    );

    // Footer
    _drawFooter(canvas, '#SomKiSayantika · Thank You For Your Warm Blessings');
  }

  void _drawLinkButton(
    Canvas canvas,
    Rect rect, {
    required String label,
    required Color borderColor,
    required Color textColor,
    required Color bgColor,
    double fontSize = 17.0,
  }) {
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.drawRRect(rrect, bgPaint);
    canvas.drawRRect(rrect, borderPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
          fontFamilyFallback: const ['Cormorant Garamond', 'Georgia', 'serif'],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.width - 24);

    tp.paint(
      canvas,
      Offset(
        rect.left + (rect.width - tp.width) / 2,
        rect.top + (rect.height - tp.height) / 2,
      ),
    );
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
      ..color = const Color(0xFF33050A).withValues(alpha: .80)
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
      color: goldDeep,
    );

    cy += 6;
    cy = _drawCenteredText(
      canvas,
      venue,
      y: cy,
      fontSize: 25,
      fontWeight: FontWeight.w700,
      color: ivory,
    );

    cy += 4;
    cy = _drawCenteredText(
      canvas,
      address,
      y: cy,
      fontSize: 17,
      color: softCream,
    );

    cy += 10;
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
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          fontFamilyFallback: const ['Cormorant Garamond', 'Georgia', 'serif'],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeW = tp.width + 48;
    const badgeH = 40.0;
    final badgeRect = Rect.fromLTWH((cardWidth - badgeW) / 2, y, badgeW, badgeH);

    final bgPaint = Paint()
      ..color = const Color(0xFFE2B857).withValues(alpha: .18)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = color.withValues(alpha: .65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(20)), bgPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(20)), borderPaint);

    tp.paint(canvas, Offset((cardWidth - tp.width) / 2, y + (badgeH - tp.height) / 2));
    return y + badgeH;
  }

  double _drawCenteredText(
    Canvas canvas,
    String text, {
    required double y,
    required double fontSize,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.w400,
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
          fontFamilyFallback: const [
            'Cinzel Decorative',
            'Playfair Display',
            'Cormorant Garamond',
            'Georgia',
            'serif',
          ],
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
