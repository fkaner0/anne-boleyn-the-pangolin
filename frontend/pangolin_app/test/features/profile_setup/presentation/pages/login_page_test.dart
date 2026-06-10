import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pangolin_app/features/auth/auth_provider.dart';
import 'package:pangolin_app/features/auth/data/authoriser.dart';
import 'package:pangolin_app/features/profile_setup/presentation/pages/login_page.dart';
import 'package:pangolin_app/router/app_router.dart';

class _FakeAuthoriser implements Authoriser {
  final int newId;
  final int existingId;
  final bool failNew;
  final bool failExisting;
  final Completer<void>? gate;

  String? lastNewUsername;
  String? lastExistingUsername;

  _FakeAuthoriser({
    this.newId = 7,
    this.existingId = 3,
    this.failNew = false,
    this.failExisting = false,
    this.gate,
  });

  @override
  Future<int> getNewUserId(String username) async {
    lastNewUsername = username;
    if (gate != null) await gate!.future;
    if (failNew) throw Exception('username taken');
    return newId;
  }

  @override
  Future<int> getExistingUserId(String username) async {
    lastExistingUsername = username;
    if (gate != null) await gate!.future;
    if (failExisting) throw Exception('no such user');
    return existingId;
  }
}

Widget _userIdProbe(String prefix) => Consumer(
  builder: (context, ref, _) => Text('$prefix ${ref.watch(userIdProvider)}'),
);

Future<void> pumpLogin(WidgetTester tester, Authoriser authoriser) {
  final router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => LoginPage(authoriser: authoriser),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (_, _) => _userIdProbe('SIGNUP'),
      ),
      GoRoute(
        path: AppRoutes.recommendations,
        builder: (_, _) => _userIdProbe('RECS'),
      ),
    ],
  );

  return tester.pumpWidget(
    ProviderScope(child: MaterialApp.router(routerConfig: router)),
  );
}

FilledButton _button(WidgetTester tester, String label) =>
    tester.widget<FilledButton>(find.widgetWithText(FilledButton, label));

void main() {
  testWidgets('buttons are disabled until a username is entered', (
    tester,
  ) async {
    await pumpLogin(tester, _FakeAuthoriser());

    expect(_button(tester, 'Login').onPressed, isNull);
    expect(_button(tester, 'Sign up').onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'anne');
    await tester.pump();

    expect(_button(tester, 'Login').onPressed, isNotNull);
    expect(_button(tester, 'Sign up').onPressed, isNotNull);
  });

  testWidgets('signing up creates the user, stores the id and enters setup', (
    tester,
  ) async {
    final authoriser = _FakeAuthoriser(newId: 7);
    await pumpLogin(tester, authoriser);

    await tester.enterText(find.byType(TextField), '  anne  ');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign up'));
    await tester.pumpAndSettle();

    expect(authoriser.lastNewUsername, 'anne');
    expect(find.text('SIGNUP 7'), findsOneWidget);
  });

  testWidgets('logging in stores the id and goes to recommendations', (
    tester,
  ) async {
    final authoriser = _FakeAuthoriser(existingId: 3);
    await pumpLogin(tester, authoriser);

    await tester.enterText(find.byType(TextField), 'anne');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pumpAndSettle();

    expect(authoriser.lastExistingUsername, 'anne');
    expect(find.text('RECS 3'), findsOneWidget);
  });

  testWidgets('a taken username keeps you on login with a message', (
    tester,
  ) async {
    await pumpLogin(tester, _FakeAuthoriser(failNew: true));

    await tester.enterText(find.byType(TextField), 'anne');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign up'));
    await tester.pumpAndSettle();

    expect(find.textContaining('username is taken'), findsOneWidget);
    expect(find.text('Welcome to PangoPal'), findsOneWidget);
  });

  testWidgets('an unknown username keeps you on login with a message', (
    tester,
  ) async {
    await pumpLogin(tester, _FakeAuthoriser(failExisting: true));

    await tester.enterText(find.byType(TextField), 'anne');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.textContaining("don't have anyone"), findsOneWidget);
    expect(find.text('Welcome to PangoPal'), findsOneWidget);
  });

  testWidgets('shows a spinner while submitting', (tester) async {
    final gate = Completer<void>();
    await pumpLogin(tester, _FakeAuthoriser(gate: gate));

    await tester.enterText(find.byType(TextField), 'anne');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign up'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);

    gate.complete();
    await tester.pumpAndSettle();
  });
}
