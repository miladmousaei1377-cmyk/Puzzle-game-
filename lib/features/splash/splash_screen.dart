import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _drawAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _drawAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    );

    _controller.forward().then((_) {
      if (mounted) context.go('/menu');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => CustomPaint(
                size: const Size(160, 160),
                painter: _SplashTreePainter(
                  progress: _drawAnim.value,
                  opacity: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: _fadeAnim,
              child: Text(
                'باغ خاموش',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashTreePainter extends CustomPainter {
  final double progress;
  final double opacity;

  _SplashTreePainter({required this.progress, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ink.withValues(alpha: opacity)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final bottom = size.height;

    // Draw trunk
    _drawLine(canvas, paint, Offset(cx, bottom), Offset(cx, bottom * 0.5),
        progress, 0.0, 0.3);

    // Main branches
    _drawLine(canvas, paint, Offset(cx, bottom * 0.5),
        Offset(cx - 40, bottom * 0.25), progress, 0.3, 0.55);
    _drawLine(canvas, paint, Offset(cx, bottom * 0.5),
        Offset(cx + 40, bottom * 0.25), progress, 0.35, 0.6);

    // Sub branches
    _drawLine(canvas, paint, Offset(cx - 40, bottom * 0.25),
        Offset(cx - 65, bottom * 0.08), progress, 0.55, 0.75);
    _drawLine(canvas, paint, Offset(cx - 40, bottom * 0.25),
        Offset(cx - 20, bottom * 0.10), progress, 0.58, 0.78);
    _drawLine(canvas, paint, Offset(cx + 40, bottom * 0.25),
        Offset(cx + 65, bottom * 0.08), progress, 0.6, 0.80);
    _drawLine(canvas, paint, Offset(cx + 40, bottom * 0.25),
        Offset(cx + 20, bottom * 0.10), progress, 0.62, 0.82);
  }

  void _drawLine(Canvas canvas, Paint paint, Offset start, Offset end,
      double progress, double startAt, double endAt) {
    if (progress < startAt) return;
    final t = ((progress - startAt) / (endAt - startAt)).clamp(0.0, 1.0);
    final pt = Offset.lerp(start, end, t)!;
    canvas.drawLine(start, pt, paint);
  }

  @override
  bool shouldRepaint(_SplashTreePainter old) =>
      old.progress != progress || old.opacity != opacity;
}
