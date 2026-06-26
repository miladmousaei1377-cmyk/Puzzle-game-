import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../data/models/puzzle_model.dart';

class DraggableObjectWidget extends StatefulWidget {
  final PuzzleObject object;
  final Offset position;
  final double rotation;
  final bool isSnapped;
  final bool reducedMotion;
  final ValueChanged<Offset> onPositionChanged;
  final ValueChanged<double> onRotationChanged;
  final VoidCallback? onSnap;

  const DraggableObjectWidget({
    super.key,
    required this.object,
    required this.position,
    required this.rotation,
    required this.onPositionChanged,
    required this.onRotationChanged,
    this.isSnapped = false,
    this.reducedMotion = false,
    this.onSnap,
  });

  @override
  State<DraggableObjectWidget> createState() => _DraggableObjectWidgetState();
}

class _DraggableObjectWidgetState extends State<DraggableObjectWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _snapCtrl;

  Offset _dragStart = Offset.zero;
  Offset _posAtDragStart = Offset.zero;
  Offset _currentDragPos = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController(
      vsync: this,
      duration: widget.reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 300),
    );
    CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _snapCtrl.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails d) {
    if (!widget.object.movable) return;
    setState(() {
      _isDragging = true;
      _dragStart = d.globalPosition;
      _posAtDragStart = widget.position;
      _currentDragPos = widget.position;
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (!widget.object.movable) return;
    final delta = d.globalPosition - _dragStart;
    _currentDragPos = _posAtDragStart + delta;
    widget.onPositionChanged(_currentDragPos);
  }

  void _onPanEnd(DragEndDetails d) {
    if (!widget.object.movable) return;
    setState(() => _isDragging = false);

    for (final zone in widget.object.snapZones) {
      final dist = (_currentDragPos - zone.targetPosition).distance;
      if (dist <= zone.snapRadius) {
        widget.onPositionChanged(zone.targetPosition);
        _snapCtrl.forward(from: 0);
        widget.onSnap?.call();
        return;
      }
    }
  }

  void _onTap() {
    if (!widget.object.rotatable) return;
    widget.onRotationChanged(widget.rotation + 45.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: _onTap,
      child: AnimatedScale(
        scale: _isDragging ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Transform.rotate(
          angle: widget.rotation * (3.14159 / 180),
          child: _ObjectShape(
            objectId: widget.object.id,
            isSnapped: widget.isSnapped,
          ),
        ),
      ),
    );
  }
}

class _ObjectShape extends StatelessWidget {
  final String objectId;
  final bool isSnapped;

  const _ObjectShape({required this.objectId, required this.isSnapped});

  @override
  Widget build(BuildContext context) {
    // Render placeholder shapes since we don't have actual image assets.
    // These will be replaced with Image.asset() once real assets are added.
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: isSnapped
            ? AppColors.accent.withValues(alpha: 0.15)
            : AppColors.muted.withValues(alpha: 0.3),
        border: Border.all(
          color: isSnapped ? AppColors.accent : AppColors.ink,
          width: 2,
        ),
        borderRadius: _shapeRadius(objectId),
      ),
      child: Center(
        child: Icon(
          _shapeIcon(objectId),
          color: isSnapped ? AppColors.accent : AppColors.ink,
          size: 32,
        ),
      ),
    );
  }

  BorderRadius _shapeRadius(String id) {
    if (id.contains('branch')) return BorderRadius.circular(4);
    if (id.contains('fish')) return BorderRadius.circular(32);
    if (id.contains('frame')) return BorderRadius.circular(2);
    return BorderRadius.circular(12);
  }

  IconData _shapeIcon(String id) {
    if (id.contains('branch')) return Icons.park_outlined;
    if (id.contains('bird')) return Icons.flutter_dash;
    if (id.contains('frame')) return Icons.crop_square_outlined;
    if (id.contains('fish')) return Icons.set_meal_outlined;
    return Icons.circle_outlined;
  }
}
