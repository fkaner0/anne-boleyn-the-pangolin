import 'package:flutter/material.dart';

class PinchToZoom extends StatefulWidget {
  final Widget child;
  final double maxScale;
  final Duration resetDuration;
  final Curve resetCurve;

  const PinchToZoom({
    super.key,
    required this.child,
    this.maxScale = 3.0,
    this.resetDuration = const Duration(milliseconds: 220),
    this.resetCurve = Curves.easeOut,
  });

  @override
  State<PinchToZoom> createState() => _PinchToZoomState();
}

class _PinchToZoomState extends State<PinchToZoom>
    with SingleTickerProviderStateMixin {
  late final AnimationController _resetController;
  Animation<Matrix4>? _resetAnimation;

  Matrix4 _transform = Matrix4.identity();
  Offset _initialFocalPoint = Offset.zero;
  bool _engaged = false;

  @override
  void initState() {
    super.initState();
    _resetController =
        AnimationController(vsync: this, duration: widget.resetDuration)
          ..addListener(() {
            final animation = _resetAnimation;
            if (animation != null) {
              setState(() => _transform = animation.value);
            }
          });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (details.pointerCount < 2) return;
    _resetController.stop();
    _initialFocalPoint = details.localFocalPoint;
    _engaged = true;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (!_engaged || details.pointerCount < 2) return;

    final scale = details.scale.clamp(1.0, widget.maxScale);
    final focal = details.localFocalPoint;

    final transform =
        Matrix4.translationValues(focal.dx, focal.dy, 0.0) *
        Matrix4.diagonal3Values(scale, scale, 1.0) *
        Matrix4.translationValues(
          -_initialFocalPoint.dx,
          -_initialFocalPoint.dy,
          0.0,
        );

    setState(() => _transform = transform);
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (!_engaged) return;
    _engaged = false;

    _resetAnimation = Matrix4Tween(begin: _transform, end: Matrix4.identity())
        .animate(
          CurvedAnimation(parent: _resetController, curve: widget.resetCurve),
        );
    _resetController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      child: ClipRect(
        child: Transform(transform: _transform, child: widget.child),
      ),
    );
  }
}
