import 'package:flutter/material.dart';

import 'package:pangolin_app/widgets/app_icon.dart';

enum IslandNavTab { editProfile, recommendations, friends }

class IslandNavBar extends StatelessWidget {
  final IslandNavTab current;
  final VoidCallback onEditProfile;
  final VoidCallback onRecommendations;
  final VoidCallback? onFriends;

  const IslandNavBar({
    super.key,
    required this.current,
    required this.onEditProfile,
    required this.onRecommendations,
    this.onFriends,
  });

  void _select(IslandNavTab tab, VoidCallback? action) {
    if (tab == current) return;
    action?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _IslandNavItem(
              filledIcon: AppIconType.meFilled,
              unfilledIcon: AppIconType.meUnfilled,
              label: 'Profile',
              selected: current == IslandNavTab.editProfile,
              onTap: () => _select(IslandNavTab.editProfile, onEditProfile),
            ),
            _IslandNavItem(
              filledIcon: AppIconType.findFilled,
              unfilledIcon: AppIconType.findUnfilled,
              label: 'Recommendations',
              selected: current == IslandNavTab.recommendations,
              onTap: () =>
                  _select(IslandNavTab.recommendations, onRecommendations),
            ),
            _IslandNavItem(
              filledIcon: AppIconType.palsFilled,
              unfilledIcon: AppIconType.palsUnfilled,
              label: 'Friends',
              selected: current == IslandNavTab.friends,
              onTap: onFriends == null
                  ? null
                  : () => _select(IslandNavTab.friends, onFriends),
            ),
          ],
        ),
      ),
    );
  }
}

class _IslandNavItem extends StatelessWidget {
  final AppIconType filledIcon;
  final AppIconType unfilledIcon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _IslandNavItem({
    required this.filledIcon,
    required this.unfilledIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;

    Widget icon = AppIcon(selected ? filledIcon : unfilledIcon, size: 24);
    if (!enabled) {
      icon = Opacity(opacity: 0.38, child: icon);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 16 : 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            if (selected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
