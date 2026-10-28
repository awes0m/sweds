import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/scroll/section_spec.dart';

part 'scene_providers.g.dart';

enum DeviceClass {
  mobile,
  tablet,
  desktop;

  /// Particle budget for the atmosphere layer.
  int get particles => switch (this) {
    mobile => 34,
    tablet => 64,
    desktop => 110,
  };

  /// Scroll-parallax intensity multiplier.
  double get depth => switch (this) {
    mobile => 0.45,
    tablet => 0.75,
    desktop => 1.0,
  };

  /// Pointer-parallax multiplier.
  double get parallax => switch (this) {
    mobile => 0.0,
    tablet => 0.5,
    desktop => 1.0,
  };
}

@Riverpod(keepAlive: true)
class SceneViewport extends _$SceneViewport {
  @override
  Size build() {
    final v = PlatformDispatcher.instance.views.first;
    return v.physicalSize / v.devicePixelRatio;
  }

  void set(Size s) => state = s;
}

@Riverpod(keepAlive: true)
DeviceClass deviceClass(Ref ref) {
  final w = ref.watch(sceneViewportProvider.select((s) => s.width));
  if (w < 640) return DeviceClass.mobile;
  if (w < 1024) return DeviceClass.tablet;
  return DeviceClass.desktop;
}

/// Absolute geometry of every chapter, derived from the viewport.
@Riverpod(keepAlive: true)
List<SectionLayout> sectionLayouts(Ref ref) {
  final vh = ref.watch(sceneViewportProvider.select((s) => s.height));
  var y = 0.0;
  final out = <SectionLayout>[];
  for (final s in kSections) {
    final h = math.max(vh * s.heightFactor, s.minHeight);
    out.add(SectionLayout(s, y, h, vh));
    y += h;
  }
  return out;
}

@Riverpod(keepAlive: true)
class ScrollOffset extends _$ScrollOffset {
  @override
  double build() => 0;
  void set(double v) => state = v;
}

/// Per-chapter progress. Because it is clamped, chapters that are off-screen
/// stop notifying and therefore stop rebuilding.
@riverpod
double sectionProgress(Ref ref, int index) {
  final layout = ref.watch(sectionLayoutsProvider)[index];
  return layout.progressAt(ref.watch(scrollOffsetProvider));
}

/// Which chapter currently owns the middle of the screen (drives navigation).
@Riverpod(keepAlive: true)
int activeSection(Ref ref) {
  final layouts = ref.watch(sectionLayoutsProvider);
  final mid = ref.watch(scrollOffsetProvider) + layouts.first.viewport * 0.5;
  var idx = 0;
  for (var i = 0; i < layouts.length; i++) {
    if (layouts[i].top <= mid) idx = i;
  }
  return idx;
}

/// 0..1 progress of the whole journey.
@Riverpod(keepAlive: true)
double scrollProgress(Ref ref) {
  final layouts = ref.watch(sectionLayoutsProvider);
  final total = layouts.last.top + layouts.last.height - layouts.first.viewport;
  if (total <= 0) return 0;
  return (ref.watch(scrollOffsetProvider) / total).clamp(0.0, 1.0);
}
