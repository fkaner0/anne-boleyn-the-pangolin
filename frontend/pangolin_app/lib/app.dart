import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'theme/app_palette.dart';
import 'theme/app_theme.dart';

class PangoPalApp extends ConsumerWidget {
  const PangoPalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'PangoPal',
      routerConfig: router,
      theme: buildAppTheme(appPalette),
    );
  }
}
