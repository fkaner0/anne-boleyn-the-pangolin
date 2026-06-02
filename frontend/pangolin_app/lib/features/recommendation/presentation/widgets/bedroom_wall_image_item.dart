import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/profile_image.dart';
import 'bedroom_wall_interactive_item.dart';

class BedroomWallImageItem extends BedroomWallInteractiveBase {
  static const double _baseSize = 160;

  final ProfileImage image;

  BedroomWallImageItem({super.key, required this.image, required super.onTap})
    : super(
        width: _baseSize * image.position.scale * image.position.aspectRatio,
        height: _baseSize * image.position.scale,
      );

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: image.position.x.toDouble(),
      top: image.position.y.toDouble(),
      child: Transform.rotate(
        angle: image.position.rotation * math.pi / 180,
        child: super.build(context),
      ),
    );
  }

  @override
  Widget buildInner(BuildContext context) {
    return SizedBox.expand(
      child: Image.network(
        image.url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, size: 40),
          );
        },
      ),
    );
  }
}
