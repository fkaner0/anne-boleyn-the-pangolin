import 'dart:typed_data';

import 'package:flutter/material.dart';

class ImagePlaceholderBox extends StatelessWidget {
  const ImagePlaceholderBox({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}

class UploadingImagePlaceholder extends StatelessWidget {
  final Uint8List? bytes;

  const UploadingImagePlaceholder({super.key, this.bytes});

  @override
  Widget build(BuildContext context) {
    final preview = bytes;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (preview != null)
          Image.memory(preview, fit: BoxFit.cover)
        else
          const ImagePlaceholderBox(),
        const ColoredBox(
          color: Color(0x66000000),
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}

Widget imageLoadingPlaceholder(
  BuildContext context,
  Widget child,
  ImageChunkEvent? loadingProgress,
) {
  if (loadingProgress == null) return child;
  return const ImagePlaceholderBox();
}

class LoadingNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final ImageErrorWidgetBuilder? errorBuilder;

  const LoadingNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = Image.network(
      url,
      fit: fit,
      loadingBuilder: imageLoadingPlaceholder,
      errorBuilder: errorBuilder,
    );

    if (width != null || height != null) {
      image = SizedBox(width: width, height: height, child: image);
    }

    return image;
  }
}
