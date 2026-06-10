import 'package:pangolin_app/config/env.dart';

import '../domain/shared_element.dart';
import 'api_shared_board_service.dart';
import 'shared_board_service.dart';

class RenderSharedBoardService implements SharedBoardService {
  final ApiSharedBoardService _delegate;

  RenderSharedBoardService({
    String host = defaultRenderHost,
    int? port,
    bool useHttps = true,
  }) : _delegate = ApiSharedBoardService(
         host: host,
         port: port,
         useHttps: useHttps,
       );

  @override
  Stream<SharedElement> listen(int userId) => _delegate.listen(userId);

  @override
  Future<void> sendImage({
    required int senderId,
    required int receiverId,
    required String url,
    required int datetime,
  }) => _delegate.sendImage(
    senderId: senderId,
    receiverId: receiverId,
    url: url,
    datetime: datetime,
  );

  @override
  Future<void> sendText({
    required int senderId,
    required int receiverId,
    required String text,
    required int datetime,
  }) => _delegate.sendText(
    senderId: senderId,
    receiverId: receiverId,
    text: text,
    datetime: datetime,
  );

  @override
  Future<void> sendReply({
    required int sharedElementId,
    required int senderId,
    required int receiverId,
    required String text,
    required int datetime,
  }) => _delegate.sendReply(
    sharedElementId: sharedElementId,
    senderId: senderId,
    receiverId: receiverId,
    text: text,
    datetime: datetime,
  );
}
