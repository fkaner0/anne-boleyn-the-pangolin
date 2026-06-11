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

  Uri _uri(String path, int currentUserId, int targetUserId) {
    final authority = port == null ? host : '$host:$port';
    final query = {
      'currentUid': '$currentUserId',
      'targetUid': '$targetUserId',
    };
    return useHttps
        ? Uri.https(authority, path, query)
        : Uri.http(authority, path, query);
  }

  Future<void> _send(String path, int currentUserId, int targetUserId) async {
    final response = await http.post(_uri(path, currentUserId, targetUserId));

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
