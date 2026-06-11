import 'package:flutter/material.dart';

class BedroomWallViewport extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;
  final Key? viewportKey;

  const BedroomWallViewport({
    super.key,
    required this.child,
    this.controller,
    this.viewportKey,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: viewportKey,
      controller: controller,
      child: child,
    );
  }
}
