import 'package:flutter/material.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import 'package:pangolin_app/stickers/sticker_image.dart';
import '../../domain/profile_sticker.dart';

class BedroomWallStickerItem extends StatelessWidget {
  static const double _baseSize = 120;

  final ProfileSticker sticker;
  final StickerCatalog catalog;
  final double renderScale;

  const BedroomWallStickerItem({
    super.key,
    required this.sticker,
    required this.catalog,
    required this.renderScale,
  });

  @override
  Widget build(BuildContext context) {
    final position = sticker.position;
    final size = _baseSize * renderScale * position.scale;

    return Positioned(
      left: position.x * renderScale,
      top: position.y * renderScale,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Transform.rotate(
          angle: position.rotation,
          child: SizedBox(
            width: size,
            height: size,
            child: StickerImage(catalog: catalog, name: sticker.name),
          ),
        ),
      ),
    );
  }
}
