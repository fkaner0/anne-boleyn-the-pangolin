import 'package:flutter/material.dart';

class RollingSpinner extends StatefulWidget {
  static const String _asset = 'assets/guys/rolling.PNG';

  final double size;

  const RollingSpinner({super.key, this.size = 175});

  @override
  State<RollingSpinner> createState() => _RollingSpinnerState();
}

class _RollingSpinnerState extends State<RollingSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.50,
      child: RotationTransition(
        turns: _controller,
        child: Image.asset(
          RollingSpinner._asset,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
