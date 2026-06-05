import 'package:flutter/material.dart';
import '../../domain/recommendation.dart';
import 'info_box.dart';

class RecommendationListItem extends StatelessWidget {
  final Recommendation recommendation;
  final VoidCallback onTap;

  const RecommendationListItem({
    super.key,
    required this.recommendation,
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: InfoBox.fromRecommendation(recommendation),
      ),
    );
  }
}
