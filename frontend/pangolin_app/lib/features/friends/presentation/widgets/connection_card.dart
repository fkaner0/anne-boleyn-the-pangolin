import 'package:flutter/material.dart';

import 'package:pangolin_app/features/friends/domain/friend.dart';
import 'package:pangolin_app/theme/palette_colors.dart';
import 'package:pangolin_app/widgets/splodge.dart';

class ConnectionCard extends StatelessWidget {
  final Friend friend;
  final int variant;
  final VoidCallback? onTap;

  const ConnectionCard({
    super.key,
    required this.friend,
    required this.variant,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipPath(
                    clipper: SplodgeClipper(variant: variant),
                    child: _CollageBackground(images: friend.coverImages),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: _MainImageBadge(url: friend.mainImage),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            friend.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollageBackground extends StatelessWidget {
  final List<String> images;

  const _CollageBackground({required this.images});

  @override
  Widget build(BuildContext context) {
    final muted = context.paletteColors.surfaceMuted;

    if (images.isEmpty) {
      return ColoredBox(color: muted);
    }

    return ColoredBox(
      color: muted,
      child: GridView.count(
        crossAxisCount: 2,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        children: [
          for (final url in images)
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  ColoredBox(color: muted),
            ),
        ],
      ),
    );
  }
}

class _MainImageBadge extends StatelessWidget {
  static const double _size = 60;

  final String url;

  const _MainImageBadge({required this.url});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.surface, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isEmpty
          ? _placeholder(colorScheme)
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _placeholder(colorScheme),
            ),
    );
  }

  Widget _placeholder(ColorScheme colorScheme) {
    return ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.person, color: colorScheme.onSurfaceVariant),
    );
  }
}
