import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/config/env.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/friends/data/friends_fetcher.dart';
import 'package:pangolin_app/features/friends/domain/current_friends.dart';
import 'package:pangolin_app/features/friends/domain/friend.dart';
import 'package:pangolin_app/features/friends/domain/pending_friend.dart';
import 'package:pangolin_app/features/friends/presentation/pages/connections_page.dart';

class _FakeFriendsFetcher implements FriendsFetcher {
  final CurrentFriends current;
  const _FakeFriendsFetcher(this.current);

  @override
  Future<CurrentFriends> fetchCurrentFriends(int userId) async => current;

  @override
  Future<List<PendingFriend>> fetchPendingFriends(int userId) async => const [];
}

CurrentFriends _sample() => const CurrentFriends(
  pendingCount: 2,
  friends: [
    Friend(friendUserId: 1, name: 'Tim', coverImages: [], mainImage: ''),
    Friend(friendUserId: 2, name: 'Sally', coverImages: [], mainImage: ''),
  ],
);

void main() {
  setUp(() async {
    await getIt.reset();
    configureDependencies(BackendMode.mock);
  });

  Future<void> pumpPage(WidgetTester tester, CurrentFriends data) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ConnectionsPage(
          userId: 7,
          friendsFetcher: _FakeFriendsFetcher(data),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows connections in a grid with their names', (tester) async {
    await pumpPage(tester, _sample());

    expect(find.text('Connections'), findsOneWidget);
    expect(find.text('Tim'), findsOneWidget);
    expect(find.text('Sally'), findsOneWidget);
  });

  testWidgets('shows the pending connections count as a button', (
    tester,
  ) async {
    await pumpPage(tester, _sample());

    expect(find.text('2 pending connections'), findsOneWidget);
  });

  testWidgets('tapping the pending button opens the pending page', (
    tester,
  ) async {
    await pumpPage(tester, _sample());

    await tester.tap(find.text('2 pending connections'));
    await tester.pumpAndSettle();

    expect(find.text('Pending connections'), findsOneWidget);
  });
}
