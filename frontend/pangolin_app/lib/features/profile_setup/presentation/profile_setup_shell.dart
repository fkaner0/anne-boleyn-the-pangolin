import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_router.dart';
import 'pages/about_page.dart';

/// Tracks which step of sign-up the user is on (0 = About, 1 = Wall, 2 = Intro).
final _signupStepProvider = StateProvider<int>((ref) => 0);

class SignupShell extends ConsumerWidget {
  const SignupShell({super.key});

  static const _steps = ['About', 'Wall', 'Intro'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(_signupStepProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _SignupProgressBar(currentStep: step, steps: _steps),
            const Divider(height: 1),
            Expanded(
              child: _buildStep(step, ref, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int step, WidgetRef ref, BuildContext context) {
    void goNext() {
      if (step < _steps.length - 1) {
        ref.read(_signupStepProvider.notifier).state = step + 1;
      } else {
        // Sign-up complete — navigate to main app
        context.go(AppRoutes.recommendations);
      }
    }

    return switch (step) {
      0 => AboutPage(onNext: goNext),
      1 => AboutPage(onNext: goNext),
      2 => AboutPage(onNext: goNext),
      // 1 => WallPage(onNext: goNext),
      // 2 => IntroPage(onNext: goNext),
      _ => const SizedBox.shrink(),
    };
  }
}

class _SignupProgressBar extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const _SignupProgressBar({
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == currentStep;
          final isPast   = i < currentStep;
          return Expanded(
            child: Row(
              children: [
                _StepIndicator(
                  label: steps[i],
                  index: i + 1,
                  isActive: isActive,
                  isPast: isPast,
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isPast
                          ? colorScheme.primary
                          : colorScheme.tertiary, /// TODO: colors? idk
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final String label;
  final int index;
  final bool isActive;
  final bool isPast;

  const _StepIndicator({
    required this.label,
    required this.index,
    required this.isActive,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final color = isActive || isPast ? colorScheme.primary : colorScheme.tertiary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive || isPast ? colorScheme.primary : colorScheme.tertiary,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive || isPast ? colorScheme.surface : colorScheme.tertiary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? colorScheme.primary : colorScheme.tertiary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
