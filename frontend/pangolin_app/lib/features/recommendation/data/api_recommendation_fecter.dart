import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/recommendation.dart';
import 'recommendation_fetcher.dart';

class ApiRecommendationFetcher implements RecommendationFetcher {
  final String host;
  final int port;

  const ApiRecommendationFetcher({this.host = 'localhost', required this.port});

  @override
  Future<List<Recommendation>> fetchRecommendations() async {
    final uri = Uri.http('$host:$port', '/recommendations');

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
