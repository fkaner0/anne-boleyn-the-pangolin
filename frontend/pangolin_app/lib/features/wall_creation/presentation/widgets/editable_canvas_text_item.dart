import 'package:flutter/material.dart';
import 'package:pangolin_app/theme/palette_colors.dart';

import '../../domain/canvas_transform.dart';

class EditableCanvasTextItem extends StatefulWidget {
  final CanvasTransform initialTransform;
  final double baseFontSize;
  final double minWidth;
  final double maxWidth;
  final String text;
  final String placeholder;
  final bool editable;
  final void Function(CanvasTransform transform) onTransformEnd;
  final void Function(String text) onTextChanged;
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
    required this.editable,
    required this.onTransformEnd,
    required this.onTextChanged,
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

  bool _gesturing = false;
  Offset _startFocalPoint = Offset.zero;
  CanvasTransform _startTransform = const CanvasTransform(center: Offset.zero);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
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

  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

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
              child: Material(
                color: colorScheme.surface,
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(12),
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
                            color: colorScheme.onSurface,
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
    final textStyle = TextStyle(
      fontSize: widget.baseFontSize * scale,
      color: colorScheme.onSurface,
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
            widget.editable ? (text.isEmpty ? widget.placeholder : text) : '',
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
                : Padding(padding: const EdgeInsets.all(_hitSlop), child: box),
          ),
        ),
      ),
    );
  }
}
