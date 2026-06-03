import 'dart:typed_data';

import 'canvas_item.dart';
import 'canvas_transform.dart';

class CanvasImageItem extends CanvasItem {
  final Uint8List bytes;
  final double aspectRatio;

  const CanvasImageItem({
    required super.id,
    required this.bytes,
    required this.aspectRatio,
    required super.transform,
  });

  CanvasImageItem copyWith({CanvasTransform? transform}) {
    return CanvasImageItem(
      id: id,
      bytes: bytes,
      aspectRatio: aspectRatio,
      transform: transform ?? this.transform,
    );
  }
}
