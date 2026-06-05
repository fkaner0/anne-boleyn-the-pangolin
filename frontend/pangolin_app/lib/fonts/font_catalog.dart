class FontCatalog {
  const FontCatalog();

  static const List<String> fonts = [
    'Archivo Black',
    'Comic Sans',
    'EB Garamond',
    'Inspiration',
    'Tektur',
    'Manslava',
    'Playpen_Sans',
    'Quicksand',
    'Silkscreen',
  ];

  /// Returns the font after [current] in the list, wrapping around.
  String next(String? current) {
    if (current == null) return fonts.first;
    final index = fonts.indexOf(current);
    return fonts[(index + 1) % fonts.length];
  }
}
