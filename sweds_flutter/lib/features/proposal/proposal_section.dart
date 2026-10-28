import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/animations/motion.dart';
import '../../core/animations/reveal.dart';
import '../../core/scroll/scene_section.dart';
import '../../core/scroll/section_spec.dart';
import '../../core/theme/lux.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/widgets/pointer_parallax.dart';
import '../../core/widgets/ticking.dart';
import '../../shared/painters/ring_painter.dart';

class ProposalSection extends StatelessWidget {
  const ProposalSection({super.key});

  @override
  Widget build(BuildContext context) =>
      SceneSection(index: Sec.proposal, builder: (c, p, size) => _ProposalStage(p: p, size: size));
}

class _ProposalStage extends StatelessWidget {
  const _ProposalStage({required this.p, required this.size});
  final double p;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final wide = size.width >= 900;
    final enter = Motion.cinematic.transform(Motion.window(p, 0, 0.28));
    final exit = Motion.window(p, 0.88, 1.0);
    final ringSide = math.min(size.width, size.height) * (wide ? 0.96 : 0.82);

    return Opacity(
      opacity: 1 - exit * 0.6,
      child: Stack(children: [
        // The ring: real 3-D, reacts to cursor + scroll.
        Center(
          child: PointerParallax(
            builder: (c, o, _) => Transform(
              alignment: Alignment.center,
              transform: depthMatrix(
                rx: -o.dy * 0.12,
                ry: o.dx * 0.18,
                dz: -(1 - enter) * 420,
                dy: (1 - enter) * 120,
              ),
              child: SizedBox(
                width: ringSide,
                height: ringSide,
                child: Ticking(
                  builder: (c, time) => RepaintBoundary(
                    child: CustomPaint(
                      painter: RingPainter(
                        time: time,
                        yaw: o.dx * 0.9 + p * 1.4,
                        pitch: -0.3 + o.dy * 0.3,
                        glow: 0.5 + 0.5 * enter,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: size.height * (wide ? .11 : .10),
          left: 24,
          right: 24,
          child: ProgressReveal(
            progress: p,
            start: 0.0,
            end: 0.22,
            blur: 14,
            child: Column(children: [
              Text('THE ASHIRBAAD & UNION', style: LuxText.eyebrow(Lux.crimson)),
              const SizedBox(height: 14),
              Text('Two hearts blessed as one',
                  textAlign: TextAlign.center, style: LuxText.display(context.fluid(36, 84))),
            ]),
          ),
        ),
        Positioned(
          bottom: size.height * (wide ? .10 : .07),
          left: 24,
          right: 24,
          child: Center(
            child: ProgressReveal(
              progress: p,
              start: 0.30,
              end: 0.55,
              dy: 70,
              child: GlassPanel(
                radius: 26,
                padding: EdgeInsets.symmetric(horizontal: wide ? 40 : 22, vertical: 22),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('21 · 03 · 2025',
                        style: LuxText.serif(22, style: FontStyle.normal, spacing: 6, color: Lux.crimson, weight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Text(
                      'With the sacred sounds of the shankha, dhan-durba, and tears of joy, '
                      'our parents blessed the love we built. Chosen by our hearts, '
                      'and forever arranged by our families.',
                      textAlign: TextAlign.center,
                      style: LuxText.serif(context.fluid(18, 24), height: 1.45),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
