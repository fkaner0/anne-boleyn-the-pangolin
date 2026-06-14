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
    required String message,
    int? datetime,
  }) async {
    _elements.add(
      SharedElement(
        id: _nextId++,
        datetime: datetime ?? SharedBoardService.now(),
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
    required String message,
    int? datetime,
  }) async {
    _elements.add(
      SharedElement(
        id: _nextId++,
        datetime: datetime ?? SharedBoardService.now(),
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
    int? datetime,
  }) async {
    final index = _elements.indexWhere((e) => e.id == sharedElementId);
    if (index == -1) return;

    final element = _elements[index];
    _elements[index] = element.copyWith(
      replies: [
        ...element.replies,
        SharedReply(
          senderId: senderId,
          text: text,
          datetime: datetime ?? SharedBoardService.now(),
        ),
      ],
    );
    _controller.add(null);
  }

  @override
  Future<void> markRead({
    required int sharedElementId,
    required int userId,
  }) async {
    final index = _elements.indexWhere((e) => e.id == sharedElementId);
    if (index == -1) return;
    _elements[index] = _elements[index].copyWith(read: true);
  }
}
