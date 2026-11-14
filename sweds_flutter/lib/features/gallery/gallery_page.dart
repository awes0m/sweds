import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/animations/motion.dart';
import '../../core/animations/reveal.dart';
import '../../core/constants/wedding_config.dart';
import '../../core/theme/lux.dart';
import '../../core/widgets/art_image.dart';
import '../../core/widgets/cursor.dart';
import 'gallery_section.dart' show openLightbox;

/// Full-screen gallery page — opened as a fade-in overlay route.
/// Call [GalleryPage.open] from any nav item instead of scrolling to Sec.gallery.
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  /// Push this page as a translucent overlay over the current route.
  static Future<void> open(BuildContext context) => Navigator.of(context).push(
        PageRouteBuilder<void>(
          opaque: false,
          barrierColor: Colors.transparent,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, __, ___) => const GalleryPage(),
          transitionsBuilder: (_, a, __, child) => FadeTransition(
            opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
            child: child,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Lux.background,
      child: Focus(
        autofocus: true,
        onKeyEvent: (_, e) {
          if (e is! KeyDownEvent) return KeyEventResult.ignored;
          if (e.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).maybePop();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Stack(
          children: [
            // ── Scrollable content ───────────────────────────────────────
            CustomScrollView(
              slivers: [
                // Header spacer (behind the fixed header bar)
                const SliverToBoxAdapter(child: SizedBox(height: 88)),

                // Eyebrow + title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'MOMENTS',
                          style: LuxText.eyebrow(Lux.crimson),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'A glimpse of us',
                          style: LuxText.display(32,
                              weight: FontWeight.w600, color: Lux.dark),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: 56,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Lux.gold.withValues(alpha: 0),
                              Lux.gold,
                              Lux.gold.withValues(alpha: 0),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Grid
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 80),
                  sliver: _GalleryGrid(),
                ),
              ],
            ),

            // ── Fixed header bar ─────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _GalleryHeader(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _GalleryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: Lux.background.withValues(alpha: 0.90),
            border: Border(
              bottom: BorderSide(color: Lux.gold.withValues(alpha: 0.35)),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: wide ? 20 : 14),
          child: Row(
            children: [
              // Back / close button
              CursorHover(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Lux.crimson.withValues(alpha: 0.08),
                      border: Border.all(
                          color: Lux.crimson.withValues(alpha: 0.5)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: Lux.crimson),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  '${WeddingConfig.bride} & ${WeddingConfig.groom}',
                  style: LuxText.serif(wide ? 20 : 17,
                      style: FontStyle.italic, color: Lux.crimson),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Decorative icon
              Icon(Icons.photo_camera_rounded,
                  color: Lux.gold.withValues(alpha: 0.8), size: 20),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Gallery grid ──────────────────────────────────────────────────────────────

class _GalleryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cols = size.width >= 720 ? 3 : 2;

    // Distribute items across columns (round-robin)
    final columns = [for (var c = 0; c < cols; c++) <int>[]];
    for (var i = 0; i < kGallery.length; i++) {
      columns[i % cols].add(i);
    }

    return SliverToBoxAdapter(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var c = 0; c < cols; c++) ...[
            if (c > 0) const SizedBox(width: 14),
            Expanded(
              child: Column(
                children: [
                  for (final i in columns[c]) ...[
                    AspectRatio(
                      aspectRatio: kGallery[i].aspect,
                      child: GalleryTile(index: i, item: kGallery[i]),
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Gallery tile (public copy of gallery_section._GalleryTile) ────────────────

class GalleryTile extends StatefulWidget {
  const GalleryTile({super.key, required this.index, required this.item});
  final int index;
  final GalleryItem item;

  @override
  State<GalleryTile> createState() => _GalleryTileState();
}

class _GalleryTileState extends State<GalleryTile> {
  Offset? _hover; // –1..1 inside tile, null when not hovered

  @override
  Widget build(BuildContext context) {
    final it = widget.item;
    return AppearOnVisible(
      lazy: true,
      delay: Duration(milliseconds: 120 * (widget.index % 3)),
      child: CursorHover(
        child: MouseRegion(
          onHover: (e) {
            final s = context.size;
            if (s == null) return;
            setState(() => _hover = Offset(
                e.localPosition.dx / s.width * 2 - 1,
                e.localPosition.dy / s.height * 2 - 1));
          },
          onExit: (_) => setState(() => _hover = null),
          child: GestureDetector(
            onTap: () => openLightbox(context, widget.index),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: _hover == null ? 0 : 1),
              duration: const Duration(milliseconds: 450),
              curve: Motion.cinematic,
              builder: (context, hov, _) =>
                  TweenAnimationBuilder<Offset>(
                tween: Tween<Offset>(end: _hover ?? Offset.zero),
                duration: const Duration(milliseconds: 180),
                builder: (context, o, _) => Transform(
                  alignment: Alignment.center,
                  transform: depthMatrix(
                      ry: o.dx * 0.16,
                      rx: -o.dy * 0.16,
                      dz: 70 * hov,
                      rz: o.dx * 0.01),
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      color: Lux.ivory.withValues(alpha: 0.6),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8)),
                      boxShadow: [
                        BoxShadow(
                          color: Lux.dark
                              .withValues(alpha: 0.10 + 0.10 * hov),
                          blurRadius: 40 + 30 * hov,
                          offset: Offset(0, 22 + 10 * hov),
                        ),
                        BoxShadow(
                          color: Lux.gold.withValues(alpha: 0.16 * hov),
                          blurRadius: 60,
                        ),
                      ],
                    ),
                    child: Stack(fit: StackFit.expand, children: [
                      Hero(
                        tag: 'g${widget.index}',
                        child: ArtImage(
                          name: it.name,
                          seed: it.seed,
                          radius: 18,
                          cacheWidth: 900,
                          gracefulFit: true,
                        ),
                      ),
                      // Shimmer reflection
                      IgnorePointer(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: () {
                                  final s = (0.5 +
                                          o.dx * 0.35 +
                                          o.dy * 0.15)
                                      .clamp(0.25, 0.75);
                                  return [s - 0.25, s, s + 0.25];
                                }(),
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white
                                      .withValues(alpha: 0.38 * hov),
                                  Colors.white.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
