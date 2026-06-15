import 'dart:async';

import 'package:flutter/material.dart';

class WiggleHint extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Duration delay;
  final Duration interval;

  const WiggleHint({
    super.key,
    required this.child,
    this.enabled = true,
    this.delay = const Duration(seconds: 3),
    this.interval = const Duration(seconds: 6),
  });

  @override
  State<WiggleHint> createState() => _WiggleHintState();
}

class _WiggleHintState extends State<WiggleHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _wiggle;

  Timer? _delayTimer;
  Timer? _repeatTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _wiggle = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.08), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.08, end: -0.08), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.08, end: 0.06), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.06, end: -0.04), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.04, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.enabled) _scheduleWiggle();
  }

  @override
  void didUpdateWidget(WiggleHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !oldWidget.enabled) {
      _scheduleWiggle();
    } else if (!widget.enabled && oldWidget.enabled) {
      _cancelTimers();
      _controller.reset();
    }
  }

  void _scheduleWiggle() {
    _cancelTimers();
    _delayTimer = Timer(widget.delay, () {
      _wiggleNow();
      _repeatTimer = Timer.periodic(widget.interval, (_) => _wiggleNow());
    });
  }

  void _wiggleNow() {
    if (mounted) _controller.forward(from: 0);
  }

  void _cancelTimers() {
    _delayTimer?.cancel();
    _repeatTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelTimers();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _wiggle,
      child: widget.child,
      builder: (context, child) {
        return Transform.rotate(angle: _wiggle.value, child: child);
      },
    );
  }
}
