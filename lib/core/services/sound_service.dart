import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/progress_repository.dart';

final soundServiceProvider = Provider((ref) {
  final service = SoundService();
  final settings = ref.read(progressRepositoryProvider).getSettings();
  service.setMusicVolume(settings.musicVolume);
  service.setSfxVolume(settings.sfxVolume);
  ref.listen(settingsProvider, (_, next) {
    service.setMusicVolume(next.settings.musicVolume);
    service.setSfxVolume(next.settings.sfxVolume);
  });
  ref.onDispose(service.dispose);
  return service;
});

enum SfxType { pickup, drop, snap, keypadPress, correctCode, wrongCode }

class SoundService {
  final AudioPlayer _ambient = AudioPlayer();
  final AudioPlayer _sfx = AudioPlayer();

  double _musicVolume = 0.5;
  double _sfxVolume = 0.8;
  bool _ambientStarted = false;

  void setMusicVolume(double v) {
    _musicVolume = v;
    _ambient.setVolume(v);
  }

  void setSfxVolume(double v) {
    _sfxVolume = v;
  }

  Future<void> startAmbient() async {
    if (_ambientStarted) return;
    _ambientStarted = true;
    try {
      await _ambient.setVolume(_musicVolume);
      await _ambient.setReleaseMode(ReleaseMode.loop);
      await _ambient.play(AssetSource('sounds/ambient/garden_ambient.mp3'));
    } catch (_) {
      // Audio not critical — continue silently if asset missing/invalid
    }
  }

  Future<void> stopAmbient() async {
    await _ambient.stop();
    _ambientStarted = false;
  }

  Future<void> playSfx(SfxType type) async {
    if (_sfxVolume == 0) return;
    final path = _sfxPath(type);
    try {
      await _sfx.setVolume(_sfxVolume);
      await _sfx.play(AssetSource(path));
    } catch (_) {}
  }

  String _sfxPath(SfxType type) {
    switch (type) {
      case SfxType.pickup:
        return 'sounds/sfx/pickup.mp3';
      case SfxType.drop:
        return 'sounds/sfx/drop.mp3';
      case SfxType.snap:
        return 'sounds/sfx/snap.mp3';
      case SfxType.keypadPress:
        return 'sounds/sfx/keypad_press.mp3';
      case SfxType.correctCode:
        return 'sounds/sfx/correct_code.mp3';
      case SfxType.wrongCode:
        return 'sounds/sfx/wrong_code.mp3';
    }
  }

  Future<void> dispose() async {
    await _ambient.dispose();
    await _sfx.dispose();
  }
}
