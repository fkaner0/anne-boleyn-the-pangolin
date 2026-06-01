import 'package:flutter/material.dart';
import '../../domain/profile.dart';
import '../../domain/profile_image.dart';
import '../../domain/profile_text.dart';
import 'bedroom_wall_image_item.dart';
import 'bedroom_wall_textbox_item.dart';

class BedroomWallView extends StatelessWidget {
  final Profile profile;
  final void Function(ProfileImage) onImageTap;
  final void Function(ProfileText) onTextTap;

  const BedroomWallView({
    super.key,
    required this.profile,
    required this.onImageTap,
    required this.onTextTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          for (final image in profile.images)
            BedroomWallImageItem(image: image, onTap: () => onImageTap(image)),
          for (final textbox in profile.textboxes)
            BedroomWallTextBoxItem(
              textbox: textbox,
              onTap: () => onTextTap(textbox),
            ),
        ],
      ),
    );
  }
}
