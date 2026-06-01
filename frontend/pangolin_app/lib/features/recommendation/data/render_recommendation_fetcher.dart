import '../domain/recommendation.dart';
import 'api_recommendation_fetcher.dart';
import 'recommendation_fetcher.dart';

class RenderRecommendationFetcher implements RecommendationFetcher {
  final ApiRecommendationFetcher _delegate;

  RenderRecommendationFetcher({String host = 'anne-boleyn-the-pangolin-huqk.onrender.com'}) : _delegate = ApiRecommendationFetcher(host: host);

  @override
  Future<List<Recommendation>> fetchRecommendations() {
    return _delegate.fetchRecommendations();
  }
}
