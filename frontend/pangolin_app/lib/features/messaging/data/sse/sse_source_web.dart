import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

Stream<String> sseDataStream(Uri uri) {
  web.EventSource? source;
  late final StreamController<String> controller;

  controller = StreamController<String>(
    onListen: () {
      final eventSource = web.EventSource(uri.toString());
      source = eventSource;
      eventSource.onmessage = (web.MessageEvent event) {
        final data = event.data;
        if (data != null && data.isA<JSString>()) {
          if (!controller.isClosed) controller.add((data as JSString).toDart);
        }
      }.toJS;
    },
    onCancel: () {
      source?.close();
      source = null;
    },
  );

  return controller.stream;
}
