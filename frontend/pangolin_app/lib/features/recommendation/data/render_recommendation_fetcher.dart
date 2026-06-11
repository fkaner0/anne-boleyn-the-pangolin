import 'package:pangolin_app/config/env.dart';

import '../domain/recommendation.dart';
import 'api_recommendation_fetcher.dart';
import 'recommendation_fetcher.dart';

class RenderRecommendationFetcher implements RecommendationFetcher {
  final ApiRecommendationFetcher _delegate;

  RenderRecommendationFetcher({
    String host = defaultRenderHost,
    int? port,
    bool useHttps = true,
  }) : _delegate = ApiRecommendationFetcher(
         host: host,
         port: port,
         useHttps: useHttps,
       );

  @override
  Future<List<Recommendation>> fetchRecommendations(int userId) {
    return _delegate.fetchRecommendations(userId);
  }
}
