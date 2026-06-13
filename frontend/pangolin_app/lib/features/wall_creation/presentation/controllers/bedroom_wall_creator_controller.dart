import 'package:flutter/material.dart';
import 'package:pangolin_app/features/recommendation/domain/position.dart';
import 'package:pangolin_app/features/recommendation/domain/profile.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_builder.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_image.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_sticker.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_text.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import 'package:pangolin_app/fonts/font_catalog.dart';
import 'dart:typed_data';

import '../../data/picker/image_file_picker.dart';
import '../../data/uploader/wall_image_uploader.dart';
import '../../domain/canvas_item.dart';
import '../../domain/canvas_prompt.dart';
import '../../domain/canvas_transform.dart';
import '../../domain/virtual_canvas.dart';

class BedroomWallCreatorController {
  final VirtualCanvas canvas;
  final ImageFilePicker imagePicker;
  final ImageUploader imageUploader;
  final StickerCatalog stickerCatalog;
  final FontCatalog fontCatalog;
  final List<CanvasItem> _items = [];
  final List<CanvasPrompt> _prompts;
  int _nextId = 0;

  BedroomWallCreatorController({
    /// TODO: these should probably all become optional
    required this.imagePicker,
    required this.imageUploader,
    required this.stickerCatalog,
    required this.fontCatalog,
    VirtualCanvas? canvas,
  }) : canvas = canvas ?? const VirtualCanvas(),
       _prompts = CanvasPrompt.defaults();

  List<CanvasItem> get items => List.unmodifiable(_items);

  List<CanvasPrompt> get prompts => List.unmodifiable(_prompts);

  Iterable<CanvasImageItem> get imageItems => _items.whereType();

  Iterable<CanvasTextItem> get textItems => _items.whereType();

  Iterable<CanvasStickerItem> get stickerItems => _items.whereType();

  Color _backgroundColor = Color(0xFFFEF9F2);

  Color get backgroundColor => _backgroundColor;

  void updateBackgroundColor(Color color) {
    _backgroundColor = color;
  }

  CanvasTransform _centeredTransform() {
    return CanvasTransform(center: Offset(canvas.width / 2, canvas.height / 2));
  }

  CanvasTransform _transformAt(Offset? center) {
    return center != null
        ? CanvasTransform(center: center)
        : _centeredTransform();
  }

  CanvasTransform _transformFor(Position position) {
    return CanvasTransform(
      center: Offset(position.x.toDouble(), position.y.toDouble()),
      scale: position.scale,
      rotation: position.rotation,
    );
  }

  void loadFrom(Profile profile) {
    _backgroundColor = Color(profile.wallBackgroundHexARGB);
    _items.clear();
    _prompts.clear();

    for (final image in profile.images) {
      _items.add(
        CanvasImageItem(
          id: _nextId++,
          transform: _transformFor(image.position),
          aspectRatio: image.position.aspectRatio,
          url: image.url,
        ),
      );
    }

    for (final textbox in profile.textboxes) {
      _items.add(
        CanvasTextItem(
          id: _nextId++,
          transform: _transformFor(textbox.position),
          text: textbox.body,
          font: textbox.font,
          textColor: textbox.fontHexARGB != null
              ? Color(textbox.fontHexARGB!)
              : null,
          backgroundColor: textbox.backgroundHexARGB != null
              ? Color(textbox.backgroundHexARGB!)
              : null,
        ),
      );
    }

    for (final sticker in profile.stickers) {
      _items.add(
        CanvasStickerItem(
          id: _nextId++,
          transform: _transformFor(sticker.position),
          stickerName: sticker.name,
        ),
      );
    }
  }

  Future<void> addImage({Offset? center}) async {
    final picked = await imagePicker.pickImage();
    if (picked == null) return;

    _items.add(
      CanvasImageItem(
        id: _nextId++,
        transform: _transformAt(center),
        bytes: picked.bytes,
        aspectRatio: picked.aspectRatio,
        url: await _uploadImage(picked.bytes),
      ),
    );
  }

  void addTextBoxWithText(String text, {Offset? center}) {
    _items.add(
      CanvasTextItem(
        id: _nextId++,
        transform: _transformAt(center),
        text: text,
      ),
    );
  }

  void addTextBox({Offset? center}) {
    addTextBoxWithText('', center: center);
  }

  void addSticker(String stickerName, {Offset? center}) {
    if (stickerCatalog.assetForName(stickerName) == null) return;

    _items.add(
      CanvasStickerItem(
        id: _nextId++,
        transform: _transformAt(center),
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
        url: await _uploadImage(picked.bytes),
      ),
    );
    _prompts.removeAt(index);
  }

  Future<String?> _uploadImage(Uint8List bytes) async {
    try {
      return await imageUploader.uploadImage(bytes);
    } catch (_) {
      return null;
    }
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

  void removeItem(int id) {
    _items.removeWhere((item) => item.id == id);
  }

  void updateTransform(int id, CanvasTransform transform) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final clamped = transform.copyWith(
      center: Offset(
        transform.center.dx.clamp(0.0, canvas.width),
        transform.center.dy.clamp(0.0, canvas.height),
      ),
    );
    final updated = _items.removeAt(index).withTransform(clamped);
    _items.add(updated);
  }

  void _updateTextFromId(int id, CanvasTextItem Function(CanvasTextItem) f) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final item = _items[index];
    if (item is CanvasTextItem) {
      _items[index] = f(item);
    }
  }

  void updateText(int id, String text) {
    _updateTextFromId(id, (item) => item.withText(text));
  }

  // TODO: FONT TYPE?
  void updateTextFont(int id, String? font) {
    _updateTextFromId(id, (item) => item.withFont(font));
  }

  void updateTextboxTextColor(int id, Color? color) {
    _updateTextFromId(id, (item) => item.withTextColor(color));
  }

  void updateTextboxBackgroundColor(int id, Color? color) {
    _updateTextFromId(id, (item) => item.withBackgroundColor(color));
  }

  void exportInto(ProfileBuilder builder) {
    builder.setWallBackgroundHexARGB(_backgroundColor.toARGB32());

    for (final item in _items) {
      switch (item) {
        case CanvasImageItem():
          builder.addImage(
            ProfileImage(
              url: item.url ?? '',
              position: _positionFor(item.transform, item.aspectRatio),
            ),
          );
        case CanvasTextItem():
          builder.addTextBox(
            ProfileText(
              title: '',
              body: item.text,
              font: item.font,
              fontHexARGB: item.textColor?.toARGB32() ?? 0xFF000000,
              backgroundHexARGB: item.backgroundColor?.toARGB32(),
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
      rotation: transform.rotation,
      aspectRatio: aspectRatio,
      scale: transform.scale,
    );
  }
}
