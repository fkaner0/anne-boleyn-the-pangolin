import 'dart:ui' show Offset;

import 'package:pangolin_app/stickers/sticker_catalog.dart';
import '../../data/image_file_picker.dart';
import '../../domain/canvas_image_item.dart';
import '../../domain/canvas_text_item.dart';
import '../../domain/canvas_sticker_item.dart';
import '../../domain/canvas_transform.dart';
import '../../domain/virtual_canvas.dart';

class BedroomWallCreatorController {
  final VirtualCanvas canvas;
  final ImageFilePicker imagePicker;
  final StickerCatalog stickerCatalog;
  final List<CanvasImageItem> _imageItems = [];
  final List<CanvasTextItem> _textItems = [];
  final List<CanvasStickerItem> _stickerItems = [];
  int _nextId = 0;

  BedroomWallCreatorController({
    required this.imagePicker,
    required this.stickerCatalog,
    VirtualCanvas? canvas,
  }) : canvas = canvas ?? const VirtualCanvas();

  List<CanvasImageItem> get imageItems => List.unmodifiable(_imageItems);

  List<CanvasTextItem> get textItems => List.unmodifiable(_textItems);

  List<CanvasStickerItem> get stickerItems => List.unmodifiable(_stickerItems);

  CanvasTransform _centeredTransform() {
    return CanvasTransform(center: Offset(canvas.width / 2, canvas.height / 2));
  }

  Future<void> addImage() async {
    final picked = await imagePicker.pickImage();
    if (picked == null) return;

    _imageItems.add(
      CanvasImageItem(
        id: _nextId++,
        bytes: picked.bytes,
        aspectRatio: picked.aspectRatio,
        transform: _centeredTransform(),
      ),
    );
  }

  void updateImageTransform(int id, CanvasTransform transform) {
    final index = _imageItems.indexWhere((item) => item.id == id);
    if (index == -1) return;

    _imageItems[index] = _imageItems[index].copyWith(transform: transform);
  }

  void addTextBox() {
    _textItems.add(
      CanvasTextItem(id: _nextId++, text: '', transform: _centeredTransform()),
    );
  }

  void updateTextTransform(int id, CanvasTransform transform) {
    final index = _textItems.indexWhere((item) => item.id == id);
    if (index == -1) return;

    _textItems[index] = _textItems[index].copyWith(transform: transform);
  }

  void updateText(int id, String text) {
    final index = _textItems.indexWhere((item) => item.id == id);
    if (index == -1) return;

    _textItems[index] = _textItems[index].copyWith(text: text);
  }

  void addSticker(String stickerName) {
    _stickerItems.add(
      CanvasStickerItem(
        id: _nextId++,
        stickerName: stickerName,
        transform: _centeredTransform(),
      ),
    );
  }

  void updateStickerTransform(int id, CanvasTransform transform) {
    final index = _stickerItems.indexWhere((item) => item.id == id);
    if (index == -1) return;

    _stickerItems[index] = _stickerItems[index].copyWith(transform: transform);
  }
}
