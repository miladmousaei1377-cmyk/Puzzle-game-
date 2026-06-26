import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/generated/app_localizations.dart';

import '../../app/theme.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/puzzle_repository.dart';
import 'widgets/growing_tree_widget.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final solved = ref.watch(solvedPuzzlesProvider);
    final puzzleList = ref.watch(puzzleListProvider);
    final settings = ref.watch(settingsProvider);
    final totalCount = puzzleList.value?.length ?? 2;
    final screenHeight = MediaQuery.of(context).size.height;

    // Find last in-progress puzzle for "continue"
    final lastPuzzle = _findLastPuzzle(solved, totalCount);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background tree — occupies top 50% only so it doesn't overlap buttons
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: screenHeight * 0.5,
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: GrowingTreeWidget(
                solvedCount: solved.length,
                totalCount: totalCount,
                reducedMotion: settings.settings.reducedMotion,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  Text(
                    l10n.appTitle,
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 3),
                  if (lastPuzzle != null)
                    _MenuButton(
                      label: l10n.menuContinue,
                      onTap: () => context.push('/puzzle/$lastPuzzle'),
                      primary: true,
                    ),
                  if (lastPuzzle != null) const SizedBox(height: 12),
                  _MenuButton(
                    label: l10n.menuLevels,
                    onTap: () => context.push('/levels'),
                  ),
                  const SizedBox(height: 12),
                  _MenuButton(
                    label: l10n.menuHelp,
                    onTap: () => context.push('/instructions'),
                  ),
                  const SizedBox(height: 12),
                  _MenuButton(
                    label: l10n.menuSettings,
                    onTap: () => context.push('/settings'),
                  ),
                  const SizedBox(height: 12),
                  _MenuButton(
                    label: l10n.menuAbout,
                    onTap: () => _showAbout(context, l10n),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _findLastPuzzle(Set<String> solved, int total) {
    for (var i = 1; i <= total; i++) {
      final id = 'puzzle_${i.toString().padLeft(3, '0')}';
      if (!solved.contains(id)) return id;
    }
    return null;
  }

  void _showAbout(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(l10n.menuAbout,
            style: const TextStyle(fontFamily: AppFonts.display)),
        content: Text(l10n.aboutText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.confirm),
          )
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool primary;

  const _MenuButton({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    if (primary) {
      return ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.background,
        ),
        child: Text(label),
      );
    }
    return OutlinedButton(
      onPressed: onTap,
      child: Text(label),
    );
  }
}
