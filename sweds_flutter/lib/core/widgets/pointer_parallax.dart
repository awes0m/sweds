import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/app_providers.dart';
import '../../shared/providers/scene_providers.dart';

/// Hands the builder a *smoothed* pointer offset (-1..1). Only the builder's
/// subtree is rebuilt as the cursor glides; nothing above it.
class PointerParallax extends ConsumerStatefulWidget {
  const PointerParallax({
    super.key,
    required this.builder,
    this.child,
    this.smoothing = 5,
  });
  final Widget Function(BuildContext context, Offset pointer, Widget? child)
  builder;
  final Widget? child;
  final double smoothing;

  @override
  ConsumerState<PointerParallax> createState() => _PointerParallaxState();
}

class _PointerParallaxState extends ConsumerState<PointerParallax>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _value = ValueNotifier<Offset>(Offset.zero);
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((e) {
      final dt = _last == Duration.zero
          ? 1 / 60
          : ((e - _last).inMicroseconds / 1e6).clamp(0.0, 0.05);
      _last = e;
      final target =
          ref.read(pointerNormProvider) *
          ref.read(deviceClassProvider).parallax;
      final next = Offset.lerp(
        _value.value,
        target,
        1 - math.exp(-widget.smoothing * dt),
      )!;
      if ((next - _value.value).distance > 0.0004) _value.value = next;
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Offset>(
    valueListenable: _value,
    builder: widget.builder,
    child: widget.child,
  );
}
