import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/generated/app_localizations.dart';

import '../../app/theme.dart';
import '../../data/repositories/puzzle_repository.dart';

class CompletionScreen extends ConsumerStatefulWidget {
  final String puzzleId;

  const CompletionScreen({super.key, required this.puzzleId});

  @override
  ConsumerState<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends ConsumerState<CompletionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 1.0),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String? _nextPuzzleId(List<String> all) {
    final idx = all.indexOf(widget.puzzleId);
    if (idx >= 0 && idx < all.length - 1) return all[idx + 1];
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final puzzleList = ref.watch(puzzleListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.accent,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _fade,
                  child: Column(
                    children: [
                      Text(
                        l10n.congratulations,
                        style: Theme.of(context).textTheme.displayLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.levelComplete,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.muted,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                FadeTransition(
                  opacity: _fade,
                  child: puzzleList.when(
                    data: (all) {
                      final next = _nextPuzzleId(all);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (next != null)
                            ElevatedButton(
                              onPressed: () =>
                                  context.pushReplacement('/puzzle/$next'),
                              child: Text(l10n.nextLevel),
                            ),
                          if (next != null) const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () => context.go('/levels'),
                            child: Text(l10n.backToMap),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context.go('/menu'),
                            child: Text(l10n.backToMenu,
                                style:
                                    const TextStyle(color: AppColors.muted)),
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
