import 'dart:typed_data';

import 'package:pangolin_app/config/env.dart';

import 'api_wall_image_uploader.dart';
import 'wall_image_uploader.dart';

class RenderWallImageUploader implements WallImageUploader {
  final ApiWallImageUploader _delegate;

  RenderWallImageUploader({
    String host = defaultRenderHost,
    bool useHttps = true,
  }) : _delegate = ApiWallImageUploader(host: host, useHttps: useHttps);

  @override
  Future<String> uploadImage(Uint8List bytes) => _delegate.uploadImage(bytes);
}
