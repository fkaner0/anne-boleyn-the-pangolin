import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/widgets/island_nav_bar.dart';

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

  testWidgets('shows the label only for the current tab', (tester) async {
    await pumpBar(
      tester,
      current: IslandNavTab.recommendations,
      onEditProfile: () {},
      onRecommendations: () {},
    );

    expect(find.text('Recommendations'), findsOneWidget);
    expect(find.text('Profile'), findsNothing);
    expect(find.text('Friends'), findsNothing);
  });

  testWidgets('tapping another tab invokes its callback', (tester) async {
    var recommendationsTapped = false;
    await pumpBar(
      tester,
      current: IslandNavTab.editProfile,
      onEditProfile: () {},
      onRecommendations: () => recommendationsTapped = true,
    );

    await tester.tap(find.byIcon(Icons.style_outlined));
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

    await tester.tap(find.byIcon(Icons.person_outline));
    expect(editProfileTapped, isFalse);
  });

  testWidgets('friends is inert when no callback is provided', (tester) async {
    await pumpBar(
      tester,
      current: IslandNavTab.editProfile,
      onEditProfile: () {},
      onRecommendations: () {},
    );

    await tester.tap(find.byIcon(Icons.group_outlined));
    expect(tester.takeException(), isNull);
  });
}
