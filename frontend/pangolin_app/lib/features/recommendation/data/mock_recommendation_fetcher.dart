import 'package:pangolin_app/features/recommendation/data/recommendation_fetcher.dart';

import '../domain/recommendation.dart';

class MockRecommendationFetcher implements RecommendationFetcher {
  @override
  Future<List<Recommendation>> fetchRecommendations() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return const [
      Recommendation(
        userId: 0,
        name: 'Tim Johnson',
        location: 'Harrow, London',
        bio: 'Watercolouring a new pond every day',
        imageUrl: 'https://via.placeholder.com/150',
      ),
      Recommendation(
        userId: 1,
        name: 'Sally Parks',
        location: 'Hammersmith, London',
        bio: 'still-4-lyferrrr',
        imageUrl: 'https://via.placeholder.com/150',
      ),
      Recommendation(
        userId: 2,
        name: 'Selena Davis',
        location: 'Richmond, London',
        bio: 'willing to try anything new and messy',
        imageUrl: 'https://via.placeholder.com/150',
      ),
    ];
  }
}
