import 'dart:typed_data';

class PickedImage {
  final Uint8List bytes;
  final double aspectRatio;

  const PickedImage({required this.bytes, required this.aspectRatio});
}

abstract interface class ImageFilePicker {
  Future<PickedImage?> pickImage();
}
