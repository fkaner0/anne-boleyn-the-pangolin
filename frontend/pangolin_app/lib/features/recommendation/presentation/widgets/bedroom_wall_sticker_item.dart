import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/profile_sticker.dart';

class BedroomWallStickerItem extends StatelessWidget {
  static const double _baseSize = 120;

  final ProfileSticker sticker;
  final String assetPath;

  const BedroomWallStickerItem({
    super.key,
    required this.sticker,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    final position = sticker.position;

    return Positioned(
      left: position.x.toDouble(),
      top: position.y.toDouble(),
      child: Transform.rotate(
        angle: position.rotation * math.pi / 180,
        child: SizedBox(
          width: _baseSize * position.scale * position.aspectRatio,
          height: _baseSize * position.scale,
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
