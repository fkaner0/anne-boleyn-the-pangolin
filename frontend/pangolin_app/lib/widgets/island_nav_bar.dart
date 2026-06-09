import 'package:flutter/material.dart';

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
              icon: Icons.person_outline,
              label: 'Profile',
              selected: current == IslandNavTab.editProfile,
              onTap: () => _select(IslandNavTab.editProfile, onEditProfile),
            ),
            _IslandNavItem(
              icon: Icons.style_outlined,
              label: 'Recommendations',
              selected: current == IslandNavTab.recommendations,
              onTap: () =>
                  _select(IslandNavTab.recommendations, onRecommendations),
            ),
            _IslandNavItem(
              icon: Icons.group_outlined,
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
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _IslandNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;

    final foreground = !enabled
        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.38)
        : selected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

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
            Icon(icon, color: foreground, size: 24),
            if (selected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
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
