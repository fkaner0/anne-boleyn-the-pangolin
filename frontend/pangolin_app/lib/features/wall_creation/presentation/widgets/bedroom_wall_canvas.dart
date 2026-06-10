import 'package:flutter/material.dart';
import 'package:pangolin_app/fonts/font_catalog.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import 'package:pangolin_app/stickers/sticker_image.dart';
import '../../domain/canvas_item.dart';
import '../../domain/canvas_prompt.dart';
import '../../domain/canvas_transform.dart';
import '../../domain/virtual_canvas.dart';
import 'canvas_prompt_item.dart';
import 'editable_canvas_text_item.dart';
import 'interactive_canvas_item.dart';

class BedroomWallCanvas extends StatelessWidget {
  static const double _imageBaseWidth = 160;
  static const double _stickerBaseSize = 120;
  static const double _textBaseFontSize = 16;
  static const double _textMinWidth = 96;
  static const double _textMaxWidth = 240;
  static const double _promptImageBaseSize = 130;
  static const double _promptTextBaseWidth = 220;

  final VirtualCanvas canvas;
  final StickerCatalog stickerCatalog;
  final FontCatalog fontCatalog;
  final List<CanvasItem> items;
  final List<CanvasPrompt> prompts;
  final void Function(int id, CanvasTransform transform) onItemTransform;
  final void Function(int id, String text) onTextChanged;
  final void Function(int id, String? font) onFontChanged;
  final void Function(int id, Color? color) onTextColorChanged;
  final void Function(int id, Color? color) onTextBackgroundColorChanged;
  final Future<void> Function(int promptId) onPromptAddImage;
  final void Function(int promptId) onPromptAddTextBox;
  final void Function(int id, bool active) onItemInteractionChanged;
  final void Function(Offset globalPosition) onItemDragUpdate;
  final bool editable;
  final Color backgroundColor;

  const BedroomWallCanvas({
    super.key,
    required this.canvas,
    required this.stickerCatalog,
    required this.fontCatalog,
    required this.items,
    required this.prompts,
    required this.onItemTransform,
    required this.onTextChanged,
    required this.onFontChanged,
    required this.onTextColorChanged,
    required this.onTextBackgroundColorChanged,
    required this.onPromptAddImage,
    required this.onPromptAddTextBox,
    required this.onItemInteractionChanged,
    required this.onItemDragUpdate,
    required this.editable, 
    required this.backgroundColor,
  });

  CanvasTransform _toRendered(CanvasTransform transform, double renderScale) {
    return transform.copyWith(center: transform.center * renderScale);
  }

  CanvasTransform _toLogical(CanvasTransform transform, double renderScale) {
    return transform.copyWith(center: transform.center / renderScale);
  }

  Widget _imageChild(CanvasImageItem item) {
    final bytes = item.bytes;
    if (bytes != null) {
      return Image.memory(bytes, fit: BoxFit.cover);
    }

    final url = item.url;
    if (url != null && url.isNotEmpty) {
      return Image.network(url, fit: BoxFit.cover);
    }

    return const ColoredBox(color: Color(0x22000000));
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
        editable: editable,
        onInteractionChanged: (active) =>
            onItemInteractionChanged(item.id, active),
        onDragUpdate: onItemDragUpdate,
        child: _imageChild(item),
      ),
      CanvasStickerItem() => InteractiveCanvasItem(
        key: key,
        initialTransform: initialTransform,
        baseSize: Size.square(_stickerBaseSize) * renderScale,
        onTransformEnd: onEnd,
        editable: editable,
        onInteractionChanged: (active) =>
            onItemInteractionChanged(item.id, active),
        onDragUpdate: onItemDragUpdate,
        child: StickerImage(catalog: stickerCatalog, name: item.stickerName),
      ),
      CanvasTextItem() => EditableCanvasTextItem(
        key: key,
        initialTransform: initialTransform,
        baseFontSize: _textBaseFontSize * renderScale,
        minWidth: _textMinWidth * renderScale,
        maxWidth: _textMaxWidth * renderScale,
        text: item.text,
        font: item.font,
        textColor: item.textColor,
        backgroundColor: item.backgroundColor,
        fontCatalog: fontCatalog,
        editable: editable,
        onTransformEnd: onEnd,
        onTextChanged: (text) => onTextChanged(item.id, text),
        onFontChanged: (font) => onFontChanged(item.id, font),
        onTextColorChanged: (color) => onTextColorChanged(item.id, color),
        onTextBackgroundColorChanged: (color) =>
            onTextBackgroundColorChanged(item.id, color),
        onInteractionChanged: (active) =>
            onItemInteractionChanged(item.id, active),
        onDragUpdate: onItemDragUpdate,
      ),
    };
  }

  Widget _buildPrompt(CanvasPrompt prompt, double renderScale) {
    final transform = _toRendered(prompt.transform, renderScale);
    final baseWidth = switch (prompt.action) {
      CanvasPromptAction.addImage => _promptImageBaseSize * renderScale,
      CanvasPromptAction.addTextBox => _promptTextBaseWidth * renderScale,
    };

    return CanvasPromptItem(
      key: ValueKey('prompt_${prompt.id}'),
      transform: transform,
      label: prompt.label,
      action: prompt.action,
      baseWidth: baseWidth,
      onTap: switch (prompt.action) {
        CanvasPromptAction.addImage => () => onPromptAddImage(prompt.id),
        CanvasPromptAction.addTextBox => () => onPromptAddTextBox(prompt.id),
      },
    );
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
                  child: ColoredBox(
                    color: backgroundColor,
                  ),
                ),
              ),
              for (final prompt in prompts) _buildPrompt(prompt, renderScale),
              for (final item in items) _buildItem(item, renderScale),
            ],
          ),
        );
      },
    );
  }
}
