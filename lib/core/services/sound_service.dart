import 'dart:math' as math;
import 'dart:typed_data';
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
  double _musicVolume = 0.4;
  double _sfxVolume = 0.7;
  bool _ambientStarted = false;

  // Generate a PCM WAV in memory
  static Uint8List _makeWav(
      List<({double freq, double ms, double vol})> segments) {
    const sr = 22050;
    int totalSamples = 0;
    for (final s in segments) {
      totalSamples += (sr * s.ms / 1000).ceil();
    }

    final data = ByteData(44 + totalSamples * 2);
    // RIFF header
    final riff = 'RIFF'.codeUnits;
    for (int i = 0; i < 4; i++) {
      data.setUint8(i, riff[i]);
    }
    data.setUint32(4, 36 + totalSamples * 2, Endian.little);
    final wave = 'WAVE'.codeUnits;
    for (int i = 0; i < 4; i++) {
      data.setUint8(8 + i, wave[i]);
    }
    final fmt = 'fmt '.codeUnits;
    for (int i = 0; i < 4; i++) {
      data.setUint8(12 + i, fmt[i]);
    }
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little); // PCM
    data.setUint16(22, 1, Endian.little); // mono
    data.setUint32(24, sr, Endian.little);
    data.setUint32(28, sr * 2, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    final dataTag = 'data'.codeUnits;
    for (int i = 0; i < 4; i++) {
      data.setUint8(36 + i, dataTag[i]);
    }
    data.setUint32(40, totalSamples * 2, Endian.little);

    int offset = 44;
    for (final seg in segments) {
      final n = (sr * seg.ms / 1000).ceil();
      for (int i = 0; i < n; i++) {
        final t = i / sr;
        final fade = i < 200
            ? i / 200.0
            : (i > n - 200 ? (n - i) / 200.0 : 1.0);
        final sample = (seg.vol *
                32767 *
                fade *
                math.sin(2 * math.pi * seg.freq * t))
            .round()
            .clamp(-32768, 32767);
        data.setInt16(offset, sample, Endian.little);
        offset += 2;
      }
    }
    return data.buffer.asUint8List();
  }

  static Uint8List _sfxBytes(SfxType type) {
    switch (type) {
      case SfxType.snap:
        return _makeWav([
          (freq: 880, ms: 60, vol: 0.6),
          (freq: 1200, ms: 40, vol: 0.4),
        ]);
      case SfxType.keypadPress:
        return _makeWav([(freq: 660, ms: 40, vol: 0.5)]);
      case SfxType.correctCode:
        return _makeWav([
          (freq: 528, ms: 150, vol: 0.5),
          (freq: 660, ms: 150, vol: 0.5),
          (freq: 880, ms: 250, vol: 0.6),
        ]);
      case SfxType.wrongCode:
        return _makeWav([
          (freq: 300, ms: 150, vol: 0.5),
          (freq: 220, ms: 200, vol: 0.4),
        ]);
      case SfxType.pickup:
        return _makeWav([(freq: 440, ms: 50, vol: 0.4)]);
      case SfxType.drop:
        return _makeWav([(freq: 330, ms: 50, vol: 0.4)]);
    }
  }

  void setMusicVolume(double v) {
    _musicVolume = v;
    _ambient.setVolume(v);
  }

  void setSfxVolume(double v) => _sfxVolume = v;

  Future<void> startAmbient() async {
    if (_ambientStarted) return;
    _ambientStarted = true;
    try {
      await _ambient.setVolume(_musicVolume);
      await _ambient.setReleaseMode(ReleaseMode.loop);
      // Try real asset file first; fall back to synthesized drone
      try {
        await _ambient.play(AssetSource('sounds/ambient/garden_ambient.wav'));
      } catch (_) {
        final drone = _makeWav([
          (freq: 220, ms: 2000, vol: 0.15),
          (freq: 330, ms: 2000, vol: 0.10),
        ]);
        await _ambient.play(BytesSource(drone));
      }
    } catch (_) {}
  }

  Future<void> stopAmbient() async {
    await _ambient.stop();
    _ambientStarted = false;
  }

  static String _sfxFileName(SfxType type) {
    switch (type) {
      case SfxType.snap:        return 'snap.wav';
      case SfxType.keypadPress: return 'keypad_press.wav';
      case SfxType.correctCode: return 'correct_code.wav';
      case SfxType.wrongCode:   return 'wrong_code.wav';
      case SfxType.pickup:      return 'pickup.wav';
      case SfxType.drop:        return 'drop.wav';
    }
  }

  Future<void> playSfx(SfxType type) async {
    if (_sfxVolume == 0) return;
    try {
      await _sfx.setVolume(_sfxVolume);
      // Try real asset file first; fall back to synthesized tone
      try {
        await _sfx.play(AssetSource('sounds/sfx/${_sfxFileName(type)}'));
      } catch (_) {
        final bytes = _sfxBytes(type);
        await _sfx.play(BytesSource(bytes));
      }
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _ambient.dispose();
    await _sfx.dispose();
  }
}
