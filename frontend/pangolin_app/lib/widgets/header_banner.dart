import 'package:flutter/material.dart';

class HeaderBanner extends StatelessWidget {
  static const String _asset = 'assets/icons/header/header.png';
  static const double aspectRatio = 2557 / 476;
  static const double clipStartOffset = -18;
  static const double _shift = 18;

  static double heightFor(BuildContext context, {double extraHeight = 0}) =>
      MediaQuery.sizeOf(context).width / aspectRatio +
      clipStartOffset +
      extraHeight;

  final Widget? overlay;
  final double extraHeight;

  const HeaderBanner({super.key, this.overlay, this.extraHeight = 0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.translate(
          offset: Offset(0, -(_shift - extraHeight)),
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
