import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/progress_model.dart';

const _progressBoxName = 'progress_box';
const _settingsBoxName = 'settings_box';

final progressRepositoryProvider =
    Provider((ref) => ProgressRepository());

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(ref.read(progressRepositoryProvider)),
);

final solvedPuzzlesProvider = StateNotifierProvider<SolvedPuzzlesNotifier, Set<String>>(
  (ref) => SolvedPuzzlesNotifier(ref.read(progressRepositoryProvider)),
);

class ProgressRepository {
  Box<PuzzleProgress> get _progressBox =>
      Hive.box<PuzzleProgress>(_progressBoxName);
  Box<AppSettings> get _settingsBox =>
      Hive.box<AppSettings>(_settingsBoxName);

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PuzzleProgressAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    await Hive.openBox<PuzzleProgress>(_progressBoxName);
    await Hive.openBox<AppSettings>(_settingsBoxName);
  }

  AppSettings getSettings() {
    return _settingsBox.get('settings') ?? AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put('settings', settings);
  }

  Set<String> getSolvedPuzzles() {
    return _progressBox.values
        .where((p) => p.solved)
        .map((p) => p.puzzleId)
        .toSet();
  }

  PuzzleProgress? getProgress(String puzzleId) {
    return _progressBox.get(puzzleId);
  }

  Future<void> markSolved(String puzzleId) async {
    final existing = _progressBox.get(puzzleId);
    if (existing != null) {
      existing.solved = true;
      await existing.save();
    } else {
      await _progressBox.put(
          puzzleId, PuzzleProgress(puzzleId: puzzleId, solved: true));
    }
  }

  Future<void> saveObjectState(
    String puzzleId,
    Map<String, double> posX,
    Map<String, double> posY,
    Map<String, double> rotations,
  ) async {
    final existing = _progressBox.get(puzzleId);
    if (existing != null) {
      existing.objectPositionsX = posX;
      existing.objectPositionsY = posY;
      existing.objectRotations = rotations;
      await existing.save();
    } else {
      await _progressBox.put(
        puzzleId,
        PuzzleProgress(
          puzzleId: puzzleId,
          objectPositionsX: posX,
          objectPositionsY: posY,
          objectRotations: rotations,
        ),
      );
    }
  }

  Future<void> incrementHint(String puzzleId) async {
    final existing = _progressBox.get(puzzleId);
    if (existing != null) {
      existing.hintsUsed++;
      await existing.save();
    } else {
      await _progressBox.put(
          puzzleId, PuzzleProgress(puzzleId: puzzleId, hintsUsed: 1));
    }
  }

  Future<void> resetAll() async {
    await _progressBox.clear();
  }

  void clearPuzzleState(String puzzleId) {
    final box = _progressBox;
    final existing = box.get(puzzleId);
    if (existing != null && !existing.solved) {
      box.delete(puzzleId);
    }
  }
}

class SettingsState {
  final AppSettings settings;

  const SettingsState(this.settings);

  Locale? get locale {
    return Locale(settings.languageCode);
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final ProgressRepository _repo;

  SettingsNotifier(this._repo)
      : super(SettingsState(_repo.getSettings()));

  Future<void> setLanguage(String code) async {
    state.settings.languageCode = code;
    await _repo.saveSettings(state.settings);
    state = SettingsState(state.settings);
  }

  Future<void> setMusicVolume(double v) async {
    state.settings.musicVolume = v;
    await _repo.saveSettings(state.settings);
    state = SettingsState(state.settings);
  }

  Future<void> setSfxVolume(double v) async {
    state.settings.sfxVolume = v;
    await _repo.saveSettings(state.settings);
    state = SettingsState(state.settings);
  }

  Future<void> toggleReducedMotion(bool v) async {
    state.settings.reducedMotion = v;
    await _repo.saveSettings(state.settings);
    state = SettingsState(state.settings);
  }

  Future<void> toggleColorblind(bool v) async {
    state.settings.colorblindMode = v;
    await _repo.saveSettings(state.settings);
    state = SettingsState(state.settings);
  }
}

class SolvedPuzzlesNotifier extends StateNotifier<Set<String>> {
  final ProgressRepository _repo;

  SolvedPuzzlesNotifier(this._repo) : super(_repo.getSolvedPuzzles());

  Future<void> markSolved(String puzzleId) async {
    await _repo.markSolved(puzzleId);
    state = {...state, puzzleId};
  }

  void refresh() {
    state = _repo.getSolvedPuzzles();
  }
}
