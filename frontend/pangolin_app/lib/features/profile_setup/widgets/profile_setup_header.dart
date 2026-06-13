import 'package:flutter/material.dart';

const double _ballSize = 26;

class ProfileSetupHeader extends StatelessWidget {
  static const String _bannerAsset = 'assets/icons/header/header.png';
  static const double _bannerShift = 30;
  static const Alignment _pillAlignment = Alignment(0, -0.6);

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

    return Stack(
      alignment: _pillAlignment,
      children: [
        Transform.translate(
          offset: const Offset(0, -_bannerShift),
          child: Image.asset(
            _bannerAsset,
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
        SizedBox(
          width: size.width * 0.66,
          child: _ProgressBubbles(currentStep: currentStep, steps: steps),
        ),
      ],
    );
  }
}

class _ProgressBubbles extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const _ProgressBubbles({required this.currentStep, required this.steps});

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
          ),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(top: _ballSize / 2 - 1),
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

  const _StepIndicator({
    required this.label,
    required this.index,
    required this.color,
    required this.isActive,
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
          width: _ballSize,
          height: _ballSize,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Center(
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 13,
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
              fontSize: 10,
              color: colorScheme.onSurface,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
