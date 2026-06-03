import 'dart:ui' show Offset;

import 'package:pangolin_app/features/recommendation/domain/position.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_builder.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_image.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_sticker.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_text.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import '../../data/image_file_picker.dart';
import '../../domain/canvas_item.dart';
import '../../domain/canvas_prompt.dart';
import '../../domain/canvas_transform.dart';
import '../../domain/virtual_canvas.dart';

class BedroomWallCreatorController {
  final VirtualCanvas canvas;
  final ImageFilePicker imagePicker;
  final StickerCatalog stickerCatalog;
  final List<CanvasItem> _items = [];
  final List<CanvasPrompt> _prompts;
  int _nextId = 0;

  BedroomWallCreatorController({
    required this.imagePicker,
    required this.stickerCatalog,
    VirtualCanvas? canvas,
  }) : canvas = canvas ?? const VirtualCanvas(),
       _prompts = CanvasPrompt.defaults();

  List<CanvasItem> get items => List.unmodifiable(_items);

  List<CanvasPrompt> get prompts => List.unmodifiable(_prompts);

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

  Future<void> addImageFromPrompt(int promptId) async {
    final index = _prompts.indexWhere((p) => p.id == promptId);
    if (index == -1) return;
    final prompt = _prompts[index];

    final picked = await imagePicker.pickImage();
    if (picked == null) return;

    _items.add(
      CanvasImageItem(
        id: _nextId++,
        transform: prompt.transform,
        bytes: picked.bytes,
        aspectRatio: picked.aspectRatio,
      ),
    );
    _prompts.removeAt(index);
  }

  void addTextBoxFromPrompt(int promptId) {
    final index = _prompts.indexWhere((p) => p.id == promptId);
    if (index == -1) return;
    final prompt = _prompts[index];

    _items.add(
      CanvasTextItem(id: _nextId++, transform: prompt.transform, text: ''),
    );
    _prompts.removeAt(index);
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

  void exportInto(ProfileBuilder builder) {
    for (final item in _items) {
      switch (item) {
        case CanvasImageItem():
          builder.addImage(
            ProfileImage(
              url: '',
              position: _positionFor(item.transform, item.aspectRatio),
            ),
          );
        case CanvasTextItem():
          builder.addTextBox(
            ProfileText(
              title: '',
              body: item.text,
              position: _positionFor(item.transform, 1.0),
            ),
          );
        case CanvasStickerItem():
          builder.addSticker(
            ProfileSticker(
              name: item.stickerName,
              position: _positionFor(item.transform, 1.0),
            ),
          );
      }
    }
  }

  Position _positionFor(CanvasTransform transform, double aspectRatio) {
    return Position(
      x: transform.center.dx.round(),
      y: transform.center.dy.round(),
      rotation: transform.rotation.round(),
      aspectRatio: aspectRatio,
      scale: transform.scale,
    );
  }
}
