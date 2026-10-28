import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'motion.dart';

/// Scroll-driven reveal: fade-up + rise-from-depth + blur-to-focus, all
/// derived from a 0..1 [progress] so it is perfectly scrubbable.
/// [dz] is how far *behind* the screen plane the child starts.
/// (Children should be stateless; the blur wrapper is added/removed.)
class ProgressReveal extends StatelessWidget {
  const ProgressReveal({
    super.key,
    required this.progress,
    required this.child,
    this.start = 0,
    this.end = 0.3,
    this.dy = 56,
    this.dz = 0,
    this.rx = 0,
    this.blur = 10,
    this.curve = Motion.cinematic,
  });

  final double progress, start, end, dy, dz, rx, blur;
  final Curve curve;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = curve.transform(Motion.window(progress, start, end));
    final inv = 1 - t;
    Widget w = Transform(
      alignment: Alignment.center,
      transform: depthMatrix(dy: dy * inv, dz: -dz * inv, rx: rx * inv),
      child: Opacity(opacity: t, child: child),
    );
    final sigma = blur * inv;
    if (sigma > 0.2) {
      w = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma, tileMode: TileMode.decal),
        child: w,
      );
    }
    return w;
  }
}

/// Plays a fade / rise / blur-to-focus once, the first time it is seen.
/// With [lazy] the child is not built until it becomes visible
/// (the gallery uses this so images load on demand).
class AppearOnVisible extends StatefulWidget {
  const AppearOnVisible({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.dy = 40,
    this.lazy = false,
    this.threshold = 0.12,
  });
  final Widget child;
  final Duration delay;
  final double dy, threshold;
  final bool lazy;

  @override
  State<AppearOnVisible> createState() => _AppearOnVisibleState();
}

class _AppearOnVisibleState extends State<AppearOnVisible> {
  final _key = UniqueKey();
  bool _shown = false;

  @override
  Widget build(BuildContext context) {
    final Widget inner = (!_shown && widget.lazy)
        ? const SizedBox.expand()
        : widget.child
            .animate(target: _shown ? 1 : 0, delay: widget.delay)
            .fadeIn(duration: 900.ms, curve: Motion.cinematic)
            .moveY(begin: widget.dy, end: 0, duration: 1100.ms, curve: Motion.cinematic)
            .blur(begin: const Offset(8, 8), end: Offset.zero, duration: 900.ms);
    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: (info) {
        if (!_shown && info.visibleFraction > widget.threshold && mounted) {
          setState(() => _shown = true);
        }
      },
      child: inner,
    );
  }
}

/// Letter-by-letter assembly with blur-to-focus.
class LetterReveal extends StatelessWidget {
  const LetterReveal({
    super.key,
    required this.text,
    required this.style,
    this.delay = Duration.zero,
    this.stagger = const Duration(milliseconds: 85),
  });
  final String text;
  final TextStyle style;
  final Duration delay, stagger;

  @override
  Widget build(BuildContext context) {
    final chars = text.characters.toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < chars.length; i++)
          chars[i] == ' '
              ? SizedBox(width: (style.fontSize ?? 40) * 0.3)
              : Text(chars[i], style: style)
                  .animate(delay: delay + stagger * i)
                  .fadeIn(duration: 900.ms, curve: Curves.easeOut)
                  .moveY(begin: 46, end: 0, duration: 1300.ms, curve: Motion.cinematic)
                  .blur(begin: const Offset(14, 14), end: Offset.zero, duration: 1000.ms),
      ],
    );
  }
}
