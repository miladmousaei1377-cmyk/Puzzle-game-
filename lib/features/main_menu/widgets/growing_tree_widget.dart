import 'package:flutter/material.dart';

import '../../../app/theme.dart';

class GrowingTreeWidget extends StatefulWidget {
  final int solvedCount;
  final int totalCount;
  final bool reducedMotion;

  const GrowingTreeWidget({
    super.key,
    required this.solvedCount,
    required this.totalCount,
    this.reducedMotion = false,
  });

  @override
  State<GrowingTreeWidget> createState() => _GrowingTreeWidgetState();
}

class _GrowingTreeWidgetState extends State<GrowingTreeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;
  int _prevSolved = 0;

  @override
  void initState() {
    super.initState();
    _prevSolved = widget.solvedCount;
    _controller = AnimationController(
      vsync: this,
      duration: widget.reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 1500),
    );
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(GrowingTreeWidget old) {
    super.didUpdateWidget(old);
    if (widget.solvedCount > _prevSolved) {
      _prevSolved = widget.solvedCount;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        widget.totalCount > 0 ? widget.solvedCount / widget.totalCount : 0.0;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        painter: _TreePainter(
          progress: progress,
          animValue: _anim.value,
          solvedCount: widget.solvedCount,
        ),
      ),
    );
  }
}

class _TreePainter extends CustomPainter {
  final double progress;
  final double animValue;
  final int solvedCount;

  _TreePainter({
    required this.progress,
    required this.animValue,
    required this.solvedCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final bottom = size.height;

    final trunkPaint = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final branchPaint = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final leafPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    // Trunk
    canvas.drawLine(
      Offset(cx, bottom),
      Offset(cx, bottom * 0.45),
      trunkPaint,
    );

    // Level 1 branches (always visible if progress > 0)
    final b1Show = progress >= 0;
    if (b1Show) {
      final b1Left = Offset(cx - size.width * 0.25, bottom * 0.30);
      final b1Right = Offset(cx + size.width * 0.25, bottom * 0.30);
      canvas.drawLine(Offset(cx, bottom * 0.45), b1Left, branchPaint);
      canvas.drawLine(Offset(cx, bottom * 0.45), b1Right, branchPaint);

      // Level 2 branches (appear as puzzles are solved)
      if (solvedCount >= 1) {
        final b2a = Offset(cx - size.width * 0.38, bottom * 0.15);
        canvas.drawLine(b1Left, b2a, branchPaint);
        _drawLeaf(canvas, leafPaint, b2a, 6.0);
      }
      if (solvedCount >= 1) {
        final b2b = Offset(cx - size.width * 0.12, bottom * 0.18);
        canvas.drawLine(b1Left, b2b, branchPaint);
        _drawLeaf(canvas, leafPaint, b2b, 5.0);
      }
      if (solvedCount >= 2) {
        final b2c = Offset(cx + size.width * 0.38, bottom * 0.15);
        canvas.drawLine(b1Right, b2c, branchPaint);
        _drawLeaf(canvas, leafPaint, b2c, 6.0);
      }
      if (solvedCount >= 2) {
        final b2d = Offset(cx + size.width * 0.12, bottom * 0.18);
        canvas.drawLine(b1Right, b2d, branchPaint);
        _drawLeaf(canvas, leafPaint, b2d, 5.0);
      }

      // Extra leaves for higher solved counts
      if (solvedCount >= 3) {
        _drawLeaf(canvas, leafPaint, Offset(cx, bottom * 0.42), 4.0);
        _drawLeaf(canvas, leafPaint, Offset(cx - 20, bottom * 0.38), 4.0);
      }
    }
  }

  void _drawLeaf(Canvas canvas, Paint paint, Offset center, double r) {
    final path = Path()
      ..moveTo(center.dx, center.dy - r)
      ..quadraticBezierTo(
          center.dx + r, center.dy, center.dx, center.dy + r * 0.6)
      ..quadraticBezierTo(
          center.dx - r, center.dy, center.dx, center.dy - r)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TreePainter old) =>
      old.progress != progress ||
      old.animValue != animValue ||
      old.solvedCount != solvedCount;
}
