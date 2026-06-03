// Model of the canvas, used to store positional information
// later sent to backend.
class VirtualCanvas {
  static const double defaultWidth = 400;

  static const double defaultHeight = 700;

  final double width;

  final double height;

  const VirtualCanvas({this.width = defaultWidth, this.height = defaultHeight});
}
