import 'dart:typed_data';

import 'canvas_transform.dart';

sealed class CanvasItem {
  final int id;
  final CanvasTransform transform;

  const CanvasItem({required this.id, required this.transform});

  CanvasItem withTransform(CanvasTransform transform);
}

final class CanvasImageItem extends CanvasItem {
  final Uint8List bytes;
  final double aspectRatio;
  final String? url;

  const CanvasImageItem({
    required super.id,
    required super.transform,
    required this.bytes,
    required this.aspectRatio,
    this.url,
  });

  @override
  CanvasImageItem withTransform(CanvasTransform transform) {
    return CanvasImageItem(
      id: id,
      transform: transform,
      bytes: bytes,
      aspectRatio: aspectRatio,
      url: url,
    );
  }
}

final class CanvasTextItem extends CanvasItem {
  final String text;

  const CanvasTextItem({
    required super.id,
    required super.transform,
    required this.text,
  });

  @override
  CanvasTextItem withTransform(CanvasTransform transform) {
    return CanvasTextItem(id: id, transform: transform, text: text);
  }

  CanvasTextItem withText(String text) {
    return CanvasTextItem(id: id, transform: transform, text: text);
  }
}

final class CanvasStickerItem extends CanvasItem {
  final String stickerName;

  const CanvasStickerItem({
    required super.id,
    required super.transform,
    required this.stickerName,
  });

  @override
  CanvasStickerItem withTransform(CanvasTransform transform) {
    return CanvasStickerItem(
      id: id,
      transform: transform,
      stickerName: stickerName,
    );
  }
}
