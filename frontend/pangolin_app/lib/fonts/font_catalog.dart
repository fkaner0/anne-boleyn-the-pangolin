class FontCatalog {
  const FontCatalog();

  static const List<String> fonts = [
    'Bauhaus 93',
    'Comic Sans',
    'Bradley Hand ITC',
    // etc.
  ];

  /// Returns the font after [current] in the list, wrapping around.
  String next(String? current) {
    if (current == null) return fonts.first;
    final index = fonts.indexOf(current);
    return fonts[(index + 1) % fonts.length];
  }
}
