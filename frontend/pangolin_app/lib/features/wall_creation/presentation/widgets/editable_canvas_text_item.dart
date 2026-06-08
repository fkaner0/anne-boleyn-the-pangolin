import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:pangolin_app/fonts/font_catalog.dart';
import 'package:pangolin_app/theme/palette_colors.dart';

import '../../domain/canvas_transform.dart';

class EditableCanvasTextItem extends StatefulWidget {
  final CanvasTransform initialTransform;
  final double baseFontSize;
  final double minWidth;
  final double maxWidth;
  final String text;
  final String? font;
  final FontCatalog fontCatalog;
  final Color? textColor;
  final Color? backgroundColor;
  final String placeholder;
  final bool editable;
  final void Function(CanvasTransform transform) onTransformEnd;
  final void Function(String text) onTextChanged;
  final void Function(String? font) onFontChanged;
  final void Function(Color? color) onTextColorChanged;
  final void Function(Color? color) onTextBackgroundColorChanged;
  final void Function(bool active)? onInteractionChanged;
  final void Function(Offset globalPosition)? onDragUpdate;
  final double minScale;
  final double maxScale;

  const EditableCanvasTextItem({
    super.key,
    required this.initialTransform,
    required this.baseFontSize,
    required this.minWidth,
    required this.maxWidth,
    required this.text,
    required this.fontCatalog,
    required this.editable,
    required this.onTransformEnd,
    required this.onTextChanged,
    required this.onFontChanged,
    required this.onTextColorChanged,
    required this.onTextBackgroundColorChanged,
    this.font,
    this.textColor,
    this.backgroundColor,
    this.onInteractionChanged,
    this.onDragUpdate,
    this.placeholder = 'Your text',
    this.minScale = 0.3,
    this.maxScale = 5.0,
  });

  @override
  State<EditableCanvasTextItem> createState() => _EditableCanvasTextItemState();
}

class _EditableCanvasTextItemState extends State<EditableCanvasTextItem> {
  static const double _hitSlop = 24.0;

  late final TextEditingController _controller = TextEditingController(
    text: widget.text,
  );
  final FocusNode _focusNode = FocusNode();

  late CanvasTransform _transform = widget.initialTransform;
  bool _editing = false;
  OverlayEntry? _overlayEntry;

  late String? _font = widget.font;
  late Color? _textColor = widget.textColor;
  late Color? _backgroundColor = widget.backgroundColor;

  bool _pickingColor = false;
  String _colorPickerTitle = '';
  Color _pendingColor = const Color(0xFF000000);
  void Function(Color)? _onColorPicked;

  bool _gesturing = false;
  Offset _startFocalPoint = Offset.zero;
  CanvasTransform _startTransform = const CanvasTransform(center: Offset.zero);

  void _refreshOverlay() {
    if (_overlayEntry == null) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _overlayEntry?.markNeedsBuild();
      });
    } else {
      _overlayEntry!.markNeedsBuild();
    }
  }

  @override
  void didUpdateWidget(EditableCanvasTextItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_gesturing && widget.initialTransform != oldWidget.initialTransform) {
      _transform = widget.initialTransform;
    }
    if (!_editing && widget.text != oldWidget.text) {
      _controller.text = widget.text;
    }
    if (widget.font != oldWidget.font) {
      _font = widget.font;
      _refreshOverlay();
    }
    if (widget.textColor != oldWidget.textColor) {
      _textColor = widget.textColor;
      _refreshOverlay();
    }
    if (widget.backgroundColor != oldWidget.backgroundColor) {
      _backgroundColor = widget.backgroundColor;
      _refreshOverlay();
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _startEditing() {
    if (_editing) return;
    setState(() => _editing = true);
    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _focusNode.requestFocus();
  }

  void _stopEditing() {
    if (!_editing) return;
    _editing = false;
    widget.onTextChanged(_controller.text);
    _overlayEntry?.remove();
    _overlayEntry = null;
    _focusNode.unfocus();
    if (mounted) setState(() {});
  }

  void _onScaleStart(ScaleStartDetails details) {
    _gesturing = true;
    _startFocalPoint = details.focalPoint;
    _startTransform = _transform;
    widget.onInteractionChanged?.call(true);
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    widget.onDragUpdate?.call(details.focalPoint);
    setState(() {
      _transform = _startTransform.copyWith(
        center:
            _startTransform.center + (details.focalPoint - _startFocalPoint),
        scale: (_startTransform.scale * details.scale).clamp(
          widget.minScale,
          widget.maxScale,
        ),
        rotation: _startTransform.rotation + details.rotation,
      );
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _gesturing = false;
    widget.onTransformEnd(_transform);
    widget.onInteractionChanged?.call(false);
  }

  void _cycleFont() {
    final nextFont = widget.fontCatalog.next(_font);
    setState(() => _font = nextFont);
    widget.onFontChanged(nextFont);
    _refreshOverlay();
    _focusNode.requestFocus();
  }

  void _pickColor(
    Color? defaultVal,
    String dialogText,
    void Function(Color) onColorChange,
  ) {
    if (_pickingColor) return;
    _focusNode.unfocus();
    _pickingColor = true;
    _colorPickerTitle = dialogText;
    _pendingColor = defaultVal ?? Theme.of(context).colorScheme.onSurface;
    _onColorPicked = onColorChange;
    _refreshOverlay();
  }

  void _finishPickColor() {
    if (!_pickingColor) return;
    final onPicked = _onColorPicked;
    final color = _pendingColor;
    _pickingColor = false;
    _onColorPicked = null;
    onPicked?.call(color);
    _refreshOverlay();
    _focusNode.requestFocus();
  }

  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

        // The effective text colour to show on the swatch button.
        final effectiveTextColor = _textColor ?? colorScheme.onSurface;
        final effectiveBackgroundColor =
            _backgroundColor ?? colorScheme.surface;

        const double buttonsBufferSize = 8;
        const double edgeBufferSize = 12;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _stopEditing,
                child: ColoredBox(color: context.paletteColors.overlay),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: keyboardInset,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: buttonsBufferSize,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(edgeBufferSize),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: buttonsBufferSize,
                      children: [
                        _TextColorSwatchButton(
                          color: effectiveTextColor,
                          onTap: () =>
                              _pickColor(_textColor, 'Text Colour', (color) {
                                setState(() => _textColor = color);
                                widget.onTextColorChanged(color);
                              }),
                        ),
                        _TextBackgroundColorSwatchButton(
                          color: effectiveBackgroundColor,
                          onTap: () => _pickColor(
                            _backgroundColor,
                            'Text Background Colour',
                            (color) {
                              setState(() => _backgroundColor = color);
                              widget.onTextBackgroundColorChanged(color);
                            },
                          ),
                        ),
                        _TextFontCycleButton(
                          colorScheme: colorScheme,
                          onTap: _cycleFont,
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: Color.alphaBlend(
                      effectiveBackgroundColor,
                      colorScheme.surface,
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(edgeBufferSize),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              readOnly: !widget.editable,
                              controller: _controller,
                              focusNode: _focusNode,
                              onChanged: widget.onTextChanged,
                              onSubmitted: (_) => _stopEditing(),
                              maxLines: null,
                              textInputAction: TextInputAction.done,
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: _font,
                                color: effectiveTextColor,
                              ),
                              decoration: InputDecoration(
                                hintText: widget.placeholder,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _stopEditing,
                            icon: const Icon(Icons.check),
                            tooltip: 'Done',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_pickingColor)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _finishPickColor,
                  child: ColoredBox(
                    color: Colors.black54,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: AlertDialog(
                          title: Text(_colorPickerTitle),
                          content: ColorPicker(
                            pickerColor: _pendingColor,
                            onColorChanged: (color) => _pendingColor = color,
                          ),
                          actions: [
                            TextButton(
                              onPressed: _finishPickColor,
                              child: const Text('Done'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final scale = _transform.scale;

    // Resolve the display colour: prefer explicit colour, fall back to theme.
    final resolvedTextColor = _textColor ?? colorScheme.onSurface;
    final resolvedBackgroundColor = _backgroundColor ?? colorScheme.surface;

    final textStyle = TextStyle(
      fontSize: widget.baseFontSize * scale,
      fontFamily: _font,
      color: resolvedTextColor,
    );
    final text = _controller.text;

    final box = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: widget.minWidth * scale,
        maxWidth: widget.maxWidth * scale,
      ),
      child: IntrinsicWidth(
        child: Container(
          padding: EdgeInsets.all(8 * scale),
          decoration: BoxDecoration(
            color: resolvedBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.editable && text.isEmpty ? widget.placeholder : text,
            textAlign: TextAlign.center,
            style: text.isEmpty
                ? textStyle.copyWith(color: colorScheme.onSurfaceVariant)
                : textStyle,
          ),
        ),
      ),
    );

    return Positioned(
      left: _transform.center.dx,
      top: _transform.center.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Transform.rotate(
          angle: _transform.rotation,
          child: Opacity(
            opacity: _editing ? 0.0 : 1.0,
            child: widget.editable
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _startEditing,
                    onScaleStart: _onScaleStart,
                    onScaleUpdate: _onScaleUpdate,
                    onScaleEnd: _onScaleEnd,
                    child: Padding(
                      padding: const EdgeInsets.all(_hitSlop),
                      child: box,
                    ),
                  )
                : box,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Private helper widgets
// =============================================================================

/// A small circular button showing the current text colour.
/// Tapping it opens the colour picker.
class _TextColorSwatchButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _TextColorSwatchButton({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Use a contrasting background so the colour change is visible on any background.
    final Color bgCol = _getContrastColorWithAlpha(color);

    return _buttonFromIcon(Icons.format_color_text, bgCol, color, onTap);
  }
}

class _TextBackgroundColorSwatchButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _TextBackgroundColorSwatchButton({
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use a contrasting background so the colour change is visible on any background.
    final Color fgCol = _getContrastColorWithAlpha(color);

    return _buttonFromIcon(Icons.text_fields, color, fgCol, onTap);
  }
}

class _TextFontCycleButton extends StatelessWidget {
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _TextFontCycleButton({required this.colorScheme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _buttonFromIcon(
      Symbols.brand_family_rounded,
      colorScheme.surface.withAlpha(20),
      colorScheme.onSurface,
      onTap,
    );
  }
}

/// HELPERS /////

Color _getContrastColorWithAlpha(Color color) {
  return ThemeData.estimateBrightnessForColor(color) == Brightness.light
      ? const Color.fromARGB(165, 0, 0, 0)
      : const Color.fromARGB(163, 255, 255, 255);
}

GestureDetector _buttonFromIcon(
  IconData icon,
  Color backgroundCol,
  Color foregroundCol,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: backgroundCol,
        shape: BoxShape.circle,
        border: Border.all(color: foregroundCol, width: 2),
      ),
      child: Center(child: Icon(icon, color: foregroundCol, size: 30)),
    ),
  );
}
