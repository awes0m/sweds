import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/lux.dart';

typedef V = (double, double, double);

/// A true 3-D engagement ring rendered in software: a torus built from
/// depth-sorted spheres and an 8-sided brilliant gem with per-facet lighting,
/// animated specular flashes and star sparkles. [yaw]/[pitch] respond to the
/// cursor so the perspective changes as the mouse moves.
class RingPainter extends CustomPainter {
  RingPainter({required this.time, this.yaw = 0, this.pitch = -0.3, this.glow = 1})
      : super(repaint: time);

  final ValueListenable<double> time;
  final double yaw, pitch, glow;

  static const V _light = (-0.42, 0.66, 0.62);
  static const V _half = (-0.2334, 0.3669, 0.9005);
  static const _ice = [Color(0xFFF2F8FF), Color(0xFFD5E6FF), Color(0xFFFFF4E8), Color(0xFFE9DEFF)];

  static V _rot(V v, double yaw, double pitch) {
    final cy = math.cos(yaw), sy = math.sin(yaw);
    final x1 = v.$1 * cy + v.$3 * sy;
    final z1 = -v.$1 * sy + v.$3 * cy;
    final cp = math.cos(pitch), sp = math.sin(pitch);
    return (x1, v.$2 * cp - z1 * sp, v.$2 * sp + z1 * cp);
  }

  static double _dot(V a, V b) => a.$1 * b.$1 + a.$2 * b.$2 + a.$3 * b.$3;

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value;
    final u = size.shortestSide * 0.30;
    final c = size.center(Offset.zero) + Offset(0, u * 0.30);
    final ya = yaw + t * 0.42;
    const f = 4.2;

    Offset proj(V v) {
      final k = f / (f - v.$3);
      return Offset(c.dx + v.$1 * u * k, c.dy - v.$2 * u * k);
    }

    double sc(double z) => f / (f - z);

    // Halo and ground shadow.
    final halo = size.shortestSide * 0.46;
    canvas.drawCircle(
      c,
      halo,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Lux.goldLight.withValues(alpha: 0.38 * glow),
            Lux.rose.withValues(alpha: 0.14 * glow),
            Colors.transparent,
          ],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: c, radius: halo)),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: c + Offset(0, size.shortestSide * 0.40),
        width: size.shortestSide * 0.5,
        height: size.shortestSide * 0.07,
      ),
      Paint()
        ..color = Lux.dark.withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    final draws = <(double, VoidCallback)>[];
    final stars = <(Offset, double)>[];

    void sphere(V world, double radius, double diff) {
      final p = proj(world);
      final rad = radius * u * sc(world.$3);
      final col = Color.lerp(const Color(0xFF7C5B14), Lux.goldLight, (0.12 + 0.88 * diff).clamp(0.0, 1.0))!;
      draws.add((world.$3, () {
        canvas.drawCircle(p, rad, Paint()..color = col);
        if (diff > 0.55) {
          canvas.drawCircle(
            p.translate(-rad * .28, -rad * .3),
            rad * .32,
            Paint()..color = Colors.white.withValues(alpha: ((diff - .55) * 1.4).clamp(0.0, 1.0)),
          );
        }
      }));
    }

    // Band (torus of spheres).
    const n = 132;
    for (var i = 0; i < n; i++) {
      final a = i / n * math.pi * 2;
      final v = _rot((math.cos(a), math.sin(a), 0), ya, pitch);
      sphere(v, 0.115, math.max(0.0, _dot(v, _light)));
    }

    // Gem geometry (local space, sitting on top of the band).
    const gy = 1.16;
    V gv(int k) {
      final a = k * math.pi / 4 + math.pi / 8;
      return (0.44 * math.cos(a), gy, 0.44 * math.sin(a));
    }

    V tv(int k) {
      final a = k * math.pi / 4 + math.pi / 8;
      return (0.25 * math.cos(a), gy + 0.20, 0.25 * math.sin(a));
    }

    const V culet = (0.0, gy - 0.46, 0.0);

    // Prongs.
    for (var k = 0; k < 8; k += 2) {
      final v = _rot(gv(k), ya, pitch);
      sphere((v.$1, v.$2 + 0.01, v.$3), 0.055, math.max(0.0, _dot(v, _light)));
    }

    final faces = <List<V>>[
      [for (var k = 0; k < 8; k++) tv(k)],
      for (var k = 0; k < 8; k++) [tv(k), tv((k + 1) % 8), gv((k + 1) % 8), gv(k)],
      for (var k = 0; k < 8; k++) [gv(k), gv((k + 1) % 8), culet],
    ];

    for (var fi = 0; fi < faces.length; fi++) {
      final r = [for (final v in faces[fi]) _rot(v, ya, pitch)];
      final ax = r[1].$1 - r[0].$1, ay = r[1].$2 - r[0].$2, az = r[1].$3 - r[0].$3;
      final bx = r[2].$1 - r[0].$1, by = r[2].$2 - r[0].$2, bz = r[2].$3 - r[0].$3;
      var nx = ay * bz - az * by, ny = az * bx - ax * bz, nz = ax * by - ay * bx;
      final len = math.sqrt(nx * nx + ny * ny + nz * nz);
      if (len > 0) {
        nx /= len;
        ny /= len;
        nz /= len;
      }
      final nv = (nx, ny, nz);
      final diff = _dot(nv, _light).abs();
      final spec = math.pow(_dot(nv, _half).abs(), 32).toDouble();
      final flash = math.pow(math.max(0.0, math.sin(t * 1.8 + fi * 2.39)), 14).toDouble();
      final base = _ice[(fi * 3 + 1) % _ice.length];
      var col = Color.lerp(const Color(0xFF9DB4D6), base, 0.35 + 0.65 * diff)!;
      col = Color.lerp(col, Colors.white, math.min(1.0, flash + spec * 0.8))!;

      final pts = [for (final v in r) proj(v)];
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (var i = 1; i < pts.length; i++) {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
      path.close();
      final z = r.fold<double>(0, (s, v) => s + v.$3) / r.length;
      draws.add((z, () {
        canvas.drawPath(path, Paint()..color = col.withValues(alpha: 0.9));
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8
            ..color = Colors.white.withValues(alpha: 0.5),
        );
      }));
      if (flash > 0.45) {
        final cx = pts.fold<double>(0, (s, p) => s + p.dx) / pts.length;
        final cy = pts.fold<double>(0, (s, p) => s + p.dy) / pts.length;
        stars.add((Offset(cx, cy), u * 0.17 * flash));
      }
    }

    draws.sort((a, b) => a.$1.compareTo(b.$1));
    for (final d in draws) {
      d.$2();
    }
    for (final s in stars) {
      _star(canvas, s.$1, s.$2, 0.95);
    }

    // Orbiting sparkles.
    for (var i = 0; i < 22; i++) {
      final ang = t * 0.15 * (0.5 + (i % 5) * 0.15) + i * 2.4;
      final rad = u * (1.5 + (i % 7) * 0.12);
      final pos = c + Offset(math.cos(ang) * rad * 1.15, math.sin(ang) * rad * 0.7 - u * 0.1);
      final tw = math.pow(0.5 + 0.5 * math.sin(t * 2 + i * 1.7), 3).toDouble();
      _star(canvas, pos, 4 + (i % 4) * 2.5, tw * 0.85, gold: true);
    }
  }

  void _star(Canvas canvas, Offset c, double r, double alpha, {bool gold = false}) {
    final p = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(p, Paint()..color = (gold ? Lux.goldLight : Colors.white).withValues(alpha: alpha.clamp(0.0, 1.0)));
  }

  @override
  bool shouldRepaint(RingPainter old) => old.yaw != yaw || old.pitch != pitch || old.glow != glow;
}
