import 'package:flutter/material.dart';
import '../../domain/profile_text.dart';
import 'bedroom_wall_interactive_item.dart';

class BedroomWallTextBoxItem extends BedroomWallInteractiveBase {
  final ProfileText textbox;

  const BedroomWallTextBoxItem({
    super.key,
    required this.textbox,
    required super.onTap,
  }) : super(width: 220);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: textbox.position.x.toDouble(),
      top: textbox.position.y.toDouble(),
      child: Transform.rotate(
        angle: textbox.position.rotation,
        child: super.build(context),
      ),
    );
  }

  @override
  Widget buildInner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            textbox.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(textbox.body, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
