import 'package:flutter/material.dart';

import '../../domain/canvas_prompt.dart';
import '../../domain/canvas_transform.dart';

class CanvasPromptItem extends StatelessWidget {
  final CanvasTransform transform;
  final String label;
  final CanvasPromptAction action;
  final double baseWidth;
  final VoidCallback onTap;

  const CanvasPromptItem({
    super.key,
    required this.transform,
    required this.label,
    required this.action,
    required this.baseWidth,
    required this.onTap,
  });

  double get _width => baseWidth * transform.scale;
  double get _height =>
      action == CanvasPromptAction.addImage ? _width : _width * 0.44;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary.withValues(alpha: 0.75);

    return Positioned(
      left: transform.center.dx,
      top: transform.center.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Transform.rotate(
          angle: transform.rotation,
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: CustomPaint(
              painter: _DashedRectPainter(color: color),
              child: ClipRect(
                child: SizedBox(
                  width: _width,
                  height: _height,
                  child: Padding(
                    padding: EdgeInsets.all(_width * 0.08),
                    child: action == CanvasPromptAction.addImage
                        ? _ImageContent(label: label, color: color)
                        : _TextContent(label: label, color: color),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageContent extends StatelessWidget {
  final String label;
  final Color color;

  const _ImageContent({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add, color: color, size: 26),
        const SizedBox(height: 6),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
            style: TextStyle(color: color, fontSize: 11, height: 1.3),
          ),
        ),
      ],
    );
  }
}

class _TextContent extends StatelessWidget {
  final String label;
  final Color color;

  const _TextContent({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;

  const _DashedRectPainter({required this.color});

  static const double _dash = 5;
  static const double _gap = 4;
  static const double _strokeWidth = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawDashedLine(canvas, Offset.zero, Offset(size.width, 0), paint);
    _drawDashedLine(
      canvas,
      Offset(size.width, 0),
      Offset(size.width, size.height),
      paint,
    );
    _drawDashedLine(
      canvas,
      Offset(size.width, size.height),
      Offset(0, size.height),
      paint,
    );
    _drawDashedLine(canvas, Offset(0, size.height), Offset.zero, paint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final dir = end - start;
    final len = dir.distance;
    if (len == 0) return;
    final unit = dir / len;
    double pos = 0;
    bool drawing = true;
    while (pos < len) {
      final seg = drawing ? _dash : _gap;
      if (drawing) {
        canvas.drawLine(
          start + unit * pos,
          start + unit * (pos + seg).clamp(0.0, len),
          paint,
        );
      }
      pos += seg;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(_DashedRectPainter old) => old.color != color;
}
