import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../data/models/puzzle_model.dart';

class SymbolKeypadWidget extends StatefulWidget {
  final int requiredLength;
  final bool enabled;
  final bool wrongAnswer;
  final ValueChanged<List<PuzzleSymbol>> onChanged;
  final VoidCallback onSubmit;

  const SymbolKeypadWidget({
    super.key,
    required this.requiredLength,
    required this.onChanged,
    required this.onSubmit,
    this.enabled = true,
    this.wrongAnswer = false,
  });

  @override
  State<SymbolKeypadWidget> createState() => _SymbolKeypadWidgetState();
}

class _SymbolKeypadWidgetState extends State<SymbolKeypadWidget>
    with SingleTickerProviderStateMixin {
  final List<PuzzleSymbol> _input = [];
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  static const _symbols = PuzzleSymbol.values;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void didUpdateWidget(SymbolKeypadWidget old) {
    super.didUpdateWidget(old);
    if (widget.wrongAnswer && !old.wrongAnswer) {
      _shakeCtrl.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _input.clear());
        widget.onChanged([]);
      });
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _addSymbol(PuzzleSymbol s) {
    if (!widget.enabled) return;
    if (_input.length >= widget.requiredLength) return;
    setState(() => _input.add(s));
    widget.onChanged(List.unmodifiable(_input));
    if (_input.length == widget.requiredLength) {
      widget.onSubmit();
    }
  }

  void _clear() {
    setState(() => _input.clear());
    widget.onChanged([]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Input display
        AnimatedBuilder(
          animation: _shakeAnim,
          builder: (_, child) => Transform.translate(
            offset: Offset(
              _shakeAnim.value *
                  ((_shakeCtrl.value * 6).floor() % 2 == 0 ? 1 : -1),
              0,
            ),
            child: child,
          ),
          child: _InputRow(
            input: _input,
            requiredLength: widget.requiredLength,
            wrongAnswer: widget.wrongAnswer,
          ),
        ),
        const SizedBox(height: 16),
        // Symbol grid (3x2)
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: _symbols.map((s) => _SymbolButton(
            symbol: s,
            enabled: widget.enabled &&
                _input.length < widget.requiredLength,
            onTap: () => _addSymbol(s),
          )).toList(),
        ),
        const SizedBox(height: 12),
        // Clear button
        TextButton.icon(
          onPressed: _clear,
          icon: const Icon(Icons.backspace_outlined,
              size: 16, color: AppColors.muted),
          label: const Text('پاک کردن',
              style: TextStyle(color: AppColors.muted, fontSize: 13)),
        ),
      ],
    );
  }
}

class _InputRow extends StatelessWidget {
  final List<PuzzleSymbol> input;
  final int requiredLength;
  final bool wrongAnswer;

  const _InputRow({
    required this.input,
    required this.requiredLength,
    required this.wrongAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(requiredLength, (i) {
        final filled = i < input.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: filled
                ? (wrongAnswer
                    ? AppColors.error.withValues(alpha: 0.15)
                    : AppColors.accent.withValues(alpha: 0.12))
                : AppColors.background,
            border: Border.all(
              color: wrongAnswer
                  ? AppColors.error
                  : (filled ? AppColors.accent : AppColors.muted),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: filled
                ? Image.asset(
                    input[i].assetPath,
                    width: 26,
                    height: 26,
                    color: wrongAnswer ? AppColors.error : AppColors.ink,
                    errorBuilder: (_, __, ___) => Text(
                      input[i].label,
                      style: TextStyle(
                        fontSize: 24,
                        color: wrongAnswer ? AppColors.error : AppColors.ink,
                      ),
                    ),
                  )
                : null,
          ),
        );
      }),
    );
  }
}

class _SymbolButton extends StatelessWidget {
  final PuzzleSymbol symbol;
  final bool enabled;
  final VoidCallback onTap;

  const _SymbolButton({
    required this.symbol,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: enabled ? AppColors.surface : AppColors.muted.withValues(alpha: 0.2),
          border: Border.all(
            color: enabled ? AppColors.muted : AppColors.muted.withValues(alpha: 0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Image.asset(
            symbol.assetPath,
            width: 32,
            height: 32,
            color: enabled ? AppColors.ink : AppColors.muted,
            errorBuilder: (_, __, ___) => Text(
              symbol.label,
              style: TextStyle(
                fontSize: 28,
                color: enabled ? AppColors.ink : AppColors.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
