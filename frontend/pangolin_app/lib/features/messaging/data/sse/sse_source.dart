import 'sse_source_io.dart'
    if (dart.library.js_interop) 'sse_source_web.dart'
    as impl;

Stream<String> sseDataStream(Uri uri) => impl.sseDataStream(uri);
