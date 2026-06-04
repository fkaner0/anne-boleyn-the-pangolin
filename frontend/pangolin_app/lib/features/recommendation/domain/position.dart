class Position {
  final int x;
  final int y;
  final double rotation;
  final double aspectRatio;
  final double scale;

  const Position({
    required this.x,
    required this.y,
    required this.rotation,
    this.aspectRatio = 1.0,
    this.scale = 1.0,
  });

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'rotation': rotation,
    'aspectRatio': aspectRatio,
    'scale': scale,
  };

  factory Position.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v, double defaultValue) {
      if (v == null) return defaultValue;
      if (v is int) return v.toDouble();
      if (v is double) return v;
      if (v is String) return double.tryParse(v) ?? defaultValue;
      return defaultValue;
    }

    return Position(
      x: json['x'] as int,
      y: json['y'] as int,
      rotation: parseDouble(json['rotation'], 0.0),
      aspectRatio: parseDouble(json['aspectRatio'], 1.0),
      scale: parseDouble(json['scale'], 1.0),
    );
  }
}
