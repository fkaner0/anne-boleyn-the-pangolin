import 'package:flutter/material.dart';
import 'package:pangolin_app/config/env.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import 'theme/app_palette.dart';
import 'theme/app_theme.dart';
import 'features/wall_creation/presentation/pages/bedroom_wall_creator_page.dart';

void main() {
  // Configure dependencies from compile-time env flags
  configureDependencies(Env.backend);

  // Load sticker catalog asynchronously and replace the default
  StickerCatalog.load()
      .then((catalog) {
        getIt.unregister<StickerCatalog>();
        getIt.registerSingleton<StickerCatalog>(catalog);
      })
      .catchError((_) {
        // If loading fails, keep the default empty catalog
      });

  runApp(const MyApp());
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
