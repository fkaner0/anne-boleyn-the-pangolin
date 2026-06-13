import 'package:flutter/material.dart';

class PangolinHeader extends StatelessWidget {
  static const String _bannerAsset = 'assets/icons/header/header.png';
  static const double _bannerAspectRatio = 2557 / 476;

  static double bannerHeightFor(BuildContext context) =>
      MediaQuery.sizeOf(context).width / _bannerAspectRatio;

  final String title;
  final VoidCallback? onTap;
  final List<Widget> actions;

  const PangolinHeader({
    super.key,
    required this.title,
    this.onTap,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget banner = SizedBox(
      height: bannerHeightFor(context),
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(_bannerAsset, fit: BoxFit.fitWidth),
          Padding(
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
        ],
      ),
    );

    if (onTap != null) {
      banner = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: banner,
      );
    }

    if (actions.isEmpty) return banner;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        banner,
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: Row(mainAxisSize: MainAxisSize.min, children: actions),
          ),
        ),
      ],
    );
  }
}
