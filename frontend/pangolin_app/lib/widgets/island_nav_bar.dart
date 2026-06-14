import 'package:flutter/material.dart';

import 'package:pangolin_app/theme/palette_colors.dart';
import 'package:pangolin_app/widgets/app_icon.dart';
import 'package:pangolin_app/widgets/pangolin_mascot.dart';

enum IslandNavTab { editProfile, recommendations, friends }

class PangolinNavBar extends StatelessWidget {
  static const double _mascotHeight = PangolinMascot.navBarHeight;
  static const double _clawOverlap = 100;

  final PangolinMascotController mascotController;
  final IslandNavTab current;
  final VoidCallback onEditProfile;
  final VoidCallback onRecommendations;
  final VoidCallback? onFriends;

  const PangolinNavBar({
    super.key,
    required this.mascotController,
    required this.current,
    required this.onEditProfile,
    required this.onRecommendations,
    this.onFriends,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IslandNavBar(
          current: current,
          onEditProfile: onEditProfile,
          onRecommendations: onRecommendations,
          onFriends: onFriends,
        ),
        Positioned(
          top: _clawOverlap - _mascotHeight,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Center(
              child: PangolinMascot(
                controller: mascotController,
                height: _mascotHeight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
    final palette = context.paletteColors;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _IslandNavItem(
              filledIcon: AppIconType.meFilled,
              unfilledIcon: AppIconType.meUnfilled,
              selected: current == IslandNavTab.editProfile,
              onTap: () => _select(IslandNavTab.editProfile, onEditProfile),
            ),
            _IslandNavItem(
              filledIcon: AppIconType.findFilled,
              unfilledIcon: AppIconType.findUnfilled,
              selected: current == IslandNavTab.recommendations,
              onTap: () =>
                  _select(IslandNavTab.recommendations, onRecommendations),
            ),
            _IslandNavItem(
              filledIcon: AppIconType.palsFilled,
              unfilledIcon: AppIconType.palsUnfilled,
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
  final bool selected;
  final VoidCallback? onTap;

  const _IslandNavItem({
    required this.filledIcon,
    required this.unfilledIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.paletteColors;
    final enabled = onTap != null;

    Widget icon = AppIcon(selected ? filledIcon : unfilledIcon, size: 30);
    if (!enabled) {
      icon = Opacity(opacity: 0.38, child: icon);
    }

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? palette.pangolin : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: icon,
      ),
    );
  }
}
