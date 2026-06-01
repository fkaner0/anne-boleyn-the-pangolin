import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/profile_image.dart';

class BedroomWallImageItem extends StatelessWidget {
  final ProfileImage image;

  const BedroomWallImageItem({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: image.position.x.toDouble(),
      top: image.position.y.toDouble(),
      child: Transform.rotate(
        angle: image.position.rotation * math.pi / 180,
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
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
        ),
      ),
    );
  }
}
