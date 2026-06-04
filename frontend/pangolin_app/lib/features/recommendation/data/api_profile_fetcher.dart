import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/domain/profile.dart';

class ApiProfileFetcher implements ProfileFetcher {
  final String host;
  final int? port;
  final bool useHttps;

  const ApiProfileFetcher({
    this.host = 'localhost',
    this.port,
    this.useHttps = true,
  });

  @override
  Future<Profile> fetchProfile(int userId) async {
    String baseUrl;
    if (port == null) {
      baseUrl = host;
    } else {
      baseUrl = '$host:$port';
    }
    final uri = useHttps
        ? Uri.https(baseUrl, '/profile/view/$userId')
        : Uri.http(baseUrl, '/profile/view/$userId');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch recommendations: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    return Profile.fromJson(decoded as Map<String, dynamic>);
  }
}
