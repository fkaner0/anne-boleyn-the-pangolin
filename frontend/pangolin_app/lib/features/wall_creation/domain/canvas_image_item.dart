import 'dart:typed_data';
import 'dart:ui' show Offset;

import 'canvas_item.dart';

class CanvasImageItem extends CanvasItem {
  final Uint8List bytes;
  final double aspectRatio;

  const CanvasImageItem({
    required super.id,
    required this.bytes,
    required this.aspectRatio,
    required super.center,
    super.scale,
  });

  CanvasImageItem copyWith({Offset? center, double? scale}) {
    return CanvasImageItem(
      id: id,
      bytes: bytes,
      aspectRatio: aspectRatio,
      center: center ?? this.center,
      scale: scale ?? this.scale,
    );
  }
}
