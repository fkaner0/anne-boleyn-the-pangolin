import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/widgets/app_icon.dart';
import 'package:pangolin_app/widgets/island_nav_bar.dart';

Finder iconOfType(AppIconType type) =>
    find.byWidgetPredicate((w) => w is AppIcon && w.type == type);

void main() {
  Future<void> pumpBar(
    WidgetTester tester, {
    required IslandNavTab current,
    required VoidCallback onEditProfile,
    required VoidCallback onRecommendations,
    VoidCallback? onFriends,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: IslandNavBar(
            current: current,
            onEditProfile: onEditProfile,
            onRecommendations: onRecommendations,
            onFriends: onFriends,
          ),
        ),
      ),
    );
  }

  testWidgets('shows the filled icon for the current tab only', (tester) async {
    await pumpBar(
      tester,
      current: IslandNavTab.recommendations,
      onEditProfile: () {},
      onRecommendations: () {},
    );

    expect(iconOfType(AppIconType.findFilled), findsOneWidget);
    expect(iconOfType(AppIconType.meUnfilled), findsOneWidget);
    expect(iconOfType(AppIconType.palsUnfilled), findsOneWidget);
    expect(iconOfType(AppIconType.findUnfilled), findsNothing);
  });

  testWidgets('tapping another tab invokes its callback', (tester) async {
    var recommendationsTapped = false;
    await pumpBar(
      tester,
      current: IslandNavTab.editProfile,
      onEditProfile: () {},
      onRecommendations: () => recommendationsTapped = true,
    );

    await tester.tap(iconOfType(AppIconType.findUnfilled));
    expect(recommendationsTapped, isTrue);
  });

  testWidgets('tapping the current tab does nothing', (tester) async {
    var editProfileTapped = false;
    await pumpBar(
      tester,
      current: IslandNavTab.editProfile,
      onEditProfile: () => editProfileTapped = true,
      onRecommendations: () {},
    );

    await tester.tap(iconOfType(AppIconType.meFilled));
    expect(editProfileTapped, isFalse);
  });

  testWidgets('friends is inert when no callback is provided', (tester) async {
    await pumpBar(
      tester,
      current: IslandNavTab.editProfile,
      onEditProfile: () {},
      onRecommendations: () {},
    );

    await tester.tap(iconOfType(AppIconType.palsUnfilled));
    expect(tester.takeException(), isNull);
  });
}
