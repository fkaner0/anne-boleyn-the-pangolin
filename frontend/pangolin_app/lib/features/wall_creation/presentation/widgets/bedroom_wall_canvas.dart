import 'package:flutter/material.dart';
import 'package:pangolin_app/theme/palette_colors.dart';
import '../../domain/canvas_image_item.dart';
import '../../domain/virtual_canvas.dart';
import 'interactive_canvas_item.dart';

class BedroomWallCanvas extends StatelessWidget {
  static const double _imageBaseWidth = 160;

  final VirtualCanvas canvas;
  final List<CanvasImageItem> imageItems;
  final void Function(int id, Offset center, double scale) onImageTransform;

  const BedroomWallCanvas({
    super.key,
    required this.canvas,
    required this.imageItems,
    required this.onImageTransform,
  });

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
                child: ColoredBox(color: context.paletteColors.surfaceMuted),
              ),
              for (final item in imageItems)
                InteractiveCanvasItem(
                  key: ValueKey(item.id),
                  initialCenter: item.center * renderScale,
                  initialScale: item.scale,
                  baseSize:
                      Size(
                        _imageBaseWidth,
                        _imageBaseWidth / item.aspectRatio,
                      ) *
                      renderScale,
                  onTransformEnd: (center, scale) =>
                      onImageTransform(item.id, center / renderScale, scale),
                  child: Image.memory(item.bytes, fit: BoxFit.cover),
                ),
            ],
          ),
        );
      },
    );
  }
}
