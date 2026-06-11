import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/features/messaging/domain/shared_element.dart';
import 'package:pangolin_app/features/messaging/domain/shared_reply.dart';
import 'package:pangolin_app/features/messaging/presentation/widgets/shared_element_tile.dart';

SharedElement _element({
  required List<SharedReply> replies,
  bool read = false,
}) => SharedElement(
  id: 1,
  datetime: 1,
  kind: SharedElementKind.text,
  content: 'look at this',
  replies: replies,
  read: read,
);

SharedReply _reply(int senderId, String text) =>
    SharedReply(senderId: senderId, text: text, datetime: senderId);

Future<void> _pump(WidgetTester tester, SharedElement element) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SharedElementTile(
          element: element,
          userId: 1,
          friendName: 'Sally',
          onTap: () {},
        ),
      ),
    ),
  );
}

Text _messageContaining(WidgetTester tester, String fragment) =>
    tester.widget<Text>(
      find.byWidgetPredicate(
        (w) =>
            w is Text &&
            (w.textSpan?.toPlainText().contains(fragment) ?? false),
      ),
    );

void main() {
  testWidgets('tags my messages with "You: " and theirs with their name', (
    tester,
  ) async {
    await _pump(
      tester,
      _element(replies: [_reply(1, 'hi there'), _reply(2, 'hey back')]),
    );

    expect(_messageContaining(tester, 'You: hi there'), isNotNull);
    expect(_messageContaining(tester, 'Sally: hey back'), isNotNull);
  });

  testWidgets('shows only the two most recent messages', (tester) async {
    await _pump(
      tester,
      _element(
        replies: [_reply(1, 'first'), _reply(2, 'second'), _reply(1, 'third')],
      ),
    );

    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Text && (w.textSpan?.toPlainText().contains('first') ?? false),
      ),
      findsNothing,
    );
    expect(_messageContaining(tester, 'Sally: second'), isNotNull);
    expect(_messageContaining(tester, 'You: third'), isNotNull);
  });

  testWidgets('messages are bold when the element is unread', (tester) async {
    await _pump(tester, _element(replies: [_reply(2, 'hello')], read: false));

    expect(
      _messageContaining(tester, 'hello').style?.fontWeight,
      FontWeight.bold,
    );
  });

  testWidgets('messages are not bold when the element is read', (tester) async {
    await _pump(tester, _element(replies: [_reply(2, 'hello')], read: true));

    expect(
      _messageContaining(tester, 'hello').style?.fontWeight,
      FontWeight.normal,
    );
  });
}
