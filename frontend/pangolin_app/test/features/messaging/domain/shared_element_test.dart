import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/features/messaging/domain/shared_element.dart';
import 'package:pangolin_app/features/messaging/domain/shared_reply.dart';

void main() {
  test('parses an image element with replies', () {
    final element = SharedElement.fromJson({
      'sharedElemId': 3,
      'datetime': 1000,
      'url': 'pic.jpg',
      'messages': [
        {'senderId': 2, 'text': 'nice', 'datetime': 1100},
      ],
      'read': false,
    });

    expect(element.id, 3);
    expect(element.datetime, 1000);
    expect(element.isImage, isTrue);
    expect(element.content, 'pic.jpg');
    expect(element.replies, hasLength(1));
    expect(element.latestReply?.text, 'nice');
    expect(element.latestReply?.senderId, 2);
  });

  test('parses a text element', () {
    final element = SharedElement.fromJson({
      'sharedElemId': 4,
      'datetime': 2000,
      'text': 'hello',
      'messages': const [],
      'read': true,
    });

    expect(element.isImage, isFalse);
    expect(element.content, 'hello');
    expect(element.read, isTrue);
    expect(element.replies, isEmpty);
  });

  test('latestReply returns the most recent reply', () {
    const element = SharedElement(
      id: 1,
      datetime: 0,
      kind: SharedElementKind.image,
      content: 'pic.jpg',
      replies: [
        SharedReply(senderId: 1, text: 'a', datetime: 1),
        SharedReply(senderId: 2, text: 'b', datetime: 2),
      ],
    );

    expect(element.latestReply?.text, 'b');
  });
}
