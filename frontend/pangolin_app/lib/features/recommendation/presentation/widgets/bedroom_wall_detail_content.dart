import 'package:flutter/material.dart';
import '../../domain/profile_image.dart';
import '../../domain/profile_text.dart';

class BedroomWallDetailContent extends StatelessWidget {
  final ProfileImage? image;
  final ProfileText? textbox;

  const BedroomWallDetailContent({super.key, this.image, this.textbox})
    : assert(
        image != null || textbox != null,
        'Either image or textbox must be provided.',
      );

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return SizedBox(
        width: double.infinity,
        height: 320,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            image!.url,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 300,
                color: Colors.grey.shade300,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image, size: 48),
              );
            },
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          textbox!.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(textbox!.body, style: const TextStyle(fontSize: 18, height: 1.4)),
      ],
    );
  }
}
