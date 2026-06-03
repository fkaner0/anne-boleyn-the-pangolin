import 'dart:ui' show Offset;

import 'package:pangolin_app/stickers/sticker_catalog.dart';
import '../../data/image_file_picker.dart';
import '../../domain/canvas_item.dart';
import '../../domain/canvas_transform.dart';
import '../../domain/virtual_canvas.dart';

class BedroomWallCreatorController {
  final VirtualCanvas canvas;
  final ImageFilePicker imagePicker;
  final StickerCatalog stickerCatalog;
  final List<CanvasItem> _items = [];
  int _nextId = 0;

  BedroomWallCreatorController({
    required this.imagePicker,
    required this.stickerCatalog,
    VirtualCanvas? canvas,
  }) : canvas = canvas ?? const VirtualCanvas();

  List<CanvasItem> get items => List.unmodifiable(_items);

  Iterable<CanvasImageItem> get imageItems => _items.whereType();

  Iterable<CanvasTextItem> get textItems => _items.whereType();

  Iterable<CanvasStickerItem> get stickerItems => _items.whereType();

  CanvasTransform _centeredTransform() {
    return CanvasTransform(center: Offset(canvas.width / 2, canvas.height / 2));
  }

  Future<void> addImage() async {
    final picked = await imagePicker.pickImage();
    if (picked == null) return;

    _items.add(
      CanvasImageItem(
        id: _nextId++,
        transform: _centeredTransform(),
        bytes: picked.bytes,
        aspectRatio: picked.aspectRatio,
      ),
    );
  }

  void addTextBox() {
    _items.add(
      CanvasTextItem(id: _nextId++, transform: _centeredTransform(), text: ''),
    );
  }

  void addSticker(String stickerName) {
    if (stickerCatalog.assetForName(stickerName) == null) return;

    _items.add(
      CanvasStickerItem(
        id: _nextId++,
        transform: _centeredTransform(),
        stickerName: stickerName,
      ),
    );
  }

  void updateTransform(int id, CanvasTransform transform) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    _items[index] = _items[index].withTransform(transform);
  }

  void updateText(int id, String text) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final item = _items[index];
    if (item is CanvasTextItem) {
      _items[index] = item.withText(text);
    }
  }
}
