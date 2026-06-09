import 'package:flutter/material.dart';

class SplodgeClipper extends CustomClipper<Path> {
  final int variant;

  const SplodgeClipper({this.variant = 0});

  static const List<List<Offset>> _variants = [
    [
      Offset(0.50, 0.05),
      Offset(0.80, 0.12),
      Offset(0.95, 0.42),
      Offset(0.86, 0.74),
      Offset(0.58, 0.95),
      Offset(0.28, 0.88),
      Offset(0.07, 0.60),
      Offset(0.14, 0.28),
    ],
    [
      Offset(0.46, 0.08),
      Offset(0.78, 0.06),
      Offset(0.94, 0.36),
      Offset(0.95, 0.70),
      Offset(0.64, 0.93),
      Offset(0.32, 0.96),
      Offset(0.06, 0.64),
      Offset(0.10, 0.30),
    ],
    [
      Offset(0.55, 0.06),
      Offset(0.82, 0.18),
      Offset(0.93, 0.50),
      Offset(0.80, 0.82),
      Offset(0.50, 0.95),
      Offset(0.20, 0.84),
      Offset(0.08, 0.50),
      Offset(0.20, 0.16),
    ],
    [
      Offset(0.50, 0.04),
      Offset(0.76, 0.14),
      Offset(0.96, 0.40),
      Offset(0.90, 0.66),
      Offset(0.70, 0.94),
      Offset(0.40, 0.92),
      Offset(0.12, 0.78),
      Offset(0.05, 0.40),
      Offset(0.18, 0.16),
    ],
  ];

  static int get variantCount => _variants.length;

  @override
  Path getClip(Size size) {
    final points = _variants[variant % _variants.length];
    return _smoothClosedPath(points, size);
  }

  @override
  bool shouldReclip(covariant SplodgeClipper oldClipper) =>
      oldClipper.variant != variant;
}

Path _smoothClosedPath(List<Offset> normalised, Size size) {
  final points = [
    for (final point in normalised)
      Offset(point.dx * size.width, point.dy * size.height),
  ];
  final count = points.length;
  final path = Path()..moveTo(points[0].dx, points[0].dy);

  for (var i = 0; i < count; i++) {
    final previous = points[(i - 1 + count) % count];
    final start = points[i];
    final end = points[(i + 1) % count];
    final next = points[(i + 2) % count];

    final controlA = start + (end - previous) / 6;
    final controlB = end - (next - start) / 6;

    path.cubicTo(
      controlA.dx,
      controlA.dy,
      controlB.dx,
      controlB.dy,
      end.dx,
      end.dy,
    );
  }

  return path..close();
}
