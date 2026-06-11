import 'package:flutter/material.dart';
import 'package:pangolin_app/widgets/app_icon.dart';

class ProfileHeaderBar extends StatelessWidget {
  final String name;
  final String location;
  final VoidCallback onBackPressed;

  const ProfileHeaderBar({
    super.key,
    required this.name,
    required this.location,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(location, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: onBackPressed,
                icon: const AppIcon(AppIconType.back),
                tooltip: 'Back',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
