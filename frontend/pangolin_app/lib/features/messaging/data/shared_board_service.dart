import '../domain/shared_element.dart';

abstract interface class SharedBoardService {
  Stream<SharedElement> listen(int userId);

  Future<void> sendImage({
    required int senderId,
    required int receiverId,
    required String url,
    required int datetime,
  });

  Future<void> sendText({
    required int senderId,
    required int receiverId,
    required String text,
    required int datetime,
  });

  Future<void> sendReply({
    required int sharedElementId,
    required int senderId,
    required int receiverId,
    required String text,
    required int datetime,
  });
}
