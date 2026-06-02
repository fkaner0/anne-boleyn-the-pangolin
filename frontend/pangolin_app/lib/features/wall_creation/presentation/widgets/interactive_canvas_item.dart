import 'package:flutter/material.dart';

class InteractiveCanvasItem extends StatefulWidget {
  final Offset initialCenter;
  final double initialScale;
  final Size baseSize;
  final Widget child;
  final void Function(Offset center, double scale) onTransformEnd;
  final double minScale;
  final double maxScale;

  const InteractiveCanvasItem({
    super.key,
    required this.initialCenter,
    required this.initialScale,
    required this.baseSize,
    required this.child,
    required this.onTransformEnd,
    this.minScale = 0.3,
    this.maxScale = 5.0,
  });

  @override
  State<InteractiveCanvasItem> createState() => _InteractiveCanvasItemState();
}

class _InteractiveCanvasItemState extends State<InteractiveCanvasItem> {
  late Offset _center = widget.initialCenter;
  late double _scale = widget.initialScale;

  bool _gesturing = false;
  Offset _startFocalPoint = Offset.zero;
  Offset _startCenter = Offset.zero;
  double _startScale = 1.0;

  @override
  void didUpdateWidget(InteractiveCanvasItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_gesturing) {
      _center = widget.initialCenter;
      _scale = widget.initialScale;
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _gesturing = true;
    _startFocalPoint = details.focalPoint;
    _startCenter = _center;
    _startScale = _scale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_startScale * details.scale).clamp(
        widget.minScale,
        widget.maxScale,
      );
      _center = _startCenter + (details.focalPoint - _startFocalPoint);
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _gesturing = false;
    widget.onTransformEnd(_center, _scale);
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.baseSize.width * _scale;
    final height = widget.baseSize.height * _scale;

    return Positioned(
      left: _center.dx - width / 2,
      top: _center.dy - height / 2,
      width: width,
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
        child: widget.child,
      ),
    );
  }
}
