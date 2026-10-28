import 'package:flutter/widgets.dart';

/// Shared easing + helpers so every transition in the film feels related.
abstract final class Motion {
  static const cinematic = Cubic(0.16, 1, 0.3, 1); // expo-out
  static const silk = Cubic(0.65, 0, 0.35, 1); // in-out

  /// Remaps [v] so that [a]..[b] becomes 0..1 (clamped).
  static double window(double v, double a, double b) =>
      b == a ? (v >= b ? 1.0 : 0.0) : ((v - a) / (b - a)).clamp(0.0, 1.0);

  static double lerp(double a, double b, double t) => a + (b - a) * t;
}

/// Perspective matrix. Positive [dz] moves the layer *toward* the viewer.
Matrix4 depthMatrix({
  double rx = 0,
  double ry = 0,
  double rz = 0,
  double dx = 0,
  double dy = 0,
  double dz = 0,
  double perspective = 0.0011,
}) {
  final m = Matrix4.identity()..setEntry(3, 2, perspective);
  m.multiply(Matrix4.translationValues(dx, dy, -dz));
  m.rotateX(rx);
  m.rotateY(ry);
  m.rotateZ(rz);
  return m;
}
