import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/features/friends/data/friends_fetcher.dart';
import 'package:pangolin_app/features/friends/data/mock_friend_action_sender.dart';
import 'package:pangolin_app/features/friends/domain/current_friends.dart';
import 'package:pangolin_app/features/friends/domain/pending_friend.dart';
import 'package:pangolin_app/features/friends/presentation/widgets/pending_connections_dialog.dart';
import 'package:pangolin_app/features/logging/data/mock_button_click_logger.dart';

class _FakeFriendsFetcher implements FriendsFetcher {
  final List<PendingFriend> all;
  final MockFriendActionSender sender;
  int pendingFetchCount = 0;

  _FakeFriendsFetcher(this.all, this.sender);

  @override
  Future<CurrentFriends> fetchCurrentFriends(int userId) async =>
      const CurrentFriends(pendingCount: 0, friends: []);

  @override
  Future<List<PendingFriend>> fetchPendingFriends(int userId) async {
    pendingFetchCount++;
    final actioned = sender.actions.map((a) => a.targetUserId).toSet();
    return all.where((f) => !actioned.contains(f.friendUserId)).toList();
  }
}

Future<_FakeFriendsFetcher> _pump(WidgetTester tester) async {
  final sender = MockFriendActionSender();
  final fetcher = _FakeFriendsFetcher(const [
    PendingFriend(friendUserId: 11, name: 'Jess', mainImage: '', age: 24),
  ], sender);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PendingConnectionsDialog(
          userId: 7,
          friendsFetcher: fetcher,
          friendActionSender: sender,
          logger: MockButtonClickLogger(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return fetcher;
}

void main() {
  testWidgets('shows the name with age and a message button', (tester) async {
    await _pump(tester);

    expect(find.text('Jess (24)'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Message Jess'), findsOneWidget);
  });

  testWidgets('Ignore rejects the friend and re-fetches the pending list', (
    tester,
  ) async {
    final fetcher = await _pump(tester);
    expect(fetcher.pendingFetchCount, 1);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ignore'));
    await tester.pumpAndSettle();

    expect(fetcher.sender.actions.single.kind, FriendActionKind.reject);
    expect(fetcher.sender.actions.single.currentUserId, 7);
    expect(fetcher.sender.actions.single.targetUserId, 11);
    expect(fetcher.pendingFetchCount, 2);
    expect(find.text('Jess (24)'), findsNothing);
    expect(find.text('No pending connections'), findsOneWidget);
    expect(find.textContaining('moderation team'), findsNothing);
  });

  testWidgets('Report and ignore reports then rejects, then re-fetches', (
    tester,
  ) async {
    final fetcher = await _pump(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report and ignore'));
    await tester.pumpAndSettle();

    expect(fetcher.sender.actions.map((a) => a.kind), [
      FriendActionKind.report,
      FriendActionKind.reject,
    ]);
    expect(fetcher.sender.actions.every((a) => a.targetUserId == 11), isTrue);
    expect(fetcher.pendingFetchCount, 2);

    expect(find.textContaining("Jess's request"), findsOneWidget);
    expect(find.textContaining('moderation team'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
  });
}
