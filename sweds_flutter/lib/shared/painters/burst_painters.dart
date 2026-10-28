import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/lux.dart';
import 'floral_painter.dart';

class _Particle {
  _Particle(math.Random r, this.petal)
      : angle = r.nextDouble() * math.pi * 2,
        speed = petal ? 300 + r.nextDouble() * 650 : 200 + r.nextDouble() * 900,
        spin = (r.nextDouble() - .5) * 8,
        size = petal ? 12 + r.nextDouble() * 20 : 1.5 + r.nextDouble() * 3.2,
        phase = r.nextDouble() * 6.28,
        life = 2.4 + r.nextDouble() * 1.8,
        tint = r.nextInt(3);
  final bool petal;
  final double angle, speed, spin, size, phase, life;
  final int tint;
}

/// Petals + golden sparks erupting from [origin] — plays once.
class PetalBurst extends StatefulWidget {
  const PetalBurst({super.key, this.origin = const Alignment(0, 0.1)});
  final Alignment origin;

  @override
  State<PetalBurst> createState() => _PetalBurstState();
}

class _PetalBurstState extends State<PetalBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 4400))..forward();
  late final List<_Particle> _ps = () {
    final r = math.Random(21);
    return [
      for (var i = 0; i < 70; i++) _Particle(r, true),
      for (var i = 0; i < 110; i++) _Particle(r, false),
    ];
  }();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.infinite,
        painter: _BurstPainter(_c, _ps, widget.origin),
      );
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.anim, this.ps, this.origin) : super(repaint: anim);
  final Animation<double> anim;
  final List<_Particle> ps;
  final Alignment origin;

  @override
  void paint(Canvas canvas, Size size) {
    final tau = anim.value * 4.4;
    final o = origin.alongSize(size);
    final k = math.max(size.shortestSide / 800, 0.5);
    final paint = Paint();
    const colors = [Lux.crimson, Lux.marigold, Lux.ivory];

    for (final p in ps) {
      if (tau > p.life) continue;
      final life = tau / p.life;
      const drag = 2.2;
      final dist = p.speed * k * (1 - math.exp(-drag * tau)) / drag;
      final g = p.petal ? 120.0 : 70.0;
      final pos = o +
          Offset(
            math.cos(p.angle) * dist + (p.petal ? math.sin(tau * 3 + p.phase) * 14 : 0),
            math.sin(p.angle) * dist + 0.5 * g * k * tau * tau,
          );
      final fade = 1 - ((life - 0.6) / 0.4).clamp(0.0, 1.0);

      if (p.petal) {
        canvas.save();
        canvas.translate(pos.dx, pos.dy);
        canvas.rotate(p.angle + p.spin * tau);
        canvas.scale(p.size * k * (0.7 + 0.3 * math.cos(tau * 4 + p.phase).abs()));
        canvas.drawPath(kUnitPetal, paint..color = colors[p.tint].withValues(alpha: 0.9 * fade));
        canvas.restore();
      } else {
        final r = p.size * (1 - life * 0.5);
        canvas.drawCircle(pos, r * 3.2, paint..color = Lux.gold.withValues(alpha: 0.18 * fade));
        canvas.drawCircle(pos, r, paint..color = Lux.goldLight.withValues(alpha: fade));
      }
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => false;
}
