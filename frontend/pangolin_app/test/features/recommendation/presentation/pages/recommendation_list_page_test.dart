import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pangolin_app/features/recommendation/data/recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/domain/recommendation.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/recommendation_list_page.dart';

class MockRecommendationFetcher extends Mock implements RecommendationFetcher {}

void main() {
  late MockRecommendationFetcher mockFetcher;

  setUp(() {
    mockFetcher = MockRecommendationFetcher();
  });

  testWidgets('shows fetched recommendations', (tester) async {
    when(() => mockFetcher.fetchRecommendations()).thenAnswer(
      (_) async => const [
        Recommendation(
          userId: 0,
          name: 'Alice',
          location: 'London',
          bio: 'Artist',
          imageUrl: 'https://example.com/alice.jpg',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RecommendationListPage(recommendationFetcher: mockFetcher),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('London'), findsOneWidget);
    verify(() => mockFetcher.fetchRecommendations()).called(1);
  });

  testWidgets('shows empty state', (tester) async {
    when(() => mockFetcher.fetchRecommendations()).thenAnswer((_) async => []);

    await tester.pumpWidget(
      MaterialApp(
        home: RecommendationListPage(recommendationFetcher: mockFetcher),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No recommendations available'), findsOneWidget);
  });

  testWidgets('shows error state', (tester) async {
    when(
      () => mockFetcher.fetchRecommendations(),
    ).thenAnswer((_) async => throw Exception('Fetch failed'));

    await tester.pumpWidget(
      MaterialApp(
        home: RecommendationListPage(recommendationFetcher: mockFetcher),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Error:'), findsOneWidget);
  });
}
