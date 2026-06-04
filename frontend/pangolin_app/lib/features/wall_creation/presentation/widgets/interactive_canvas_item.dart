import 'package:flutter/material.dart';

import '../../domain/canvas_transform.dart';

class InteractiveCanvasItem extends StatefulWidget {
  final CanvasTransform initialTransform;
  final Size baseSize;
  final Widget child;
  final void Function(CanvasTransform transform) onTransformEnd;
  final void Function(bool active)? onInteractionChanged;
  final void Function(Offset globalPosition)? onDragUpdate;
  final double minScale;
  final double maxScale;

  const InteractiveCanvasItem({
    super.key,
    required this.initialTransform,
    required this.baseSize,
    required this.child,
    required this.onTransformEnd,
    this.onInteractionChanged,
    this.onDragUpdate,
    this.minScale = 0.3,
    this.maxScale = 5.0,
  });

  @override
  State<InteractiveCanvasItem> createState() => _InteractiveCanvasItemState();
}

class _InteractiveCanvasItemState extends State<InteractiveCanvasItem> {
  static const double _hitSlop = 24.0;

  late CanvasTransform _transform = widget.initialTransform;

  bool _gesturing = false;
  Offset _startFocalPoint = Offset.zero;
  CanvasTransform _startTransform = const CanvasTransform(center: Offset.zero);

  @override
  void didUpdateWidget(InteractiveCanvasItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_gesturing && widget.initialTransform != oldWidget.initialTransform) {
      _transform = widget.initialTransform;
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _gesturing = true;
    _startFocalPoint = details.focalPoint;
    _startTransform = _transform;
    widget.onInteractionChanged?.call(true);
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    widget.onDragUpdate?.call(details.focalPoint);
    setState(() {
      _transform = _startTransform.copyWith(
        center:
            _startTransform.center + (details.focalPoint - _startFocalPoint),
        scale: (_startTransform.scale * details.scale).clamp(
          widget.minScale,
          widget.maxScale,
        ),
        rotation: _startTransform.rotation + details.rotation,
      );
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _gesturing = false;
    widget.onTransformEnd(_transform);
    widget.onInteractionChanged?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.baseSize.width * _transform.scale;
    final height = widget.baseSize.height * _transform.scale;
    final boxWidth = width + _hitSlop * 2;
    final boxHeight = height + _hitSlop * 2;

    return Positioned(
      left: _transform.center.dx - boxWidth / 2,
      top: _transform.center.dy - boxHeight / 2,
      width: boxWidth,
      height: boxHeight,
      child: Transform.rotate(
        angle: _transform.rotation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          child: Center(
            child: SizedBox(width: width, height: height, child: widget.child),
          ),
        ),
      ),
    );
  }
}
