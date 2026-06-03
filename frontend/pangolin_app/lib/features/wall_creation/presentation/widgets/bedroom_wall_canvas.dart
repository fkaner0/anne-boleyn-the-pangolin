import 'package:flutter/material.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import 'package:pangolin_app/stickers/sticker_image.dart';
import 'package:pangolin_app/theme/palette_colors.dart';
import '../../domain/canvas_item.dart';
import '../../domain/canvas_transform.dart';
import '../../domain/virtual_canvas.dart';
import 'editable_canvas_text_item.dart';
import 'interactive_canvas_item.dart';

class BedroomWallCanvas extends StatelessWidget {
  static const double _imageBaseWidth = 160;
  static const double _stickerBaseSize = 120;
  static const double _textBaseFontSize = 16;
  static const double _textMinWidth = 96;
  static const double _textMaxWidth = 240;

  final VirtualCanvas canvas;
  final StickerCatalog stickerCatalog;
  final List<CanvasItem> items;
  final void Function(int id, CanvasTransform transform) onItemTransform;
  final void Function(int id, String text) onTextChanged;

  const BedroomWallCanvas({
    super.key,
    required this.canvas,
    required this.stickerCatalog,
    required this.items,
    required this.onItemTransform,
    required this.onTextChanged,
  });

  CanvasTransform _toRendered(CanvasTransform transform, double renderScale) {
    return transform.copyWith(center: transform.center * renderScale);
  }

  CanvasTransform _toLogical(CanvasTransform transform, double renderScale) {
    return transform.copyWith(center: transform.center / renderScale);
  }

  Widget _buildItem(CanvasItem item, double renderScale) {
    final key = ValueKey(item.id);
    final initialTransform = _toRendered(item.transform, renderScale);
    void onEnd(CanvasTransform transform) =>
        onItemTransform(item.id, _toLogical(transform, renderScale));

    return switch (item) {
      CanvasImageItem() => InteractiveCanvasItem(
        key: key,
        initialTransform: initialTransform,
        baseSize:
            Size(_imageBaseWidth, _imageBaseWidth / item.aspectRatio) *
            renderScale,
        onTransformEnd: onEnd,
        child: Image.memory(item.bytes, fit: BoxFit.cover),
      ),
      CanvasStickerItem() => InteractiveCanvasItem(
        key: key,
        initialTransform: initialTransform,
        baseSize: Size.square(_stickerBaseSize) * renderScale,
        onTransformEnd: onEnd,
        child: StickerImage(catalog: stickerCatalog, name: item.stickerName),
      ),
      CanvasTextItem() => EditableCanvasTextItem(
        key: key,
        initialTransform: initialTransform,
        baseFontSize: _textBaseFontSize * renderScale,
        minWidth: _textMinWidth * renderScale,
        maxWidth: _textMaxWidth * renderScale,
        text: item.text,
        onTransformEnd: onEnd,
        onTextChanged: (text) => onTextChanged(item.id, text),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final renderScale = constraints.maxHeight.isFinite
            ? (constraints.maxWidth / canvas.width).clamp(
                0.0,
                constraints.maxHeight / canvas.height,
              )
            : constraints.maxWidth / canvas.width;

        return SizedBox(
          width: constraints.maxWidth,
          height: canvas.height * renderScale,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: ColoredBox(color: context.paletteColors.surfaceMuted),
                ),
              ),
              for (final item in items) _buildItem(item, renderScale),
            ],
          ),
        );
      },
    );
  }
}
