import 'package:flutter/material.dart';
import 'package:pangolin_app/widgets/app_icon.dart';
import 'package:pangolin_app/widgets/pangolin_header.dart';

class ProfileHeaderBar extends StatelessWidget {
  final String name;
  final String location;
  final VoidCallback onBackPressed;
  final bool floatActionsOverBody;
  final Widget Function(BuildContext context, double topInset) bodyBuilder;

  const ProfileHeaderBar({
    super.key,
    required this.name,
    required this.location,
    required this.onBackPressed,
    this.floatActionsOverBody = false,
    required this.bodyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PangolinHeader(
      title: name,
      floatActionsOverBody: floatActionsOverBody,
      leading: IconButton.filledTonal(
        onPressed: onBackPressed,
        icon: const AppIcon(AppIconType.back),
        tooltip: 'Back',
      ),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            location,
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
      bodyBuilder: bodyBuilder,
    );
  }
}
