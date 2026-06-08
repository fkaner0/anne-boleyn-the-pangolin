import 'package:flutter/material.dart';
import 'package:pangolin_app/features/wall_creation/domain/virtual_canvas.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import 'package:pangolin_app/fonts/font_catalog.dart';
import 'package:pangolin_app/theme/palette_colors.dart';
import 'package:pangolin_app/widgets/pinch_to_zoom.dart';
import '../../domain/profile.dart';
import '../../domain/profile_image.dart';
import '../../domain/profile_text.dart';
import 'bedroom_wall_image_item.dart';
import 'bedroom_wall_sticker_item.dart';
import 'bedroom_wall_textbox_item.dart';

class BedroomWallView extends StatelessWidget {
  final Profile profile;
  final StickerCatalog stickerCatalog;
  final FontCatalog fontCatalog;
  final void Function(ProfileImage) onImageTap;
  final void Function(ProfileText) onTextTap;

  const BedroomWallView({
    super.key,
    required this.profile,
    required this.stickerCatalog,
    required this.fontCatalog,
    required this.onImageTap,
    required this.onTextTap,
  });

  @override
  Widget build(BuildContext context) {
    const canvasWidth = VirtualCanvas.defaultWidth;
    const canvasHeight = VirtualCanvas.defaultHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final renderScale = constraints.maxHeight.isFinite
            ? (constraints.maxWidth / canvasWidth).clamp(
                0.0,
                constraints.maxHeight / canvasHeight,
              )
            : constraints.maxWidth / canvasWidth;

        return PinchToZoom(
          child: SizedBox(
            width: constraints.maxWidth,
            height: canvasHeight * renderScale,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ColoredBox(color: context.paletteColors.surfaceMuted),
                ),
                for (final image in profile.images)
                  BedroomWallImageItem(
                    image: image,
                    renderScale: renderScale,
                    onTap: () => onImageTap(image),
                  ),
                for (final textbox in profile.textboxes)
                  BedroomWallTextBoxItem(
                    textbox: textbox,
                    renderScale: renderScale,
                    onTap: () => onTextTap(textbox),
                  ),
                for (final sticker in profile.stickers)
                  BedroomWallStickerItem(
                    sticker: sticker,
                    catalog: stickerCatalog,
                    renderScale: renderScale,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
