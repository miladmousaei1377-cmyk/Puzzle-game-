import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';

import '../../../app/theme.dart';

class HintButtonWidget extends StatelessWidget {
  final int hintsRemaining;
  final String hintText;
  final VoidCallback onUseHint;

  const HintButtonWidget({
    super.key,
    required this.hintsRemaining,
    required this.hintText,
    required this.onUseHint,
  });

  static const _maxHints = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canUse = hintsRemaining < _maxHints;

    return OutlinedButton.icon(
      onPressed: canUse ? () => _showHint(context, l10n) : null,
      icon: const Icon(Icons.lightbulb_outline, size: 18),
      label: Text(
        canUse
            ? l10n.hintRemaining(_maxHints - hintsRemaining)
            : l10n.hintButton,
        style: const TextStyle(fontSize: 13),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: canUse ? AppColors.accent : AppColors.muted,
        side: BorderSide(
          color: canUse ? AppColors.accent : AppColors.muted,
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  void _showHint(BuildContext context, AppLocalizations l10n) {
    onUseHint();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: AppColors.accent),
            const SizedBox(width: 8),
            Text(l10n.hintTitle,
                style: const TextStyle(fontFamily: AppFonts.body)),
          ],
        ),
        content: Text(hintText,
            style: const TextStyle(color: AppColors.ink, height: 1.6)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}
