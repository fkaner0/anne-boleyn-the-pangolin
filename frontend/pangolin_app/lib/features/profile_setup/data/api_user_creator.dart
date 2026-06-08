import 'dart:convert';

import 'package:http/http.dart' as http;

import 'user_creator.dart';

class ApiUserCreator implements UserCreator {
  final String host;
  final int? port;
  final bool useHttps;

  const ApiUserCreator({
    this.host = 'localhost',
    this.port,
    this.useHttps = false,
  });

  @override
  Future<int> createUser(String username) async {
    final authority = port == null ? host : '$host:$port';
    final uri = useHttps
        ? Uri.https(authority, '/user')
        : Uri.http(authority, '/user');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to create user $username: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['userId'] as int;
  }
}
