import 'package:hive_flutter/hive_flutter.dart';

part 'progress_model.g.dart';

@HiveType(typeId: 0)
class PuzzleProgress extends HiveObject {
  @HiveField(0)
  String puzzleId;

  @HiveField(1)
  bool solved;

  @HiveField(2)
  int hintsUsed;

  @HiveField(3)
  Map<String, double>? objectPositionsX;

  @HiveField(4)
  Map<String, double>? objectPositionsY;

  @HiveField(5)
  Map<String, double>? objectRotations;

  PuzzleProgress({
    required this.puzzleId,
    this.solved = false,
    this.hintsUsed = 0,
    this.objectPositionsX,
    this.objectPositionsY,
    this.objectRotations,
  });
}

@HiveType(typeId: 1)
class AppSettings extends HiveObject {
  @HiveField(0)
  String languageCode;

  @HiveField(1)
  double musicVolume;

  @HiveField(2)
  double sfxVolume;

  @HiveField(3)
  bool reducedMotion;

  @HiveField(4)
  bool colorblindMode;

  AppSettings({
    this.languageCode = 'fa',
    this.musicVolume = 0.5,
    this.sfxVolume = 0.8,
    this.reducedMotion = false,
    this.colorblindMode = false,
  });
}
