import 'package:flutter/foundation.dart';

abstract interface class AmbientAudioService {
  Future<void> setPlaying(bool on);
}

/// Placeholder. To ship real audio add `audioplayers`, put a loop in
/// assets/audio/ambient.mp3 and implement:
///   final _p = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
///   on  → _p.play(AssetSource('audio/ambient.mp3'), volume: .35)
///   off → _p.pause()
/// (Browsers only allow audio after a user gesture — the toggle is one.)
class SilentAudioService implements AmbientAudioService {
  @override
  Future<void> setPlaying(bool on) async => debugPrint('ambient audio: $on');
}
