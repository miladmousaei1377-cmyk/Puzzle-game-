import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../core/services/sound_service.dart';
import '../../data/models/puzzle_model.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/puzzle_repository.dart';
import 'widgets/draggable_object_widget.dart';
import 'widgets/numeric_keypad_widget.dart';
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
  String _numericInput = '';
  bool _wrongAnswer = false;
  bool _codeRevealed = false;
  int _resetCount = 0;

  SoundService get _sound => ref.read(soundServiceProvider);

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sound.startAmbient();
    });
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
    final wasRevealed = _codeRevealed;
    setState(() {
      _positions[id] = pos;
      _codeRevealed = _checkRevealCondition();
    });
    if (_codeRevealed && !wasRevealed) {
      _sound.playSfx(SfxType.snap);
    }
  }

  void _onObjectSnapped() {
    _sound.playSfx(SfxType.snap);
  }

  void _onObjectRotationChanged(String id, double rot) {
    final wasRevealed = _codeRevealed;
    setState(() {
      _rotations[id] = rot % 360;
      _codeRevealed = _checkRevealCondition();
    });
    if (_codeRevealed && !wasRevealed) {
      _sound.playSfx(SfxType.snap);
    }
  }

  void _onKeypadChanged(List<PuzzleSymbol> input) {
    if (input.length > _input.length) {
      _sound.playSfx(SfxType.keypadPress);
    }
    setState(() {
      _input = input;
      _wrongAnswer = false;
    });
  }

  void _onSubmit() {
    if (widget.puzzle.isNumericCode) {
      if (_numericInput == widget.puzzle.solutionCode) {
        _sound.playSfx(SfxType.correctCode);
        _onSolved();
      } else {
        _sound.playSfx(SfxType.wrongCode);
        setState(() => _wrongAnswer = true);
      }
      return;
    }

    // Symbol logic
    final solution = widget.puzzle.solutionSymbols;
    if (_input.length != solution.length) return;

    final correct = List.generate(
      solution.length,
      (i) => _input[i] == solution[i],
    ).every((e) => e);

    if (correct) {
      _sound.playSfx(SfxType.correctCode);
      _onSolved();
    } else {
      _sound.playSfx(SfxType.wrongCode);
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

  void _resetPuzzle() {
    setState(() {
      _positions = {
        for (final obj in widget.puzzle.objects) obj.id: obj.initialPosition,
      };
      _rotations = {
        for (final obj in widget.puzzle.objects) obj.id: 0.0,
      };
      _input = [];
      _numericInput = '';
      _wrongAnswer = false;
      _codeRevealed = false;
      _resetCount++;
    });
    // Clear saved state for this puzzle
    final repo = ref.read(progressRepositoryProvider);
    repo.clearPuzzleState(widget.puzzle.id);
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
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'شروع از نو',
            onPressed: _resetPuzzle,
          ),
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
              onSnap: _onObjectSnapped,
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
                      Text(
                        widget.puzzle.isNumericCode
                            ? 'کد آشکار شد — اعداد را وارد کن'
                            : 'کد آشکار شد — نمادها را وارد کن',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 13,
                          fontFamily: AppFonts.body,
                        ),
                      ),
                    ],
                  )
                : Text(
                    widget.puzzle.revealCondition?.type == 'rotation_match'
                        ? 'روی هر شیء ضربه بزن تا بچرخد'
                        : 'اشیاء را به محل درست بکش',
                    style: const TextStyle(
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
            child: widget.puzzle.isNumericCode
                ? NumericKeypadWidget(
                    key: ValueKey(_resetCount),
                    requiredLength: widget.puzzle.solutionCode!.length,
                    enabled: _codeRevealed,
                    wrongAnswer: _wrongAnswer,
                    onChanged: (s) {
                      setState(() {
                        _numericInput = s;
                        _wrongAnswer = false;
                      });
                    },
                    onSubmit: _onSubmit,
                  )
                : SymbolKeypadWidget(
                    key: ValueKey(_resetCount),
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
  final VoidCallback? onSnap;

  const _SceneArea({
    required this.puzzle,
    required this.positions,
    required this.rotations,
    required this.codeRevealed,
    required this.reducedMotion,
    required this.onPositionChanged,
    required this.onRotationChanged,
    this.onSnap,
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
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              width: double.infinity,
              height: double.infinity,
              color: codeRevealed
                  ? AppColors.accent.withValues(alpha: 0.06)
                  : Colors.transparent,
            ),

            // Subtle reveal border glow
            if (codeRevealed)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.35),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
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
                  onSnap: onSnap,
                ),
              );
            }),

            // Symbol hints when code revealed (symbol puzzles only)
            if (codeRevealed && !puzzle.isNumericCode)
              Positioned(
                bottom: 12,
                right: 0,
                left: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: puzzle.solutionSymbols
                      .map((s) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
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
                          ))
                      .toList(),
                ),
              ),

            // Numeric code hint when code revealed (numeric puzzles only)
            if (codeRevealed && puzzle.isNumericCode)
              Positioned(
                bottom: 12,
                right: 0,
                left: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: codeRevealed ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      puzzle.solutionCode!,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                        fontFamily: AppFonts.body,
                        letterSpacing: 8,
                      ),
                    ),
                  ),
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
