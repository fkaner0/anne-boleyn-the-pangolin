import 'canvas_item.dart';
import 'canvas_transform.dart';

class CanvasTextItem extends CanvasItem {
  final String text;

  const CanvasTextItem({
    required super.id,
    required this.text,
    required super.transform,
  });

  CanvasTextItem copyWith({CanvasTransform? transform, String? text}) {
    return CanvasTextItem(
      id: id,
      text: text ?? this.text,
      transform: transform ?? this.transform,
    );
  }
}
