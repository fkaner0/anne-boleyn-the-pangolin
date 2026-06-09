import 'package:flutter/material.dart';

class MainImagePicker extends StatelessWidget {
  final ImageProvider? image;
  final bool uploading;
  final VoidCallback? onTap;

  const MainImagePicker({
    super.key,
    required this.image,
    required this.uploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null)
              Image(image: image!, fit: BoxFit.cover)
            else
              Icon(Icons.add, size: 48, color: colorScheme.outline),
            if (uploading)
              const ColoredBox(
                color: Color(0x66000000),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
