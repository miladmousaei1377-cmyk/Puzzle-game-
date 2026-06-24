import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../data/models/puzzle_model.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/puzzle_repository.dart';
import 'widgets/draggable_object_widget.dart';
import 'widgets/symbol_keypad_widget.dart';
import 'widgets/hint_button_widget.dart';

class PuzzleScreen extends ConsumerWidget {
  final String puzzleId;

  const PuzzleScreen({super.key, required this.puzzleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzleAsync = ref.watch(puzzleProvider(puzzleId));

    return puzzleAsync.when(
      data: (puzzle) => _PuzzleView(puzzle: puzzle),
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('خطا: $e')),
      ),
    );
  }
}

class _PuzzleView extends ConsumerStatefulWidget {
  final PuzzleModel puzzle;

  const _PuzzleView({required this.puzzle});

  @override
  ConsumerState<_PuzzleView> createState() => _PuzzleViewState();
}

class _PuzzleViewState extends ConsumerState<_PuzzleView> {
  late Map<String, Offset> _positions;
  late Map<String, double> _rotations;
  List<PuzzleSymbol> _input = [];
  bool _wrongAnswer = false;
  bool _codeRevealed = false;

  @override
  void initState() {
    super.initState();
    _positions = {
      for (final obj in widget.puzzle.objects)
        obj.id: obj.initialPosition,
    };
    _rotations = {
      for (final obj in widget.puzzle.objects) obj.id: 0.0,
    };
    _loadSavedState();
  }

  void _loadSavedState() {
    final repo = ref.read(progressRepositoryProvider);
    final saved = repo.getProgress(widget.puzzle.id);
    if (saved != null) {
      if (saved.objectPositionsX != null && saved.objectPositionsY != null) {
        for (final obj in widget.puzzle.objects) {
          final x = saved.objectPositionsX![obj.id];
          final y = saved.objectPositionsY![obj.id];
          if (x != null && y != null) {
            _positions[obj.id] = Offset(x, y);
          }
        }
      }
      if (saved.objectRotations != null) {
        for (final obj in widget.puzzle.objects) {
          final r = saved.objectRotations![obj.id];
          if (r != null) _rotations[obj.id] = r;
        }
      }
    }
  }

  void _saveState() {
    final repo = ref.read(progressRepositoryProvider);
    repo.saveObjectState(
      widget.puzzle.id,
      {for (final e in _positions.entries) e.key: e.value.dx},
      {for (final e in _positions.entries) e.key: e.value.dy},
      Map.from(_rotations),
    );
  }

  bool _checkRevealCondition() {
    final condition = widget.puzzle.revealCondition;
    if (condition == null) return false;

    if (condition.type == 'all_snapped') {
      for (final obj in widget.puzzle.objects) {
        bool snapped = false;
        for (final zone in obj.snapZones) {
          if ((_positions[obj.id]! - zone.targetPosition).distance <= 2.0) {
            snapped = true;
            break;
          }
        }
        if (obj.snapZones.isNotEmpty && !snapped) return false;
      }
      return true;
    }

    if (condition.type == 'rotation_match') {
      for (final req in condition.requires) {
        final id = req['object_id'] as String;
        final target = (req['target_angle'] as num).toDouble();
        final current = (_rotations[id] ?? 0.0) % 360;
        if ((current - target).abs() > 5) return false;
      }
      return true;
    }

    return false;
  }

  void _onObjectPositionChanged(String id, Offset pos) {
    setState(() {
      _positions[id] = pos;
      _codeRevealed = _checkRevealCondition();
    });
    _saveState();
  }

  void _onObjectRotationChanged(String id, double rot) {
    setState(() {
      _rotations[id] = rot % 360;
      _codeRevealed = _checkRevealCondition();
    });
    _saveState();
  }

  void _onKeypadChanged(List<PuzzleSymbol> input) {
    setState(() {
      _input = input;
      _wrongAnswer = false;
    });
  }

  void _onSubmit() {
    final solution = widget.puzzle.solutionSymbols;
    if (_input.length != solution.length) return;

    final correct = List.generate(
      solution.length,
      (i) => _input[i] == solution[i],
    ).every((e) => e);

    if (correct) {
      _onSolved();
    } else {
      setState(() {
        _wrongAnswer = true;
      });
    }
  }

  void _onSolved() async {
    final repo = ref.read(progressRepositoryProvider);
    await repo.markSolved(widget.puzzle.id);
    ref.read(solvedPuzzlesProvider.notifier).refresh();
    if (mounted) context.pushReplacement('/completion/${widget.puzzle.id}');
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final repo = ref.read(progressRepositoryProvider);
    final progress = repo.getProgress(widget.puzzle.id);
    final hintsUsed = progress?.hintsUsed ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(widget.puzzle.titleFa,
            style: const TextStyle(
                fontFamily: AppFonts.body, color: AppColors.ink, fontSize: 16)),
        iconTheme: const IconThemeData(color: AppColors.ink),
        actions: [
          HintButtonWidget(
            hintsRemaining: hintsUsed,
            hintText: widget.puzzle.hintTextFa,
            onUseHint: () {
              repo.incrementHint(widget.puzzle.id);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Scene area
          Expanded(
            flex: 3,
            child: _SceneArea(
              puzzle: widget.puzzle,
              positions: _positions,
              rotations: _rotations,
              codeRevealed: _codeRevealed,
              reducedMotion: settings.settings.reducedMotion,
              onPositionChanged: _onObjectPositionChanged,
              onRotationChanged: _onObjectRotationChanged,
            ),
          ),

          // Code reveal indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _codeRevealed
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'کد آشکار شد — نمادها را وارد کن',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 13,
                          fontFamily: AppFonts.body,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'اشیاء را جابه‌جا کن',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      fontFamily: AppFonts.body,
                    ),
                  ),
          ),

          // Keypad
          Container(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.muted, width: 0.5),
              ),
            ),
            child: SymbolKeypadWidget(
              requiredLength: widget.puzzle.solutionSymbols.length,
              enabled: _codeRevealed,
              wrongAnswer: _wrongAnswer,
              onChanged: _onKeypadChanged,
              onSubmit: _onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneArea extends StatelessWidget {
  final PuzzleModel puzzle;
  final Map<String, Offset> positions;
  final Map<String, double> rotations;
  final bool codeRevealed;
  final bool reducedMotion;
  final void Function(String, Offset) onPositionChanged;
  final void Function(String, double) onRotationChanged;

  const _SceneArea({
    required this.puzzle,
    required this.positions,
    required this.rotations,
    required this.codeRevealed,
    required this.reducedMotion,
    required this.onPositionChanged,
    required this.onRotationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sortedObjects = [...puzzle.objects]
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.muted, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Background tint when code is revealed
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: double.infinity,
              height: double.infinity,
              color: codeRevealed
                  ? AppColors.accent.withValues(alpha: 0.04)
                  : Colors.transparent,
            ),

            // Objects
            ...sortedObjects.map((obj) {
              final pos = positions[obj.id] ?? obj.initialPosition;
              final rot = rotations[obj.id] ?? 0.0;
              final snapped = _isSnapped(obj, pos);

              return Positioned(
                left: pos.dx,
                top: pos.dy,
                child: DraggableObjectWidget(
                  key: ValueKey(obj.id),
                  object: obj,
                  position: pos,
                  rotation: rot,
                  isSnapped: snapped,
                  reducedMotion: reducedMotion,
                  onPositionChanged: (p) => onPositionChanged(obj.id, p),
                  onRotationChanged: (r) => onRotationChanged(obj.id, r),
                ),
              );
            }),

            // Symbol hints when code revealed
            if (codeRevealed)
              Positioned(
                bottom: 12,
                right: 0,
                left: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: puzzle.solutionSymbols.map((s) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedOpacity(
                      opacity: codeRevealed ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        s.label,
                        style: const TextStyle(
                          fontSize: 22,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isSnapped(PuzzleObject obj, Offset pos) {
    for (final zone in obj.snapZones) {
      if ((pos - zone.targetPosition).distance <= 2.0) return true;
    }
    return false;
  }
}
