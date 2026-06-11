import 'friend_action_sender.dart';

enum FriendActionKind { report, remove, reject }

class FriendAction {
  final FriendActionKind kind;
  final int currentUserId;
  final int targetUserId;

  const FriendAction({
    required this.kind,
    required this.currentUserId,
    required this.targetUserId,
  });
}

class MockFriendActionSender implements FriendActionSender {
  final List<FriendAction> actions = [];

  @override
  Future<void> report({
    required int currentUserId,
    required int targetUserId,
  }) async => _record(FriendActionKind.report, currentUserId, targetUserId);

  @override
  Future<void> remove({
    required int currentUserId,
    required int targetUserId,
  }) async => _record(FriendActionKind.remove, currentUserId, targetUserId);

  @override
  Future<void> reject({
    required int currentUserId,
    required int targetUserId,
  }) async => _record(FriendActionKind.reject, currentUserId, targetUserId);

  void _record(FriendActionKind kind, int currentUserId, int targetUserId) {
    actions.add(
      FriendAction(
        kind: kind,
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      ),
    );
  }
}
