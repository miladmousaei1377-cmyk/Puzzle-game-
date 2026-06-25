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
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late AnimationController _leafCtrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  late Animation<double> _leafDraw;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _leafCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 1.0),
    );
    _leafDraw = CurvedAnimation(parent: _leafCtrl, curve: Curves.easeOut);

    _ctrl.forward().then((_) => _leafCtrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _leafCtrl.dispose();
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
                // Leaf growth animation
                AnimatedBuilder(
                  animation: _leafDraw,
                  builder: (_, __) => CustomPaint(
                    size: const Size(120, 80),
                    painter: _LeafGrowPainter(_leafDraw.value),
                  ),
                ),
                const SizedBox(height: 8),
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

class _LeafGrowPainter extends CustomPainter {
  final double progress;
  _LeafGrowPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final leafPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height;

    // Draw stem
    final stemEnd = Offset(cx, cy * (1 - progress * 0.6));
    canvas.drawLine(Offset(cx, cy), stemEnd, paint);

    if (progress > 0.3) {
      final leafProgress = ((progress - 0.3) / 0.7).clamp(0.0, 1.0);
      // Left leaf
      _drawLeaf(canvas, paint, leafPaint,
          Offset(cx, cy * 0.6), leafProgress, -0.6);
      // Right leaf
      _drawLeaf(canvas, paint, leafPaint,
          Offset(cx, cy * 0.5), leafProgress, 0.6);
    }

    if (progress > 0.7) {
      final tipProgress = ((progress - 0.7) / 0.3).clamp(0.0, 1.0);
      _drawLeaf(canvas, paint, leafPaint,
          Offset(cx, cy * 0.3), tipProgress, 0.0);
    }
  }

  void _drawLeaf(Canvas canvas, Paint stroke, Paint fill, Offset base,
      double p, double angle) {
    final r = 14.0 * p;
    if (r < 1) return;
    final tip = base + Offset(r * 1.5 * angle.sign * (1 - angle.abs() * 0.3),
        -r * 1.2);
    final ctrl = Offset(
        base.dx + (tip.dx - base.dx) * 0.3 + r * 0.8 * (angle > 0 ? 1 : -1),
        base.dy - r * 0.5);

    final path = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy)
      ..quadraticBezierTo(
          base.dx + (tip.dx - base.dx) * 0.7 - r * 0.4 * (angle > 0 ? 1 : -1),
          base.dy - r * 0.8,
          base.dx,
          base.dy)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_LeafGrowPainter old) => old.progress != progress;
}
