import 'package:flutter/material.dart';
import '../../domain/profile.dart';
import 'bedroom_wall_image_item.dart';
import 'bedroom_wall_textbox_item.dart';

class BedroomWallView extends StatelessWidget {
  final Profile profile;

  const BedroomWallView({super.key, required this.profile});

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
            BedroomWallImageItem(image: image),
          for (final textbox in profile.textboxes)
            BedroomWallTextBoxItem(textbox: textbox),
        ],
      ),
    );
  }
}
