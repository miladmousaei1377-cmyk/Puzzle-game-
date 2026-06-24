// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PuzzleProgressAdapter extends TypeAdapter<PuzzleProgress> {
  @override
  final int typeId = 0;

  @override
  PuzzleProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PuzzleProgress(
      puzzleId: fields[0] as String,
      solved: fields[1] as bool,
      hintsUsed: fields[2] as int,
      objectPositionsX: (fields[3] as Map?)?.cast<String, double>(),
      objectPositionsY: (fields[4] as Map?)?.cast<String, double>(),
      objectRotations: (fields[5] as Map?)?.cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, PuzzleProgress obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.puzzleId)
      ..writeByte(1)
      ..write(obj.solved)
      ..writeByte(2)
      ..write(obj.hintsUsed)
      ..writeByte(3)
      ..write(obj.objectPositionsX)
      ..writeByte(4)
      ..write(obj.objectPositionsY)
      ..writeByte(5)
      ..write(obj.objectRotations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PuzzleProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 1;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      languageCode: fields[0] as String,
      musicVolume: fields[1] as double,
      sfxVolume: fields[2] as double,
      reducedMotion: fields[3] as bool,
      colorblindMode: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.languageCode)
      ..writeByte(1)
      ..write(obj.musicVolume)
      ..writeByte(2)
      ..write(obj.sfxVolume)
      ..writeByte(3)
      ..write(obj.reducedMotion)
      ..writeByte(4)
      ..write(obj.colorblindMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
