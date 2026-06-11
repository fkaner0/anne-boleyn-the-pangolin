import 'package:pangolin_app/config/env.dart';

import 'api_friend_action_sender.dart';
import 'friend_action_sender.dart';

class RenderFriendActionSender implements FriendActionSender {
  final ApiFriendActionSender _delegate;

  RenderFriendActionSender({
    String host = defaultRenderHost,
    int? port,
    bool useHttps = true,
  }) : _delegate = ApiFriendActionSender(
         host: host,
         port: port,
         useHttps: useHttps,
       );

  @override
  Future<void> report({
    required int currentUserId,
    required int targetUserId,
  }) => _delegate.report(
    currentUserId: currentUserId,
    targetUserId: targetUserId,
  );

  @override
  Future<void> remove({
    required int currentUserId,
    required int targetUserId,
  }) => _delegate.remove(
    currentUserId: currentUserId,
    targetUserId: targetUserId,
  );

  @override
  Future<void> reject({
    required int currentUserId,
    required int targetUserId,
  }) => _delegate.reject(
    currentUserId: currentUserId,
    targetUserId: targetUserId,
  );
}
