import 'dart:typed_data';

abstract interface class ImageCompressor {
  Future<Uint8List> compress(Uint8List bytes);
}
