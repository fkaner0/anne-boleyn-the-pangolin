import 'package:flutter/material.dart';

import 'package:pangolin_app/widgets/header_back_button.dart';
import 'package:pangolin_app/widgets/header_banner.dart';

class PangolinHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final double contentInset;
  final Widget Function(BuildContext context, double topInset) bodyBuilder;

  const PangolinHeader({
    super.key,
    required this.title,
    this.onTap,
    this.onBack,
    this.actions = const [],
    this.contentInset = 16,
    required this.bodyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bannerHeight = HeaderBanner.heightFor(context);

    Widget banner = SizedBox(
      height: bannerHeight,
      width: double.infinity,
      child: OverflowBox(
        alignment: Alignment.topCenter,
        maxHeight: double.infinity,
        child: HeaderBanner(
          overlay: Positioned(
            top: -10,
            left: onBack != null ? 8 : contentInset,
            right: 8,
            height: bannerHeight,
            child: OverflowBox(
              maxHeight: double.infinity,
              alignment: Alignment.center,
              child: Row(
                children: [
                  if (onBack != null) ...[
                    HeaderBackButton(onPressed: onBack!),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ...actions,
                ],
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
        Positioned.fill(child: bodyBuilder(context, bannerHeight)),
        Positioned(top: 0, left: 0, right: 0, child: banner),
      ],
    );
  }
}
