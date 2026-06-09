import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/features/wall_creation/presentation/widgets/prompt_generator.dart';
import 'package:pangolin_app/widgets/app_icon.dart';

final _refreshIcon = find.byWidgetPredicate(
  (w) => w is AppIcon && w.type == AppIconType.refresh,
);
final _lightbulbIcon = find.byWidgetPredicate(
  (w) => w is AppIcon && w.type == AppIconType.lightbulb,
);

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required void Function(String) onCreate,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PromptGenerator(onCreate: onCreate)),
      ),
    );
  }

  Offset slideOffset(WidgetTester tester) =>
      tester.widget<AnimatedSlide>(find.byType(AnimatedSlide)).offset;

  Future<void> useHint(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField), 'a hint');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
  }

  testWidgets('starts expanded showing a refresh icon, not a lightbulb', (
    tester,
  ) async {
    await pump(tester, onCreate: (_) {});

    expect(slideOffset(tester), Offset.zero);
    expect(_refreshIcon, findsOneWidget);
    expect(_lightbulbIcon, findsNothing);
  });

  testWidgets('shows the lightbulb once collapsed', (tester) async {
    await pump(tester, onCreate: (_) {});
    await useHint(tester);

    expect(_lightbulbIcon, findsOneWidget);
    expect(_refreshIcon, findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('stays expanded indefinitely before a hint is used', (
    tester,
  ) async {
    await pump(tester, onCreate: (_) {});

    await tester.pump(const Duration(seconds: 30));

    expect(slideOffset(tester), Offset.zero);
  });

  testWidgets('using a hint creates it then slides the bar off', (
    tester,
  ) async {
    final created = <String>[];
    await pump(tester, onCreate: created.add);

    await useHint(tester);

    expect(created, ['a hint']);
    expect(slideOffset(tester), isNot(Offset.zero));
    await tester.pumpAndSettle();
  });

  testWidgets('lightbulb slides the bar back on once collapsed', (
    tester,
  ) async {
    await pump(tester, onCreate: (_) {});
    await useHint(tester);
    expect(slideOffset(tester), isNot(Offset.zero));

    await tester.tap(_lightbulbIcon);
    await tester.pump();

    expect(slideOffset(tester), Offset.zero);

    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();
  });

  testWidgets('re-expanded bar auto-collapses after the timeout', (
    tester,
  ) async {
    await pump(tester, onCreate: (_) {});
    await useHint(tester);

    await tester.tap(_lightbulbIcon);
    await tester.pump();
    expect(slideOffset(tester), Offset.zero);

    await tester.pump(const Duration(seconds: 7));
    await tester.pump();

    expect(slideOffset(tester), isNot(Offset.zero));
    await tester.pumpAndSettle();
  });
}
