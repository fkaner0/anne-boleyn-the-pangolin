import 'package:flutter/material.dart';

import 'package:pangolin_app/widgets/app_icon.dart';
import '../../domain/shared_element.dart';

class SharedElementTile extends StatelessWidget {
  final SharedElement element;
  final VoidCallback onTap;

  const SharedElementTile({
    super.key,
    required this.element,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final latest = element.latestReply;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: element.isImage
                ? Image.network(
                    element.content,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _fallback(
                      colorScheme,
                      const AppIcon(AppIconType.brokenImage),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(20),
                    color: colorScheme.surfaceContainerHighest,
                    child: Text(
                      element.content,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
          ),
          if (latest != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
              child: Text(
                latest.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallback(ColorScheme colorScheme, Widget child) {
    return AspectRatio(
      aspectRatio: 1,
      child: ColoredBox(
        color: colorScheme.surfaceContainerHighest,
        child: Center(child: child),
      ),
    );
  }
}
