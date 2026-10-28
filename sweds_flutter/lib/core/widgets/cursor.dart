import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/lux.dart';
import '../../shared/providers/app_providers.dart';

/// Wrap any interactive element: the luxury cursor blooms while hovering it.
class CursorHover extends ConsumerWidget {
  const CursorHover({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) => MouseRegion(
        onEnter: (_) => ref.read(cursorHoveringProvider.notifier).set(true),
        onExit: (_) => ref.read(cursorHoveringProvider.notifier).set(false),
        child: child,
      );
}

/// Gold dot + trailing ring. Only shown once a real mouse has been seen.
class LuxuryCursor extends ConsumerWidget {
  const LuxuryCursor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(hasMouseProvider)) return const SizedBox.shrink();
    final p = ref.watch(pointerPxProvider);
    final hover = ref.watch(cursorHoveringProvider);
    final ringSize = hover ? 68.0 : 34.0;

    return IgnorePointer(
      child: Stack(children: [
        TweenAnimationBuilder<Offset>(
          tween: Tween<Offset>(end: p),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          builder: (context, o, _) => Positioned(
            left: o.dx - ringSize / 2,
            top: o.dy - ringSize / 2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              width: ringSize,
              height: ringSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Lux.gold.withValues(alpha: hover ? 0.16 : 0),
                border: Border.all(color: Lux.gold.withValues(alpha: hover ? 0.9 : 0.7), width: 1),
              ),
            ),
          ),
        ),
        Positioned(
          left: p.dx - 3,
          top: p.dy - 3,
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: Lux.goldDeep, shape: BoxShape.circle),
          ),
        ),
      ]),
    );
  }
}
