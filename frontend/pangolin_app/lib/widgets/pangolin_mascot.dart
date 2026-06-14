import 'dart:async';

import 'package:flutter/material.dart';

enum PangolinMascotState { awake, sleep, fall, sweatFall, sweat }

class PangolinMascotController extends ChangeNotifier {
  static const Duration _idleDelay = Duration(seconds: 3);
  static const Duration _sweatRecoverDelay = Duration(milliseconds: 1500);
  static const Duration _fallLingerDelay = Duration(milliseconds: 450);
  static const double _fallThreshold = 4;
  static const double _sweatThreshold = 12;
  static const Duration _minDwell = Duration(milliseconds: 250);

  static const int _tierGentle = 0;
  static const int _tierFall = 1;
  static const int _tierSweat = 2;

  PangolinMascotState _state = PangolinMascotState.awake;
  PangolinMascotState get state => _state;

  int _peakTier = _tierGentle;
  Timer? _idleTimer;
  Timer? _recoverTimer;

  bool _dwellLocked = false;
  PangolinMascotState? _pendingState;
  Timer? _dwellTimer;

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
    _peakTier = _tierGentle;
    _requestState(PangolinMascotState.awake);
  }

  void _onScrollUpdate(double delta) {
    _cancelTimers();
    final magnitude = delta.abs();
    final tier = magnitude >= _sweatThreshold
        ? _tierSweat
        : magnitude >= _fallThreshold
        ? _tierFall
        : _tierGentle;
    if (tier > _peakTier) _peakTier = tier;

    _requestState(switch (_peakTier) {
      _tierSweat => PangolinMascotState.sweatFall,
      _tierFall => PangolinMascotState.fall,
      _ => PangolinMascotState.awake,
    });
  }

  void _onScrollEnd() {
    switch (_peakTier) {
      case _tierSweat:
        _applyState(PangolinMascotState.sweatFall);
        _recoverTimer = Timer(_minDwell, () {
          _applyState(PangolinMascotState.sweat);
          _recoverTimer = Timer(_sweatRecoverDelay, () {
            _applyState(PangolinMascotState.awake);
            _scheduleSleep();
          });
        });
      case _tierFall:
        _recoverTimer = Timer(_fallLingerDelay, () {
          _requestState(PangolinMascotState.awake);
          _scheduleSleep();
        });
      default:
        _requestState(PangolinMascotState.awake);
        _scheduleSleep();
    }
  }

  void _scheduleSleep() {
    _idleTimer?.cancel();
    _idleTimer = Timer(
      _idleDelay,
      () => _requestState(PangolinMascotState.sleep),
    );
  }

  void _cancelTimers() {
    _idleTimer?.cancel();
    _recoverTimer?.cancel();
  }

  void _requestState(PangolinMascotState next) {
    if (_dwellLocked) {
      _pendingState = next == _state ? null : next;
      return;
    }
    _applyState(next);
  }

  void _applyState(PangolinMascotState next) {
    _pendingState = null;
    if (_state == next) return;

    _state = next;
    notifyListeners();
    _dwellLocked = true;
    _dwellTimer?.cancel();
    _dwellTimer = Timer(_minDwell, () {
      _dwellLocked = false;
      final pending = _pendingState;
      _pendingState = null;
      if (pending != null) _applyState(pending);
    });
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    _cancelTimers();
    super.dispose();
  }
}

class PangolinMascot extends StatefulWidget {
  static const double navBarHeight = 220;

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
  State<PangolinMascot> createState() => _PangolinMascotState();
}

class _PangolinMascotState extends State<PangolinMascot> {
  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    for (final asset in PangolinMascot._assets.values) {
      precacheImage(AssetImage(asset), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) => Image.asset(
        PangolinMascot._assets[widget.controller.state]!,
        height: widget.height,
        fit: BoxFit.contain,
        gaplessPlayback: true,
      ),
    );
  }
}
