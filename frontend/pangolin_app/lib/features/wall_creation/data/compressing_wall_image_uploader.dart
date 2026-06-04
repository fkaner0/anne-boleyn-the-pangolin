import 'dart:typed_data';

import 'image_compressor.dart';
import 'wall_image_uploader.dart';

class CompressingWallImageUploader implements WallImageUploader {
  final WallImageUploader _inner;
  final ImageCompressor _compressor;

  const CompressingWallImageUploader(this._inner, this._compressor);

  @override
  Future<String> uploadImage(Uint8List bytes) async {
    final compressed = await _compressor.compress(bytes);
    return _inner.uploadImage(compressed);
  }
}
