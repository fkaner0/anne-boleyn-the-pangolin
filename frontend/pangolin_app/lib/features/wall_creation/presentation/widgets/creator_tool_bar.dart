import 'package:flutter/material.dart';

/// Bottom toolbar of circular creation tools for the bedroom-wall creator.
///
/// Emits a callback per tool; deciding what each one does to the canvas is the
/// controller's responsibility, not this View's.
class CreatorToolBar extends StatelessWidget {
  final VoidCallback onAddTextBox;
  final VoidCallback onAddImage;
  final VoidCallback onAddSticker;

  const CreatorToolBar({
    super.key,
    required this.onAddTextBox,
    required this.onAddImage,
    required this.onAddSticker,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CircularToolButton(
            icon: Icons.title,
            label: 'Text box',
            onPressed: onAddTextBox,
          ),
          _CircularToolButton(
            icon: Icons.add_photo_alternate_outlined,
            label: 'Image',
            onPressed: onAddImage,
          ),
          _CircularToolButton(
            icon: Icons.emoji_emotions_outlined,
            label: 'Sticker',
            onPressed: onAddSticker,
          ),
        ],
      ),
    );
  }
}

class _CircularToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _CircularToolButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: colorScheme.primaryContainer,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              width: 64,
              height: 64,
              child: Icon(
                icon,
                size: 28,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
