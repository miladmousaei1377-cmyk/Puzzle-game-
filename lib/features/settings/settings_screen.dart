import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/generated/app_localizations.dart';

import '../../app/theme.dart';
import '../../data/repositories/progress_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final s = settings.settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(l10n.menuSettings,
            style: const TextStyle(
                fontFamily: AppFonts.body, color: AppColors.ink)),
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SectionTitle(l10n.settingsLanguage),
          _LanguageSelector(
            current: s.languageCode,
            onChanged: notifier.setLanguage,
          ),
          const _Divider(),
          _SectionTitle(l10n.settingsMusic),
          Slider(
            value: s.musicVolume,
            onChanged: notifier.setMusicVolume,
            activeColor: AppColors.accent,
            inactiveColor: AppColors.muted,
          ),
          const SizedBox(height: 8),
          _SectionTitle(l10n.settingsSfx),
          Slider(
            value: s.sfxVolume,
            onChanged: notifier.setSfxVolume,
            activeColor: AppColors.accent,
            inactiveColor: AppColors.muted,
          ),
          const _Divider(),
          SwitchListTile(
            title: Text(l10n.settingsReducedMotion,
                style: const TextStyle(fontFamily: AppFonts.body)),
            value: s.reducedMotion,
            onChanged: notifier.toggleReducedMotion,
            activeColor: AppColors.accent,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: Text(l10n.settingsColorblind,
                style: const TextStyle(fontFamily: AppFonts.body)),
            value: s.colorblindMode,
            onChanged: notifier.toggleColorblind,
            activeColor: AppColors.accent,
            contentPadding: EdgeInsets.zero,
          ),
          const _Divider(),
          OutlinedButton(
            onPressed: () => _confirmReset(context, ref, l10n),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
            child: Text(l10n.settingsResetProgress),
          ),
        ],
      ),
    );
  }

  void _confirmReset(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(l10n.resetConfirmTitle,
            style: const TextStyle(fontFamily: AppFonts.body)),
        content: Text(l10n.resetConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(progressRepositoryProvider).resetAll();
              ref.read(solvedPuzzlesProvider.notifier).refresh();
            },
            child: Text(l10n.confirm,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const _LanguageSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LangChip(label: 'فارسی', code: 'fa', current: current, onTap: onChanged),
        const SizedBox(width: 12),
        _LangChip(label: 'English', code: 'en', current: current, onTap: onChanged),
      ],
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final String code;
  final String current;
  final ValueChanged<String> onTap;

  const _LangChip({
    required this.label,
    required this.code,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = code == current;
    return GestureDetector(
      onTap: () => onTap(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          border: Border.all(
              color: selected ? AppColors.accent : AppColors.muted),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.body,
            color: selected ? AppColors.background : AppColors.ink,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 13,
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
            )),
      );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Divider(color: AppColors.muted, thickness: 0.5),
      );
}
