import 'package:flutter/material.dart';

import 'package:pangolin_app/widgets/app_icon.dart';

class HeaderBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const HeaderBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      tooltip: 'Back',
      icon: const AppIcon(AppIconType.back, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        minimumSize: const Size(36, 36),
        maximumSize: const Size(36, 36),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
