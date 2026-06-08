import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/features/logging/button_ids.dart';
import 'package:pangolin_app/features/logging/data/mock_button_click_logger.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/domain/position.dart';
import 'package:pangolin_app/features/recommendation/domain/profile.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_text.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/recommendation_profile_page.dart';

class _FakeProfileFetcher implements ProfileFetcher {
  final Profile profile;

  const _FakeProfileFetcher(this.profile);

  @override
  Future<Profile> fetchProfile(int userId) async => profile;
}

void main() {
  testWidgets('logs a bedroom-wall click for the viewer when a textbox is '
      'tapped', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final logger = MockButtonClickLogger();
    const profile = Profile(
      userId: 5,
      name: 'Bob',
      location: 'NYC',
      images: [],
      textboxes: [
        ProfileText(
          title: '',
          body: 'hello wall',
          position: Position(x: 200, y: 490, rotation: 0),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RecommendationProfilePage(
          viewerUserId: 7,
          profileFetcher: const _FakeProfileFetcher(profile),
          userId: 5,
          logger: logger,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('hello wall'));
    await tester.pump();

    expect(logger.clicks, hasLength(1));
    expect(logger.clicks.single.userId, 7);
    expect(logger.clicks.single.buttonId, ButtonIds.bedroomWall);
  });
}
