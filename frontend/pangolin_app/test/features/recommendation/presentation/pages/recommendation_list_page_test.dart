import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pangolin_app/config/env.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/logging/button_ids.dart';
import 'package:pangolin_app/features/logging/data/mock_button_click_logger.dart';
import 'package:pangolin_app/features/recommendation/data/recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/domain/recommendation.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/recommendation_list_page.dart';
import 'package:pangolin_app/features/recommendation/presentation/widgets/recommendation_list_item.dart';
import 'package:pangolin_app/router/app_router.dart';

import '../../../../support/auth_test_support.dart';

class MockRecommendationFetcher extends Mock implements RecommendationFetcher {}

void main() {
  late MockRecommendationFetcher mockFetcher;

  setUp(() {
    mockFetcher = MockRecommendationFetcher();
  });

  Future<void> pumpList(
    WidgetTester tester, {
    required RecommendationFetcher fetcher,
    MockButtonClickLogger? logger,
    int loggedInId = 1,
  }) {
    final router = GoRouter(
      initialLocation: AppRoutes.recommendations,
      routes: [
        GoRoute(
          path: AppRoutes.recommendations,
          builder: (_, _) => RecommendationListPage(
            recommendationFetcher: fetcher,
            logger: logger,
          ),
        ),
        GoRoute(
          path: AppRoutes.viewProfile,
          builder: (_, _) => const Text('PROFILE'),
        ),
      ],
    );

    return tester.pumpWidget(
      ProviderScope(
        overrides: [loggedInUserId(loggedInId)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
  }

  testWidgets('shows fetched recommendations', (tester) async {
    when(() => mockFetcher.fetchRecommendations(any())).thenAnswer(
      (_) async => const [
        Recommendation(
          userId: 0,
          name: 'Alice',
          age: 30,
          location: 'London',
          bio: 'Artist',
          imageUrl: 'https://example.com/alice.jpg',
        ),
      ],
    );

    await pumpList(tester, fetcher: mockFetcher);
    await tester.pumpAndSettle();

    expect(find.text('Alice (30)'), findsOneWidget);
    expect(find.text('London'), findsOneWidget);
    verify(() => mockFetcher.fetchRecommendations(1)).called(1);
  });

  testWidgets('shows empty state', (tester) async {
    when(
      () => mockFetcher.fetchRecommendations(any()),
    ).thenAnswer((_) async => []);

    await pumpList(tester, fetcher: mockFetcher);
    await tester.pumpAndSettle();

    expect(find.text('No recommendations available'), findsOneWidget);
  });

  testWidgets('shows error state', (tester) async {
    when(
      () => mockFetcher.fetchRecommendations(any()),
    ).thenAnswer((_) async => throw Exception('Fetch failed'));

    await pumpList(tester, fetcher: mockFetcher);
    await tester.pumpAndSettle();

    expect(find.textContaining('Error:'), findsOneWidget);
  });

  testWidgets('logs a button click when a recommendation is tapped', (
    tester,
  ) async {
    await getIt.reset();
    configureDependencies(BackendMode.mock);
    final logger = MockButtonClickLogger();

    when(() => mockFetcher.fetchRecommendations(any())).thenAnswer(
      (_) async => const [
        Recommendation(
          userId: 5,
          name: 'Alice',
          age: 30,
          location: 'London',
          bio: 'Artist',
          imageUrl: 'https://example.com/alice.jpg',
        ),
      ],
    );

    await pumpList(tester, fetcher: mockFetcher, logger: logger, loggedInId: 7);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(RecommendationListItem));
    await tester.pumpAndSettle();

    expect(logger.clicks, hasLength(1));
    expect(logger.clicks.single.userId, 7);
    expect(logger.clicks.single.buttonId, ButtonIds.recommendationList);
  });
}
