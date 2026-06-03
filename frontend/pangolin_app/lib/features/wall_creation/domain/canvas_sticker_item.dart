import 'canvas_item.dart';
import 'canvas_transform.dart';

class CanvasStickerItem extends CanvasItem {
  final String stickerName;

  const CanvasStickerItem({
    required super.id,
    required super.transform,
    required this.stickerName,
  });

  CanvasStickerItem copyWith({CanvasTransform? transform}) {
    return CanvasStickerItem(
      id: id,
      transform: transform ?? this.transform,
      stickerName: stickerName,
    );
  }
}
