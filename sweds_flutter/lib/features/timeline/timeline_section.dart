import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/animations/motion.dart';
import '../../core/constants/wedding_config.dart';
import '../../core/scroll/scene_section.dart';
import '../../core/scroll/section_spec.dart';
import '../../core/theme/lux.dart';
import '../../core/widgets/glass_panel.dart';

class TimelineSection extends StatelessWidget {
  const TimelineSection({super.key});

  @override
  Widget build(BuildContext context) =>
      SceneSection(index: Sec.timeline, builder: (c, p, size) => _TimelineStage(p: p, size: size));
}

/// Vertical scroll scrubs a horizontal rail. Cards rise out of depth as they
/// approach the centre; the rail glows up to the active event.
class _TimelineStage extends StatelessWidget {
  const _TimelineStage({required this.p, required this.size});
  final double p;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final n = kEvents.length;
    final w = size.width, h = size.height;
    final cw = (w * 0.78).clamp(280.0, 400.0);
    const gap = 36.0;
    final step = cw + gap;
    final pad = (w - cw) / 2;
    final rowW = pad * 2 + n * cw + (n - 1) * gap;
    final f = p * (n - 1);
    final cardH = (h * 0.44).clamp(300.0, 400.0);
    final active = f.round().clamp(0, n - 1);

    return Stack(children: [
      Positioned(
        left: w >= 900 ? 64 : 22,
        top: h * (w >= 900 ? .10 : .09),
        right: 22,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('THE CELEBRATIONS', style: LuxText.eyebrow(Lux.crimson)),
              const SizedBox(height: 10),
              Text('Five Days of Joy & Traditions', style: LuxText.display(context.fluid(30, 60))),
            ]),
            const Spacer(),
            Text('0${active + 1} / 0$n', style: LuxText.serif(context.fluid(22, 34), style: FontStyle.normal, color: Lux.goldDeep, spacing: 3)),
          ],
        ),
      ),
      Positioned(
        left: 0,
        top: h * 0.30,
        child: Transform.translate(
          offset: Offset(-f * step, 0),
          child: SizedBox(
            width: rowW,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: cardH,
                child: Row(children: [
                  SizedBox(width: pad),
                  for (var i = 0; i < n; i++) ...[
                    _EventCard(event: kEvents[i], index: i, d: i - f, width: cw, height: cardH),
                    SizedBox(width: i == n - 1 ? pad : gap),
                  ],
                ]),
              ),
              const SizedBox(height: 26),
              SizedBox(
                height: 70,
                width: rowW,
                child: CustomPaint(painter: _RailPainter(n: n, cw: cw, gap: gap, pad: pad, f: f)),
              ),
            ]),
          ),
        ),
      ),
    ]);
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.index, required this.d, required this.width, required this.height});
  final WeddingEvent event;
  final int index;
  final double d, width, height;

  @override
  Widget build(BuildContext context) {
    final ad = d.abs().clamp(0.0, 2.2);
    return Transform(
      alignment: Alignment.center,
      transform: depthMatrix(
        ry: -d.clamp(-1.5, 1.5) * 0.33,
        rx: ad * 0.05,
        dy: ad * 26,
        dz: -ad * 140,
      ),
      child: Opacity(
        opacity: (1 - ad * 0.38).clamp(0.12, 1.0),
        child: SizedBox(
          width: width,
          height: height,
          child: GlassPanel(
            radius: 30,
            padding: const EdgeInsets.all(26),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('0${index + 1}', style: LuxText.display(34, color: Lux.crimson, style: FontStyle.italic)),
                const Spacer(),
                Text(event.date.toUpperCase(), style: LuxText.eyebrow(Lux.crimson).copyWith(fontSize: 13, letterSpacing: 3)),
              ]),
              const Spacer(),
              Text(event.name, style: LuxText.display(context.fluid(30, 42))),
              const SizedBox(height: 8),
              Text('${event.time}  ·  ${event.place}', style: LuxText.serif(18, color: Lux.crimson, weight: FontWeight.w600)),
              const SizedBox(height: 14),
              Container(width: 40, height: 1.5, color: Lux.gold),
              const SizedBox(height: 14),
              Text(event.blurb, style: LuxText.body(14.5, height: 1.65)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _RailPainter extends CustomPainter {
  _RailPainter({required this.n, required this.cw, required this.gap, required this.pad, required this.f});
  final int n;
  final double cw, gap, pad, f;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.5;
    final step = cw + gap;
    final x0 = pad + cw / 2;
    final x1 = x0 + (n - 1) * step;
    final ax = x0 + f * step;

    canvas.drawLine(
      Offset(x0, y),
      Offset(x1, y),
      Paint()
        ..color = Lux.champagne
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
    // Soft glow + core of the travelled portion.
    canvas.drawLine(
      Offset(x0, y),
      Offset(ax, y),
      Paint()
        ..color = Lux.gold.withValues(alpha: 0.45)
        ..strokeWidth = 9
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawLine(
      Offset(x0, y),
      Offset(ax, y),
      Paint()
        ..shader = LinearGradient(colors: [Lux.goldDeep, Lux.goldLight]).createShader(Rect.fromPoints(Offset(x0, y), Offset(math.max(ax, x0 + 1), y)))
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );

    for (var i = 0; i < n; i++) {
      final cx = x0 + i * step;
      final near = (1 - (i - f).abs()).clamp(0.0, 1.0);
      final reached = i <= f + 0.01;
      if (near > 0) {
        canvas.drawCircle(Offset(cx, y), 12 + 14 * near, Paint()..color = Lux.gold.withValues(alpha: 0.18 * near));
      }
      canvas.drawCircle(Offset(cx, y), 5 + 4 * near, Paint()..color = reached ? Lux.gold : Lux.ivory);
      canvas.drawCircle(
        Offset(cx, y),
        5 + 4 * near,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = reached ? Lux.goldDeep : Lux.champagne,
      );
    }
    // Travelling spark.
    canvas.drawCircle(Offset(ax, y), 9, Paint()..color = Colors.white.withValues(alpha: 0.9)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    canvas.drawCircle(Offset(ax, y), 3.2, Paint()..color = Lux.goldLight);
  }

  @override
  bool shouldRepaint(_RailPainter old) => old.f != f || old.cw != cw || old.pad != pad;
}
