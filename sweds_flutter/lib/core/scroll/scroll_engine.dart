import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'section_spec.dart';

/// The single scroll controller for the whole film.
///
/// * Mouse-wheel input is converted into an eased, frame-rate independent
///   glide (cinematic inertia) instead of stepping.
/// * Touch / trackpad use native Flutter physics; the engine just follows.
/// * Programmatic jumps (nav, CTA, deep links) reuse the same glide.
class ScrollEngine {
  ScrollEngine({required TickerProvider vsync, required this.sectionTop}) {
    _ticker = vsync.createTicker(_tick);
    controller.addListener(_follow);
  }

  final ScrollController controller = ScrollController();
  final double Function(int index) sectionTop;
  late final Ticker _ticker;

  double _target = 0;
  double _stiffness = 9;
  Duration _last = Duration.zero;

  double get _max => controller.position.maxScrollExtent;

  void _follow() {
    if (!_ticker.isActive && controller.hasClients) _target = controller.offset;
  }

  void wheel(double dy) {
    if (!controller.hasClients) return;
    _target = (_target + dy).clamp(0.0, _max);
    _stiffness = 9;
    _kick();
  }

  void animateTo(double offset, {double stiffness = 4.5}) {
    if (!controller.hasClients) return;
    _target = offset.clamp(0.0, _max);
    _stiffness = stiffness;
    _kick();
  }

  void goToSection(int i) => animateTo(sectionTop(i));

  void jumpToSection(int i) {
    if (!controller.hasClients) return;
    final o = sectionTop(i).clamp(0.0, _max);
    _target = o;
    controller.jumpTo(o);
  }

  void _kick() {
    if (_ticker.isActive) return;
    _last = Duration.zero;
    _ticker.start();
  }

  void _tick(Duration elapsed) {
    final dt = _last == Duration.zero
        ? 1 / 60
        : ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _last = elapsed;
    final cur = controller.offset;
    final diff = _target - cur;
    if (diff.abs() < 0.4) {
      controller.jumpTo(_target);
      _ticker.stop();
      return;
    }
    controller.jumpTo(cur + diff * (1 - math.exp(-_stiffness * dt)));
  }

  void dispose() {
    _ticker.dispose();
    controller.dispose();
  }
}

/// Wrap each sliver child in this so wheel events reach the engine before the
/// Scrollable claims them (deepest hit-test target registers first).
class WheelCapture extends StatelessWidget {
  const WheelCapture({super.key, required this.engine, required this.child});
  final ScrollEngine engine;
  final Widget child;

  @override
  Widget build(BuildContext context) => Listener(
    behavior: HitTestBehavior.translucent,
    onPointerSignal: (event) {
      if (event is PointerScrollEvent) {
        GestureBinding.instance.pointerSignalResolver.register(event, (e) {
          engine.wheel((e as PointerScrollEvent).scrollDelta.dy);
        });
      }
    },
    child: child,
  );
}

class ScrollEngineScope extends InheritedWidget {
  const ScrollEngineScope({
    super.key,
    required this.engine,
    required super.child,
  });
  final ScrollEngine engine;

  static ScrollEngine of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ScrollEngineScope>()!.engine;

  @override
  bool updateShouldNotify(ScrollEngineScope old) => engine != old.engine;
}

extension SectionNavigation on BuildContext {
  /// Glides to a section and reflects it in the URL (`/?s=venue`).
  void goToSection(int i) {
    ScrollEngineScope.of(this).goToSection(i);
    GoRouter.of(this).go('/?s=${kSections[i].id}');
  }
}
