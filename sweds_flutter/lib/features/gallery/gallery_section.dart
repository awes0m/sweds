import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/animations/motion.dart';
import '../../core/animations/reveal.dart';
import '../../core/constants/wedding_config.dart';
import '../../core/scroll/scene_section.dart';
import '../../core/scroll/section_spec.dart';
import '../../core/theme/lux.dart';
import '../../core/widgets/art_image.dart';
import '../../core/widgets/cursor.dart';
import '../../core/widgets/section_title.dart';
import '../../shared/providers/scene_providers.dart';

class GallerySection extends StatelessWidget {
  const GallerySection({super.key});

  @override
  Widget build(BuildContext context) =>
      SceneSection(index: Sec.gallery, builder: (c, p, size) => _GalleryStage(p: p, size: size));
}

class _GalleryStage extends ConsumerWidget {
  const _GalleryStage({required this.p, required this.size});
  final double p;
  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final depth = ref.watch(deviceClassProvider).depth;
    final cols = size.width >= 720 ? 3 : 2;
    final enter = Motion.cinematic.transform(Motion.window(p, 0.05, 0.42));
    final hPad = size.width >= 900 ? 80.0 : 18.0;

    final columns = [for (var c = 0; c < cols; c++) <int>[]];
    for (var i = 0; i < kGallery.length; i++) {
      columns[i % cols].add(i);
    }

    return OverflowBox(
      alignment: Alignment.topCenter,
      minHeight: 0,
      maxHeight: double.infinity,
      child: Padding(
        padding: EdgeInsets.fromLTRB(hPad, size.height * 0.10, hPad, 60),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ProgressReveal(
            progress: p,
            start: 0.02,
            end: 0.3,
            child: const SectionTitle(eyebrow: 'Moments', title: 'A glimpse of us'),
          ),
          const SizedBox(height: 56),
          // The whole wall leans toward you as it arrives.
          Transform(
            alignment: Alignment.topCenter,
            transform: depthMatrix(rx: (1 - enter) * 0.42 * depth, dz: -(1 - enter) * 260 * depth),
            child: Opacity(
              opacity: enter,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (var c = 0; c < cols; c++) ...[
                  if (c > 0) const SizedBox(width: 22),
                  Expanded(
                    child: Transform.translate(
                      // each column drifts at its own speed → layered depth
                      offset: Offset(0, (p - 0.5) * size.height * 0.16 * depth * (c.isEven ? 1 : -1.6) + (c.isOdd ? 50 : 0)),
                      child: Column(children: [
                        for (final i in columns[c]) ...[
                          AspectRatio(
                            aspectRatio: kGallery[i].aspect,
                            child: _GalleryTile(index: i, item: kGallery[i]),
                          ),
                          const SizedBox(height: 22),
                        ],
                      ]),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _GalleryTile extends StatefulWidget {
  const _GalleryTile({required this.index, required this.item});
  final int index;
  final GalleryItem item;

  @override
  State<_GalleryTile> createState() => _GalleryTileState();
}

class _GalleryTileState extends State<_GalleryTile> {
  Offset? _hover; // -1..1 inside the tile, null when not hovered

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
            setState(() => _hover = Offset(e.localPosition.dx / s.width * 2 - 1, e.localPosition.dy / s.height * 2 - 1));
          },
          onExit: (_) => setState(() => _hover = null),
          child: GestureDetector(
            onTap: () => openLightbox(context, widget.index),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: _hover == null ? 0 : 1),
              duration: const Duration(milliseconds: 450),
              curve: Motion.cinematic,
              builder: (context, hov, _) => TweenAnimationBuilder<Offset>(
                tween: Tween<Offset>(end: _hover ?? Offset.zero),
                duration: const Duration(milliseconds: 180),
                builder: (context, o, _) => Transform(
                  alignment: Alignment.center,
                  transform: depthMatrix(ry: o.dx * 0.16, rx: -o.dy * 0.16, dz: 70 * hov, rz: o.dx * 0.01),
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      color: Lux.ivory.withValues(alpha: 0.6),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                      boxShadow: [
                        BoxShadow(color: Lux.dark.withValues(alpha: 0.10 + 0.10 * hov), blurRadius: 40 + 30 * hov, offset: Offset(0, 22 + 10 * hov)),
                        BoxShadow(color: Lux.gold.withValues(alpha: 0.16 * hov), blurRadius: 60),
                      ],
                    ),
                    child: Stack(fit: StackFit.expand, children: [
                      Hero(tag: 'g${widget.index}', child: ArtImage(name: it.name, seed: it.seed, radius: 18, cacheWidth: 900)),
                      // moving light reflection
                      IgnorePointer(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: () {
                                  final s = (0.5 + o.dx * 0.35 + o.dy * 0.15).clamp(0.25, 0.75);
                                  return [s - 0.25, s, s + 0.25];
                                }(),
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.38 * hov),
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
    _pc.animateToPage(n, duration: const Duration(milliseconds: 600), curve: Motion.cinematic);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: ColoredBox(color: Lux.dark.withValues(alpha: 0.82)),
              ),
            ),
          ),
          PageView.builder(
            controller: _pc,
            itemCount: kGallery.length,
            onPageChanged: (v) => setState(() => _i = v),
            itemBuilder: (context, i) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 64),
                child: AspectRatio(
                  aspectRatio: kGallery[i].aspect,
                  child: Hero(
                    tag: 'g$i',
                    child: ArtImage(name: kGallery[i].name, seed: kGallery[i].seed, radius: 22, cacheWidth: 2000),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 28,
            right: 28,
            child: _RoundIcon(icon: Icons.close_rounded, onTap: () => Navigator.of(context).maybePop()),
          ),
          Positioned(left: 20, top: 0, bottom: 0, child: Center(child: _RoundIcon(icon: Icons.chevron_left_rounded, onTap: () => _go(-1)))),
          Positioned(right: 20, top: 0, bottom: 0, child: Center(child: _RoundIcon(icon: Icons.chevron_right_rounded, onTap: () => _go(1)))),
          Positioned(
            bottom: 26,
            left: 0,
            right: 0,
            child: Text(
              '${_i + 1} / ${kGallery.length}    ${WeddingConfig.bride} & ${WeddingConfig.groom}',
              textAlign: TextAlign.center,
              style: LuxText.serif(18, style: FontStyle.normal, color: Lux.champagne, spacing: 3),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.10),
              border: Border.all(color: Lux.gold.withValues(alpha: 0.7)),
            ),
            child: Icon(icon, color: Lux.champagne),
          ),
        ),
      );
}
