import 'package:pangolin_app/features/recommendation/data/recommendation_fetcher.dart';

import '../domain/recommendation.dart';

class MockRecommendationFetcher implements RecommendationFetcher {
  @override
  Future<List<Recommendation>> fetchRecommendations(int userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final recommendations = [
      Recommendation(
        userId: 0,
        name: 'Tim Johnson',
        age: 27,
        location: 'Harrow, London',
        bio: 'Watercolouring a new pond every day',
        imageUrl: 'https://via.placeholder.com/150',
      ),
      Recommendation(
        userId: 1,
        name: 'Sally Parks',
        age: 34,
        location: 'Hammersmith, London',
        bio: 'still-4-lyferrrr',
        imageUrl: 'https://via.placeholder.com/150',
      ),
      Recommendation(
        userId: 2,
        name: 'Selena Davis',
        age: 22,
        location: 'Richmond, London',
        bio: 'willing to try anything new and messy',
        imageUrl: 'https://via.placeholder.com/150',
      ),
      Recommendation(
        userId: 3,
        name: 'Marcus Lee',
        age: 31,
        location: 'Shoreditch, London',
        bio:
            'Avid potter and watercolourist who loves long countryside walks, '
            'vintage cameras, and very strong coffee.',
        imageUrl: 'https://via.placeholder.com/150',
      ),
    ];
    return recommendations.where((rec) => rec.userId != userId).toList();
  }
}
