import 'package:flutter/material.dart';

import 'package:pangolin_app/widgets/header_banner.dart';

class ProfileSetupHeader extends StatelessWidget {
  static const double _progressTopFraction = 0.02;
  static const double _progressHeightFraction = 0.50;

  static double heightFor(BuildContext context) =>
      HeaderBanner.heightFor(context);

  final int currentStep;
  final List<String> steps;

  const ProfileSetupHeader({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bannerHeight = size.width / HeaderBanner.aspectRatio;
    final barHeight = bannerHeight * _progressHeightFraction;

    return HeaderBanner(
      overlay: Positioned(
        top: bannerHeight * _progressTopFraction,
        left: 0,
        right: 0,
        height: barHeight,
        child: Center(
          child: SizedBox(
            width: size.width * 0.66,
            child: _ProgressBubbles(
              currentStep: currentStep,
              steps: steps,
              ballSize: (barHeight * 0.6).clamp(14.0, 64.0),
              labelFontSize: (barHeight * 0.18).clamp(8.0, 16.0),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBubbles extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  final double ballSize;
  final double labelFontSize;

  const _ProgressBubbles({
    required this.currentStep,
    required this.steps,
    required this.ballSize,
    required this.labelFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final completedColor = colorScheme.primaryContainer;
    final currentColor = colorScheme.tertiary;
    const uncompletedColor = Colors.white;

    Color colorFor(int i) {
      if (i < currentStep) return completedColor;
      if (i == currentStep) return currentColor;
      return uncompletedColor;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _StepIndicator(
            label: steps[i],
            index: i + 1,
            color: colorFor(i),
            isActive: i == currentStep,
            ballSize: ballSize,
            labelFontSize: labelFontSize,
          ),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: EdgeInsets.only(top: ballSize / 2 - 1),
                color: i < currentStep ? completedColor : uncompletedColor,
              ),
            ),
        ],
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final String label;
  final int index;
  final Color color;
  final bool isActive;
  final double ballSize;
  final double labelFontSize;

  const _StepIndicator({
    required this.label,
    required this.index,
    required this.color,
    required this.isActive,
    required this.ballSize,
    required this.labelFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final numberColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: ballSize,
          height: ballSize,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Center(
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: ballSize * 0.45,
                fontWeight: FontWeight.bold,
                color: numberColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: labelFontSize,
              color: colorScheme.onSurface,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
