import 'dart:math';

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

class BedroomWallView extends StatefulWidget {
  final Profile profile;
  final StickerCatalog stickerCatalog;
  final FontCatalog fontCatalog;
  final void Function(ProfileImage) onImageTap;
  final void Function(ProfileText) onTextTap;
  final bool enableWiggle;

  const BedroomWallView({
    super.key,
    required this.profile,
    required this.stickerCatalog,
    required this.fontCatalog,
    required this.onImageTap,
    required this.onTextTap,
    this.enableWiggle = true,
  });

  @override
  State<BedroomWallView> createState() => _BedroomWallViewState();
}

class _BedroomWallViewState extends State<BedroomWallView> {
  int? _wiggleTarget;

  @override
  void initState() {
    super.initState();
    _wiggleTarget = _pickWiggleTarget();
  }

  @override
  void didUpdateWidget(BedroomWallView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile != oldWidget.profile) {
      _wiggleTarget = _pickWiggleTarget();
    }
  }

  int? _pickWiggleTarget() {
    if (!widget.enableWiggle) return null;
    final interactableCount =
        widget.profile.images.length + widget.profile.textboxes.length;
    if (interactableCount == 0) return null;
    return Random().nextInt(interactableCount);
  }

  @override
  Widget build(BuildContext context) {
    const canvasWidth = VirtualCanvas.defaultWidth;
    const canvasHeight = VirtualCanvas.defaultHeight;

    final profile = widget.profile;
    final imageCount = profile.images.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final renderScale = constraints.maxWidth / canvasWidth;

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
                for (final (index, image) in profile.images.indexed)
                  BedroomWallImageItem(
                    image: image,
                    renderScale: renderScale,
                    onTap: () => widget.onImageTap(image),
                    wiggle: _wiggleTarget == index,
                  ),
                for (final (index, textbox) in profile.textboxes.indexed)
                  BedroomWallTextBoxItem(
                    textbox: textbox,
                    renderScale: renderScale,
                    onTap: () => widget.onTextTap(textbox),
                    wiggle: _wiggleTarget == imageCount + index,
                  ),
                for (final sticker in profile.stickers)
                  BedroomWallStickerItem(
                    sticker: sticker,
                    catalog: widget.stickerCatalog,
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
