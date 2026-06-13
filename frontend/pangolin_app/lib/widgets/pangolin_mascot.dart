import 'dart:async';

import 'package:flutter/material.dart';

enum PangolinMascotState { awake, sleep, fall, sweatFall, sweat }

class PangolinMascotController extends ChangeNotifier {
  static const Duration _idleDelay = Duration(seconds: 3);
  static const Duration _sweatRecoverDelay = Duration(seconds: 2);
  static const Duration _fallLingerDelay = Duration(milliseconds: 450);
  static const double _fastScrollThreshold = 9;

  PangolinMascotState _state = PangolinMascotState.awake;
  PangolinMascotState get state => _state;

  bool _scrolledFast = false;
  Timer? _idleTimer;
  Timer? _recoverTimer;

  PangolinMascotController() {
    _scheduleSleep();
  }

  bool handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _onScrollStart();
    } else if (notification is ScrollUpdateNotification) {
      _onScrollUpdate(notification.scrollDelta ?? 0);
    } else if (notification is ScrollEndNotification) {
      _onScrollEnd();
    }
    return false;
  }

  void _onScrollStart() {
    _cancelTimers();
    _scrolledFast = false;
    _setState(PangolinMascotState.fall);
  }

  void _onScrollUpdate(double delta) {
    _cancelTimers();
    if (delta.abs() >= _fastScrollThreshold) {
      _scrolledFast = true;
      _setState(PangolinMascotState.sweatFall);
    } else if (_state != PangolinMascotState.sweatFall) {
      _setState(PangolinMascotState.fall);
    }
  }

  void _onScrollEnd() {
    if (_scrolledFast) {
      _setState(PangolinMascotState.sweat);
      _recoverTimer = Timer(_sweatRecoverDelay, () {
        _setState(PangolinMascotState.awake);
        _scheduleSleep();
      });
    } else {
      _recoverTimer = Timer(_fallLingerDelay, () {
        _setState(PangolinMascotState.awake);
        _scheduleSleep();
      });
    }
  }

  void _scheduleSleep() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_idleDelay, () => _setState(PangolinMascotState.sleep));
  }

  void _cancelTimers() {
    _idleTimer?.cancel();
    _recoverTimer?.cancel();
  }

  void _setState(PangolinMascotState next) {
    if (_state == next) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}

class PangolinMascot extends StatelessWidget {
  static const Map<PangolinMascotState, String> _assets = {
    PangolinMascotState.awake: 'assets/guys/nav_awake.PNG',
    PangolinMascotState.sleep: 'assets/guys/nav_sleep.PNG',
    PangolinMascotState.fall: 'assets/guys/nav_fall.PNG',
    PangolinMascotState.sweatFall: 'assets/guys/nav_sweat_fall.PNG',
    PangolinMascotState.sweat: 'assets/guys/nav_sweat.png',
  };

  final PangolinMascotController controller;
  final double height;

  const PangolinMascot({super.key, required this.controller, this.height = 88});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Image.asset(
        _assets[controller.state]!,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}
