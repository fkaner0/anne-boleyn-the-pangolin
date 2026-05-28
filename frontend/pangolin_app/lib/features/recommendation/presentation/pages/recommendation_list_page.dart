import 'package:flutter/material.dart';
import 'package:pangolin_app/features/recommendation/data/profile_rejection_decider.dart';
import 'package:pangolin_app/features/recommendation/data/render_profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/recommendation_profile_page.dart';
import '../../data/recommendation_fetcher.dart';
import '../../domain/recommendation.dart';
import '../widgets/recommendation_list_item.dart';

class RecommendationListPage extends StatelessWidget {
  final RecommendationFetcher recommendationFetcher;
  final ProfileRejectionDecider profileRejectionDecider;

  const RecommendationListPage({
    super.key,
    required this.recommendationFetcher,
    required this.profileRejectionDecider
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recommendations')),
      body: FutureBuilder<List<Recommendation>>(
        future: recommendationFetcher.fetchRecommendations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final recommendations = snapshot.data ?? [];

          if (recommendations.isEmpty) {
            return const Center(child: Text('No recommendations available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];

              return RecommendationListItem(
                recommendation: recommendation,
                onAccept: () {
                  profileRejectionDecider.putProfileRejection(userId: recommendation.userId, rejected: false);
                },
                onReject: () {
                  profileRejectionDecider.putProfileRejection(userId: recommendation.userId, rejected: true);
                },
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RecommendationProfilePage(
                        profileFetcher: RenderProfileFetcher(),
                        userId: recommendation.userId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
