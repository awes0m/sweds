import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/lux.dart';

/// Unit petal pointing up from the origin (reused by the petal burst).
final Path kUnitPetal = Path()
  ..moveTo(0, 0)
  ..cubicTo(.38, -.22, .42, -.78, 0, -1)
  ..cubicTo(-.42, -.78, -.38, -.22, 0, 0)
  ..close();

class _Flower {
  const _Flower(this.x, this.y, this.r, this.d, this.n);
  final double x, y, r, d;
  final int n;
}

/// Slowly rotating translucent blooms at different depths. [progress] pushes
/// them past the camera, [pointer] shifts them in parallax.
class FloralPainter extends CustomPainter {
  FloralPainter({required this.time, required this.progress, required this.pointer})
      : super(repaint: time);

  final ValueListenable<double> time;
  final double progress;
  final Offset pointer;

  static const _flowers = <_Flower>[
    _Flower(.10, .24, 250, .9, 9),
    _Flower(.90, .16, 320, .55, 11),
    _Flower(.84, .84, 280, 1.0, 9),
    _Flower(.08, .82, 200, .5, 8),
    _Flower(.52, -.02, 170, .3, 7),
    _Flower(.50, 1.02, 230, .4, 10),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value;
    final unit = size.shortestSide / 900;
    for (var i = 0; i < _flowers.length; i++) {
      final f = _flowers[i];
      final c = Offset(
        f.x * size.width + pointer.dx * 60 * f.d - progress * size.width * 0.05 * (f.x < .5 ? -1 : 1) * f.d,
        f.y * size.height + pointer.dy * 40 * f.d - progress * size.height * 0.30 * f.d,
      );
      final r = f.r * unit * (0.92 + 0.08 * math.sin(t * 0.4 + i)) * (1 + progress * 0.6 * f.d);
      final a = (0.5 + 0.5 * f.d) * 0.55;
      _flower(canvas, c, r, f.n, t * 0.04 * f.d * (i.isEven ? 1 : -1) + i, a);
    }
  }

  void _flower(Canvas canvas, Offset o, double r, int n, double rot, double a) {
    final fill = Paint();
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 / r;
    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.rotate(rot);
    canvas.scale(r);
    for (var i = 0; i < n; i++) {
      canvas.save();
      canvas.rotate(i * math.pi * 2 / n);
      final petalFill = (i % 3 == 0)
          ? Lux.crimson.withValues(alpha: a * .42)
          : (i % 3 == 1)
              ? Lux.marigold.withValues(alpha: a * .38)
              : Lux.rose.withValues(alpha: a * .50);
      canvas.drawPath(kUnitPetal, fill..color = petalFill);
      canvas.save();
      canvas.scale(.62);
      canvas.drawPath(kUnitPetal, fill..color = Lux.ivory.withValues(alpha: a * .75));
      canvas.restore();
      canvas.drawPath(kUnitPetal, line..color = Lux.gold.withValues(alpha: a * .75));
      canvas.restore();
    }
    canvas.drawCircle(Offset.zero, .07, fill..color = Lux.gold.withValues(alpha: a * .9));
    canvas.restore();
  }

  @override
  bool shouldRepaint(FloralPainter old) => old.progress != progress || old.pointer != pointer;
}
