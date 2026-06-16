import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pangolin_app/features/wall_creation/presentation/widgets/example_boards_dialog.dart';

void main() {
  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ExampleBoardsDialog.show(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders one dot per example board', (tester) async {
    await openDialog(tester);

    expect(
      find.byType(AnimatedContainer),
      findsNWidgets(ExampleBoardsDialog.imagePaths.length),
    );
  });

  testWidgets('hides the back arrow on the first board and shows it after '
      'advancing', (tester) async {
    await openDialog(tester);

    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
  });

  testWidgets('hides the forward arrow on the last board', (tester) async {
    await openDialog(tester);

    for (var i = 0; i < ExampleBoardsDialog.imagePaths.length - 1; i++) {
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
    }

    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('OK closes the dialog', (tester) async {
    await openDialog(tester);
    expect(find.byType(ExampleBoardsDialog), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'OK'));
    await tester.pumpAndSettle();

    expect(find.byType(ExampleBoardsDialog), findsNothing);
  });
}
