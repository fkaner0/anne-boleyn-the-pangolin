import 'package:flutter/material.dart';
import '../../domain/profile_image.dart';
import 'wiggle_hint.dart';

class BedroomWallImageItem extends StatelessWidget {
  static const double _baseWidth = 160;

  final ProfileImage image;
  final double renderScale;
  final VoidCallback onTap;
  final bool wiggle;

  const BedroomWallImageItem({
    super.key,
    required this.image,
    required this.renderScale,
    required this.onTap,
    this.wiggle = false,
  });

  @override
  Widget build(BuildContext context) {
    final position = image.position;
    final width = _baseWidth * renderScale * position.scale;
    final height =
        _baseWidth / position.aspectRatio * renderScale * position.scale;

    return Positioned(
      left: position.x * renderScale,
      top: position.y * renderScale,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Transform.rotate(
          angle: position.rotation,
          child: WiggleHint(
            enabled: wiggle,
            child: GestureDetector(
              onTap: onTap,
              child: SizedBox(
                width: width,
                height: height,
                child: Image.network(
                  image.url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Theme.of(context).colorScheme.outline,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, size: 40),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
