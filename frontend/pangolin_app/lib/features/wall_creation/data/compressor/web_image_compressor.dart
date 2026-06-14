import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'image_compressor.dart';

ImageCompressor createImageCompressor({
  int maxDimension = 2048,
  int quality = 85,
}) => WebImageCompressor(maxDimension: maxDimension, quality: quality);

class WebImageCompressor implements ImageCompressor {
  final int maxDimension;
  final int quality;

  const WebImageCompressor({this.maxDimension = 2048, this.quality = 85});

  @override
  Future<Uint8List> compress(Uint8List bytes) async {
    final source = web.Blob(<JSAny>[bytes.toJS].toJS);
    final bitmap = await web.window.createImageBitmap(source).toDart;

    try {
      final longestSide = bitmap.width > bitmap.height
          ? bitmap.width
          : bitmap.height;
      final scale = longestSide > maxDimension
          ? maxDimension / longestSide
          : 1.0;
      final targetWidth = (bitmap.width * scale).round();
      final targetHeight = (bitmap.height * scale).round();

      final canvas = web.OffscreenCanvas(targetWidth, targetHeight);
      final context =
          canvas.getContext('2d') as web.OffscreenCanvasRenderingContext2D?;
      if (context == null) return bytes;

      context.drawImage(
        bitmap,
        0,
        0,
        targetWidth.toDouble(),
        targetHeight.toDouble(),
      );

      final encoded = await canvas
          .convertToBlob(
            web.ImageEncodeOptions(type: 'image/jpeg', quality: quality / 100),
          )
          .toDart;
      final buffer = await encoded.arrayBuffer().toDart;
      final result = buffer.toDart.asUint8List();

      return result.length < bytes.length ? result : bytes;
    } finally {
      bitmap.close();
    }
  }
}
