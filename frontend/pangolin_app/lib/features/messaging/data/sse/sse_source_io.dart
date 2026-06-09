import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'sse_event_parser.dart';

Stream<String> sseDataStream(Uri uri) {
  http.Client? client;
  var active = true;
  late final StreamController<String> controller;

  Future<void> run() async {
    var backoff = const Duration(seconds: 1);

    while (active) {
      client = http.Client();
      try {
        final request = http.Request('GET', uri)
          ..headers['Accept'] = 'text/event-stream'
          ..headers['Cache-Control'] = 'no-cache';

        final response = await client!.send(request);
        if (response.statusCode != 200) {
          throw http.ClientException(
            'Unexpected status ${response.statusCode}',
          );
        }

        backoff = const Duration(seconds: 1);

        final lines = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        await for (final data in decodeSseData(lines)) {
          if (!active) break;
          if (!controller.isClosed) controller.add(data);
        }
      } catch (_) {
        // Swallow and reconnect below.
      } finally {
        client?.close();
        client = null;
      }

      if (!active) break;
      await Future<void>.delayed(backoff);
      backoff = _nextBackoff(backoff);
    }
  }

  controller = StreamController<String>(
    onListen: () => unawaited(run()),
    onCancel: () {
      active = false;
      client?.close();
      client = null;
    },
  );

  return controller.stream;
}

Duration _nextBackoff(Duration current) {
  const max = Duration(seconds: 30);
  final next = current * 2;
  return next > max ? max : next;
}
