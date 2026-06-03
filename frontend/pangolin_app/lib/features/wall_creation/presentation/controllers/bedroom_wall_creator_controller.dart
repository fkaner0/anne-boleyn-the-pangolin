import 'dart:ui' show Offset;

import '../../data/image_file_picker.dart';
import '../../domain/canvas_image_item.dart';
import '../../domain/canvas_text_item.dart';
import '../../domain/virtual_canvas.dart';

class BedroomWallCreatorController {
  final VirtualCanvas canvas;
  final ImageFilePicker imagePicker;
  final List<CanvasImageItem> _imageItems = [];
  final List<CanvasTextItem> _textItems = [];
  int _nextId = 0;

  BedroomWallCreatorController({
    required this.imagePicker,
    VirtualCanvas? canvas,
  }) : canvas = canvas ?? const VirtualCanvas();

  List<CanvasImageItem> get imageItems => List.unmodifiable(_imageItems);

  List<CanvasTextItem> get textItems => List.unmodifiable(_textItems);

  Future<void> addImage() async {
    final picked = await imagePicker.pickImage();
    if (picked == null) return;

    _imageItems.add(
      CanvasImageItem(
        id: _nextId++,
        bytes: picked.bytes,
        aspectRatio: picked.aspectRatio,
        center: Offset(canvas.width / 2, canvas.height / 2),
      ),
    );
  }

  void updateImageTransform(int id, Offset center, double scale) {
    final index = _imageItems.indexWhere((item) => item.id == id);
    if (index == -1) return;

    _imageItems[index] = _imageItems[index].copyWith(
      center: center,
      scale: scale,
    );
  }

  void addTextBox() {
    _textItems.add(
      CanvasTextItem(
        id: _nextId++,
        text: '',
        center: Offset(canvas.width / 2, canvas.height / 2),
      ),
    );
  }

  void updateTextTransform(int id, Offset center, double scale) {
    final index = _textItems.indexWhere((item) => item.id == id);
    if (index == -1) return;

    _textItems[index] = _textItems[index].copyWith(
      center: center,
      scale: scale,
    );
  }

  void updateText(int id, String text) {
    final index = _textItems.indexWhere((item) => item.id == id);
    if (index == -1) return;

    _textItems[index] = _textItems[index].copyWith(text: text);
  }

  void addSticker() {}
}
