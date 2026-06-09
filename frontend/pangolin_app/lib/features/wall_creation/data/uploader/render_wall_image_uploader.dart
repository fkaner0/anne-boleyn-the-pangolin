import 'dart:typed_data';

import 'package:pangolin_app/config/env.dart';

import 'api_wall_image_uploader.dart';
import 'wall_image_uploader.dart';

class RenderImageUploader implements ImageUploader {
  final ApiImageUploader _delegate;

  RenderImageUploader({
    String host = defaultRenderHost,
    int? port,
    bool useHttps = true,
  }) : _delegate = ApiImageUploader(host: host, port: port, useHttps: useHttps);

  @override
  Future<String> uploadImage(Uint8List bytes) => _delegate.uploadImage(bytes);
}
