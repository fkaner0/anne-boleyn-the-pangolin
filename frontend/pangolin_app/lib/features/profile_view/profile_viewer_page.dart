import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pangolin_app/widgets/app_icon.dart';

class ProfileViewerPage extends StatelessWidget {
  final int userId;
  const ProfileViewerPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const AppIcon(AppIconType.back),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          '(Placeholder — Viewing User Profile for $userId)',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
    );
  }
}
