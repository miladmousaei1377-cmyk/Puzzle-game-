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
    // Use only the upper portion for the tree (trunk base at 60% down)
    final bottom = size.height * 0.6;

    final trunkPaint = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final branchPaint = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final secBranchPaint = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final leafPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    final leafPaintExtra = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    // --- Trunk ---
    final trunkTop = Offset(cx, bottom * 0.40);
    final trunkBase = Offset(cx, bottom);
    canvas.drawLine(trunkBase, trunkTop, trunkPaint);

    // --- Level 1 main branches ---
    final b1Left = Offset(cx - size.width * 0.28, bottom * 0.22);
    final b1Right = Offset(cx + size.width * 0.28, bottom * 0.22);
    final b1Join = Offset(cx, bottom * 0.38);

    canvas.drawLine(b1Join, b1Left, branchPaint);
    canvas.drawLine(b1Join, b1Right, branchPaint);

    // --- Level 2 secondary branches (always visible — base tree) ---
    // Left side: 2 branches off b1Left
    final b2LL = Offset(cx - size.width * 0.42, bottom * 0.06);
    final b2LR = Offset(cx - size.width * 0.14, bottom * 0.09);
    canvas.drawLine(b1Left, b2LL, secBranchPaint);
    canvas.drawLine(b1Left, b2LR, secBranchPaint);

    // Right side: 2 branches off b1Right
    final b2RL = Offset(cx + size.width * 0.14, bottom * 0.09);
    final b2RR = Offset(cx + size.width * 0.42, bottom * 0.06);
    canvas.drawLine(b1Right, b2RL, secBranchPaint);
    canvas.drawLine(b1Right, b2RR, secBranchPaint);

    // Center top tip
    final centerTip = Offset(cx, -bottom * 0.05);
    canvas.drawLine(trunkTop, centerTip, secBranchPaint);

    // --- Base leaf clusters at ALL tips (always shown) ---
    // Left outer tip
    _drawLeafCluster(canvas, leafPaint, b2LL, 14.0);
    // Left inner tip
    _drawLeafCluster(canvas, leafPaint, b2LR, 12.0);
    // Right inner tip
    _drawLeafCluster(canvas, leafPaint, b2RL, 12.0);
    // Right outer tip
    _drawLeafCluster(canvas, leafPaint, b2RR, 14.0);
    // Center top tip
    _drawLeafCluster(canvas, leafPaint, centerTip, 13.0);
    // Mid-branch leaf tufts on main branches
    _drawLeafCluster(canvas, leafPaint, b1Left, 9.0);
    _drawLeafCluster(canvas, leafPaint, b1Right, 9.0);

    // --- Extra leaf clusters as solvedCount increases ---
    if (solvedCount >= 1) {
      _drawLeafCluster(canvas, leafPaintExtra,
          Offset(cx - size.width * 0.32, bottom * 0.16), 10.0);
      _drawLeafCluster(canvas, leafPaintExtra,
          Offset(cx + size.width * 0.32, bottom * 0.16), 10.0);
    }
    if (solvedCount >= 2) {
      _drawLeafCluster(canvas, leafPaintExtra,
          Offset(cx - size.width * 0.20, bottom * 0.04), 11.0);
      _drawLeafCluster(canvas, leafPaintExtra,
          Offset(cx + size.width * 0.20, bottom * 0.04), 11.0);
    }
    if (solvedCount >= 3) {
      _drawLeafCluster(canvas, leafPaintExtra,
          Offset(cx, bottom * 0.28), 10.0);
      _drawLeafCluster(canvas, leafPaintExtra,
          Offset(cx - size.width * 0.08, bottom * 0.13), 9.0);
      _drawLeafCluster(canvas, leafPaintExtra,
          Offset(cx + size.width * 0.08, bottom * 0.13), 9.0);
    }
    if (solvedCount >= 5) {
      _drawLeafCluster(canvas, leafPaintExtra,
          Offset(cx - size.width * 0.36, bottom * 0.30), 8.0);
      _drawLeafCluster(canvas, leafPaintExtra,
          Offset(cx + size.width * 0.36, bottom * 0.30), 8.0);
    }
  }

  /// Draws a cluster of 5 overlapping leaves around [center].
  void _drawLeafCluster(Canvas canvas, Paint paint, Offset center, double r) {
    // Central leaf
    _drawLeaf(canvas, paint, center, r);
    // Four surrounding leaves
    _drawLeaf(canvas, paint, Offset(center.dx - r * 0.7, center.dy - r * 0.4), r * 0.75);
    _drawLeaf(canvas, paint, Offset(center.dx + r * 0.7, center.dy - r * 0.4), r * 0.75);
    _drawLeaf(canvas, paint, Offset(center.dx - r * 0.45, center.dy + r * 0.6), r * 0.65);
    _drawLeaf(canvas, paint, Offset(center.dx + r * 0.45, center.dy + r * 0.6), r * 0.65);
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
