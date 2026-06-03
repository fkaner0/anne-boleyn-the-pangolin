import 'package:flutter/material.dart';

import '../../domain/canvas_transform.dart';

class EditableCanvasTextItem extends StatefulWidget {
  final CanvasTransform initialTransform;
  final double baseFontSize;
  final double maxWidth;
  final String text;
  final String placeholder;
  final void Function(CanvasTransform transform) onTransformEnd;
  final void Function(String text) onTextChanged;
  final double minScale;
  final double maxScale;

  const EditableCanvasTextItem({
    super.key,
    required this.initialTransform,
    required this.baseFontSize,
    required this.maxWidth,
    required this.text,
    required this.onTransformEnd,
    required this.onTextChanged,
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
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _editing) {
      setState(() => _editing = false);
      widget.onTextChanged(_controller.text);
    }
  }

  void _enterEdit() {
    setState(() => _editing = true);
    _focusNode.requestFocus();
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final scale = _transform.scale;
    final textStyle = TextStyle(
      fontSize: widget.baseFontSize * scale,
      color: colorScheme.onSurface,
    );

    final Widget inner;
    if (_editing) {
      inner = TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onTextChanged,
        maxLines: null,
        textAlign: TextAlign.center,
        style: textStyle,
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: widget.placeholder,
          hintStyle: textStyle.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      );
    } else {
      final text = _controller.text;
      inner = Text(
        text.isEmpty ? widget.placeholder : text,
        textAlign: TextAlign.center,
        style: text.isEmpty
            ? textStyle.copyWith(color: colorScheme.onSurfaceVariant)
            : textStyle,
      );
    }

    final box = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.maxWidth * scale),
      child: Container(
        padding: EdgeInsets.all(8 * scale),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(8 * scale),
        ),
        child: inner,
      ),
    );

    return Positioned(
      left: _transform.center.dx,
      top: _transform.center.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Transform.rotate(
          angle: _transform.rotation,
          child: _editing
              ? box
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _enterEdit,
                  onScaleStart: _onScaleStart,
                  onScaleUpdate: _onScaleUpdate,
                  onScaleEnd: _onScaleEnd,
                  child: box,
                ),
        ),
      ),
    );
  }
}
