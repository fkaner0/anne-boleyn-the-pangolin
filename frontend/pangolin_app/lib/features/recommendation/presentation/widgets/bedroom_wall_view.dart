import 'package:flutter/material.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import 'package:pangolin_app/theme/palette_colors.dart';
import '../../domain/profile.dart';
import '../../domain/profile_image.dart';
import '../../domain/profile_text.dart';
import 'bedroom_wall_image_item.dart';
import 'bedroom_wall_sticker_item.dart';
import 'bedroom_wall_textbox_item.dart';

class BedroomWallView extends StatelessWidget {
  final Profile profile;
  final StickerCatalog stickerCatalog;
  final void Function(ProfileImage) onImageTap;
  final void Function(ProfileText) onTextTap;

  const BedroomWallView({
    super.key,
    required this.profile,
    required this.stickerCatalog,
    required this.onImageTap,
    required this.onTextTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: context.paletteColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final image in profile.images)
            BedroomWallImageItem(image: image, onTap: () => onImageTap(image)),
          for (final textbox in profile.textboxes)
            BedroomWallTextBoxItem(
              textbox: textbox,
              onTap: () => onTextTap(textbox),
            ),
          for (final sticker in profile.stickers)
            BedroomWallStickerItem(sticker: sticker, catalog: stickerCatalog),
        ],
      ),
    );
  }
}
