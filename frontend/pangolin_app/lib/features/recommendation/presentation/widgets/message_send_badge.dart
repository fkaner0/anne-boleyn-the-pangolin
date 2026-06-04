import 'package:flutter/material.dart';
import 'package:pangolin_app/theme/palette_colors.dart';

class MessageSendBadge extends StatelessWidget {
  const MessageSendBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: context.paletteColors.overlay,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(Icons.send, size: 16, color: colorScheme.surface),
    );
  }
}
