import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pangolin_app/config/env.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/friends/data/friends_fetcher.dart';
import 'package:pangolin_app/features/friends/domain/current_friends.dart';
import 'package:pangolin_app/features/friends/domain/friend.dart';
import 'package:pangolin_app/features/friends/domain/pending_friend.dart';
import 'package:pangolin_app/features/friends/presentation/pages/connections_page.dart';
import 'package:pangolin_app/features/friends/presentation/widgets/connection_card.dart';
import 'package:pangolin_app/features/logging/button_ids.dart';
import 'package:pangolin_app/features/logging/data/mock_button_click_logger.dart';
import 'package:pangolin_app/features/messaging/presentation/pages/shared_board_page.dart';
import 'package:pangolin_app/router/app_router.dart';

import '../../../../support/auth_test_support.dart';
import '../../../../support/fake_shared_board_service.dart';

class _FakeFriendsFetcher implements FriendsFetcher {
  final CurrentFriends current;
  final List<PendingFriend> pending;
  int currentFetchCount = 0;

  _FakeFriendsFetcher(this.current, {this.pending = const []});

  @override
  Future<CurrentFriends> fetchCurrentFriends(int userId) async {
    currentFetchCount++;
    return current;
  }

  @override
  Future<List<PendingFriend>> fetchPendingFriends(int userId) async => pending;
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

  Future<_FakeFriendsFetcher> pumpPage(
    WidgetTester tester,
    CurrentFriends data, {
    MockButtonClickLogger? logger,
    List<PendingFriend> pending = const [],
    FakeSharedBoardService? boardService,
  }) async {
    final fetcher = _FakeFriendsFetcher(data, pending: pending);
    final router = GoRouter(
      initialLocation: AppRoutes.connections,
      routes: [
        GoRoute(
          path: AppRoutes.connections,
          builder: (_, _) => ConnectionsPage(
            friendsFetcher: fetcher,
            boardService: boardService,
            logger: logger,
          ),
        ),
        GoRoute(
          path: AppRoutes.sharedBoard,
          builder: (_, state) =>
              SharedBoardPage(friendUserId: state.extra as int),
        ),
        GoRoute(
          path: AppRoutes.viewProfile,
          builder: (_, _) => const Text('PROFILE'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [loggedInUserId(7)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    return fetcher;
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

  testWidgets('tapping any connection logs a connections click', (
    tester,
  ) async {
    final logger = MockButtonClickLogger();
    await pumpPage(tester, _sample(), logger: logger);

    await tester.tap(find.byType(ConnectionCard).first);
    await tester.pumpAndSettle();

    expect(logger.clicks, hasLength(1));
    expect(logger.clicks.single.userId, 7);
    expect(logger.clicks.single.buttonId, ButtonIds.connectionsList);
  });

  testWidgets('tapping the pending button logs a pending click', (
    tester,
  ) async {
    final logger = MockButtonClickLogger();
    await pumpPage(tester, _sample(), logger: logger);

    await tester.tap(find.text('2 pending connections'));
    await tester.pumpAndSettle();

    expect(
      logger.clicks.map((click) => click.buttonId),
      contains(ButtonIds.connectionsPending),
    );
  });

  testWidgets('the pending popup lists pending friends as cards', (
    tester,
  ) async {
    await pumpPage(
      tester,
      _sample(),
      pending: const [
        PendingFriend(friendUserId: 11, name: 'Jess', mainImage: ''),
        PendingFriend(friendUserId: 12, name: 'Diego', mainImage: ''),
      ],
    );

    await tester.tap(find.text('2 pending connections'));
    await tester.pumpAndSettle();

    expect(find.text('Pending connections'), findsOneWidget);
    expect(find.text('Jess'), findsOneWidget);
    expect(find.text('Diego'), findsOneWidget);
  });

  testWidgets('tapping a pending friend opens the shared board', (
    tester,
  ) async {
    await pumpPage(
      tester,
      _sample(),
      pending: const [
        PendingFriend(friendUserId: 11, name: 'Jess', mainImage: ''),
      ],
    );

    await tester.tap(find.text('2 pending connections'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reply'));
    await tester.pumpAndSettle();

    expect(find.text('Grab from their wall'), findsOneWidget);
  });

  testWidgets('tapping a pending friend profile area opens their profile', (
    tester,
  ) async {
    await pumpPage(
      tester,
      _sample(),
      pending: const [
        PendingFriend(friendUserId: 11, name: 'Jess', mainImage: ''),
      ],
    );

    await tester.tap(find.text('2 pending connections'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Jess'));
    await tester.pumpAndSettle();

    expect(find.text('PROFILE'), findsOneWidget);
  });

  testWidgets('tapping a connection opens the shared board', (tester) async {
    await pumpPage(tester, _sample());

    await tester.tap(find.byType(ConnectionCard).first);
    await tester.pumpAndSettle();

    expect(find.text('Grab from their wall'), findsOneWidget);
  });

  testWidgets('tapping a pending friend logs a pending connection click', (
    tester,
  ) async {
    final logger = MockButtonClickLogger();
    await pumpPage(
      tester,
      _sample(),
      logger: logger,
      pending: const [
        PendingFriend(friendUserId: 11, name: 'Jess', mainImage: ''),
      ],
    );

    await tester.tap(find.text('2 pending connections'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reply'));
    await tester.pumpAndSettle();

    expect(
      logger.clicks.map((click) => click.buttonId),
      contains(ButtonIds.pendingConnection),
    );
  });

  testWidgets('closing the pending popup logs a close click', (tester) async {
    final logger = MockButtonClickLogger();
    await pumpPage(tester, _sample(), logger: logger);

    await tester.tap(find.text('2 pending connections'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(
      logger.clicks.map((click) => click.buttonId),
      contains(ButtonIds.pendingConnectionsClose),
    );
  });

  testWidgets('refetches the connections when returning from a board', (
    tester,
  ) async {
    final fetcher = await pumpPage(tester, _sample());
    expect(fetcher.currentFetchCount, 1);

    await tester.tap(find.byType(ConnectionCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(fetcher.currentFetchCount, 2);
  });

  testWidgets('refetches the connections on an sse notification', (
    tester,
  ) async {
    final board = FakeSharedBoardService();
    final fetcher = await pumpPage(tester, _sample(), boardService: board);
    expect(fetcher.currentFetchCount, 1);

    board.fireNotification();
    await tester.pumpAndSettle();

    expect(fetcher.currentFetchCount, 2);
  });
}
