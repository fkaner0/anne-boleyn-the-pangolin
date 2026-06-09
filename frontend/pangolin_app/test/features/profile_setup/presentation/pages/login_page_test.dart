import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/config/env.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/profile_setup/data/user_creator.dart';
import 'package:pangolin_app/features/profile_setup/presentation/pages/login_page.dart';

class _FakeUserCreator implements UserCreator {
  final int id;
  final bool fail;
  final Completer<void>? gate;
  String? lastUsername;
  int callCount = 0;

  _FakeUserCreator({this.id = 42, this.fail = false, this.gate});

  @override
  Future<int> createUser(String username) async {
    callCount++;
    lastUsername = username;
    if (gate != null) await gate!.future;
    if (fail) throw Exception('username taken');
    return id;
  }
}

void main() {
  setUp(() async {
    await getIt.reset();
    configureDependencies(BackendMode.mock);
  });

  Future<void> pumpPage(WidgetTester tester, UserCreator creator) {
    return tester.pumpWidget(
      MaterialApp(home: LoginPage(userCreator: creator)),
    );
  }

  FilledButton continueButton(WidgetTester tester) =>
      tester.widget<FilledButton>(find.byType(FilledButton));

  testWidgets('continue is disabled until a username is entered', (
    tester,
  ) async {
    await pumpPage(tester, _FakeUserCreator());

    expect(continueButton(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'anne');
    await tester.pump();

    expect(continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('submitting a username creates the user and enters signup', (
    tester,
  ) async {
    final creator = _FakeUserCreator(id: 7);
    await pumpPage(tester, creator);

    await tester.enterText(find.byType(TextField), '  anne  ');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(creator.callCount, 1);
    expect(creator.lastUsername, 'anne');
    expect(find.text('About your craft'), findsOneWidget);
  });

  testWidgets('shows a spinner while creating', (tester) async {
    final gate = Completer<void>();
    await pumpPage(tester, _FakeUserCreator(gate: gate));

    await tester.enterText(find.byType(TextField), 'anne');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    gate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('a taken username shows a message and stays on the page', (
    tester,
  ) async {
    await pumpPage(tester, _FakeUserCreator(fail: true));

    await tester.enterText(find.byType(TextField), 'anne');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.textContaining('coming soon'), findsOneWidget);
    expect(find.text('Welcome to PangoPal'), findsOneWidget);
  });
}
