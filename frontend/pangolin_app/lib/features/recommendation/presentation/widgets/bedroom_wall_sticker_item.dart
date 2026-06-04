import 'package:flutter/material.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import 'package:pangolin_app/stickers/sticker_image.dart';
import '../../domain/profile_sticker.dart';

class BedroomWallStickerItem extends StatelessWidget {
  static const double _baseSize = 120;

  final ProfileSticker sticker;
  final StickerCatalog catalog;

  const BedroomWallStickerItem({
    super.key,
    required this.sticker,
    required this.catalog,
  });

  @override
  Widget build(BuildContext context) {
    final position = sticker.position;

    return Positioned(
      left: position.x.toDouble(),
      top: position.y.toDouble(),
      child: Transform.rotate(
        angle: position.rotation,
        child: SizedBox(
          width: _baseSize * position.scale * position.aspectRatio,
          height: _baseSize * position.scale,
          child: StickerImage(catalog: catalog, name: sticker.name),
        ),
      ),
    );
  }
}
