import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/features/messaging/data/sse/sse_event_parser.dart';

void main() {
  Stream<String> linesOf(List<String> lines) => Stream.fromIterable(lines);

  test('emits one payload per event, split by blank lines', () async {
    final data = await decodeSseData(
      linesOf(['data: {"a":1}', '', 'data: {"b":2}', '']),
    ).toList();

    expect(data, ['{"a":1}', '{"b":2}']);
  });

  test('joins multi-line data fields with newlines', () async {
    final data = await decodeSseData(
      linesOf(['data: line one', 'data: line two', '']),
    ).toList();

    expect(data, ['line one\nline two']);
  });

  test('ignores comments and non-data fields', () async {
    final data = await decodeSseData(
      linesOf([': keep-alive', 'event: ping', 'data: hello', '']),
    ).toList();

    expect(data, ['hello']);
  });

  test('emits a trailing event with no final blank line', () async {
    final data = await decodeSseData(linesOf(['data: last'])).toList();

    expect(data, ['last']);
  });
}
