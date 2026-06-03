import 'package:flutter/material.dart';

import 'palette.dart';

class PaletteColors extends ThemeExtension<PaletteColors> {
  final Color pangolin;
  final Color success;
  final Color danger;
  final Color overlay;
  final Color shadow;
  final Color surfaceMuted;

  const PaletteColors({
    required this.pangolin,
    required this.success,
    required this.danger,
    required this.overlay,
    required this.shadow,
    required this.surfaceMuted,
  });

  factory PaletteColors.fromPalette(Palette palette) {
    return PaletteColors(
      pangolin: palette.pangolin,
      success: palette.success,
      danger: palette.danger,
      overlay: palette.overlay,
      shadow: palette.shadow,
      surfaceMuted: palette.surfaceMuted,
    );
  }

  @override
  PaletteColors copyWith({
    Color? pangolin,
    Color? success,
    Color? danger,
    Color? overlay,
    Color? shadow,
    Color? surfaceMuted,
  }) {
    return PaletteColors(
      pangolin: pangolin ?? this.pangolin,
      success: success ?? this.success,
      danger: danger ?? this.danger,
      overlay: overlay ?? this.overlay,
      shadow: shadow ?? this.shadow,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
    );
  }

  @override
  PaletteColors lerp(PaletteColors? other, double t) {
    if (other == null) return this;
    return PaletteColors(
      pangolin: Color.lerp(pangolin, other.pangolin, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
    );
  }
}
