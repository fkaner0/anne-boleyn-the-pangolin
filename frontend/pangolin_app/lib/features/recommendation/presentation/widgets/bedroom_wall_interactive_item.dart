import 'package:flutter/material.dart';

abstract class BedroomWallInteractiveBase extends StatelessWidget {
  final VoidCallback onTap;
  final double width;
  final double? height;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const BedroomWallInteractiveBase({
    super.key,
    required this.onTap,
    required this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.backgroundColor = Colors.white,
    this.border,
    this.boxShadow,
  });

  Widget buildInner(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: border,
          boxShadow:
              boxShadow ??
              const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            buildInner(context),
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.send, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
