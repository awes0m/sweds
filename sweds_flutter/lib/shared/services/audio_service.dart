import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

abstract interface class AmbientAudioService {
  Future<void> setPlaying(bool on);
}

/// Real implementation using `audioplayers`.
/// Plays ambient background music in a loop with volume leveling.
class AppAudioService implements AmbientAudioService {
  AppAudioService({
    this.assetPath = 'audio/audio.mp3',
    this.volume = 0.35,
  });

  final String assetPath;
  final double volume;

  final AudioPlayer _player = AudioPlayer();
  bool _configured = false;

  Future<void> _configure() async {
    if (_configured) return;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(volume);
      _configured = true;
    } catch (e) {
      debugPrint('AppAudioService configure error: $e');
    }
  }

  @override
  Future<void> setPlaying(bool on) async {
    try {
      await _configure();
      if (on) {
        if (_player.state == PlayerState.paused) {
          await _player.resume();
        } else {
          await _player.play(AssetSource(assetPath), volume: volume);
        }
      } else {
        await _player.pause();
      }
    } catch (e) {
      debugPrint('AppAudioService setPlaying($on) error: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}

/// Alias for AppAudioService for semantic compatibility.
typedef RealAmbientAudioService = AppAudioService;

/// Fallback silent audio implementation.
class SilentAudioService implements AmbientAudioService {
  @override
  Future<void> setPlaying(bool on) async => debugPrint('ambient audio: $on');
}
