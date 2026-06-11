import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/features/friends/data/friends_fetcher.dart';
import 'package:pangolin_app/features/friends/data/mock_friend_action_sender.dart';
import 'package:pangolin_app/features/friends/domain/current_friends.dart';
import 'package:pangolin_app/features/friends/domain/pending_friend.dart';
import 'package:pangolin_app/features/friends/presentation/widgets/pending_connections_dialog.dart';
import 'package:pangolin_app/features/logging/data/mock_button_click_logger.dart';

class _FakeFriendsFetcher implements FriendsFetcher {
  final List<PendingFriend> pending;

  const _FakeFriendsFetcher(this.pending);

  @override
  Future<CurrentFriends> fetchCurrentFriends(int userId) async =>
      const CurrentFriends(pendingCount: 0, friends: []);

  @override
  Future<List<PendingFriend>> fetchPendingFriends(int userId) async => pending;
}

Future<MockFriendActionSender> _pump(WidgetTester tester) async {
  final sender = MockFriendActionSender();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PendingConnectionsDialog(
          userId: 7,
          friendsFetcher: const _FakeFriendsFetcher([
            PendingFriend(
              friendUserId: 11,
              name: 'Jess',
              mainImage: '',
              age: 24,
            ),
          ]),
          friendActionSender: sender,
          logger: MockButtonClickLogger(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return sender;
}

void main() {
  testWidgets('shows the name with age and a message button', (tester) async {
    await _pump(tester);

    expect(find.text('Jess (24)'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Message Jess'), findsOneWidget);
  });

  testWidgets('Ignore rejects the friend and removes the card', (tester) async {
    final sender = await _pump(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ignore'));
    await tester.pumpAndSettle();

    expect(sender.actions, hasLength(1));
    expect(sender.actions.single.kind, FriendActionKind.reject);
    expect(sender.actions.single.currentUserId, 7);
    expect(sender.actions.single.targetUserId, 11);
    expect(find.text('Jess (24)'), findsNothing);
    expect(find.text('No pending connections'), findsOneWidget);
  });

  testWidgets('Report and ignore reports then rejects the friend', (
    tester,
  ) async {
    final sender = await _pump(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report and ignore'));
    await tester.pumpAndSettle();

    expect(sender.actions.map((a) => a.kind), [
      FriendActionKind.report,
      FriendActionKind.reject,
    ]);
    expect(sender.actions.every((a) => a.targetUserId == 11), isTrue);
    expect(find.text('Jess (24)'), findsNothing);
  });
}
