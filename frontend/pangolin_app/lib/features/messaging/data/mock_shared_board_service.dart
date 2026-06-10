import 'dart:async';

import '../domain/shared_element.dart';
import '../domain/shared_reply.dart';
import 'shared_board_service.dart';

class MockSharedBoardService implements SharedBoardService {
  final StreamController<void> _controller = StreamController<void>.broadcast();
  final List<SharedElement> _elements = [];
  int _nextId = 1;

  @override
  Stream<void> notifications(int userId) => _controller.stream;

  @override
  Future<List<SharedElement>> fetchBoard(int userId, int friendUserId) async {
    return List.unmodifiable(_elements);
  }

  @override
  Future<void> sendImage({
    required int senderId,
    required int receiverId,
    required String url,
    required int datetime,
  }) async {
    _elements.add(
      SharedElement(
        id: _nextId++,
        datetime: datetime,
        kind: SharedElementKind.image,
        content: url,
      ),
    );
    _controller.add(null);
  }

  @override
  Future<void> sendText({
    required int senderId,
    required int receiverId,
    required String text,
    required int datetime,
  }) async {
    _elements.add(
      SharedElement(
        id: _nextId++,
        datetime: datetime,
        kind: SharedElementKind.text,
        content: text,
      ),
    );
    _controller.add(null);
  }

  @override
  Future<void> sendReply({
    required int sharedElementId,
    required int senderId,
    required int receiverId,
    required String text,
    required int datetime,
  }) async {
    final index = _elements.indexWhere((e) => e.id == sharedElementId);
    if (index == -1) return;

    final element = _elements[index];
    _elements[index] = SharedElement(
      id: element.id,
      datetime: element.datetime,
      kind: element.kind,
      content: element.content,
      read: element.read,
      replies: [
        ...element.replies,
        SharedReply(senderId: senderId, text: text, datetime: datetime),
      ],
    );
    _controller.add(null);
  }
}
