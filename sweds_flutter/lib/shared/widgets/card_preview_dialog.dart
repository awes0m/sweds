import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/theme/lux.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/widgets/luxury_button.dart';
import '../models/rsvp_models.dart';
import '../services/card_generator_service.dart';
import '../utils/card_download.dart';

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
  Uint8List? _cardBytes;
  bool _generating = true;
  bool _downloading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _renderCard();
  }

  Future<void> _renderCard() async {
    setState(() {
      _generating = true;
      _error = null;
    });
    try {
      const generator = CardGeneratorService();
      final bytes = await generator.generateCardBytes(widget.submission);
      if (mounted) {
        setState(() {
          _cardBytes = bytes;
          _generating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _generating = false;
        });
      }
    }
  }

  String _getFileName() {
    final isAccept = widget.submission.attendance == Attendance.accepts;
    final sanitizedName = widget.submission.name
        .trim()
        .replaceAll(RegExp(r'[^\w\s]+'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    return isAccept
        ? 'Sayantika_Som_Wedding_Invite_${sanitizedName.isEmpty ? 'Guest' : sanitizedName}.png'
        : 'Sayantika_Som_Wedding_Greeting_${sanitizedName.isEmpty ? 'Friend' : sanitizedName}.png';
  }

  Future<void> _download() async {
    if (_cardBytes == null) return;
    setState(() => _downloading = true);
    try {
      downloadCardImage(_cardBytes!, _getFileName());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card download started!'),
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

  void _openInNewTab() {
    if (_cardBytes == null) return;
    openCardImage(_cardBytes!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Card opened! Tap and hold to save to Photos.'),
        backgroundColor: Lux.crimson,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAccept = widget.submission.attendance == Attendance.accepts;
    final wide = MediaQuery.sizeOf(context).width >= 700;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: wide ? 40 : 16,
        vertical: 20,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 760),
        child: GlassPanel(
          radius: 32,
          padding: EdgeInsets.all(wide ? 24 : 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isAccept ? 'Your Wedding Invitation' : 'Your Greeting Card',
                      style: LuxText.display(
                        wide ? 24 : 19,
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
              const SizedBox(height: 10),
              // Card View Container
              Expanded(
                child: Center(
                  child: _generating
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(color: Lux.gold),
                            const SizedBox(height: 16),
                            Text(
                              'Decorating your invitation card...',
                              style: LuxText.serif(15, color: Lux.goldDeep),
                            ),
                          ],
                        )
                      : _error != null
                          ? Center(
                              child: Text(
                                'Error generating card: $_error',
                                style: LuxText.body(13, color: const Color(0xFFB3463B)),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Lux.gold, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Lux.dark.withValues(alpha: .2),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: InteractiveViewer(
                                  maxScale: 3.0,
                                  child: Image.memory(
                                    _cardBytes!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                ),
              ),
              const SizedBox(height: 14),
              // Action Buttons
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 8,
                children: [
                  LuxuryButton(
                    label: _downloading ? 'Downloading...' : 'Download PNG 📥',
                    loading: _downloading,
                    onPressed: _cardBytes != null ? _download : null,
                  ),
                  LuxuryButton(
                    label: 'Open / Save to Photos ↗',
                    filled: false,
                    onPressed: _cardBytes != null ? _openInNewTab : null,
                  ),
                  LuxuryButton(
                    label: 'Close',
                    filled: false,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '📱 Mobile Tip: Tap "Open / Save to Photos" to view in full resolution, then press & hold the card to save to your photos.',
                textAlign: TextAlign.center,
                style: LuxText.body(11, color: Lux.dark.withValues(alpha: .6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
