import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class NumericKeypadWidget extends StatefulWidget {
  final int requiredLength;
  final bool enabled;
  final bool wrongAnswer;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  const NumericKeypadWidget({
    super.key,
    required this.requiredLength,
    required this.onChanged,
    required this.onSubmit,
    this.enabled = true,
    this.wrongAnswer = false,
  });

  @override
  State<NumericKeypadWidget> createState() => _NumericKeypadWidgetState();
}

class _NumericKeypadWidgetState extends State<NumericKeypadWidget>
    with SingleTickerProviderStateMixin {
  String _input = '';
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

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
  void didUpdateWidget(NumericKeypadWidget old) {
    super.didUpdateWidget(old);
    if (widget.wrongAnswer && !old.wrongAnswer) {
      _shakeCtrl.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _input = '');
        widget.onChanged('');
      });
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _addDigit(String d) {
    if (!widget.enabled) return;
    if (_input.length >= widget.requiredLength) return;
    setState(() => _input += d);
    widget.onChanged(_input);
    if (_input.length == widget.requiredLength) widget.onSubmit();
  }

  void _backspace() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
    widget.onChanged(_input);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Display
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.requiredLength, (i) {
              final filled = i < _input.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: filled
                      ? (widget.wrongAnswer
                          ? AppColors.error.withValues(alpha: 0.15)
                          : AppColors.accent.withValues(alpha: 0.12))
                      : AppColors.background,
                  border: Border.all(
                    color: widget.wrongAnswer
                        ? AppColors.error
                        : (filled ? AppColors.accent : AppColors.muted),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: filled
                      ? Text(
                          _input[i],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.body,
                            color: widget.wrongAnswer
                                ? AppColors.error
                                : AppColors.ink,
                          ),
                        )
                      : null,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        // Numpad 3x4
        ...[
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', '⌫'],
        ].map((row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((k) {
                  if (k == '') return const SizedBox(width: 72);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _NumKey(
                      label: k,
                      enabled: widget.enabled &&
                          (k == '⌫' || _input.length < widget.requiredLength),
                      onTap: () => k == '⌫' ? _backspace() : _addDigit(k),
                    ),
                  );
                }).toList(),
              ),
            )),
      ],
    );
  }
}

class _NumKey extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _NumKey({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 60,
        height: 48,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.surface
              : AppColors.muted.withValues(alpha: 0.15),
          border: Border.all(
            color: enabled
                ? AppColors.muted
                : AppColors.muted.withValues(alpha: 0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: label == '⌫' ? 18 : 20,
              fontWeight: FontWeight.w500,
              color: enabled ? AppColors.ink : AppColors.muted,
              fontFamily: AppFonts.body,
            ),
          ),
        ),
      ),
    );
  }
}
