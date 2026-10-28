import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/lux.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(28),
    this.radius = 28,
    this.blur = 22,
    this.opacity = 0.5,
    this.shadow = true,
  });
  final Widget child;
  final EdgeInsets padding;
  final double radius, blur, opacity;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: shadow
            ? [
                BoxShadow(color: Lux.dark.withValues(alpha: 0.10), blurRadius: 50, offset: const Offset(0, 24)),
                BoxShadow(color: Lux.gold.withValues(alpha: 0.08), blurRadius: 80),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: r,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Lux.ivory.withValues(alpha: (opacity + 0.18).clamp(0.0, 1.0)),
                  Lux.ivory.withValues(alpha: (opacity - 0.12).clamp(0.0, 1.0)),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
