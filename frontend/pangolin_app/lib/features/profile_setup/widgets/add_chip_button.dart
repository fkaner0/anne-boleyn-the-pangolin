import 'package:flutter/material.dart';

import 'package:pangolin_app/widgets/app_icon.dart';

class AddChipButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddChipButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surface,
        ),
        child: const Center(child: AppIcon(AppIconType.add, size: 18)),
      ),
    );
  }
}
