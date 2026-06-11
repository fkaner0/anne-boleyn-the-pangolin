import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/features/friends/data/mock_friend_action_sender.dart';

void main() {
  test('report records a report action with both ids', () async {
    final sender = MockFriendActionSender();

    await sender.report(currentUserId: 7, targetUserId: 11);

    expect(sender.actions, hasLength(1));
    expect(sender.actions.single.kind, FriendActionKind.report);
    expect(sender.actions.single.currentUserId, 7);
    expect(sender.actions.single.targetUserId, 11);
  });

  test('remove records a remove action', () async {
    final sender = MockFriendActionSender();

    await sender.remove(currentUserId: 1, targetUserId: 2);

    expect(sender.actions.single.kind, FriendActionKind.remove);
  });

  test('reject records a reject action', () async {
    final sender = MockFriendActionSender();

    await sender.reject(currentUserId: 1, targetUserId: 2);

    expect(sender.actions.single.kind, FriendActionKind.reject);
  });

  test('records each call in order', () async {
    final sender = MockFriendActionSender();

    await sender.report(currentUserId: 1, targetUserId: 2);
    await sender.remove(currentUserId: 1, targetUserId: 3);
    await sender.reject(currentUserId: 1, targetUserId: 4);

    expect(sender.actions.map((a) => a.kind), [
      FriendActionKind.report,
      FriendActionKind.remove,
      FriendActionKind.reject,
    ]);
    expect(sender.actions.map((a) => a.targetUserId), [2, 3, 4]);
  });
}
