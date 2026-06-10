import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/features/messaging/data/mock_shared_board_service.dart';
import 'package:pangolin_app/features/messaging/domain/shared_element.dart';

void main() {
  test('sendImage echoes the new element on the listen stream', () async {
    final service = MockSharedBoardService();
    final received = <SharedElement>[];
    final sub = service.listen(1).listen(received.add);

    await service.sendImage(
      senderId: 1,
      receiverId: 2,
      url: 'pic.jpg',
      datetime: 10,
    );
    await Future<void>.delayed(Duration.zero);

    expect(received, hasLength(1));
    expect(received.single.isImage, isTrue);
    expect(received.single.content, 'pic.jpg');

    await sub.cancel();
  });

  test('sendReply re-emits the element with the reply appended', () async {
    final service = MockSharedBoardService();
    final received = <SharedElement>[];
    final sub = service.listen(1).listen(received.add);

    await service.sendText(
      senderId: 1,
      receiverId: 2,
      text: 'hi',
      datetime: 10,
    );
    await Future<void>.delayed(Duration.zero);

    final elementId = received.single.id;
    await service.sendReply(
      sharedElementId: elementId,
      senderId: 2,
      receiverId: 1,
      text: 'hey',
      datetime: 20,
    );
    await Future<void>.delayed(Duration.zero);

    expect(received, hasLength(2));
    expect(received.last.replies.single.text, 'hey');

    await sub.cancel();
  });
}
