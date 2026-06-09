import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/features/messaging/domain/shared_element.dart';
import 'package:pangolin_app/features/messaging/domain/shared_reply.dart';

void main() {
  test('parses an image element with replies', () {
    final element = SharedElement.fromJson({
      'id': 3,
      'senderId': 1,
      'receiverId': 2,
      'datetime': 1000,
      'type': 'image',
      'url': 'pic.jpg',
      'replies': [
        {'senderId': 2, 'text': 'nice', 'datetime': 1100},
      ],
    });

    expect(element.id, 3);
    expect(element.isImage, isTrue);
    expect(element.content, 'pic.jpg');
    expect(element.replies, hasLength(1));
    expect(element.latestReply?.text, 'nice');
  });

  test('parses a text element', () {
    final element = SharedElement.fromJson({
      'id': 4,
      'senderId': 1,
      'receiverId': 2,
      'datetime': 1000,
      'type': 'text',
      'text': 'hello',
    });

    expect(element.isImage, isFalse);
    expect(element.content, 'hello');
    expect(element.replies, isEmpty);
  });

  test('involves matches either direction', () {
    const element = SharedElement(
      id: 1,
      senderId: 7,
      receiverId: 9,
      datetime: 0,
      kind: SharedElementKind.text,
      content: 'hi',
    );

    expect(element.involves(7, 9), isTrue);
    expect(element.involves(9, 7), isTrue);
    expect(element.involves(7, 8), isFalse);
  });

  test('withReply appends and keeps the latest', () {
    const element = SharedElement(
      id: 1,
      senderId: 7,
      receiverId: 9,
      datetime: 0,
      kind: SharedElementKind.image,
      content: 'pic.jpg',
    );

    final updated = element
        .withReply(const SharedReply(senderId: 9, text: 'a', datetime: 1))
        .withReply(const SharedReply(senderId: 7, text: 'b', datetime: 2));

    expect(updated.replies, hasLength(2));
    expect(updated.latestReply?.text, 'b');
  });
}
