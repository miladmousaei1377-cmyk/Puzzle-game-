import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/generated/app_localizations.dart';

import '../../app/theme.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/puzzle_repository.dart';

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final solved = ref.watch(solvedPuzzlesProvider);
    final puzzleList = ref.watch(puzzleListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(l10n.menuLevels,
            style: const TextStyle(
                fontFamily: AppFonts.body, color: AppColors.ink)),
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      body: puzzleList.when(
        data: (ids) => _buildGrid(context, ids, solved, l10n, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<String> ids,
    Set<String> solved,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    final solvedCount = solved.length;
    final totalCount = ids.length;
    final progress = totalCount > 0 ? solvedCount / totalCount : 0.0;

    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$solvedCount از $totalCount مرحله',
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
                          fontFamily: AppFonts.body)),
                  Text('${(progress * 100).round()}٪',
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.accent,
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.muted.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        // Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: ids.length,
            itemBuilder: (_, index) {
              final id = ids[index];
              final isSolved = solved.contains(id);
              final isLocked = index > 0 && !solved.contains(ids[index - 1]);

              return _LevelCard(
                id: id,
                index: index + 1,
                isSolved: isSolved,
                isLocked: isLocked,
                onTap: isLocked ? null : () => context.push('/puzzle/$id'),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String id;
  final int index;
  final bool isSolved;
  final bool isLocked;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.id,
    required this.index,
    required this.isSolved,
    required this.isLocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.surface;
    Color border = AppColors.muted;
    Widget icon;

    if (isLocked) {
      bg = AppColors.muted.withValues(alpha: 0.3);
      icon = const Icon(Icons.lock_outline, color: AppColors.muted, size: 28);
    } else if (isSolved) {
      bg = AppColors.accent.withValues(alpha: 0.12);
      border = AppColors.accent;
      icon = const Icon(Icons.check, color: AppColors.accent, size: 28);
    } else {
      icon = Text(
        index.toString(),
        style: const TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: AppColors.ink,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: icon),
      ),
    );
  }
}
