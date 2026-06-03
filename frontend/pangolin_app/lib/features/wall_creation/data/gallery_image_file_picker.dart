import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image_picker/image_picker.dart';

import 'image_file_picker.dart';

class GalleryImageFilePicker implements ImageFilePicker {
  final ImagePicker _picker;

  GalleryImageFilePicker({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  @override
  Future<PickedImage?> pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    final aspectRatio = await _decodeAspectRatio(bytes);
    return PickedImage(bytes: bytes, aspectRatio: aspectRatio);
  }

  Future<double> _decodeAspectRatio(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final aspectRatio = image.width / image.height;
    image.dispose();
    return aspectRatio;
  }
}
