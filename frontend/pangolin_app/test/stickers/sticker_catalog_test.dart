import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';

void main() {
  test('matches a name to its file, ignoring the extension', () {
    final catalog = StickerCatalog.fromAssetKeys([
      'assets/stickers/pangolin.png',
      'assets/stickers/heart.webp',
    ]);

    expect(catalog.assetForName('pangolin'), 'assets/stickers/pangolin.png');
    expect(catalog.assetForName('heart'), 'assets/stickers/heart.webp');
  });

  test('matching is case-insensitive and trims whitespace', () {
    final catalog = StickerCatalog.fromAssetKeys(['assets/stickers/Star.png']);

    expect(catalog.assetForName('  STAR '), 'assets/stickers/Star.png');
  });

  test('ignores assets outside the sticker directory', () {
    final catalog = StickerCatalog.fromAssetKeys([
      'assets/stickers/sun.png',
      'assets/images/cat.png',
      'assets/stickers/nested/moon.png',
    ]);

    expect(catalog.assetForName('sun'), 'assets/stickers/sun.png');
    expect(catalog.assetForName('cat'), isNull);
    expect(catalog.assetForName('moon'), isNull);
  });

  test('returns null for an unknown name', () {
    final catalog = StickerCatalog.fromAssetKeys(['assets/stickers/sun.png']);

    expect(catalog.assetForName('missing'), isNull);
  });
}
