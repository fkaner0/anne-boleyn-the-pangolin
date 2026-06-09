import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/features/logging/button_ids.dart';
import 'package:pangolin_app/features/logging/data/mock_button_click_logger.dart';
import 'package:pangolin_app/features/recommendation/domain/position.dart';
import 'package:pangolin_app/features/recommendation/domain/profile.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_text.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/bedroom_wall_detail_page.dart';

import '../../../../support/auth_test_support.dart';

void main() {
  const profile = Profile(
    userId: 5,
    name: 'Bob',
    location: 'NYC',
    images: [],
    textboxes: [],
  );

  const textbox = ProfileText(
    title: '',
    body: 'hello wall',
    position: Position(x: 200, y: 490, rotation: 0),
  );

  testWidgets('logs a back click with a unique id', (tester) async {
    final logger = MockButtonClickLogger();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [loggedInUserId(7)],
        child: MaterialApp(
          home: BedroomWallDetailPage(
            profile: profile,
            textbox: textbox,
            logger: logger,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();

    expect(logger.clicks, hasLength(1));
    expect(logger.clicks.single.userId, 7);
    expect(logger.clicks.single.buttonId, ButtonIds.wallDetailBack);
  });
}
