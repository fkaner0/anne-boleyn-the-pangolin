import 'package:flutter/material.dart';
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: InfoBox(
                recommendation: recommendation,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: onAccept,
                icon: const Icon(Icons.check_circle, color: Colors.green),
              ),
              const SizedBox(height: 8),
              IconButton(
                onPressed: onReject,
                icon: const Icon(Icons.cancel, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}