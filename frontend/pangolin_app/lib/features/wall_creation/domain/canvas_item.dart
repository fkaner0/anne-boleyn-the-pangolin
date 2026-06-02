import 'dart:ui' show Offset;

abstract class CanvasItem {
  final int id;
  final Offset center;
  final double scale;

  const CanvasItem({required this.id, required this.center, this.scale = 1.0});
}
