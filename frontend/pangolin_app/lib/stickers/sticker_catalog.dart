import 'package:flutter/services.dart';

class StickerCatalog {
  static const String directory = 'assets/stickers/';

  final Map<String, String> _assetByName;

  StickerCatalog.fromAssetKeys(Iterable<String> assetKeys)
    : _assetByName = _index(assetKeys);

  String? assetForName(String name) => _assetByName[_normalize(name)];

  Iterable<String> get names => _assetByName.keys;

  static Map<String, String> _index(Iterable<String> assetKeys) {
    final result = <String, String>{};
    for (final key in assetKeys) {
      if (!key.startsWith(directory)) continue;
      final fileName = key.substring(directory.length);
      if (fileName.isEmpty || fileName.contains('/')) continue;
      final name = _normalize(_stripExtension(fileName));
      if (name.isEmpty) continue;
      result[name] = key;
    }
    return result;
  }

  static String _stripExtension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    return dot <= 0 ? fileName : fileName.substring(0, dot);
  }

  static String _normalize(String name) => name.trim().toLowerCase();

  static Future<StickerCatalog>? _cached;

  static Future<StickerCatalog> load({AssetBundle? bundle}) {
    if (bundle != null) return _loadFrom(bundle);
    return _cached ??= _loadFrom(rootBundle);
  }

  static Future<StickerCatalog> _loadFrom(AssetBundle bundle) async {
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);
    return StickerCatalog.fromAssetKeys(manifest.listAssets());
  }
}
