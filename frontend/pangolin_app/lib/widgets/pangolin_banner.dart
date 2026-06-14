import 'dart:math';

import 'package:flutter/material.dart';

import 'package:pangolin_app/widgets/pangolin_mascot.dart';

class PangolinBanner extends StatefulWidget {
  static const List<String> _pool = [
    'assets/guys/knitting.PNG',
    'assets/guys/pottery.PNG',
    'assets/guys/painting.PNG',
    'assets/guys/photography.PNG',
  ];

  static final Random _random = Random();

  static List<String> randomTrio() =>
      (List<String>.of(_pool)..shuffle(_random)).take(3).toList();

  final List<String> assets;

  const PangolinBanner({super.key, required this.assets});

  @override
  State<PangolinBanner> createState() => _PangolinBannerState();
}

class _PangolinBannerState extends State<PangolinBanner> {
  bool _ready = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _preload();
  }

  Future<void> _preload() async {
    await Future.wait([
      for (final asset in widget.assets)
        precacheImage(AssetImage(asset), context).catchError((Object _) {}),
    ]);
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SizedBox(
        width: double.infinity,
        height: PangolinMascot.navBarHeight,
      );
    }

    return Opacity(
      opacity: 0.25,
      child: SizedBox(
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, asset) in widget.assets.indexed) ...[
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
