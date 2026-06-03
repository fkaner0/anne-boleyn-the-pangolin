import 'dart:ui' show Offset;

import 'canvas_item.dart';

class CanvasTextItem extends CanvasItem {
  final String text;

  const CanvasTextItem({
    required super.id,
    required this.text,
    required super.center,
    super.scale,
  });

  CanvasTextItem copyWith({Offset? center, double? scale, String? text}) {
    return CanvasTextItem(
      id: id,
      text: text ?? this.text,
      center: center ?? this.center,
      scale: scale ?? this.scale,
    );
  }
}
