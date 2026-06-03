import 'canvas_transform.dart';

abstract class CanvasItem {
  final int id;
  final CanvasTransform transform;

  const CanvasItem({required this.id, required this.transform});
}
