import 'dart:typed_data';

import '../compressor/image_compressor.dart';
import 'wall_image_uploader.dart';

class CompressingImageUploader implements ImageUploader {
  final ImageUploader _inner;
  final ImageCompressor _compressor;

  const CompressingImageUploader(this._inner, this._compressor);

  @override
  Future<String> uploadImage(Uint8List bytes) async {
    await Future<void>.delayed(Duration.zero);
    final compressed = await _compressor.compress(bytes);
    return _inner.uploadImage(compressed);
  }
}
