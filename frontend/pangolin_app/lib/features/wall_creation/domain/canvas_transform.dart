import 'dart:ui' show Offset;

class CanvasTransform {
  final Offset center;
  final double scale;
  final double rotation;

  const CanvasTransform({
    required this.center,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  CanvasTransform copyWith({Offset? center, double? scale, double? rotation}) {
    return CanvasTransform(
      center: center ?? this.center,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CanvasTransform &&
        other.center == center &&
        other.scale == scale &&
        other.rotation == rotation;
  }

  @override
  int get hashCode => Object.hash(center, scale, rotation);
}
