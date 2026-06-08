import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pangolin_app/features/wall_creation/data/compressor/default_image_compressor.dart';

void main() {
  test('caps the longest side and shrinks an oversized image', () async {
    final large = img.Image(width: 2500, height: 1000);
    for (var y = 0; y < large.height; y++) {
      for (var x = 0; x < large.width; x++) {
        large.setPixelRgb(
          x,
          y,
          (x * 7 + y * 13) % 256,
          (x * 3) % 256,
          (y * 5) % 256,
        );
      }
    }
    final originalBytes = img.encodeJpg(large, quality: 90);

    const compressor = DefaultImageCompressor(maxDimension: 2048, quality: 85);
    final result = await compressor.compress(originalBytes);

    final decoded = img.decodeImage(result)!;
    expect(decoded.width, 2048);
    expect(decoded.height, closeTo(819, 1));
    expect(result.length, lessThan(originalBytes.length));
  });

  test('does not upscale an image already within bounds', () async {
    final small = img.Image(width: 400, height: 300);
    img.fill(small, color: img.ColorRgb8(10, 20, 30));
    final originalBytes = img.encodePng(small);

    const compressor = DefaultImageCompressor(maxDimension: 2048);
    final result = await compressor.compress(originalBytes);

    final decoded = img.decodeImage(result)!;
    expect(decoded.width, lessThanOrEqualTo(400));
    expect(decoded.height, lessThanOrEqualTo(300));
  });
}
