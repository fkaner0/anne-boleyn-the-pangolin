import 'package:pangolin_app/features/recommendation/data/recommendation_fetcher.dart';

import '../domain/recommendation.dart';

class MockRecommendationRepository implements RecommendationFetcher {
  @override
  Future<List<Recommendation>> fetchRecommendations() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return const [
      Recommendation(
        userId: 0,
        name: 'Tim Johnson',
        location: 'Harrow, London',
        bio: 'Budding watercolour artist, been enjoying painting ponds.',
        imageUrl: 'https://via.placeholder.com/150',
      ),
      Recommendation(
        userId: 1,
        name: 'Sally Parks',
        location: 'Hammersmith, London',
        bio: 'I love apples. I love still life. I love drawing apples in still life.',
        imageUrl: 'https://via.placeholder.com/150',
      ),
      Recommendation(
        userId: 2,
        name: 'Selena Davis',
        location: 'Richmond, London',
        bio: 'Finger painting fanatic, check out my pangolin art.',
        imageUrl: 'https://via.placeholder.com/150',
      ),
    ];
  }
}