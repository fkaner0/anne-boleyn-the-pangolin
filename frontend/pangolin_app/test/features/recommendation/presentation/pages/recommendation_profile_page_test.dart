import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/features/logging/button_ids.dart';
import 'package:pangolin_app/features/logging/data/mock_button_click_logger.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/domain/position.dart';
import 'package:pangolin_app/features/recommendation/domain/profile.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_text.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/recommendation_profile_page.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';

import '../../../../support/auth_test_support.dart';

class _FakeProfileFetcher implements ProfileFetcher {
  final Profile profile;

  const _FakeProfileFetcher(this.profile);

  @override
  Future<Profile> fetchProfile(int userId) async => profile;
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxFrames = 120,
}) async {
  for (var i = 0; i < maxFrames && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

void main() {
  setUp(StickerCatalog.resetCache);

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

  Future<void> pumpPage(
    WidgetTester tester,
    MockButtonClickLogger logger,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [loggedInUserId(7)],
        child: MaterialApp(
          home: RecommendationProfilePage(
            profileFetcher: const _FakeProfileFetcher(profile),
            userId: 5,
            logger: logger,
          ),
        ),
      ),
    );
  }

  testWidgets('logs a bedroom-wall click for the viewer when a textbox is '
      'tapped', (tester) async {
    final logger = MockButtonClickLogger();
    await pumpPage(tester, logger);
    await _pumpUntilFound(tester, find.text('hello wall'));

    await tester.tap(find.text('hello wall'));
    await tester.pump();

    expect(logger.clicks, hasLength(1));
    expect(logger.clicks.single.userId, 7);
    expect(logger.clicks.single.buttonId, ButtonIds.bedroomWall);
  });

  testWidgets('logs a back click with a unique id', (tester) async {
    final logger = MockButtonClickLogger();
    await pumpPage(tester, logger);
    await _pumpUntilFound(tester, find.byTooltip('Back'));

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();

    expect(logger.clicks, hasLength(1));
    expect(logger.clicks.single.userId, 7);
    expect(logger.clicks.single.buttonId, ButtonIds.bedroomWallBack);
  });
}
