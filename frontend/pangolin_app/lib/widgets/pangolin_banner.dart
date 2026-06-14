import 'dart:math';

import 'package:flutter/material.dart';

import 'package:pangolin_app/widgets/pangolin_mascot.dart';

class PangolinBanner extends StatelessWidget {
  static const List<String> _pool = [
    'assets/guys/knitting.PNG',
    'assets/guys/pottery.PNG',
    'assets/guys/painting.PNG',
    'assets/guys/photography.PNG',
  ];

  static final Random _random = Random();

  static List<String> randomTrio() =>
      (List<String>.of(_pool)..shuffle(_random)).take(3).toList();

  static Future<void> precache(BuildContext context, List<String> assets) {
    return Future.wait([
      for (final asset in assets)
        precacheImage(AssetImage(asset), context).catchError((Object _) {}),
    ]);
  }

  final List<String> assets;

  const PangolinBanner({super.key, required this.assets});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.25,
      child: SizedBox(
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, asset) in assets.indexed) ...[
                if (index > 0) const SizedBox(width: 8),
                Image.asset(
                  asset,
                  height: PangolinMascot.navBarHeight,
                  fit: BoxFit.contain,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
