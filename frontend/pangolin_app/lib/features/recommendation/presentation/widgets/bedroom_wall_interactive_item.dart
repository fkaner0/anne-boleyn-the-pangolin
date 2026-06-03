import 'package:flutter/material.dart';
import 'package:pangolin_app/theme/palette_colors.dart';

abstract class BedroomWallInteractiveBase extends StatelessWidget {
  final VoidCallback onTap;
  final double width;
  final double? height;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const BedroomWallInteractiveBase({
    super.key,
    required this.onTap,
    required this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.backgroundColor,
    this.border,
    this.boxShadow,
  });

  Widget buildInner(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final paletteColors = context.paletteColors;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? colorScheme.surface,
          borderRadius: borderRadius,
          border: border,
          boxShadow:
              boxShadow ??
              [
                BoxShadow(
                  color: paletteColors.shadow,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
        ),
        clipBehavior: Clip.none,
        child: Stack(
          children: [
            buildInner(context),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: paletteColors.overlay,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.send, size: 16, color: colorScheme.surface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
