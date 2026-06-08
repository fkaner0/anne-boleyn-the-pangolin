import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/features/wall_creation/data/uploader/compressing_wall_image_uploader.dart';
import 'package:pangolin_app/features/wall_creation/data/compressor/image_compressor.dart';
import 'package:pangolin_app/features/wall_creation/data/uploader/wall_image_uploader.dart';

class _RecordingUploader implements WallImageUploader {
  Uint8List? received;
    
  @override
  Future<String> uploadImage(Uint8List bytes) async {
    received = bytes;
    return 'https://example.com/uploaded.jpg';
  }
}

class _StubCompressor implements ImageCompressor {
  final Uint8List output;
  Uint8List? received;

  _StubCompressor(this.output);

  @override
  Future<Uint8List> compress(Uint8List bytes) async {
    received = bytes;
    return output;
  }
}

void main() {
  test(
    'compresses the bytes before delegating to the inner uploader',
    () async {
      final original = Uint8List.fromList([1, 2, 3, 4]);
      final compressed = Uint8List.fromList([9, 9]);
      final inner = _RecordingUploader();
      final compressor = _StubCompressor(compressed);

      final uploader = CompressingWallImageUploader(inner, compressor);
      final url = await uploader.uploadImage(original);

      expect(compressor.received, original);
      expect(inner.received, compressed);
      expect(url, 'https://example.com/uploaded.jpg');
    },
  );
}
