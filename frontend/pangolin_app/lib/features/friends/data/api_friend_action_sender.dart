import 'dart:convert';

import 'package:http/http.dart' as http;

import 'friend_action_sender.dart';

class ApiFriendActionSender implements FriendActionSender {
  final String host;
  final int? port;
  final bool useHttps;

  const ApiFriendActionSender({
    this.host = 'localhost',
    this.port,
    this.useHttps = true,
  });

  Uri _uri(String path) {
    final authority = port == null ? host : '$host:$port';
    return useHttps ? Uri.https(authority, path) : Uri.http(authority, path);
  }

  Future<void> _send(String path, int currentUserId, int targetUserId) async {
    final response = await http.post(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'currentUserId': currentUserId,
        'targetUserId': targetUserId,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to POST $path: ${response.statusCode}');
    }
  }

  @override
  Future<void> report({
    required int currentUserId,
    required int targetUserId,
  }) => _send('/friends/report/', currentUserId, targetUserId);

  @override
  Future<void> remove({
    required int currentUserId,
    required int targetUserId,
  }) => _send('/friends/remove/', currentUserId, targetUserId);

  @override
  Future<void> reject({
    required int currentUserId,
    required int targetUserId,
  }) => _send('/friends/reject/', currentUserId, targetUserId);
}
