import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pangolin_app/features/auth/data/authoriser.dart';

class ApiAuthoriser implements Authoriser {
  final String host;
  final int? port;
  final bool useHttps;

  const ApiAuthoriser({
    this.host = 'localhost',
    this.port,
    this.useHttps = true,
  });

  @override
  Future<int> getNewUserId(String username) async {
    String baseUrl;
    if (port == null) {
      baseUrl = host;
    } else {
      baseUrl = '$host:$port';
    }
    final uri = useHttps
        ? Uri.https(baseUrl, '/auth/$username')
        : Uri.http(baseUrl, '/auth/$username');

    final response = await http.post(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get a new userId for $username. May already exist: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    final userId = decoded['userId'];
    if (userId is! int) {
      throw FormatException('Expected userId to be an int, got $userId');
    }
    return userId;
  }

  @override
  Future<int> getExistingUserId(String username) async {
    String baseUrl;
    if (port == null) {
      baseUrl = host;
    } else {
      baseUrl = '$host:$port';
    }
    final uri = useHttps
        ? Uri.https(baseUrl, '/auth/$username')
        : Uri.http(baseUrl, '/auth/$username');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get existing userId for $username. May not exist yet: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    final userId = decoded['userId'];
    if (userId is! int) {
      throw FormatException('Expected userId to be an int, got $userId');
    }
    return userId;
  }
}
