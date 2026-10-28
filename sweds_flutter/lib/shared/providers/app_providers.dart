import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/wedding_config.dart';
import '../../core/theme/app_theme.dart';
import '../services/audio_service.dart';
import '../services/rsvp_service.dart';
import 'scene_providers.dart';

part 'app_providers.g.dart';

@Riverpod(keepAlive: true)
class PointerPx extends _$PointerPx {
  @override
  Offset build() => Offset.zero;
  void set(Offset o) => state = o;
}

@Riverpod(keepAlive: true)
class HasMouse extends _$HasMouse {
  @override
  bool build() => false;
  void set(bool v) {
    if (state != v) state = v;
  }
}

/// Pointer in -1..1 screen space (zero on touch devices).
@Riverpod(keepAlive: true)
Offset pointerNorm(Ref ref) {
  if (!ref.watch(hasMouseProvider)) return Offset.zero;
  final p = ref.watch(pointerPxProvider);
  final vp = ref.watch(sceneViewportProvider);
  return Offset((p.dx / vp.width) * 2 - 1, (p.dy / vp.height) * 2 - 1);
}

@Riverpod(keepAlive: true)
class CursorHovering extends _$CursorHovering {
  @override
  bool build() => false;
  void set(bool v) {
    if (state != v) state = v;
  }
}

@Riverpod(keepAlive: true)
AmbientAudioService audioService(Ref ref) => SilentAudioService();

@Riverpod(keepAlive: true)
class AmbientMusic extends _$AmbientMusic {
  @override
  bool build() => false;

  Future<void> toggle() async {
    state = !state;
    await ref.read(audioServiceProvider).setPlaying(state);
  }
}

@Riverpod(keepAlive: true)
ThemeData appTheme(Ref ref) => buildLuxTheme();

@Riverpod(keepAlive: true)
RsvpService rsvpService(Ref ref) => MockRsvpService();

@riverpod
Stream<Duration> countdown(Ref ref) async* {
  while (true) {
    yield WeddingConfig.remaining();
    await Future<void>.delayed(const Duration(seconds: 1));
  }
}
