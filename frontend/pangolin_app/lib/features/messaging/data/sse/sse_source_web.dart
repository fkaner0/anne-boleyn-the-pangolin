import 'dart:async';
import 'dart:convert';

import 'package:fetch_client/fetch_client.dart';
import 'package:http/http.dart';

/// Returns a [Stream] that emits once for every Server-Sent Event received
/// from [uri]. The event contents are intentionally ignored.
///
/// Example:
/// ```dart
/// sseStream(Uri.parse('https://example.com/events')).listen((_) {
///   print('Event received!');
/// });
/// ```
Stream<void> sseStream(Uri uri, {Map<String, String>? headers}) async* {
  final client = FetchClient(mode: RequestMode.cors);

  try {
    final request = Request('GET', uri);

    request.headers.addAll({
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      ...?headers,
    });

    final response = await client.send(request);

    if (response.statusCode != 200) {
      throw Exception(
        'SSE connection failed with status: ${response.statusCode}',
      );
    }

    // Decode the byte stream into lines — a blank line = one complete event.
    final lineStream = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lineStream) {
      // A blank line signals a complete event — emit a void signal.
      if (line.isEmpty) yield null;
      // All other lines (data, id, event, comments) are intentionally ignored.
    }
  } finally {
    client.close();
  }
}
