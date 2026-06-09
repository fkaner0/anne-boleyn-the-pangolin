import 'dart:async';
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

  Uri _uri(String path) {
    final authority = port == null ? host : '$host:$port';
    return useHttps ? Uri.https(authority, path) : Uri.http(authority, path);
  }

  @override
  Stream<SharedElement> listen(int userId) {
    return sseDataStream(_uri('/message/listen/$userId')).transform(
      StreamTransformer<String, SharedElement>.fromHandlers(
        handleData: (data, sink) {
          final element = _tryParse(data);
          if (element != null) sink.add(element);
        },
      ),
    );
  }

  SharedElement? _tryParse(String data) {
    if (data.isEmpty) return null;
    try {
      final decoded = jsonDecode(data);
      if (decoded is! Map<String, dynamic>) return null;
      return SharedElement.fromJson(decoded);
    } catch (_) {
      return null;
    }
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
    required int datetime,
  }) {
    return _post('/message/send/image', {
      'senderId': senderId,
      'receiverId': receiverId,
      'url': url,
      'datetime': datetime,
    });
  }

  @override
  Future<void> sendText({
    required int senderId,
    required int receiverId,
    required String text,
    required int datetime,
  }) {
    return _post('/message/send/text', {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'datetime': datetime,
    });
  }

  @override
  Future<void> sendReply({
    required int sharedElementId,
    required int senderId,
    required int receiverId,
    required String text,
    required int datetime,
  }) {
    return _post('/message/send/reply', {
      'sharedElementId': sharedElementId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'datetime': datetime,
    });
  }
}
