import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/lux.dart';

/// Loads `assets/images/<name>.jpg`. If the photo is missing it paints a
/// deterministic, on-brand placeholder so the film is complete before the
/// real photography arrives.
class ArtImage extends StatelessWidget {
  const ArtImage({
    super.key,
    required this.name,
    required this.seed,
    this.fit = BoxFit.cover,
    this.radius = 0,
    this.cacheWidth = 1400,
  });
  final String name;
  final int seed;
  final BoxFit fit;
  final double radius;
  final int cacheWidth;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        'assets/images/$name.jpg',
        fit: fit,
        cacheWidth: cacheWidth,
        filterQuality: FilterQuality.medium,
        frameBuilder: (context, child, frame, sync) => AnimatedOpacity(
          opacity: (frame == null && !sync) ? 0 : 1,
          duration: const Duration(milliseconds: 700),
          child: child,
        ),
        errorBuilder: (context, error, stack) =>
            CustomPaint(painter: _ArtPainter(seed), child: const SizedBox.expand()),
      ),
    );
  }
}

class _ArtPainter extends CustomPainter {
  _ArtPainter(this.seed);
  final int seed;

  static const _palettes = <List<int>>[
    [0xFFF3D9C5, 0xFFE6C7C2, 0xFFC99C8A],
    [0xFFF7E8C8, 0xFFE4D0B6, 0xFFB89268],
    [0xFFE8D5D0, 0xFFD9B8B0, 0xFF9C7A7A],
    [0xFFF4E3B5, 0xFFEBC980, 0xFFB48A2C],
    [0xFFEFE3D5, 0xFFD7BFA4, 0xFF8D7458],
    [0xFFF6D9D2, 0xFFE9B7AE, 0xFFB27C74],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final pal = _palettes[seed % _palettes.length].map(Color.new).toList();
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [pal[0], pal[1]],
        ).createShader(rect),
    );

    final sunC = Offset(w * (0.28 + 0.44 * ((seed * 0.37) % 1)), h * 0.3);
    canvas.drawCircle(
      sunC,
      w * 0.5,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withValues(alpha: 0.75), Colors.white.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: sunC, radius: w * 0.5)),
    );

    for (var layer = 0; layer < 2; layer++) {
      final base = h * (0.72 + layer * 0.1);
      final path = Path()..moveTo(0, h);
      path.lineTo(0, base);
      for (var i = 0; i <= 8; i++) {
        final x = w * i / 8;
        final y = base - math.sin(i * 0.9 + seed + layer * 2) * h * 0.04 - layer * 0;
        path.lineTo(x, y);
      }
      path.lineTo(w, h);
      path.close();
      canvas.drawPath(path, Paint()..color = pal[2].withValues(alpha: 0.32 + layer * 0.22));
    }

    // Arch
    final aw = w * 0.42, ah = h * 0.52;
    final arch = RRect.fromRectAndCorners(
      Rect.fromLTWH((w - aw) / 2, h * 0.82 - ah, aw, ah),
      topLeft: Radius.circular(aw / 2),
      topRight: Radius.circular(aw / 2),
    );
    canvas.drawRRect(arch, Paint()..color = Lux.ivory.withValues(alpha: 0.2));
    canvas.drawRRect(
      arch,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Lux.gold.withValues(alpha: 0.55),
    );

    // Two silhouettes
    final fig = Paint()..color = pal[2].withValues(alpha: 0.78);
    for (final dx in [-0.05, 0.05]) {
      final cx = w * (0.5 + dx);
      final top = h * (dx < 0 ? 0.52 : 0.55);
      canvas.drawCircle(Offset(cx, top), w * 0.028, fig);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - w * 0.032, top + w * 0.04, w * 0.064, h * 0.24),
          Radius.circular(w * 0.03),
        ),
        fig,
      );
    }
  }

  @override
  bool shouldRepaint(_ArtPainter old) => old.seed != seed;
}
