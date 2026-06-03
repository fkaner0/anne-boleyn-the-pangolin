import 'package:flutter/material.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import 'package:pangolin_app/theme/palette_colors.dart';
import '../../domain/canvas_image_item.dart';
import '../../domain/canvas_sticker_item.dart';
import '../../domain/canvas_text_item.dart';
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
  final List<CanvasImageItem> imageItems;
  final List<CanvasStickerItem> stickerItems;
  final List<CanvasTextItem> textItems;
  final void Function(int id, CanvasTransform transform) onImageTransform;
  final void Function(int id, CanvasTransform transform) onStickerTransform;
  final void Function(int id, CanvasTransform transform) onTextTransform;
  final void Function(int id, String text) onTextChanged;

  const BedroomWallCanvas({
    super.key,
    required this.canvas,
    required this.stickerCatalog,
    required this.imageItems,
    required this.stickerItems,
    required this.textItems,
    required this.onImageTransform,
    required this.onStickerTransform,
    required this.onTextTransform,
    required this.onTextChanged,
  });

  CanvasTransform _toRendered(CanvasTransform transform, double renderScale) {
    return transform.copyWith(center: transform.center * renderScale);
  }

  CanvasTransform _toLogical(CanvasTransform transform, double renderScale) {
    return transform.copyWith(center: transform.center / renderScale);
  }

  Widget _stickerChild(CanvasStickerItem item) {
    final assetPath = stickerCatalog.assetForName(item.stickerName);
    if (assetPath == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            item.stickerName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(assetPath, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final renderScale = constraints.maxWidth / canvas.width;

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
              for (final item in imageItems)
                InteractiveCanvasItem(
                  key: ValueKey('image-${item.id}'),
                  initialTransform: _toRendered(item.transform, renderScale),
                  baseSize:
                      Size(
                        _imageBaseWidth,
                        _imageBaseWidth / item.aspectRatio,
                      ) *
                      renderScale,
                  onTransformEnd: (transform) => onImageTransform(
                    item.id,
                    _toLogical(transform, renderScale),
                  ),
                  child: Image.memory(item.bytes, fit: BoxFit.cover),
                ),
              for (final item in textItems)
                EditableCanvasTextItem(
                  key: ValueKey('text-${item.id}'),
                  initialTransform: _toRendered(item.transform, renderScale),
                  baseFontSize: _textBaseFontSize * renderScale,
                  minWidth: _textMinWidth * renderScale,
                  maxWidth: _textMaxWidth * renderScale,
                  text: item.text,
                  onTransformEnd: (transform) => onTextTransform(
                    item.id,
                    _toLogical(transform, renderScale),
                  ),
                  onTextChanged: (text) => onTextChanged(item.id, text),
                ),
              for (final item in stickerItems)
                InteractiveCanvasItem(
                  key: ValueKey('sticker-${item.id}'),
                  initialTransform: _toRendered(item.transform, renderScale),
                  baseSize: Size.square(_stickerBaseSize) * renderScale,
                  onTransformEnd: (transform) => onStickerTransform(
                    item.id,
                    _toLogical(transform, renderScale),
                  ),
                  child: _stickerChild(item),
                ),
            ],
          ),
        );
      },
    );
  }
}
