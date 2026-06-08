import 'dart:typed_data';

import 'wall_image_uploader.dart';

class MockWallImageUploader implements WallImageUploader {
  final List<Uint8List> uploaded = [];
  int _counter = 0;

  @override
  Future<String> uploadImage(Uint8List bytes) async {
    uploaded.add(bytes);
    return 'https://mock.local/wall-image-${_counter++}.png';
  }
}
