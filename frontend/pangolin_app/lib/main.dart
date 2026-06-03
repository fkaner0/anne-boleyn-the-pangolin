import 'package:flutter/material.dart';
import 'package:pangolin_app/config/env.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import 'theme/app_palette.dart';
import 'theme/app_theme.dart';
import 'features/wall_creation/presentation/pages/bedroom_wall_creator_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configureDependencies(Env.backend);
  await _registerStickerCatalog();

  runApp(const MyApp());
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pangolin App',
      theme: buildAppTheme(appPalette),
      home: const BedroomWallCreatorPage(),
    );
  }
}
