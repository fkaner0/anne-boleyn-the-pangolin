import 'package:flutter/material.dart';
import '../../domain/profile_image.dart';
import 'message_send_badge.dart';

class BedroomWallImageItem extends StatelessWidget {
  static const double _baseWidth = 160;

  final ProfileImage image;
  final double renderScale;
  final VoidCallback onTap;

  const BedroomWallImageItem({
    super.key,
    required this.image,
    required this.renderScale,
    required this.onTap,
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
          child: GestureDetector(
            onTap: onTap,
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                children: [
                  Positioned.fill(
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
                  const Positioned(
                    right: 8,
                    bottom: 8,
                    child: MessageSendBadge(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
