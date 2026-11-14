import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/animations/reveal.dart';
import '../../core/constants/wedding_config.dart';
import '../../core/scroll/scene_section.dart';
import '../../core/scroll/section_spec.dart';
import '../../core/theme/lux.dart';
import '../../core/widgets/art_image.dart';
import '../../core/widgets/cursor.dart';
import '../../core/widgets/luxury_button.dart';
import '../../core/widgets/section_title.dart';
import 'gallery_page.dart';

class GallerySection extends StatelessWidget {
  const GallerySection({super.key});

  @override
  Widget build(BuildContext context) => SceneSection(
        index: Sec.gallery,
        builder: (c, p, size) => _GalleryStage(p: p, size: size),
      );
}

class _GalleryStage extends ConsumerWidget {
  const _GalleryStage({required this.p, required this.size});
  final double p;
  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = size.width >= 900;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: wide ? 40 : 16,
          vertical: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProgressReveal(
              progress: p,
              start: 0.1,
              end: 0.35,
              child: const SectionTitle(
                eyebrow: 'MOMENTS · OUR JOURNEY',
                title: 'A glimpse of us',
                subtitle: 'Cherished memories and unforgettable smiles',
              ),
            ),
            const SizedBox(height: 24),

            // Preview photos
            ProgressReveal(
              progress: p,
              start: 0.2,
              end: 0.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < (wide ? 3 : 2); i++) ...[
                    if (i > 0) SizedBox(width: wide ? 20 : 12),
                    CursorHover(
                      child: GestureDetector(
                        onTap: () => GalleryPage.open(context),
                        child: Container(
                          width: wide
                              ? 210
                              : (size.width * 0.42).clamp(130.0, 175.0),
                          height: wide
                              ? 260
                              : (size.width * 0.42 * 1.25).clamp(160.0, 215.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Lux.gold.withValues(alpha: 0.75),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Lux.dark.withValues(alpha: 0.14),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Lux.gold.withValues(alpha: 0.12),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: ArtImage(
                              name: kGallery[i].name,
                              seed: kGallery[i].seed,
                              radius: 20,
                              gracefulFit: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            ProgressReveal(
              progress: p,
              start: 0.3,
              end: 0.6,
              child: LuxuryButton(
                label: 'View Photo Gallery 📷',
                onPressed: () => GalleryPage.open(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> openLightbox(BuildContext context, int index) {
  return Navigator.of(context).push(PageRouteBuilder<void>(
    opaque: false,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 520),
    reverseTransitionDuration: const Duration(milliseconds: 380),
    pageBuilder: (context, a, b) => _Lightbox(initial: index),
    transitionsBuilder: (context, a, b, child) =>
        FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeOut), child: child),
  ));
}

class _Lightbox extends StatefulWidget {
  const _Lightbox({required this.initial});
  final int initial;

  @override
  State<_Lightbox> createState() => _LightboxState();
}

class _LightboxState extends State<_Lightbox> {
  late final PageController _pc = PageController(initialPage: widget.initial);
  late int _i = widget.initial;

  void _go(int d) {
    final n = (_i + d).clamp(0, kGallery.length - 1);
    _pc.animateToPage(n, duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Focus(
      autofocus: true,
      onKeyEvent: (n, e) {
        if (e is! KeyDownEvent) return KeyEventResult.ignored;
        if (e.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.of(context).maybePop();
        } else if (e.logicalKey == LogicalKeyboardKey.arrowRight) {
          _go(1);
        } else if (e.logicalKey == LogicalKeyboardKey.arrowLeft) {
          _go(-1);
        } else {
          return KeyEventResult.ignored;
        }
        return KeyEventResult.handled;
      },
      child: Material(
        color: Colors.transparent,
        child: Stack(children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 26, sigmaY: 26),
                child: ColoredBox(color: Lux.dark.withValues(alpha: 0.85)),
              ),
            ),
          ),
          PageView.builder(
            controller: _pc,
            itemCount: kGallery.length,
            onPageChanged: (v) => setState(() => _i = v),
            itemBuilder: (context, i) => Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: wide ? 72 : 16,
                  vertical: wide ? 64 : 54,
                ),
                child: AspectRatio(
                  aspectRatio: kGallery[i].aspect,
                  child: Hero(
                    tag: 'g$i',
                    child: ArtImage(
                      name: kGallery[i].name,
                      seed: kGallery[i].seed,
                      radius: 20,
                      cacheWidth: 2000,
                      gracefulFit: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 24,
            right: 24,
            child: _RoundIcon(icon: Icons.close_rounded, onTap: () => Navigator.of(context).maybePop()),
          ),
          if (wide) ...[
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: _RoundIcon(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => _go(-1),
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: _RoundIcon(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => _go(1),
                ),
              ),
            ),
          ],
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Text(
              '${_i + 1} / ${kGallery.length}    ${WeddingConfig.bride} & ${WeddingConfig.groom}',
              textAlign: TextAlign.center,
              style: LuxText.serif(16, style: FontStyle.normal, color: Lux.champagne, spacing: 2),
            ),
          ),
        ]),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => CursorHover(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(color: Lux.gold.withValues(alpha: 0.8)),
            ),
            child: Icon(icon, color: Lux.champagne, size: 22),
          ),
        ),
      );
}
