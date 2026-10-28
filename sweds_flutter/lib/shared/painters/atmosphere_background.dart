import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/lux.dart';
import '../../core/widgets/ticking.dart';
import '../providers/app_providers.dart';
import '../providers/scene_providers.dart';

class _Mote {
  _Mote(math.Random r)
      : x = r.nextDouble(),
        y = r.nextDouble(),
        z = 0.15 + r.nextDouble() * 0.85,
        phase = r.nextDouble() * math.pi * 2;
  final double x, y, z, phase;
}

/// The fixed "world" behind every chapter: fragment-shader fog + bloom whose
/// palette is a function of scroll progress, plus depth-sorted gold motes.
class AtmosphereBackground extends ConsumerStatefulWidget {
  const AtmosphereBackground({super.key});

  @override
  ConsumerState<AtmosphereBackground> createState() => _AtmosphereBackgroundState();
}

class _AtmosphereBackgroundState extends ConsumerState<AtmosphereBackground> {
  ui.FragmentShader? _shader;
  late final List<_Mote> _motes = () {
    final r = math.Random(7);
    return List.generate(110, (_) => _Mote(r));
  }();

  @override
  void initState() {
    super.initState();
    ui.FragmentProgram.fromAsset('shaders/atmosphere.frag').then((p) {
      if (mounted) setState(() => _shader = p.fragmentShader());
    }).catchError((Object e) {
      debugPrint('Atmosphere shader unavailable, using gradient fallback: $e');
    });
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(deviceClassProvider).particles.clamp(0, _motes.length);
    return RepaintBoundary(
      child: Ticking(
        builder: (context, time) => CustomPaint(
          size: Size.infinite,
          painter: _AtmospherePainter(
            time: time,
            shader: _shader,
            motes: _motes,
            count: count,
            scroll: () => ref.read(scrollProgressProvider),
            mouse: () => ref.read(pointerNormProvider),
          ),
        ),
      ),
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  _AtmospherePainter({
    required this.time,
    required this.shader,
    required this.motes,
    required this.count,
    required this.scroll,
    required this.mouse,
  }) : super(repaint: time);

  final ValueListenable<double> time;
  final ui.FragmentShader? shader;
  final List<_Mote> motes;
  final int count;
  final double Function() scroll;
  final Offset Function() mouse;
  final Paint _p = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value, sc = scroll(), m = mouse();
    final (a, b, c) = Lux.sceneColors(sc);
    final rect = Offset.zero & size;

    final s = shader;
    if (s != null) {
      s
        ..setFloat(0, size.width)
        ..setFloat(1, size.height)
        ..setFloat(2, t)
        ..setFloat(3, sc)
        ..setFloat(4, m.dx)
        ..setFloat(5, m.dy)
        ..setFloat(6, 1.0)
        ..setFloat(7, a.r)
        ..setFloat(8, a.g)
        ..setFloat(9, a.b)
        ..setFloat(10, b.r)
        ..setFloat(11, b.g)
        ..setFloat(12, b.b)
        ..setFloat(13, c.r)
        ..setFloat(14, c.g)
        ..setFloat(15, c.b);
      canvas.drawRect(rect, _p..shader = s);
      _p.shader = null;
    } else {
      canvas.drawRect(
        rect,
        _p
          ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), [a, c]),
      );
      final lp = Offset(size.width * (0.7 + m.dx * 0.05), size.height * 0.3);
      canvas.drawRect(
        rect,
        _p..shader = ui.Gradient.radial(lp, size.shortestSide, [b.withValues(alpha: 0.5), b.withValues(alpha: 0)]),
      );
      _p.shader = null;
    }

    final core = Color.lerp(Lux.gold, Colors.white, 0.5)!;
    for (var i = 0; i < count; i++) {
      final mt = motes[i];
      final z = mt.z;
      final y = (mt.y - t * 0.006 * (0.4 + z) - sc * z * 0.9) % 1.0;
      final x = mt.x + math.sin(t * 0.25 * z + mt.phase) * 0.015 + m.dx * 0.012 * z;
      final pos = Offset(x * size.width, y * size.height);
      final tw = 0.5 + 0.5 * math.sin(t * 1.1 + mt.phase * 3);
      final r = 0.8 + 3.2 * z;
      final al = (0.18 + 0.55 * z) * (0.4 + 0.6 * tw);
      canvas.drawCircle(pos, r * 4, _p..color = Lux.gold.withValues(alpha: al * 0.16));
      canvas.drawCircle(pos, r, _p..color = core.withValues(alpha: al));
    }
  }

  @override
  bool shouldRepaint(_AtmospherePainter old) => old.shader != shader || old.count != count;
}
