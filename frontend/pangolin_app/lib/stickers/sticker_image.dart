import 'package:flutter/material.dart';

import 'sticker_catalog.dart';

class StickerImage extends StatelessWidget {
  final StickerCatalog catalog;
  final String name;

  const StickerImage({super.key, required this.catalog, required this.name});

  @override
  Widget build(BuildContext context) {
    final assetPath = catalog.assetForName(name);
    if (assetPath == null) return const SizedBox.shrink();

    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
