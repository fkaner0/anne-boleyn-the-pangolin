import 'package:flutter/material.dart';
import 'package:pangolin_app/theme/palette_colors.dart';
import '../../domain/recommendation.dart';
import 'info_box.dart';

class RecommendationListItem extends StatelessWidget {
  final Recommendation recommendation;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onTap;

  const RecommendationListItem({
    super.key,
    required this.recommendation,
    required this.onAccept,
    required this.onReject,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: InfoBox(recommendation: recommendation),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: onAccept,
                icon: Icon(
                  Icons.check_circle,
                  color: context.paletteColors.success,
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                onPressed: onReject,
                icon: Icon(Icons.cancel, color: colorScheme.error),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
