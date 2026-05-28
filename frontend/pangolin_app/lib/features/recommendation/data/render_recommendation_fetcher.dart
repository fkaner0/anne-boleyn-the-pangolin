import '../domain/recommendation.dart';
import 'api_recommendation_fetcher.dart';
import 'recommendation_fetcher.dart';

class RenderRecommendationFetcher implements RecommendationFetcher {
  final ApiRecommendationFetcher _delegate = const ApiRecommendationFetcher(
    host: 'anne-boleyn-the-pangolin.onrender.com',
  );

  @override
  Future<List<Recommendation>> fetchRecommendations() {
    return _delegate.fetchRecommendations();
  }
}
