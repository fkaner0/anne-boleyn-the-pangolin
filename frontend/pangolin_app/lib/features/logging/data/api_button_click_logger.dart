import 'dart:convert';

import 'package:http/http.dart' as http;

import 'button_click_logger.dart';

class ApiButtonClickLogger implements ButtonClickLogger {
  final String host;
  final int? port;
  final bool useHttps;

  const ApiButtonClickLogger({
    this.host = 'localhost',
    this.port,
    this.useHttps = false,
  });

  @override
  Future<void> logButtonClick({
    required int userId,
    required String buttonId,
  }) async {
    final authority = port == null ? host : '$host:$port';
    final uri = useHttps
        ? Uri.https(authority, '/debug/button-click')
        : Uri.http(authority, '/debug/button-click');

    final body = jsonEncode({
      'userId': userId,
      'buttonId': buttonId,
      'datetime': DateTime.now().millisecondsSinceEpoch,
    });

    try {
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
    } catch (_) {}
  }
}
