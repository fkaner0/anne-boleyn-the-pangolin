import 'package:flutter/material.dart';
import 'package:pangolin_app/widgets/pangolin_header.dart';

class ProfileHeaderBar extends StatelessWidget {
  final String name;
  final String location;
  final VoidCallback onBackPressed;
  final Widget Function(BuildContext context, double topInset) bodyBuilder;

  const ProfileHeaderBar({
    super.key,
    required this.name,
    required this.location,
    required this.onBackPressed,
    required this.bodyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return PangolinHeader(
      title: name,
      onBack: onBackPressed,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            location,
            style: const TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
        ),
      ],
      bodyBuilder: bodyBuilder,
    );
  }
}
