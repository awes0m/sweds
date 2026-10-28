import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/animations/motion.dart';
import '../../core/animations/reveal.dart';
import '../../core/constants/wedding_config.dart';
import '../../core/scroll/scene_section.dart';
import '../../core/scroll/section_spec.dart';
import '../../core/theme/lux.dart';
import '../../core/widgets/section_title.dart';
import '../../shared/providers/app_providers.dart';

class CountdownSection extends StatelessWidget {
  const CountdownSection({super.key});

  @override
  Widget build(BuildContext context) => SceneSection(
    index: Sec.countdown,
    builder: (c, p, size) => _CountdownStage(p: p, size: size),
  );
}

class _CountdownStage extends ConsumerWidget {
  const _CountdownStage({required this.p, required this.size});
  final double p;
  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rem = ref.watch(countdownProvider).value ?? WeddingConfig.remaining();
    final wide = size.width >= 900;
    final dial = wide ? 230.0 : ((size.width - 70) / 2).clamp(130.0, 200.0);
    final items = <(String, int, double)>[
      ('DAYS', rem.inDays, (rem.inDays / 365).clamp(0.0, 1.0)),
      ('HOURS', rem.inHours % 24, (rem.inHours % 24) / 24),
      ('MINUTES', rem.inMinutes % 60, (rem.inMinutes % 60) / 60),
      ('SECONDS', rem.inSeconds % 60, (rem.inSeconds % 60) / 60),
    ];

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProgressReveal(
            progress: p,
            start: 0.18,
            end: 0.4,
            child: const SectionTitle(
              eyebrow: 'The countdown',
              title: 'Until forever begins',
            ),
          ),
          const SizedBox(height: 44),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: wide ? 36 : 18,
            runSpacing: wide ? 36 : 22,
            children: [
              for (var i = 0; i < items.length; i++)
                ProgressReveal(
                  progress: p,
                  start: 0.22 + i * 0.05,
                  end: 0.5 + i * 0.05,
                  dy: 70,
                  dz: 240,
                  blur: 14,
                  child: _Dial(
                    label: items[i].$1,
                    value: items[i].$2,
                    fraction: items[i].$3,
                    size: dial,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 40),
          ProgressReveal(
            progress: p,
            start: 0.4,
            end: 0.6,
            child: Text(
              '${WeddingConfig.dateLabel}  ·  ${WeddingConfig.venueName}',
              style: LuxText.serif(
                context.fluid(18, 24),
                style: FontStyle.normal,
                spacing: 4,
                color: Lux.crimson,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dial extends StatelessWidget {
  const _Dial({
    required this.label,
    required this.value,
    required this.fraction,
    required this.size,
  });
  final String label;
  final int value;
  final double fraction, size;

  @override
  Widget build(BuildContext context) {
    final digits = value.toString().padLeft(2, '0').characters.toList();
    final fs = size * 0.30;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(end: fraction),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, f, _) => CustomPaint(
                      size: Size.square(size),
                      painter: _DialPainter(f),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < digits.length; i++)
                        _Digit(char: digits[i], slot: i, size: fs),
                    ],
                  ),
                ],
              ),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .custom(
              duration: 2600.ms,
              curve: Curves.easeInOut,
              builder: (context, v, child) => DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Lux.gold.withValues(alpha: 0.10 + 0.16 * v),
                      blurRadius: 36 + 34 * v,
                    ),
                  ],
                ),
                child: child,
              ),
            ),
        const SizedBox(height: 16),
        Text(
          label,
          style: LuxText.eyebrow().copyWith(fontSize: 13, letterSpacing: 5),
        ),
      ],
    );
  }
}

/// One digit that rolls upward into the next (number morphing).
class _Digit extends StatelessWidget {
  const _Digit({required this.char, required this.slot, required this.size});
  final String char;
  final int slot;
  final double size;

  @override
  Widget build(BuildContext context) {
    final key = ValueKey('$slot-$char');
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 650),
      switchInCurve: Motion.cinematic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) {
        final incoming = child.key == key;
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, incoming ? 0.45 : -0.45),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        );
      },
      child: Text(
        char,
        key: key,
        style: LuxText.display(
          size,
          spacing: 0,
          height: 1,
        ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter(this.fraction);
  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final R = size.shortestSide / 2 - 4;
    final rect = Rect.fromCircle(center: c, radius: R);

    // Face
    canvas.drawCircle(
      c,
      R,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Lux.ivory.withValues(alpha: 0.92),
            Lux.champagne.withValues(alpha: 0.45),
          ],
        ).createShader(rect),
    );
    // Bezel
    canvas.drawCircle(
      c,
      R,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..shader = const SweepGradient(
          colors: [
            Lux.gold,
            Lux.goldLight,
            Lux.goldDeep,
            Lux.goldLight,
            Lux.gold,
          ],
        ).createShader(rect),
    );
    // Minute track
    final tick = Paint()..strokeCap = StrokeCap.round;
    for (var i = 0; i < 60; i++) {
      final a = i * math.pi / 30 - math.pi / 2;
      final big = i % 5 == 0;
      final r1 = R - 8, r2 = R - 8 - (big ? 11 : 5);
      tick
        ..strokeWidth = big ? 1.8 : 1
        ..color = (big ? Lux.goldDeep : Lux.champagne).withValues(
          alpha: big ? 0.9 : 0.8,
        );
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * r1,
        c + Offset(math.cos(a), math.sin(a)) * r2,
        tick,
      );
    }
    // Progress arc with glow
    final arcR = R * 0.70;
    final arc = Rect.fromCircle(center: c, radius: arcR);
    final sweep = math.max(fraction, 0.004) * math.pi * 2;
    canvas.drawArc(
      arc,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = Lux.gold.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawArc(
      arc,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..color = Lux.goldDeep,
    );
    final end = -math.pi / 2 + sweep;
    final ep = c + Offset(math.cos(end), math.sin(end)) * arcR;
    canvas.drawCircle(ep, 5, Paint()..color = Lux.goldLight);
    canvas.drawCircle(
      ep,
      5,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Lux.goldDeep
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(_DialPainter old) => old.fraction != fraction;
}
