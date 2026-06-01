import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/profile_text.dart';

class BedroomWallTextBoxItem extends StatelessWidget {
  final ProfileText textbox;

  const BedroomWallTextBoxItem({super.key, required this.textbox});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: textbox.position.x.toDouble(),
      top: textbox.position.y.toDouble(),
      child: Transform.rotate(
        angle: textbox.position.rotation * math.pi / 180,
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.yellow.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.yellow.shade700),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                textbox.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(textbox.body, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
