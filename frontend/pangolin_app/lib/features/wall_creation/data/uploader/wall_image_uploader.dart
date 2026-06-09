import 'dart:typed_data';

abstract interface class ImageUploader {
  Future<String> uploadImage(Uint8List bytes);
}
