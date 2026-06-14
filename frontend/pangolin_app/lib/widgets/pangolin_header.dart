import 'package:flutter/material.dart';

import 'package:pangolin_app/widgets/header_banner.dart';

class PangolinHeader extends StatelessWidget {
  static const double _actionRowExtent = 56;

  final String title;
  final VoidCallback? onTap;
  final Widget? leading;
  final List<Widget> actions;
  final bool floatActionsOverBody;
  final Widget Function(BuildContext context, double topInset) bodyBuilder;

  const PangolinHeader({
    super.key,
    required this.title,
    this.onTap,
    this.leading,
    this.actions = const [],
    this.floatActionsOverBody = false,
    required this.bodyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bannerHeight = HeaderBanner.heightFor(context);
    final hasButtons = leading != null || actions.isNotEmpty;
    final topInset =
        bannerHeight +
        (hasButtons && !floatActionsOverBody ? _actionRowExtent : 0);

    Widget banner = SizedBox(
      height: bannerHeight,
      width: double.infinity,
      child: OverflowBox(
        alignment: Alignment.topCenter,
        maxHeight: double.infinity,
        child: HeaderBanner(
          overlay: Positioned(
            top: -6,
            left: 0,
            right: 0,
            height: bannerHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      banner = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: banner,
      );
    }

    return Stack(
      children: [
        Positioned.fill(child: bodyBuilder(context, topInset)),
        Positioned(top: 0, left: 0, right: 0, child: banner),
        if (hasButtons)
          Positioned(
            top: bannerHeight,
            left: 16,
            right: 16,
            child: Row(children: [?leading, const Spacer(), ...actions]),
          ),
      ],
    );
  }
}
