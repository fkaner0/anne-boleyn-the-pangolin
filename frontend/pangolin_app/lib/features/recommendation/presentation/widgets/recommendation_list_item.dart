import 'package:flutter/material.dart';
import '../../domain/recommendation.dart';

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
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        recommendation.imageUrl,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 90,
                          height: 90,
                          color: Colors.grey.shade300,
                          alignment: Alignment.center,
                          child: const Icon(Icons.person),
                        );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recommendation.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(recommendation.location),
                            const SizedBox(height: 8),
                            Text(
                              recommendation.bio,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
