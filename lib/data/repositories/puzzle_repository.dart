import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/puzzle_model.dart';

final puzzleRepositoryProvider = Provider((ref) => PuzzleRepository());

final puzzleListProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.read(puzzleRepositoryProvider);
  return repo.listPuzzleIds();
});

final puzzleProvider =
    FutureProvider.family<PuzzleModel, String>((ref, id) async {
  final repo = ref.read(puzzleRepositoryProvider);
  return repo.loadPuzzle(id);
});

class PuzzleRepository {
  static const _knownPuzzles = [
    'puzzle_001',
    'puzzle_002',
  ];

  Future<List<String>> listPuzzleIds() async {
    return _knownPuzzles;
  }

  Future<PuzzleModel> loadPuzzle(String id) async {
    final jsonStr =
        await rootBundle.loadString('assets/puzzles/$id.json');
    return PuzzleModel.fromJsonString(jsonStr);
  }
}
