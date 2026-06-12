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
