import 'dart:convert';
import 'package:flutter/material.dart';

enum PuzzleSymbol { circle, triangle, moon, diamond, star, square }

extension PuzzleSymbolExt on PuzzleSymbol {
  String get label {
    switch (this) {
      case PuzzleSymbol.circle:
        return '○';
      case PuzzleSymbol.triangle:
        return '△';
      case PuzzleSymbol.moon:
        return '☽';
      case PuzzleSymbol.diamond:
        return '◇';
      case PuzzleSymbol.star:
        return '★';
      case PuzzleSymbol.square:
        return '□';
    }
  }

  String get id => name;

  String get assetPath => 'assets/images/symbols/$name.png';
}

PuzzleSymbol symbolFromString(String s) {
  return PuzzleSymbol.values.firstWhere(
    (e) => e.name == s,
    orElse: () => PuzzleSymbol.circle,
  );
}

class SnapZone {
  final Offset targetPosition;
  final double snapRadius;

  const SnapZone({required this.targetPosition, required this.snapRadius});

  factory SnapZone.fromJson(Map<String, dynamic> json) {
    final pos = json['target_position'] as Map<String, dynamic>;
    return SnapZone(
      targetPosition: Offset(
        (pos['x'] as num).toDouble(),
        (pos['y'] as num).toDouble(),
      ),
      snapRadius: (json['snap_radius'] as num).toDouble(),
    );
  }
}

class PuzzleObject {
  final String id;
  final String asset;
  final Offset initialPosition;
  final bool movable;
  final bool rotatable;
  final int zIndex;
  final List<SnapZone> snapZones;

  const PuzzleObject({
    required this.id,
    required this.asset,
    required this.initialPosition,
    required this.movable,
    required this.rotatable,
    required this.zIndex,
    this.snapZones = const [],
  });

  factory PuzzleObject.fromJson(Map<String, dynamic> json) {
    final pos = json['initial_position'] as Map<String, dynamic>;
    final zones = (json['snap_zones'] as List<dynamic>? ?? [])
        .map((z) => SnapZone.fromJson(z as Map<String, dynamic>))
        .toList();
    return PuzzleObject(
      id: json['id'] as String,
      asset: json['asset'] as String,
      initialPosition: Offset(
        (pos['x'] as num).toDouble(),
        (pos['y'] as num).toDouble(),
      ),
      movable: json['movable'] as bool? ?? false,
      rotatable: json['rotatable'] as bool? ?? false,
      zIndex: json['z_index'] as int? ?? 0,
      snapZones: zones,
    );
  }
}

class RevealCondition {
  final String type;
  final List<Map<String, dynamic>> requires;

  const RevealCondition({required this.type, required this.requires});

  factory RevealCondition.fromJson(Map<String, dynamic> json) {
    return RevealCondition(
      type: json['type'] as String,
      requires: (json['requires'] as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }
}

class PuzzleModel {
  final String id;
  final String titleFa;
  final String introTextFa;
  final String sceneBackground;
  final List<PuzzleSymbol> solutionSymbols;
  final String? solutionCode; // null = symbol puzzle, non-null = numeric puzzle
  final String hintTextFa;
  final List<PuzzleObject> objects;
  final RevealCondition? revealCondition;

  bool get isNumericCode => solutionCode != null && solutionCode!.isNotEmpty;

  const PuzzleModel({
    required this.id,
    required this.titleFa,
    required this.introTextFa,
    required this.sceneBackground,
    required this.solutionSymbols,
    this.solutionCode,
    required this.hintTextFa,
    required this.objects,
    this.revealCondition,
  });

  factory PuzzleModel.fromJson(Map<String, dynamic> json) {
    final solutionCode = json['solution_code'] as String?;
    final symbols = solutionCode != null
        ? <PuzzleSymbol>[]
        : (json['solution_symbols'] as List<dynamic>? ?? [])
            .map((s) => symbolFromString(s as String))
            .toList();
    final objs = (json['objects'] as List<dynamic>)
        .map((o) => PuzzleObject.fromJson(o as Map<String, dynamic>))
        .toList();
    RevealCondition? rc;
    if (json['reveal_condition'] != null) {
      rc = RevealCondition.fromJson(
          json['reveal_condition'] as Map<String, dynamic>);
    }
    return PuzzleModel(
      id: json['id'] as String,
      titleFa: json['title_fa'] as String? ?? '',
      introTextFa: json['intro_text_fa'] as String? ?? '',
      sceneBackground: json['scene_background'] as String? ?? '',
      solutionSymbols: symbols,
      solutionCode: solutionCode,
      hintTextFa: json['hint_text_fa'] as String? ?? '',
      objects: objs,
      revealCondition: rc,
    );
  }

  factory PuzzleModel.fromJsonString(String jsonString) {
    return PuzzleModel.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>);
  }
}
