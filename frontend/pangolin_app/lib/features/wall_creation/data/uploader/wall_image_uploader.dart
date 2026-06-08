import 'dart:typed_data';

abstract interface class WallImageUploader {
  Future<String> uploadImage(Uint8List bytes);
}
