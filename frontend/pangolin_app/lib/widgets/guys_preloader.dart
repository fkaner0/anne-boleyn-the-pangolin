import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:pangolin_app/widgets/pangolin_banner.dart';

mixin GuysPreloader<T extends StatefulWidget> on State<T> {
  static const Duration _fallback = Duration(seconds: 2);

  bool _guysReady = false;
  bool _started = false;
  Timer? _fallbackTimer;

  bool get guysReady => _guysReady;

  List<String> get guysAssets;

  void preloadGuys() {
    if (_started) return;
    _started = true;
    PangolinBanner.precache(context, guysAssets).whenComplete(_markReady);
    _fallbackTimer = Timer(_fallback, _markReady);
  }

  void _markReady() {
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
    if (mounted && !_guysReady) setState(() => _guysReady = true);
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }
}
