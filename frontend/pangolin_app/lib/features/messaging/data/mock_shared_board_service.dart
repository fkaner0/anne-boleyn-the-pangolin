import 'dart:async';

import '../domain/shared_element.dart';
import '../domain/shared_reply.dart';
import 'shared_board_service.dart';

class MockSharedBoardService implements SharedBoardService {
  final StreamController<SharedElement> _controller =
      StreamController<SharedElement>.broadcast();
  final List<SharedElement> _elements = [];
  int _nextId = 1;

  @override
  Stream<SharedElement> listen(int userId) async* {
    for (final element in _elements) {
      yield element;
    }
    yield* _controller.stream;
  }

  @override
  Future<void> sendImage({
    required int senderId,
    required int receiverId,
    required String url,
    required int datetime,
  }) async {
    _emit(
      SharedElement(
        id: _nextId++,
        senderId: senderId,
        receiverId: receiverId,
        datetime: datetime,
        kind: SharedElementKind.image,
        content: url,
      ),
    );
  }

  @override
  Future<void> sendText({
    required int senderId,
    required int receiverId,
    required String text,
    required int datetime,
  }) async {
    _emit(
      SharedElement(
        id: _nextId++,
        senderId: senderId,
        receiverId: receiverId,
        datetime: datetime,
        kind: SharedElementKind.text,
        content: text,
      ),
    );
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

    final updated = _elements[index].withReply(
      SharedReply(senderId: senderId, text: text, datetime: datetime),
    );
    _elements[index] = updated;
    _controller.add(updated);
  }

  void _emit(SharedElement element) {
    _elements.add(element);
    _controller.add(element);
  }
}
