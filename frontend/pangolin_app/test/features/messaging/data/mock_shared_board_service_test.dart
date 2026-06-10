import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/features/messaging/data/mock_shared_board_service.dart';

void main() {
  test('sendImage adds an image element and notifies', () async {
    final service = MockSharedBoardService();
    var ticks = 0;
    final sub = service.notifications(1).listen((_) => ticks++);

    await service.sendImage(
      senderId: 1,
      receiverId: 2,
      url: 'pic.jpg',
      message: 'initial message 1',
      datetime: 10,
    );
    await Future<void>.delayed(Duration.zero);

    final board = await service.fetchBoard(1, 2);
    expect(board, hasLength(1));
    expect(board.single.isImage, isTrue);
    expect(board.single.content, 'pic.jpg');
    expect(ticks, 1);

    await sub.cancel();
  });

  test('sendReply appends a reply to the element and notifies', () async {
    final service = MockSharedBoardService();
    var ticks = 0;
    final sub = service.notifications(1).listen((_) => ticks++);

    await service.sendText(
      senderId: 1,
      receiverId: 2,
      text: 'hi',
      message: 'initial message 2',
      datetime: 10,
    );
    final created = await service.fetchBoard(1, 2);
    final elementId = created.single.id;

    await service.sendReply(
      sharedElementId: elementId,
      senderId: 2,
      receiverId: 1,
      text: 'hey',
      datetime: 20,
    );
    await Future<void>.delayed(Duration.zero);

    final board = await service.fetchBoard(1, 2);
    expect(board.single.replies.single.text, 'hey');
    expect(ticks, greaterThanOrEqualTo(2));

    await sub.cancel();
  });
}
