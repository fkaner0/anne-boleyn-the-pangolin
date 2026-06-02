import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/config/env.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/wall_creation/presentation/pages/bedroom_wall_creator_page.dart';

void main() {
  setUp(() async {
    // Start from a clean container each test, then resolve the recommendation
    // dependencies the "Next" navigation pulls from.
    await getIt.reset();
    configureDependencies(BackendMode.mock);
  });

  Future<void> pumpPage(WidgetTester tester) {
    return tester.pumpWidget(
      const MaterialApp(home: BedroomWallCreatorPage()),
    );
  }

  testWidgets('shows the top bar with Back and Next', (tester) async {
    await pumpPage(tester);

    expect(find.text('Create your wall'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Next'), findsOneWidget);
  });

  testWidgets('shows the three creation tools', (tester) async {
    await pumpPage(tester);

    expect(find.text('Text box'), findsOneWidget);
    expect(find.text('Image'), findsOneWidget);
    expect(find.text('Sticker'), findsOneWidget);
  });

  testWidgets('the creation tools are pressable but do nothing', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Text box'));
    await tester.tap(find.text('Image'));
    await tester.tap(find.text('Sticker'));
    await tester.pump();

    // Still on the creator page; nothing navigated or threw.
    expect(find.text('Create your wall'), findsOneWidget);
  });

  testWidgets('Next opens the recommendations page', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Your recommendations'), findsOneWidget);
  });

  testWidgets('Back on recommendations returns to the creator', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.text('Your recommendations'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Create your wall'), findsOneWidget);
  });
}
