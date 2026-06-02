import 'package:flutter/material.dart';
import '../../domain/virtual_canvas.dart';

class BedroomWallCanvas extends StatelessWidget {
  final VirtualCanvas canvas;

  const BedroomWallCanvas({super.key, required this.canvas});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width * (canvas.height / canvas.width);

        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade100,
          clipBehavior: Clip.none,
          child: const Stack(),
        );
      },
    );
  }
}
