import 'package:flutter/material.dart';
import '../../data/recommendation_fetcher.dart';
import '../../domain/recommendation.dart';
import '../widgets/recommendation_list_item.dart';

class RecommendationListPage extends StatelessWidget {
  final RecommendationFetcher recommendationFetcher;

  const RecommendationListPage({
    super.key,
    required this.recommendationFetcher,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendations'),
      ),
      body: FutureBuilder<List<Recommendation>>(
        future: recommendationFetcher.fetchRecommendations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final recommendations = snapshot.data ?? [];

          if (recommendations.isEmpty) {
            return const Center(
              child: Text('No recommendations available'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];

              return RecommendationListItem(
                recommendation: recommendation,
                onAccept: () {
                  debugPrint('Accepted ${recommendation.name}');
                },
                onReject: () {
                  debugPrint('Rejected ${recommendation.name}');
                },
              );
            },
          );
        },
      ),
    );
  }
}