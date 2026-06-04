import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/recommendation.dart';
import 'recommendation_fetcher.dart';

class ApiRecommendationFetcher implements RecommendationFetcher {
  final String host;
  final int? port;
  final bool useHttps;

  const ApiRecommendationFetcher({
    this.host = 'localhost',
    this.port,
    this.useHttps = true,
  });

  @override
  Future<List<Recommendation>> fetchRecommendations() async {
    String baseUrl;
    if (port == null) {
      baseUrl = host;
    } else {
      baseUrl = '$host:$port';
    }
    final uri = useHttps
        ? Uri.https(baseUrl, '/recommendations')
        : Uri.http(baseUrl, '/recommendations');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch recommendations: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception('Expected a JSON list from /recommendations');
    }

    return decoded
        .map((item) => Recommendation.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
