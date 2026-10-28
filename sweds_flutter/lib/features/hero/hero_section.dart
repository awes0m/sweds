import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/animations/motion.dart';
import '../../core/animations/reveal.dart';
import '../../core/constants/wedding_config.dart';
import '../../core/scroll/scene_section.dart';
import '../../core/scroll/section_spec.dart';
import '../../core/theme/lux.dart';
import '../../core/widgets/pointer_parallax.dart';
import '../../core/widgets/ticking.dart';
import '../../shared/painters/floral_painter.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) =>
      SceneSection(index: Sec.hero, builder: (c, p, size) => _HeroStage(p: p, size: size));
}

class _HeroStage extends StatelessWidget {
  const _HeroStage({required this.p, required this.size});
  final double p;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final nameSize = context.fluid(58, 150);
    final fade = 1 - Motion.window(p, 0.30, 0.85);
    final blur = Motion.window(p, 0.2, 0.9) * 14;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('WITH THE BLESSINGS OF BOTH FAMILIES', style: LuxText.eyebrow(Lux.crimson))
            .animate()
            .fadeIn(delay: 300.ms, duration: 1200.ms)
            .moveY(begin: 18, end: 0, delay: 300.ms, duration: 1200.ms, curve: Motion.cinematic),
        const SizedBox(height: 18),
        Text('SHUBHO BIBAHO · শুভ বিবাহ',
                style: LuxText.serif(context.fluid(14, 18),
                    style: FontStyle.normal, spacing: 5, weight: FontWeight.w600, color: Lux.goldDeep))
            .animate()
            .fadeIn(delay: 500.ms, duration: 1200.ms),
        const SizedBox(height: 14),
        LetterReveal(text: WeddingConfig.bride, style: LuxText.display(nameSize), delay: 700.ms),
        Text('&', style: LuxText.serif(nameSize * 0.55, color: Lux.gold, height: 0.9))
            .animate()
            .fadeIn(delay: 1700.ms, duration: 1000.ms)
            .scale(
                begin: const Offset(.6, .6),
                end: const Offset(1, 1),
                delay: 1700.ms,
                duration: 1200.ms,
                curve: Motion.cinematic),
        LetterReveal(text: WeddingConfig.groom, style: LuxText.display(nameSize), delay: 1900.ms),
        const SizedBox(height: 26),
        Container(width: 1, height: 60, color: Lux.crimson.withValues(alpha: 0.6))
            .animate()
            .scale(
                begin: const Offset(1, 0),
                end: const Offset(1, 1),
                alignment: Alignment.topCenter,
                delay: 2900.ms,
                duration: 900.ms,
                curve: Motion.cinematic),
        const SizedBox(height: 16),
        Text(
          WeddingConfig.dateLabel,
          style: LuxText.serif(context.fluid(22, 34),
              style: FontStyle.normal, spacing: 8, weight: FontWeight.w600, color: Lux.crimson),
        )
            .animate()
            .fadeIn(delay: 3100.ms, duration: 1200.ms)
            .moveY(begin: 18, end: 0, delay: 3100.ms, duration: 1200.ms, curve: Motion.cinematic),
        const SizedBox(height: 6),
        Text(WeddingConfig.venueCity, style: LuxText.serif(context.fluid(17, 22), color: Lux.dark.withValues(alpha: 0.85)))
            .animate()
            .fadeIn(delay: 3400.ms, duration: 1200.ms),
      ],
    );

    return Stack(fit: StackFit.expand, children: [
      // Bloom: a breathing pool of light behind the names.
      Center(
        child: IgnorePointer(
          child: Container(
            width: size.shortestSide * 1.1,
            height: size.shortestSide * 1.1,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Lux.goldLight.withValues(alpha: .34), Colors.transparent]),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                  begin: const Offset(.92, .92),
                  end: const Offset(1.08, 1.08),
                  duration: 5.seconds,
                  curve: Curves.easeInOut),
        ),
      ),
      // Floral depth layer — rushes past the camera as you scroll.
      IgnorePointer(
        child: PointerParallax(
          builder: (c, o, _) => Transform(
            alignment: Alignment.center,
            transform: depthMatrix(ry: o.dx * 0.06, rx: -o.dy * 0.05, dz: p * 260),
            child: Ticking(
              builder: (c, time) => RepaintBoundary(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: FloralPainter(time: time, progress: p, pointer: o),
                ),
              ),
            ),
          ),
        ),
      ),
      // Names: tilt with the cursor, dolly toward the lens on scroll.
      Center(
        child: PointerParallax(
          child: content,
          builder: (c, o, child) {
            Widget w = Transform(
              alignment: Alignment.center,
              transform: depthMatrix(
                ry: o.dx * 0.08,
                rx: -o.dy * 0.06 - p * 0.18,
                dy: -p * size.height * 0.10,
                dz: p * 240,
              ),
              child: child,
            );
            w = Opacity(opacity: fade, child: w);
            if (blur > 0.3) {
              w = ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur, tileMode: TileMode.decal),
                child: w,
              );
            }
            return w;
          },
        ),
      ),
      Positioned(
        bottom: 34,
        left: 0,
        right: 0,
        child: Opacity(opacity: fade, child: const _ScrollCue()),
      ),
    ]);
  }
}

class _ScrollCue extends StatelessWidget {
  const _ScrollCue();

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('SCROLL', style: LuxText.eyebrow().copyWith(fontSize: 12, letterSpacing: 6)),
          const SizedBox(height: 10),
          Container(width: 1, height: 44, color: Lux.gold)
              .animate(onPlay: (c) => c.repeat())
              .scale(
                  begin: const Offset(1, 0),
                  end: const Offset(1, 1),
                  alignment: Alignment.topCenter,
                  duration: 1600.ms,
                  curve: Curves.easeInOutCubic)
              .then()
              .fadeOut(duration: 400.ms),
        ],
      ).animate().fadeIn(delay: 3800.ms, duration: 1200.ms);
}
