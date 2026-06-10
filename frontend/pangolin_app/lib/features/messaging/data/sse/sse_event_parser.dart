Stream<void> sseEventTicks(Stream<String> lines) =>
    lines.where((line) => line.isEmpty);

Stream<String> decodeSseData(Stream<String> lines) async* {
  final buffer = StringBuffer();

  await for (final line in lines) {
    if (line.isEmpty) {
      if (buffer.isNotEmpty) {
        yield buffer.toString();
        buffer.clear();
      }
    } else if (line.startsWith('data:')) {
      if (buffer.isNotEmpty) buffer.write('\n');
      buffer.write(
        line.startsWith('data: ') ? line.substring(6) : line.substring(5),
      );
    }
  }

  if (buffer.isNotEmpty) yield buffer.toString();
}
