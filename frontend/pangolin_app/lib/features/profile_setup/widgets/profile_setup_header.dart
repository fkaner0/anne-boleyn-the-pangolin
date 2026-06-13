import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:pangolin_app/theme/palette_colors.dart';

const double _ballSize = 20;

class ProfileSetupHeader extends StatelessWidget {
  static const String _bannerAsset = 'assets/icons/header/header.svg';
  static const double _bannerAspectRatio = 2560 / 575;
  static const Color _pillColor = Color(0xFFF4EBD8);

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
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: AspectRatio(
            aspectRatio: _bannerAspectRatio,
            child: SvgPicture.asset(_bannerAsset, fit: BoxFit.contain),
          ),
        ),
        Container(
          width: size.width * 0.66,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: _pillColor,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
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
    final completedColor = colorScheme.primary;
    final currentColor = context.paletteColors.pangolin;
    final uncompletedColor = colorScheme.outline;

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
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: numberColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurface,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
