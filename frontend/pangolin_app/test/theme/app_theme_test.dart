import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/theme/app_theme.dart';
import 'package:pangolin_app/theme/default_palette.dart';
import 'package:pangolin_app/theme/palette_colors.dart';

void main() {
  const palette = DefaultPalette();

  test('maps palette colours onto the ColorScheme', () {
    final theme = buildAppTheme(palette);
    final scheme = theme.colorScheme;

    expect(scheme.primary, palette.primaryDark);
    expect(scheme.secondary, palette.secondary);
    expect(scheme.tertiary, palette.tertiary);
    expect(scheme.surface, palette.surface);
    expect(scheme.error, palette.danger);
    expect(scheme.outline, palette.border);
  });

  test('exposes leftover palette colours through PaletteColors', () {
    final theme = buildAppTheme(palette);
    final colors = theme.extension<PaletteColors>();

    expect(colors, isNotNull);
    expect(colors!.pangolin, palette.pangolin);
    expect(colors.success, palette.success);
    expect(colors.danger, palette.danger);
    expect(colors.overlay, palette.overlay);
    expect(colors.shadow, palette.shadow);
    expect(colors.surfaceMuted, palette.surfaceMuted);
  });
}
