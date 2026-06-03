import 'package:flutter/painting.dart';

import 'palette.dart';

// Palette with current colours
class DefaultPalette implements Palette {
  const DefaultPalette();

  // UI Colours
  @override
  Color get primaryDark => const Color(0xFF647248);
  @override
  Color get primaryLight => const Color(0xFFB8C992);
  @override
  Color get secondary => const Color(0xFFFAC1D5);
  @override
  Color get tertiary => const Color(0xFFCAF2F7);
  @override
  Color get offWhite => const Color(0xFFFEF9F2);
  @override
  Color get pangolin => const Color(0xFFE59B75);

  // Surfaces & outlines.
  @override
  Color get surface => const Color(0xFFFFFFFF);
  @override
  Color get surfaceMuted => const Color(0xFFF5F5F5);
  @override
  Color get border => const Color(0xFFE0E0E0);

  // Text.
  @override
  Color get textPrimary => const Color(0xDD000000);
  @override
  Color get textSecondary => const Color(0x8A000000);

  // Effects.
  @override
  Color get shadow => const Color(0x1F000000);
  @override
  Color get overlay => const Color(0x8A000000);

  // Semantic actions.
  @override
  Color get success => const Color(0xFF4CAF50);
  @override
  Color get danger => const Color(0xFFF44336);
}
