import 'package:pangolin_app/config/env.dart';

import '../domain/recommendation.dart';
import 'api_recommendation_fetcher.dart';
import 'recommendation_fetcher.dart';

class RenderRecommendationFetcher implements RecommendationFetcher {
  final ApiRecommendationFetcher _delegate;

  RenderRecommendationFetcher({String host = defaultRenderHost})
    : _delegate = ApiRecommendationFetcher(host: host);

  @override
  Future<List<Recommendation>> fetchRecommendations() {
    return _delegate.fetchRecommendations();
  }
}
