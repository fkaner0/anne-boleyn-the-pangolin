import 'package:flutter/material.dart';

class HeaderBanner extends StatelessWidget {
  static const String _asset = 'assets/icons/header/header.png';
  static const double aspectRatio = 2557 / 476;
  static const double clipStartOffset = -30;
  static const double _shift = 30;

  static double heightFor(BuildContext context) =>
      MediaQuery.sizeOf(context).width / aspectRatio + clipStartOffset;

  final Widget? overlay;

  const HeaderBanner({super.key, this.overlay});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.translate(
          offset: const Offset(0, -_shift),
          child: Image.asset(
            _asset,
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
        ?overlay,
      ],
    );
  }
}
