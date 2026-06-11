import 'dart:async';

import 'package:pangolin_app/features/messaging/data/shared_board_service.dart';
import 'package:pangolin_app/features/messaging/domain/shared_element.dart';

class FakeSharedBoardService implements SharedBoardService {
  final StreamController<void> controller = StreamController<void>.broadcast();

  void fireNotification() => controller.add(null);

  @override
  Stream<void> notifications(int userId) => controller.stream;

  @override
  Future<List<SharedElement>> fetchBoard(int userId, int friendUserId) async =>
      const [];

  @override
  Future<void> sendImage({
    required int senderId,
    required int receiverId,
    required String url,
    required String message,
    int? datetime,
  }) async {}

  @override
  Future<void> sendText({
    required int senderId,
    required int receiverId,
    required String text,
    required String message,
    int? datetime,
  }) async {}

  @override
  Future<void> sendReply({
    required int sharedElementId,
    required int senderId,
    required int receiverId,
    required String text,
    int? datetime,
  }) async {}
}
