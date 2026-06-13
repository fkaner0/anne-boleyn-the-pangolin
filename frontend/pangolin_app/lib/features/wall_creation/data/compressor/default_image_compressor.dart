import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import 'image_compressor.dart';

ImageCompressor createImageCompressor({
  int maxDimension = 2048,
  int quality = 85,
}) => DefaultImageCompressor(maxDimension: maxDimension, quality: quality);

class DefaultImageCompressor implements ImageCompressor {
  final int maxDimension;
  final int quality;

  const DefaultImageCompressor({this.maxDimension = 2048, this.quality = 85});

  @override
  Future<Uint8List> compress(Uint8List bytes) {
    return compute(
      _compress,
      _CompressionRequest(
        bytes: bytes,
        maxDimension: maxDimension,
        quality: quality,
      ),
    );
  }
}

class _CompressionRequest {
  final Uint8List bytes;
  final int maxDimension;
  final int quality;

  const _CompressionRequest({
    required this.bytes,
    required this.maxDimension,
    required this.quality,
  });
}

Uint8List _compress(_CompressionRequest request) {
  final decoded = img.decodeImage(request.bytes);
  if (decoded == null) return request.bytes;

  final longestSide = decoded.width > decoded.height
      ? decoded.width
      : decoded.height;

  if (longestSide > request.maxDimension) {
    final resized = decoded.width >= decoded.height
        ? img.copyResize(decoded, width: request.maxDimension)
        : img.copyResize(decoded, height: request.maxDimension);
    return img.encodeJpg(resized, quality: request.quality);
  }

  final encoded = img.encodeJpg(decoded, quality: request.quality);
  return encoded.length < request.bytes.length ? encoded : request.bytes;
}
