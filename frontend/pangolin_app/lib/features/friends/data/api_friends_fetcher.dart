import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/current_friends.dart';
import '../domain/pending_friend.dart';
import 'friends_fetcher.dart';

class ApiFriendsFetcher implements FriendsFetcher {
  final String host;
  final int? port;
  final bool useHttps;

  const ApiFriendsFetcher({
    this.host = 'localhost',
    this.port,
    this.useHttps = true,
  });

  Uri _uri(String path) {
    final authority = port == null ? host : '$host:$port';
    return useHttps ? Uri.https(authority, path) : Uri.http(authority, path);
  }

  @override
  Future<CurrentFriends> fetchCurrentFriends(int userId) async {
    final response = await http.get(_uri('/friends/current/$userId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch friends: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Expected a JSON object from /friends/current');
    }

    return CurrentFriends.fromJson(decoded);
  }

  @override
  Future<List<PendingFriend>> fetchPendingFriends(int userId) async {
    final response = await http.get(_uri('/friends/pending/$userId'));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch pending friends: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Expected a JSON object from /friends/pending');
    }

    final list =
        (decoded['pendingFriends'] ?? decoded['pendingsFriends']) as List?;

    return (list ?? const [])
        .map((item) => PendingFriend.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
