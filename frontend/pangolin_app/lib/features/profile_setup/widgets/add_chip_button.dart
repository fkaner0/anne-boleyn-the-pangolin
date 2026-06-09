import 'package:flutter/material.dart';

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
        child: Icon(Icons.add, size: 18, color: colorScheme.primary),
      ),
    );
  }
}
