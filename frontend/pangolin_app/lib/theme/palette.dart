import 'package:flutter/painting.dart';

abstract interface class Palette {
  Color get primaryDark;
  Color get primaryLight;
  Color get secondary;
  Color get tertiary;
  Color get offWhite;
  Color get pangolin;

  /// Default surface colour, e.g. card backgrounds.
  Color get surface;

  /// Subtle surface colour, e.g. input fills and muted panels.
  Color get surfaceMuted;

  /// Outline / divider colour.
  Color get border;

  /// Primary text colour.
  Color get textPrimary;

  /// Secondary, lower-emphasis text colour.
  Color get textSecondary;

  /// Shadow colour (typically translucent black).
  Color get shadow;

  /// Scrim / overlay colour for badges and elements layered over content.
  Color get overlay;

  /// Positive / confirm action colour (e.g. accept).
  Color get success;

  /// Negative / destructive action colour (e.g. reject).
  Color get danger;
}
