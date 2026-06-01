class Position {
  final int x;
  final int y;
  final int rotation;

  const Position({required this.x, required this.y, required this.rotation});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      x: json['x'] as int,
      y: json['y'] as int,
      rotation: json['rotation'] as int,
    );
  }
}
