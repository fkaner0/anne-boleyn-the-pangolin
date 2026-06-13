import 'package:flutter/material.dart';

import 'package:pangolin_app/widgets/app_icon.dart';
import 'package:pangolin_app/widgets/loading_network_image.dart';
import '../../domain/shared_element.dart';
import '../../domain/shared_reply.dart';

class SharedElementTile extends StatelessWidget {
  final SharedElement element;
  final int userId;
  final String friendName;
  final VoidCallback onTap;

  const SharedElementTile({
    super.key,
    required this.element,
    required this.userId,
    required this.friendName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final replies = element.replies;
    final recent = replies.length <= 2
        ? replies
        : replies.sublist(replies.length - 2);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: element.isImage
                  ? LoadingNetworkImage(
                      url: element.content,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: MediaQuery.sizeOf(context).height / 5,
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
            if (recent.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (index, reply) in recent.indexed) ...[
                      if (index > 0) const SizedBox(height: 6),
                      _message(context, reply),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _message(BuildContext context, SharedReply reply) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMine = reply.senderId == userId;
    final prefix = isMine ? 'You: ' : '$friendName: ';
    final weight = element.read ? FontWeight.normal : FontWeight.bold;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: prefix,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          TextSpan(text: reply.text),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: weight,
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
