import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pangolin_app/theme/palette_colors.dart';

import '../../domain/canvas_transform.dart';

class EditableCanvasTextItem extends StatefulWidget {
  final CanvasTransform initialTransform;
  final double baseFontSize;
  final double minWidth;
  final double maxWidth;
  final String text;
  final String? font;
  final Color? textColor;
  final Color? backgroundColor;
  final String placeholder;
  final void Function(CanvasTransform transform) onTransformEnd;
  final void Function(String text) onTextChanged;
  final void Function(String? font) onFontChanged;
  final void Function(Color? color) onTextColorChanged;
  final void Function(Color? color) onTextBackgroundColorChanged;
  final double minScale;
  final double maxScale;

  const EditableCanvasTextItem({
    super.key,
    required this.initialTransform,
    required this.baseFontSize,
    required this.minWidth,
    required this.maxWidth,
    required this.text,
    required this.onTransformEnd,
    required this.onTextChanged,
    required this.onFontChanged,
    required this.onTextColorChanged,
    required this.onTextBackgroundColorChanged,
    this.font,
    this.textColor,
    this.backgroundColor,
    this.placeholder = 'Your text',
    this.minScale = 0.3,
    this.maxScale = 5.0,
  });

  @override
  State<EditableCanvasTextItem> createState() => _EditableCanvasTextItemState();
}

class _EditableCanvasTextItemState extends State<EditableCanvasTextItem> {
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

  bool _gesturing = false;
  Offset _startFocalPoint = Offset.zero;
  CanvasTransform _startTransform = const CanvasTransform(center: Offset.zero);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _refreshOverlay() {
    _overlayEntry?.markNeedsBuild();
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
    _focusNode.removeListener(_onFocusChange);
    _overlayEntry?.remove();
    _overlayEntry = null;
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _editing) {
      _stopEditing();
    }
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
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
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
  }

  Future<void> _pickColor() async {
    _focusNode.unfocus();
    Color pickerColor = _textColor ?? Theme.of(context).colorScheme.onSurface;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Text colour'),
        content: ColorPicker(
          pickerColor: pickerColor,
          onColorChanged: (color) => pickerColor = color,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    setState(() => _textColor = pickerColor);
    widget.onTextColorChanged(pickerColor);
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
        final effectivebackgroundColor =
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
                          onTap: _pickColor,
                        ),
                        // _TextBackgroundColorSwatchButton(
                        //   color: effectivebackgroundColor,
                        //   onTap: _pickColor,
                        // ),
                      ],
                    ),
                  ),
                  Material(
                    color: colorScheme.surface,
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(edgeBufferSize),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              onChanged: widget.onTextChanged,
                              onSubmitted: (_) => _stopEditing(),
                              maxLines: null,
                              textInputAction: TextInputAction.done,
                              style: TextStyle(
                                fontSize: 18,
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
    final resolvedColor = _textColor ?? colorScheme.onSurface;

    final textStyle = TextStyle(
      fontSize: widget.baseFontSize * scale,
      color: resolvedColor,
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
            color: colorScheme.surface,
            border: Border.all(color: colorScheme.outline),
            borderRadius: BorderRadius.circular(8 * scale),
          ),
          child: Text(
            text.isEmpty ? widget.placeholder : text,
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
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _startEditing,
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              onScaleEnd: _onScaleEnd,
              child: box,
            ),
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

// class _TextBackgroundColorSwatchButton extends StatelessWidget {
//   final Color color;
//   final VoidCallback onTap;

//   const _TextBackgroundColorSwatchButton({
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Use a contrasting background so the colour change is visible on any background.
//     final Color fgCol = _getContrastColorWithAlpha(color);

//     return _buttonFromIcon(Icons.text_fields, color, fgCol, onTap);
//   }
// }

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
