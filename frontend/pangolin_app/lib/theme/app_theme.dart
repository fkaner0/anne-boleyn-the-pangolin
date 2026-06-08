import 'package:flutter/material.dart';

import 'palette.dart';
import 'palette_colors.dart';

// Builds an app theme from a given Palette
// Flutter handles working with Themes automatically
ThemeData buildAppTheme(Palette palette) {
  final colorScheme = ColorScheme.fromSeed(seedColor: palette.primaryDark)
      .copyWith(
        primary: palette.primaryDark,
        onPrimary: palette.offWhite,
        primaryContainer: palette.primaryLight,
        secondary: palette.secondary,
        tertiary: palette.tertiary,
        surface: palette.surface,
        onSurface: palette.textPrimary,
        onSurfaceVariant: palette.textSecondary,
        error: palette.danger,
        outline: palette.border,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: palette.offWhite,
    fontFamily: 'Playpen_Sans',
    extensions: [PaletteColors.fromPalette(palette)],
  );
}
