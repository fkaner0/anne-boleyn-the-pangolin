import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:pangolin_app/app.dart';
import 'package:pangolin_app/config/env.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import 'package:pangolin_app/fonts/font_catalog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configureDependencies(Env.backend);
  await _registerStickerCatalog();
  await _registerFontCatalog();

  runApp(const ProviderScope(child: PangoPalApp()));
}

Future<void> _registerStickerCatalog() async {
  try {
    final catalog = await StickerCatalog.load();
    if (getIt.isRegistered<StickerCatalog>()) {
      getIt.unregister<StickerCatalog>();
    }
    getIt.registerSingleton<StickerCatalog>(catalog);
  } catch (_) {}
}

Future<void> _registerFontCatalog() async {
  try {
    final catalog = FontCatalog();
    if (getIt.isRegistered<FontCatalog>()) {
      getIt.unregister<FontCatalog>();
    }
    getIt.registerSingleton<FontCatalog>(catalog);
  } catch (_) {}
}
