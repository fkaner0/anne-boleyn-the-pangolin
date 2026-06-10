import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/shared_element.dart';
import 'shared_board_service.dart';
import 'sse/sse_source.dart';

class ApiSharedBoardService implements SharedBoardService {
  final String host;
  final int? port;
  final bool useHttps;
  final http.Client _client;

  ApiSharedBoardService({
    this.host = 'localhost',
    this.port,
    this.useHttps = true,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final authority = port == null ? host : '$host:$port';
    return useHttps
        ? Uri.https(authority, path, query)
        : Uri.http(authority, path, query);
  }

  @override
  Stream<void> notifications(int userId) {
    return sseEventStream(_uri('/message/listen/$userId'));
  }

  @override
  Future<List<SharedElement>> fetchBoard(int userId, int friendUserId) async {
    final response = await _client.get(
      _uri('/message/board', {
        'user1Id': '$userId',
        'user2Id': '$friendUserId',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch shared board: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Expected a JSON object from /message/board');
    }

    final elems = decoded['elems'] as List<dynamic>? ?? const [];
    return elems
        .map((e) => SharedElement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _post(String path, Map<String, dynamic> body) async {
    final response = await _client.post(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }

  @override
  Future<void> sendImage({
    required int senderId,
    required int receiverId,
    required String url,
    required String message,
    int? datetime,
  }) {
    return _post('/message/send/image', {
      'senderId': senderId,
      'receiverId': receiverId,
      'url': url,
      'message': message,
      'datetime': datetime ?? SharedBoardService.now(),
    });
  }

  @override
  Future<void> sendText({
    required int senderId,
    required int receiverId,
    required String text,
    required String message,
    int? datetime,
  }) {
    return _post('/message/send/text', {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'message': message,
      'datetime': datetime ?? SharedBoardService.now(),
    });
  }

  @override
  Future<void> sendReply({
    required int sharedElementId,
    required int senderId,
    required int receiverId,
    required String text,
    int? datetime,
  }) {
    return _post('/message/send/reply', {
      'sharedElementId': sharedElementId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'datetime': datetime ?? SharedBoardService.now(),
    });
  }
}
