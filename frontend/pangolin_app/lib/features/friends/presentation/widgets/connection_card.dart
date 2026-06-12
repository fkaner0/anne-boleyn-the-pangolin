import 'package:flutter/material.dart';

import 'package:pangolin_app/features/friends/domain/friend.dart';
import 'package:pangolin_app/theme/palette_colors.dart';
import 'package:pangolin_app/widgets/app_icon.dart';
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
                    child: _CollageBackground(
                      images: friend.coverImages,
                      friendName: friend.name,
                    ),
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
  static const int _maxImages = 4;

  final List<String> images;
  final String friendName;

  const _CollageBackground({required this.images, required this.friendName});

  @override
  Widget build(BuildContext context) {
    final muted = context.paletteColors.surfaceMuted;

    if (images.isEmpty) {
      return _EmptyCollage(friendName: friendName);
    }

    return ColoredBox(color: muted, child: _layout(muted));
  }

  Widget _layout(Color muted) {
    final urls = images.take(_maxImages).toList();

    switch (urls.length) {
      case 1:
        return _tile(urls[0], muted);
      case 2:
        return _splitRow([_tile(urls[0], muted), _tile(urls[1], muted)]);
      case 3:
        return _splitRow([
          _tile(urls[0], muted),
          _splitColumn([_tile(urls[1], muted), _tile(urls[2], muted)]),
        ]);
      default:
        return _splitColumn([
          _splitRow([_tile(urls[0], muted), _tile(urls[1], muted)]),
          _splitRow([_tile(urls[2], muted), _tile(urls[3], muted)]),
        ]);
    }
  }

  Widget _tile(String url, Color muted) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => ColoredBox(color: muted),
    );
  }

  Widget _splitRow(List<Widget> children) => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: _expanded(children),
  );

  Widget _splitColumn(List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: _expanded(children),
  );

  List<Widget> _expanded(List<Widget> children) => [
    for (final child in children) Expanded(child: child),
  ];
}

class _EmptyCollage extends StatelessWidget {
  final String friendName;

  const _EmptyCollage({required this.friendName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ColoredBox(
      color: context.paletteColors.surfaceMuted,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                AppIconType.wallpaper,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                'Send an image to $friendName to see your collage',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
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
      child: AppIcon(AppIconType.person, color: colorScheme.onSurfaceVariant),
    );
  }
}
