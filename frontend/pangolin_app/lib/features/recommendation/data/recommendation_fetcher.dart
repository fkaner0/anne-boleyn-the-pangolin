import '../domain/recommendation.dart';

abstract class RecommendationFetcher {
  Future<List<Recommendation>> fetchRecommendations();
}