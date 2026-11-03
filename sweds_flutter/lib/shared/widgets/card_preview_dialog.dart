import 'package:flutter/material.dart';

import '../../core/constants/wedding_config.dart';
import '../../core/theme/lux.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/widgets/luxury_button.dart';
import '../models/rsvp_models.dart';
import '../services/card_generator_service.dart';

class CardPreviewDialog extends StatefulWidget {
  const CardPreviewDialog({super.key, required this.submission});

  final RsvpSubmission submission;

  static void show(BuildContext context, RsvpSubmission submission) {
    showDialog<void>(
      context: context,
      barrierColor: Lux.dark.withValues(alpha: .65),
      builder: (_) => CardPreviewDialog(submission: submission),
    );
  }

  @override
  State<CardPreviewDialog> createState() => _CardPreviewDialogState();
}

class _CardPreviewDialogState extends State<CardPreviewDialog> {
  bool _downloading = false;

  Future<void> _download() async {
    setState(() => _downloading = true);
    try {
      const generator = CardGeneratorService();
      await generator.generateAndDownload(widget.submission);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card downloaded successfully!'),
            backgroundColor: Lux.crimson,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: const Color(0xFFB3463B),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAccept = widget.submission.attendance == Attendance.accepts;
    final wide = MediaQuery.sizeOf(context).width >= 700;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: wide ? 40 : 16,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        child: GlassPanel(
          radius: 32,
          padding: EdgeInsets.all(wide ? 28 : 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isAccept
                          ? 'Your Wedding Invitation'
                          : 'Your Greeting Card',
                      style: LuxText.display(
                        wide ? 24 : 20,
                        color: Lux.crimson,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Lux.dark),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Card Preview Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 26,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF7EE),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Lux.gold, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Lux.dark.withValues(alpha: .15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: isAccept ? _buildInviteBody() : _buildGreetingBody(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Action Buttons
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  LuxuryButton(
                    label: _downloading
                        ? 'Downloading...'
                        : 'Download PNG Card',
                    loading: _downloading,
                    onPressed: _download,
                  ),
                  LuxuryButton(
                    label: 'Close',
                    filled: false,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInviteBody() {
    return Column(
      children: [
        Text(
          'WITH THE BLESSINGS OF BOTH FAMILIES',
          textAlign: TextAlign.center,
          style: LuxText.eyebrow(
            Lux.crimson,
          ).copyWith(fontSize: 11, letterSpacing: 3),
        ),
        const SizedBox(height: 6),
        Text(
          'SHUBHO BIBAHO · শুভ বিবাহ',
          textAlign: TextAlign.center,
          style: LuxText.serif(
            15,
            weight: FontWeight.w700,
            color: Lux.goldDeep,
          ),
        ),
        const SizedBox(height: 12),
        _divider(),
        const SizedBox(height: 12),
        Text(
          '${WeddingConfig.bride} & ${WeddingConfig.groom}',
          textAlign: TextAlign.center,
          style: LuxText.display(28, color: Lux.crimson),
        ),
        const SizedBox(height: 12),
        _divider(),
        const SizedBox(height: 16),
        Text(
          'Cordially invite the presence of',
          style: LuxText.serif(
            14,
            style: FontStyle.italic,
            color: Lux.dark.withValues(alpha: .75),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.submission.name.trim(),
          textAlign: TextAlign.center,
          style: LuxText.display(24, color: Lux.crimson),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Lux.gold.withValues(alpha: .15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Lux.gold),
          ),
          child: Text(
            widget.submission.guests == 1
                ? '1 Guest Seat Reserved'
                : '${widget.submission.guests} Guest Seats Reserved',
            style: LuxText.serif(
              13,
              weight: FontWeight.w700,
              color: Lux.goldDeep,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'We are overjoyed to welcome you into our celebration of love and togetherness! '
          'Your warm presence and blessings will make our union truly memorable.',
          textAlign: TextAlign.center,
          style: LuxText.serif(
            14,
            height: 1.45,
            color: Lux.dark.withValues(alpha: .85),
          ),
        ),
        const SizedBox(height: 18),
        // Venues Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F0DF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Lux.gold.withValues(alpha: .5)),
          ),
          child: Column(
            children: [
              Text(
                'WEDDING CEREMONY · SHUBHO BIBAHO',
                style: LuxText.eyebrow(Lux.crimson).copyWith(fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                '${WeddingConfig.weddingDateLabel} · ${WeddingConfig.weddingTimeLabel}',
                style: LuxText.serif(
                  13,
                  weight: FontWeight.w700,
                  color: Lux.goldDeep,
                ),
              ),
              Text(
                WeddingConfig.weddingVenueName,
                style: LuxText.serif(
                  15,
                  weight: FontWeight.w600,
                  color: Lux.dark,
                ),
              ),
              Text(
                WeddingConfig.weddingVenueAddress,
                textAlign: TextAlign.center,
                style: LuxText.body(12, color: Lux.dark.withValues(alpha: .7)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: Lux.champagne, height: 1),
              ),
              Text(
                'RECEPTION GALA · BOU BHAAT',
                style: LuxText.eyebrow(Lux.crimson).copyWith(fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                '${WeddingConfig.receptionDateLabel} · ${WeddingConfig.receptionTimeLabel}',
                style: LuxText.serif(
                  13,
                  weight: FontWeight.w700,
                  color: Lux.goldDeep,
                ),
              ),
              Text(
                WeddingConfig.receptionVenueName,
                style: LuxText.serif(
                  15,
                  weight: FontWeight.w600,
                  color: Lux.dark,
                ),
              ),
              Text(
                WeddingConfig.receptionVenueAddress,
                textAlign: TextAlign.center,
                style: LuxText.body(12, color: Lux.dark.withValues(alpha: .7)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '#SomKiSayantika · Aapnar Upasthiti Kamona Kori',
          style: LuxText.serif(
            12,
            weight: FontWeight.w600,
            color: Lux.goldDeep,
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingBody() {
    return Column(
      children: [
        Text(
          'WARMEST GREETINGS & BLESSINGS',
          textAlign: TextAlign.center,
          style: LuxText.eyebrow(
            Lux.goldDeep,
          ).copyWith(fontSize: 11, letterSpacing: 3),
        ),
        const SizedBox(height: 6),
        Text(
          'আন্তরিক শুভেচ্ছা ও কৃতজ্ঞতা',
          textAlign: TextAlign.center,
          style: LuxText.serif(16, weight: FontWeight.w600, color: Lux.crimson),
        ),
        const SizedBox(height: 14),
        _divider(),
        const SizedBox(height: 14),
        Text(
          '${WeddingConfig.bride} & ${WeddingConfig.groom}',
          textAlign: TextAlign.center,
          style: LuxText.display(28, color: Lux.crimson),
        ),
        const SizedBox(height: 14),
        _divider(),
        const SizedBox(height: 18),
        Text(
          'Dear ${widget.submission.name.trim()},',
          style: LuxText.serif(18, weight: FontWeight.w700, color: Lux.crimson),
        ),
        const SizedBox(height: 14),
        Text(
          'Though we will dearly miss your presence on our wedding day, your warm love, '
          'prayers, and hearty blessings will accompany us as we step into this sacred '
          'new chapter together.',
          textAlign: TextAlign.center,
          style: LuxText.serif(
            15,
            height: 1.5,
            color: Lux.dark.withValues(alpha: .85),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'We hold your blessings close to our hearts with deepest gratitude. '
          'Wishing you and your family lasting peace, joy, and prosperity always.',
          textAlign: TextAlign.center,
          style: LuxText.serif(
            14.5,
            height: 1.5,
            color: Lux.dark.withValues(alpha: .8),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'With heartfelt love & affection,',
          style: LuxText.serif(
            14,
            style: FontStyle.italic,
            color: Lux.goldDeep,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sayantika & Som',
          style: LuxText.serif(17, weight: FontWeight.w700, color: Lux.crimson),
        ),
        const SizedBox(height: 16),
        Text(
          '#SomKiSayantika',
          style: LuxText.serif(
            12,
            weight: FontWeight.w600,
            color: Lux.goldDeep,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 50, height: 1, color: Lux.gold),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.favorite, size: 12, color: Lux.crimson),
        ),
        Container(width: 50, height: 1, color: Lux.gold),
      ],
    );
  }
}
